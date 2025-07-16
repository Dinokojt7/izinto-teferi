import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import "package:google_maps_webservice/geocoding.dart";
import 'package:google_maps_webservice/places.dart';
import 'package:izinto/live/utilities/colors.dart';
import 'package:izinto/live/view/checkout_view/view_widgets/generic_white_container.dart';
import 'package:izinto/live/widgets/buttons/blue_text_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../base/transitions.dart';
import '../../../utilities/generic_snackbar.dart';
import '../controller/address_dropdown_controller.dart';
import 'show_results_dialog.dart';
import '../../../widgets/text_widgets/heading_style_text.dart';
import '../../../../logger.dart';
import '../../../../services/map_location_picker.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/location/address_details_view.dart';
import '../../../../pages/options/autocomplete_view.dart';

class MapLocationPicker extends StatefulWidget {
  /// Padding around the map
  final EdgeInsets padding;

  /// Compass for the map (default: true)
  final bool compassEnabled;

  /// Lite mode for the map (default: false)
  final bool liteModeEnabled;

  /// API key for the map & places
  final String apiKey;

  /// GPS accuracy for the map
  final LocationAccuracy desiredAccuracy;

  /// GeoCoding base url
  final String? geoCodingBaseUrl;

  /// GeoCoding http client
  final Client? geoCodingHttpClient;

  /// GeoCoding api headers
  final Map<String, String>? geoCodingApiHeaders;

  /// GeoCoding location type
  final List<String> locationType;

  /// GeoCoding result type
  final List<String> resultType;

  /// Map minimum zoom level & maximum zoom level
  final MinMaxZoomPreference minMaxZoomPreference;

  /// Top card margin
  final EdgeInsetsGeometry topCardMargin;

  /// Top card color
  final Color? topCardColor;

  /// Top card shape
  final ShapeBorder topCardShape;

  /// Top card text field border radius
  final BorderRadius? borderRadius;

  /// Top card text field hint text
  final String searchHintText;

  /// Bottom card shape
  final ShapeBorder bottomCardShape;

  /// Bottom card margin
  final EdgeInsetsGeometry bottomCardMargin;

  /// Bottom card icon
  final Icon bottomCardIcon;

  /// Bottom card tooltip
  final String bottomCardTooltip;

  /// Bottom card color
  final Color? bottomCardColor;

  /// On Suggestion Selected callback
  final Function(PlacesDetailsResponse?)? onSuggestionSelected;

  /// On Next Page callback
  final Function(GeocodingResult?) onNext;

  /// Show back button (default: true)
  final bool showBackButton;

  /// Popup route on next press (default: false)
  final bool canPopOnNextButtonTaped;

  /// Back button replacement when [showBackButton] is false and [backButton] is not null
  final Widget? backButton;

  /// Show more suggestions
  final bool showMoreOptions;

  /// Dialog title
  final String dialogTitle;

  /// httpClient is used to make network requests.
  final Client? placesHttpClient;

  /// apiHeader is used to add headers to the request.
  final Map<String, String>? placesApiHeaders;

  /// baseUrl is used to build the url for the request.
  final String? placesBaseUrl;

  /// Session token for Google Places API
  final String? sessionToken;

  /// Offset for pagination of results
  /// offset: int,
  final num? offset;

  /// Origin location for calculating distance from results
  /// origin: Location(lat: -33.852, lng: 151.211),
  final Location? origin;

  /// currentLatLng init location for camera position
  /// currentLatLng: Location(lat: -33.852, lng: 151.211),
  final LatLng? currentLatLng;

  /// Location bounds for restricting results to a radius around a location
  /// location: Location(lat: -33.867, lng: 151.195)
  final Location? location;

  /// Radius for restricting results to a radius around a location
  /// radius: Radius in meters
  final num? radius;

  /// Language code for Places API results
  /// language: 'en',
  final String? language;

  /// Types for restricting results to a set of place types
  final List<String> types;

  /// Components set results to be restricted to a specific area
  /// components: [Component(Component.country, "us")]
  final List<Component> components;

  /// Bounds for restricting results to a set of bounds
  final bool strictbounds;

  /// Region for restricting results to a set of regions
  /// region: "us"
  final String? region;

  /// fields
  final List<String> fields;

  /// Hide Suggestions on keyboard hide
  final bool hideSuggestionsOnKeyboardHide;

  /// Map type (default: MapType.normal)
  final MapType mapType;

  /// Search text field controller
  final TextEditingController? searchController;

  /// Add your own custom markers
  final Map<String, LatLng>? additionalMarkers;

