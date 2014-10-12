FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.TopRanked extends Marionette.CompositeView
    template: FK.Template('front_page/sidebar/top_ranked')
    className: 'top-ranked'
    itemView: EventList.EventName
    itemViewContainer: 'ul'
