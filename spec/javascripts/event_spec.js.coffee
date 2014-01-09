# use require to load any .js file available to the asset pipeline
#= require application

describe "Event", ->
  loadFixtures 'event_fixture' # located at 'spec/javascripts/fixtures/event_fixture.html.erb'
  it "Default country to be US", ->
    v = new FK.Models.Event()
    expect(v.get('country')).toEqual('US')

  it "can get time in eastern", =>
    datetime = moment("2013-12-12, 16:00 GMT+200")
    v = new FK.Models.Event datetime: datetime
    expect(v.get('creation_timezone')).toEqual("GMT+100")
    expect(v.time_in_eastern()).toEqual('10:00')

  it "can detect TV times", =>
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 16:00 GMT+200")
    expect(v.time_in_eastern()).toEqual('10:00')
    expect(v.get('time')).toEqual('4/3c')
    
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 1:00 GMT+200")
    expect(v.get('time')).toEqual('1/12c')
    
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 20:00 GMT+200")
    expect(v.get('time')).toEqual('8/7c')

  describe "when upvoting", ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set 'upvote_allowed', true
      @xhr = sinon.useFakeXMLHttpRequest()

    afterEach ->
      @xhr.restore()

    it "should be able to increase its upvotes", ->
      @event.upvoteToggle()
      expect(@event.upvotes()).toBe(1)

    it "should be able to toggle its upvotes", ->
      @event.upvoteToggle()
      @event.upvoteToggle()
      expect(@event.upvotes()).toBe(0)

  describe "when getting the pieces of the local time", ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set('local_time', '7:40 PM')

    it "should be able to get the local hour", ->
      expect(@event.get('local_hour')).toBe('7')

    it "should be able to get the local minutes", ->
      expect(@event.get('local_minute')).toBe('40')

    it "should be able to get the local ampm", ->
      expect(@event.get('local_ampm')).toBe('PM')

    describe "when getting the pieces of a 24hr clock local time", ->
      beforeEach ->
        @event.set('local_time', '19:25 AM')

      it "should be able to get the local hour", ->
        expect(@event.get('local_hour')).toBe('7')

      it "should be able to get the local ampm", ->
        expect(@event.get('local_ampm')).toBe('AM')


  describe "when adding an image", ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set 'url', 'http://googlimage.ca'
      @event.set 'crop_x', 24
      @event.set 'crop_y', 25
      @event.set 'width', 200
      @event.set 'height', 300
      @event.set 'image', 'FILE'

    it "should be able to clear all image properties", ->
      @event.clearImage()
      expect(@event.get('url')).not.toBeDefined()
      expect(@event.get('crop_x')).not.toBeDefined()
      expect(@event.get('crop_y')).not.toBeDefined()
      expect(@event.get('width')).not.toBeDefined()
      expect(@event.get('height')).not.toBeDefined()
      expect(@event.get('image')).not.toBeDefined()

  describe 'when working with reminders', ->
    beforeEach ->
      @event = new FK.Models.Event()
      @event.set '_id', '1234asdf'
      @event.set 'current_user', 'grayden'
      @event.addReminder('15m')
    
    it 'should be able to add a reminder', ->
      expect(@event.reminders.length).toBe(1)

    it 'should return the reminder created with the event id on it', ->
      reminder = @event.addReminder('15m')
      expect(reminder.get('user')).toBe('grayden')
      expect(reminder.get('time_to_event')).toBe('15m')
      expect(reminder.get('event')).toBe(@event.id)

    it 'should be able to get a list of the reminder times in the event', ->
      @event.addReminder('1h')
      @event.addReminder('24h')

      expect(@event.reminderTimes()).toEqual(['15m', '1h', '24h'])

    it 'should be able to remove a reminder', ->
      @event.removeReminder '15m'
      expect(@event.reminderTimes().length).toBe(0)

  describe 'authorization', ->
    beforeEach ->
      @event = new FK.Models.Event()

    it 'should be able to authenticate user when the event has no user', ->
      expect(@event.editAllowed('grayden')).toBeTruthy()

    it 'should be able to authenticate user when the event user matches the input user', ->
      @event.set 'user', 'grayden'
      expect(@event.editAllowed('grayden')).toBeTruthy()

    it 'should be able to reject authentication when the event user does not match the input user', ->
      @event.set 'user', 'gsmith'
      expect(@event.editAllowed('grayden')).toBeFalsy()

    it 'should be able to authenticate user based on the current user property set on the event', ->
      @event.set 'user', 'grayden'
      @event.set 'current_user', 'grayden'
      expect(@event.editAllowed()).toBeTruthy()

    it 'should use the explicit argument to override the current user property', ->
      @event.set 'user', 'grayden'
      @event.set 'current_user', 'grayden'
      expect(@event.editAllowed('gsmith')).toBeFalsy()

  describe 'top ranked', ->
    beforeEach ->
      @events = new FK.Collections.EventList [
        { name: 'event 1', upvotes: 9 }
        { name: 'event 2', upvotes: 8 }
        { name: 'event 3', upvotes: 7 }
        { name: 'event 4', upvotes: 1 }
        { name: 'event 5', upvotes: 11 }
        { name: 'event 6', upvotes: 11, datetime: moment().add('days', 4) }
      ]

      @topEvents = @events.topRanked(3)

    it 'should be able to find an arbitary number of the top ranked events', ->
      expect(@topEvents.length).toBe(3)

    it 'should be finding events that are top ranked', ->
      expect(@topEvents[0].upvotes()).toBe(11)
      expect(@topEvents[1].upvotes()).toBe(11)
      expect(@topEvents[2].upvotes()).toBe(9)

    it 'should be finding events ordered by date after ranking', ->
      expect(@topEvents[0].get('name')).toBe('event 5')
      expect(@topEvents[1].get('name')).toBe('event 6')

    describe 'proxy to ranked events', ->
      beforeEach ->
        @proxy = @events.topRankedProxy(3)

      it 'should be able to make a proxy collection with the top events', ->
        expect(@proxy.at(0).upvotes()).toBe(11)

      it 'should be able to update the proxy collection on upvote change', ->
        @events.topRanked(1)[0].set('upvotes', 1)
        expect(@proxy.first().upvotes()).toBe(11)
        expect(@proxy.last().upvotes()).toBe(8)

      it 'should be able to update the proxy collection on event add', ->
        @events.add
          name: 'event 7', upvotes: 10
        expect(@proxy.first().upvotes()).toBe(11)
        expect(@proxy.last().upvotes()).toBe(10)

