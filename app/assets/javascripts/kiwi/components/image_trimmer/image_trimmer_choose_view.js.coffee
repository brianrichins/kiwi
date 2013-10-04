FK.App.module 'ImageTrimmer', (ImageTrimmer, App, Backbone, Marionette, $, _) ->
  
  class this.ImageChooseView extends Marionette.ItemView
    template: FK.Template('image_trimmer_choose')
    className: 'image-trimmer-input-container'

    events:
      'click button': 'clickFileUploader'
      'change input[type="file"]': 'startImageTrimmerFromUpload'
      'blur .url-input': 'loadFileInInput'

    clickFileUploader: (e) =>
      e.preventDefault()
      @$('input[type="file"]').click()

    startImageTrimmerFromUpload: (evt) =>
      file = evt.target.files[0]
      reader = new FileReader()

      reader.onload = (readFile) =>
        @controller.trigger 'new:image', readFile.target.result, 'upload', file

      reader.readAsDataURL(file)

    loadFileInInput: (e) =>
      @controller.trigger 'new:image', @$('input.url-input').val(), 'remote'

    initialize: (options) ->
      @controller = options.controller
      @listenTo @controller, 'new:image:ready', @clearIfSourceNotUrl

    clearIfSourceNotUrl: (url, source) =>
      @$('input.url-input').val('') if source != 'remote'
