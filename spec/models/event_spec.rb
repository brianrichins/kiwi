require 'spec_helper'
require 'date'

describe Event do
  before (:each) do
    Timecop.freeze(Time.local(2014, 1, 24, 12, 00, 00))
  end

  after (:each) do
    Timecop.return
  end

  it "should work" do 
    e = Event.new name: "foobar"
    e.save!
    Event.all.size.should == 1
  end

  describe "Event fetching" do
    describe "by date" do
      before(:each) do
        create_list :event, 3, :in_1_week
        create_list :event, 2, :back_1_week
        @testTime = 1.week.from_now - 5.minutes
      end

      it "should be able to fetch events by date" do
        Event.get_events_by_date(@testTime).size.should == 3
      end

      it "should be able to limit the number of events fetched by date" do
        Array(Event.get_events_by_date(@testTime, 2)).size.should == 2
      end

      it "should be able to skip a given number of events fetched by date" do
        Array(Event.get_events_by_date(@testTime, 0, 1)).size.should == 2
      end

      it "should be able to skip a given number of events and still limit correctly" do
        Array(Event.get_events_by_date(@testTime, 1, 1)).size.should == 1
      end

      describe "all day events" do
        before(:each) do
          create_list :event, 3, :in_2_weeks, :all_day
          @testTime = 2.weeks.from_now + 2.hours
        end

        it "should be able to get an all day event when its stored datetime falls outside the range requested" do
          Array(Event.get_events_by_date(@testTime)).size.should == 3
        end
      end
    end

    describe "by top ranked" do
      before(:each) do
        create_list :event, 2
        create :event, :with_2_upvotes, :back_1_week
        create :event, :with_5_upvotes, :in_1_week

        @topRanked = Array(Event.top_ranked(4, DateTime.now(), 1.week.from_now))
      end
      it "should be able to get an arbitrary number of the top ranked events" do
        @topRanked.size.should == 3
      end

      it "should be able to get the highest number of upvotes first" do
        @topRanked[0].upvote_names.size.should == 5
        @topRanked[1].upvote_names.size.should == 0
      end
    end

    describe "starting package" do
      before(:each) do
        create_list :event, 3, :with_2_upvotes, :in_1_week
        create_list :event, 3, :with_5_upvotes, :in_1_week
        create_list :event, 3, :with_5_upvotes, :in_2_weeks

        create :event, :with_5_upvotes, :in_1_week
        create :event, :with_5_upvotes, :back_1_week
        create :event, :with_7_upvotes, :in_1_week
      end
      it "should be able to get a total total number of events across days" do
        events = Event.get_enough_events_from_day(DateTime.now(), 5, 3)
        Array(events).size.should == 6
      end

      it "should be able to find the date of the latest event" do
        date = Event.get_last_date()
        date.should === 2.week.from_now.to_date
      end

      it "should be able to get the first 6 events and top 5 without overlap" do
        events = Event.get_starting_events(DateTime.now(), 6, 3, 7)
        events.size.should == 10
      end
    end

    describe "should be able to get events after a certain date" do
      before(:each) do
        create_list :event, 3, :in_1_week
        create :event, :back_1_week
      end

      it "should be able to get events after a certain date" do
        events = Event.get_events_after_date(3.days.from_now)
        events.size.should == 3
      end

      it "should be able to limit the number of events found after a certain date" do
        events = Event.get_events_after_date(3.days.from_now, 2)
        Array(events).size.should == 2
      end
    end
  end

  describe "event counting" do
    before(:each) do
      create_list :event, 3, :in_1_week
      create :event, :back_1_week
      create :event, :in_2_weeks
    end

    it "should be able to count events on a day" do
      Event.count_events_by_date(1.week.from_now - 1.minute).should == 3
    end
  end
end
