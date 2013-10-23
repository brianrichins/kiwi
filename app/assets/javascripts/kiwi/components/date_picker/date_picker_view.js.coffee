FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  class DatePicker.DatePickerView extends Marionette.ItemView
    template: FK.Template 'date_picker'
    events:
      'change input,select': 'pickerChanged'

    modelEvents:
      'change:datetime':   'updateStatus'
      'change:is_all_day': 'updateTimeStatus'

    pickerChanged: (e) =>
      @updateModel()

    updateModel: =>
      is_all_day = @$('input[name=is_all_day]:checked').val() is '1'
      date = @$('input[name=date]').val()
      time = "#{@$('select[name=hours]').val()}:#{@$('select[name=minutes]').val()} #{@$('select[name=ampm]').val()}"
      val = moment("#{date} #{time}")
      @model.set('datetime', val.utc())
      @model.set('is_all_day', is_all_day)

    initialize: (opts) ->
      @controller = opts.controller

    onRender: () ->
      @$('input[name=date]').datepicker()

    updateTimeStatus: =>
      selector = @$('input[name=time_format],select[name=hours],select[name=minutes],select[name=ampm],select[name=time_type]')
      if @model.get('is_all_day')
        selector.attr('disabled','disabled')
      else
        selector.removeAttr('disabled')

    updateStatus: =>
      @$('.status').text(moment(@model.get('datetime'))._d.toString())
