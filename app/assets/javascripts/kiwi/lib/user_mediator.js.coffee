class FK.UserMediator extends Marionette.Controller
  initialize: (options) =>
    @user = options.user
    @config = options.config

    @listenTo @config, 'change:country', @saveCountry

    @getUserLocation() if not FK.CurrentUser.get('country') and FK.CurrentUser.get('logged_in')

  getUserLocation: () =>
    # TODO: this is borked
    return;
    navigator.geolocation.getCurrentPosition(( position ) =>
      latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      geocoder = new google.maps.Geocoder()
      geocoder.geocode({ 'latLng': latLng }, (locations) =>
        countryObject = _.find(locations, (location) => _.contains(location.types, 'country') )
        @user.save('country', countryObject.address_components[0].short_name)
        @vent.trigger('filter:country', @user.get('country'))
      )
    )

  saveCountry: (model, country) =>
    @user.save({country: country})
