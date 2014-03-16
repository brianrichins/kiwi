window.FK = {
  Data:{}
  Views:{}
  Models:{}
  Collections:{}
  Configs: {}
  Controllers: {}
  Routers: {}
  Utils: {}
}

FK.Template = (file) ->
  JST["kiwi/templates/#{file}"]

FK.Uri = (uri) ->
  Backbone.history.fragment is uri

FK.Data.subkastOptions = {
      'TVM': 'TV and Movies'
      'SE': 'Sports and Entertainment'
      'ST': 'Science and Technology'
      'PRP': 'Product Releases / Promotions'
      'HA': 'Holidays and Anniversaries'
      'OTH': 'Other'
    }

FK.App = new Backbone.Marionette.Application()
FK.App.addRegions({
  navbarRegion: '#navbar-container-region'
  mainRegion: '#main-region'
})

FK.App.addInitializer (prefetch) ->
  FK.Links = prefetch.links
  FK.CurrentUser = new FK.Models.User(prefetch.user)

  if prefetch.user != null
    FK.CurrentUser.set(logged_in: true, silent: true)

  FK.Data.countries = new FK.Collections.CountryList(prefetch.countries)

  FK.Data.EventStore = new FK.EventStore events: prefetch.events, howManyStartingBlocks: 10, vent: FK.App.vent
  FK.Data.EventStore.fetchStartupEvents()

  FK.Data.UserMediator = new FK.UserMediator user: FK.CurrentUser, vent: FK.App.vent
  FK.Data.UserMediator.getUserLocation() if not FK.CurrentUser.get('country') and FK.CurrentUser.get('logged_in')

  if FK.CurrentUser.get('country')
    FK.App.vent.trigger 'filter:country', FK.CurrentUser.get('country')

  if FK.CurrentUser.get('subkasts')
    FK.App.vent.trigger 'filter:subkasts', FK.CurrentUser.get('subkasts')

  FK.App.appRouter = new FK.Routers.AppRouter()


FK.Controllers.MainController = {
  events: (action) ->
    FK.App.vent.trigger('container:' + action)

  show: (id) ->
    event = new FK.Models.Event
      _id: id
    event.fetch().done =>
      FK.App.vent.trigger('container:show', event)

  edit: (id) ->
    event = new FK.Models.Event
      _id: id
    event.fetch().done =>
      FK.App.vent.trigger('container:new', event)

  default: ->
    Backbone.history.navigate('events/all', trigger: true)
}

FK.App.reqres.setHandler 'events', () ->
  FK.Data.EventStore.events

FK.App.reqres.setHandler 'eventStore', () ->
  FK.Data.EventStore

FK.App.reqres.setHandler 'currentUser', () ->
  FK.CurrentUser

FK.App.reqres.setHandler 'subkastOptionsAsArray', () ->
  _.map(FK.Data.subkastOptions, (val, key) -> { value: key, option: val })

FK.App.reqres.setHandler 'countryName', (countryCode) ->
  FK.Data.countries.get(countryCode).get('en_name').trim()

class FK.Routers.AppRouter extends Backbone.Marionette.AppRouter
  controller: FK.Controllers.MainController
  appRoutes: {
    '':               'default'
    '_=_':            'default' # facebook callback route
    'events/show/:id':    'show'
    'events/edit/:id':  'edit'
    'events/:action': 'events'
  }

moment.lang('en', {
    calendar : {
        lastDay : '[Yesterday at] LT',
        sameDay : '[Today at] LT',
        nextDay : '[Tomorrow at] LT',
        lastWeek : '[last] dddd [at] LT',
        nextWeek : 'dddd [at] LT',
        sameElse : 'dddd, MMMM D '
    }
})

class FK.Utils.RenderHelpers
  @populate_checkboxes_from_array: (view, container, arr, klass) ->
    view.$el.find(container).html(_.map(arr,(item) =>
      "<div class=\"checkbox #{klass}\">
        <label class=\"#{klass}\">
          <input type=\"checkbox\" name=\"#{item.value}\" />
         #{item.option}
        </label>
      </div>").join(''))

  @populate_select_getter: (view, property, collection, label) ->
    view.$el.find("select[name=#{property}]").html(collection.map((item) =>
      selected = (if (view.model && view.model.get(property) is item.get('_id')) then " selected=\"selected\" " else "")
      "<option value=\"#{item.get('_id')}\" #{selected} >#{item.get(label)}</option>").join(''))