  const MapLocationPicker({
    Key? key,
    this.desiredAccuracy = LocationAccuracy.high,
    required this.apiKey,
    this.geoCodingBaseUrl,
    this.geoCodingHttpClient,
    this.geoCodingApiHeaders,
    this.language,
    this.locationType = const [],
    this.resultType = const [],
    this.minMaxZoomPreference = const MinMaxZoomPreference(10, 20),
    this.padding = const EdgeInsets.all(0),
    this.compassEnabled = true,
    this.liteModeEnabled = false,
    this.topCardMargin = const EdgeInsets.all(8),
    this.topCardColor,
    this.topCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.searchHintText = "Start typing to search",
    this.bottomCardShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.bottomCardMargin = const EdgeInsets.fromLTRB(8, 8, 8, 16),
    this.bottomCardIcon = const Icon(Icons.send),
    this.bottomCardTooltip = "Continue with this location",
    this.bottomCardColor,
    this.onSuggestionSelected,
    required this.onNext,
    this.currentLatLng = const LatLng(-26.056, 28.060),
    this.showBackButton = true,
    this.canPopOnNextButtonTaped = false,
    this.backButton,
    this.showMoreOptions = true,
    this.dialogTitle = 'You can also use the following options',
    this.placesHttpClient,
    this.placesApiHeaders,
    this.placesBaseUrl,
    this.sessionToken,
    this.offset,
    this.origin,
    this.location,
    this.radius,
    this.region,
    this.fields = const [],
    this.types = const [],
    this.components = const [],
    this.strictbounds = false,
    this.hideSuggestionsOnKeyboardHide = false,
    this.mapType = MapType.normal,
    this.searchController,
    this.additionalMarkers,
  }) : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  ///Create a location marker using the pin emoji
  Future<BitmapDescriptor> createEmojiMarker(String emoji) async {
    TextSpan span = TextSpan(
        style: TextStyle(
          fontSize: 50.0,
        ),
        text: emoji);

    TextPainter painter =
        TextPainter(textDirection: TextDirection.ltr, text: span);
    painter.layout();

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    painter.paint(canvas, Offset.zero);

    final img = await pictureRecorder.endRecording().toImage(100, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(pngBytes);
  }

  // Add marker to Google Map
  Future<void> addEmojiMarker(
      GoogleMapController mapController, LatLng position, String emoji) async {
    final emojiMarker = await createEmojiMarker(emoji);

    // mapController.addMarkers(
    //   Marker(
    //       markerId: MarkerId('emojiMarker'),
    //       position: position,
    //       icon: emojiMarker),
    // );
  }

  String autocompletePlace = '';
  var _searchResults = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Map controller for movement & zoom
  final Completer<GoogleMapController> _controller = Completer();

  /// initial latitude & longitude
  late LatLng _initialPosition = const LatLng(-26.056, 28.060);

  /// initial address text
  late String _address = "Tap on map to get address";

  /// Map type (default: MapType.normal)
  late MapType _mapType = MapType.normal;

  ///TextStyle for mapType itemBuilder
  late TextStyle _textStyle = TextStyle(color: LiveColors.cartBlue);

  /// initial zoom level
  late double _zoom = 19.0;

  /// GeoCoding result for further use
  GeocodingResult? _geocodingResult;

  /// GeoCoding results list for further use
  late List<GeocodingResult> _geocodingResultList = [];

  /// Camera position moved to location
  CameraPosition cameraPosition() {
    return CameraPosition(
      target: _initialPosition,
      zoom: _zoom,
    );
  }

  /// Search text field controller
  late TextEditingController _searchController = TextEditingController();

  /// Decode address from latitude & longitude
  void _decodeAddress(Location location, BuildContext context) async {
    final _addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);
    try {
      final geocoding = GoogleMapsGeocoding(
        apiKey: widget.apiKey,
        baseUrl: widget.geoCodingBaseUrl,
        apiHeaders: widget.geoCodingApiHeaders,
        httpClient: widget.geoCodingHttpClient,
      );
      final response = await geocoding.searchByLocation(
        location,
        language: widget.language,
        locationType: widget.locationType,
        resultType: widget.resultType,
      );

      /// When get any error from the API, show the error in the console.
      if (response.hasNoResults ||
          response.isDenied ||
          response.isInvalid ||
          response.isNotFound ||
          response.unknownError ||
          response.isOverQueryLimit) {
        logger.e(response.errorMessage);
        _address = response.status;
        if (mounted) {
          GenericSnackBar().showCustomSnackBar(
              null, context, 'Address not found, something went wrong!', true);
        }
        return;
      }
      _address = response.results.first.formattedAddress ?? "";
      _geocodingResult = response.results.first;

      ///Assign user current location to the controller
      _addressViewController.onAddressAutocomplete(
          _address, location.lat, location.lng);
      if (response.results.length > 1) {
        _geocodingResultList = response.results;
      }
      setState(() {});
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  void initState() {
    _initialPosition = widget.currentLatLng ?? _initialPosition;
    _mapType = widget.mapType;
    _searchController = widget.searchController ?? _searchController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final additionalMarkers = widget.additionalMarkers?.entries
            .map(
              (e) => Marker(
                markerId: MarkerId(e.key),
                position: e.value,
              ),
            )
            .toList() ??
        [];
    final emojiMarker = createEmojiMarker('\u{1F4CD}');
    final markers = Set<Marker>.from(additionalMarkers);

    markers.add(Marker(
      markerId: const MarkerId("two"),
      position: _initialPosition,
    ));

    return Consumer<MainAddressViewController>(
        builder: (context, addressViewController, child) {
      var hasMadeSelection = addressViewController.hasData;
      _initialPosition = addressViewController.initialPosition;
      return Scaffold(
        body: Column(
          children: [
            Container(
              height: 72.0,
              color: Colors.white,
              child: PlacesAutocomplete(
                hideOnEmpty: false,
                hideOnLoading: false,
                components: [Component(Component.country, "za")],
                mounted: mounted,
                apiKey: widget.apiKey,
                searchController: _searchController,
                borderRadius: widget.borderRadius,
                offset: widget.offset,
                radius: widget.radius,
                fields: widget.fields,
                hideSuggestionsOnKeyboardHide:
                    widget.hideSuggestionsOnKeyboardHide,
                language: widget.language,
                location: widget.location,
                origin: widget.origin,
                placesApiHeaders: widget.placesApiHeaders,
                placesBaseUrl: widget.placesBaseUrl,
                placesHttpClient: widget.placesHttpClient,
                region: widget.region,
                searchHintText: widget.searchHintText,
                sessionToken: widget.sessionToken,
                showBackButton: false,
                strictbounds: widget.strictbounds,
                topCardColor: widget.topCardColor,
                topCardMargin: widget.topCardMargin,
                topCardShape: widget.topCardShape,
                types: widget.types,
                onGetDetailsByPlaceId: (placesDetails) async {
                  if (placesDetails == null) {
                    logger.e("placesDetails is null");
                    return;
                  }
                  var resultsDetails =
                      placesDetails.result.formattedAddress ?? "";
                  final userLat = placesDetails.result.geometry?.location.lat;
                  final userLng = placesDetails.result.geometry?.location.lng;
                  addressViewController.onAddressAutocomplete(
                      resultsDetails, userLat, userLng);
                  _initialPosition = LatLng(
                    placesDetails.result.geometry?.location.lat ?? 0,
                    placesDetails.result.geometry?.location.lng ?? 0,
                  );
                  final controller = await _controller.future;
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition()));
                  _address = placesDetails.result.formattedAddress ?? "";
                  widget.onSuggestionSelected?.call(placesDetails);
                },
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  /// Google map view
                  GoogleMap(
                    minMaxZoomPreference: widget.minMaxZoomPreference,
                    onCameraMove: (CameraPosition position) {
                      /// set zoom level
                      _zoom = position.zoom;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: _zoom,
                    ),
                    onTap: (LatLng position) async {
                      _initialPosition = position;
                      final controller = await _controller.future;
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(cameraPosition()));
                      _decodeAddress(
                          Location(
                              lat: position.latitude, lng: position.longitude),
                          context);
                      setState(() {});
                    },
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('two'),
                        position: _initialPosition,
                      ),
                    },
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    padding: widget.padding,
                    compassEnabled: widget.compassEnabled,
                    liteModeEnabled: widget.liteModeEnabled,
                    mapType: widget.mapType,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: FloatingActionButton(
                              elevation: 0,
                              tooltip: 'My Location',
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              onPressed: () async {
                                await Geolocator.requestPermission();
                                Position position =
                                    await Geolocator.getCurrentPosition(
                                  desiredAccuracy: widget.desiredAccuracy,
                                );
                                LatLng latLng = LatLng(
                                    position.latitude, position.longitude);
                                _initialPosition = latLng;
                                final controller = await _controller.future;
                                controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        cameraPosition()));
                                _decodeAddress(
                                    Location(
                                        lat: position.latitude,
                                        lng: position.longitude),
                                    context);
                              },
                              child: Icon(
                                Icons.my_location_sharp,
                                color: LiveColors.cartBlue,
                                size: Dimensions.iconSize24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      addressViewController.hasData
                          ? ShowResultsDialog()
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
