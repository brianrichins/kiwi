class FK.Models.Event extends Backbone.Model


class FK.Models.EventBlock extends Backbone.Model


class FK.Collections.EventList extends Backbone.Collection
  model: FK.Models.Event

  topRanked: =>
    #TODO: fix me
    @first()

  mostDiscussed: =>
    #TODO: fix me
    @last()

  asBlocks: =>
    sorted = @sortBy((ev) -> ev.get('datetime').$date).reverse()
    new FK.Collections.EventBlockList(_.map(_.groupBy(sorted,(ev) -> 
      moment(ev.get('datetime').$date).format("YYYY-MM-DD")
    ), (blocks, date) ->
      events: new FK.Collections.EventList(blocks), date: date
    ))


class FK.Collections.EventBlockList extends Backbone.Collection
  model: FK.Models.EventBlock