describe 'event list', ->
  describe 'fetching events', ->
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @requests = []
      @xhr.onCreate = (xhr) =>
        @requests.push xhr

      @events = new FK.Collections.EventList()

    afterEach ->
      @xhr.restore()

    it "should be able to fetch startup events", ->
      topRanked = 10
      eventsPerDay = 3
      eventsMinimum = 10
      @events.fetchStartupEvents(topRanked, eventsPerDay, eventsMinimum)
      expect(@requests.length).toBe(1)
      expect(@requests[0].url).toBe('api/events/startupEvents?howManyTopRanked=10&howManyEventsPerDay=3&howManyEventsMinimum=10')

    it "should be able to getch more events by a date", ->
      @events.reset([
        { _id: 1 }
        { _id: 2 }
      ])
      @events.fetchMoreEventsByDate(moment(), 10)
      expect(@requests.length).toBe(1)

      @requests[0].respond(200, { "Content-Type": "application/json"},
        JSON.stringify([
          { _id: 3}
        ])
      )

      expect(@events.length).toBe(3)

    describe "getting more events from the events list by date", ->
      beforeEach ->
       @events.reset([
          { _id: 1, datetime: moment()}
          { _id: 2, datetime: moment().add('minutes', 3) }
          { _id: 3, datetime: moment().add('minutes', 7) }
          { _id: 4, datetime: moment().add('days', 3) }
        ])

      it "should be able to get events by date from the event list through a deferred", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 3, 0)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(resolvedEvents.length).toBe(3)

      it "should be able to skip a given number of events", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 2, 1)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(resolvedEvents.length).toBe(2)

      it "should be able to return less than the number of events available", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 1, 0)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(resolvedEvents.length).toBe(1)

      it "should attempt a server call if the number of events are less than requested", ->
        resolvedEvents = []
        deferred = @events.getEventsByDate(moment(), 4, 0)
        deferred.done( (events) =>
          _.each(events, (event) =>
            resolvedEvents.push event
          )
        )

        expect(@requests.length).toBe(1)
        @requests[0].respond(200, { "Content-Type": "application/json" }, JSON.stringify({_id: 5, datetime: moment().add('minutes', 20)}))
        expect(resolvedEvents.length).toBe(4)
        expect(@events.length).toBe(5)

describe 'event block', ->
  it 'can detect if the date of the event block is today', ->
    @block = new FK.Models.EventBlock
      date: moment()

    expect(@block.isToday()).toBeTruthy()

  it 'can detect if the date of the event block is not today', ->
    @block = new FK.Models.EventBlock
      date: moment().days(-2)

    expect(@block.isToday()).toBeFalsy()

  it 'can detect if the date of the event block is today ignoring seconds', ->
    @block = new FK.Models.EventBlock
      date: moment().seconds(-2)

    expect(@block.isToday()).toBeTruthy()
