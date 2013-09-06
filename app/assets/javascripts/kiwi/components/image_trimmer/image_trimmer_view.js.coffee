FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  class this.ImageTrimmerView extends Marionette.ItemView
    template: FK.Template('image_trimmer')
  
    events:
      'mousedown .slider': 'startSliding'
      'mousedown .image-container': 'startMoving'
      'click .close-box': 'close'
      'click .cancel-button': 'close'
  
    ui:
      'image': 'img'
      'container': '.image-container'
      'slider': '.slider'
      'track': '.slider-track'
  
    startSliding: (e) =>
      e.preventDefault()
      $('body').css('cursor', 'pointer')
      @disableTextSelect()
      @sliding = true
      @saveImageCoords()
  
    startMoving: (e) =>
      e.preventDefault()
      $('body').css('cursor', 'move')
      @movingImage = true
      @disableTextSelect()
      @mouseStartOffset =
        left: e.pageX
        top: e.pageY
      @saveImageCoords()
  
    slide: (e) =>
      return if ! @sliding
      e.preventDefault()
  
      newPosition = e.pageX - @ui.track.offset().left - @ui.slider.width() / 2
      return if @imageOutOfBounds(@adjustedWidth(@sliderFactor(newPosition)), parseInt(@ui.image.css('left')), parseInt(@ui.image.css('top')))
      @ui.slider.css 'left', newPosition if newPosition > 0 and newPosition < @ui.track.width() - @ui.slider.width()
      @sizeImage()
      @refocusImage()
  
    stopSliding: (e) =>
      e.preventDefault()
      @sliding = false
      @enableTextSelect()
  
    moveImage: (e) =>
      return if ! @movingImage
      e.preventDefault()
      left = @imageStartOffset.left + e.pageX - @mouseStartOffset.left
      top = @imageStartOffset.top + e.pageY - @mouseStartOffset.top
      @positionImage left, top
  
    stopMovingImage: (e) =>
      e.preventDefault()
      $('body').css('cursor', 'default')
      @movingImage = false
  
    startImage: =>
      @image =
        height: @ui.image.height()
        width:  @ui.image.width()
        wToH: @ui.image.height() / @ui.image.width()
        minWidth: @ui.container.height() / @ui.image.height() * @ui.image.width()
     
      @sizeImage()
      @centerImage()
  
    saveImageCoords: =>
      @imageStartOffset =
        left: parseInt(@ui.image.css 'left')
        top: parseInt(@ui.image.css 'top')
  
      @imageStartSize =
        width: @ui.image.width()
        height: @ui.image.height()
   
    sizeImage: (factor = 0) =>
      factor = @domSliderFactor() if (factor == 0)
      @ui.image.width(@adjustedWidth(factor))
  
    sliderFactor: (position) =>
      (position + @ui.slider.width() / 2) / @ui.track.width()
  
    domSliderFactor: =>
      @sliderFactor(parseInt(@ui.slider.css('left')))
  
    adjustedWidth: (factor) =>
      @image.minWidth + (@image.width - @image.minWidth) * factor
  
    imageOutOfBounds: (width, x, y) =>
      height = width * @image.wToH
      x > 0 || y > 0 || x + width < @ui.container.width() || y + height < @ui.container.height()
  
    centerImage: =>
      overflowedRight = @ui.image.width() - @ui.container.width()
      overflowedBottom = @ui.image.height() - @ui.container.height()
      @positionImage -overflowedRight / 2 , -overflowedBottom / 2
  
    refocusImage: =>
      newLeft = @imageStartOffset.left + (@imageStartSize.width - @ui.image.width()) / 2
      newTop = @imageStartOffset.top + (@imageStartSize.height - @ui.image.height()) / 2
     
      @positionImage newLeft, newTop
  
    positionImage: (x, y) =>
      return if @imageOutOfBounds(@ui.image.width(), x, y)
      @ui.image.css 'left', x
      @ui.image.css 'top', y
  
    disableTextSelect: =>
      window.getSelection().empty()
      $('body').on('selectstart', () => false)
  
    enableTextSelect: =>
      $('body').off('selectstart')

    setSource: (src) =>
      $('img').attr('src', src)
  
    onRender: =>
      $('body').on 'mousemove', @slide
      $('body').on 'mousemove', @moveImage
      $('body').on 'mouseup', @stopSliding
      $('body').on 'mouseup', @stopMovingImage
      _.delay @startImage, 200
  
    onClose: =>
      $('body').off 'mousemove', @slide
      $('body').off 'mousemove', @moveImage
      $('body').off 'mouseup', @stopSliding
      $('body').off 'mouseup', @stopMovingImage
  
