import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_suggestions_autocomplete_field/google_places_suggestions_autocomplete_field.dart';
import 'package:geocoding/geocoding.dart'; // Updated import
import 'package:izinto/live/utilities/colors.dart';
import 'package:provider/provider.dart';
import '../../../utilities/generic_snackbar.dart';
import '../controller/address_dropdown_controller.dart';
import 'show_results_dialog.dart';
import '../../../../logger.dart';
import '../../../../utils/dimensions.dart';

// Custom result class to replace GeocodingResult
class CustomGeocodingResult {
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;
  final Placemark? placemark;

  CustomGeocodingResult({
    this.formattedAddress,
    this.latitude,
    this.longitude,
    this.placemark,
  });
}

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
  final Function(dynamic)? onSuggestionSelected; // Updated type

  /// On Next Page callback
  final Function(CustomGeocodingResult?) onNext; // Updated type

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

  /// currentLatLng init location for camera position
  final LatLng? currentLatLng;

  /// Language code for Places API results
  final String? language;

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
    this.language,
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
  CustomGeocodingResult? _geocodingResult;

  /// GeoCoding results list for further use
  late List<CustomGeocodingResult> _geocodingResultList = [];

  /// Camera position moved to location
  CameraPosition cameraPosition() {
    return CameraPosition(
      target: _initialPosition,
      zoom: _zoom,
    );
  }

  /// Search text field controller
  late TextEditingController _searchController = TextEditingController();

  /// Decode address from latitude & longitude using geocoding package
  void _decodeAddress(LatLng position, BuildContext context) async {
    final _addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);
    try {
      // Use the geocoding package for reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _address = "Address not found";
        if (mounted) {
          GenericSnackBar().showCustomSnackBar(
              null, context, 'Address not found, something went wrong!', true);
        }
        return;
      }

      Placemark placemark = placemarks.first;

      // Format address from placemark
      String formattedAddress = _formatAddressFromPlacemark(placemark);

      _address = formattedAddress;

      // Create custom result
      _geocodingResult = CustomGeocodingResult(
        formattedAddress: formattedAddress,
        latitude: position.latitude,
        longitude: position.longitude,
        placemark: placemark,
      );

      ///Assign user current location to the controller
      _addressViewController.onAddressAutocomplete(
          _address, position.latitude, position.longitude);

      setState(() {});
    } catch (e) {
      logger.e('Geocoding error: $e');
      _address = "Error getting address";
      if (mounted) {
        GenericSnackBar().showCustomSnackBar(
            null, context, 'Failed to get address: $e', true);
      }
    }
  }

  /// Format address from Placemark
  String _formatAddressFromPlacemark(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      addressParts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      addressParts.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }

    return addressParts.join(', ');
  }

  Future<BitmapDescriptor> _createCustomPinMarker() async {
    final String emoji = '📍'; // Location pin emoji
    final double fontSize = 60.0;

    // Calculate container size based on font size
    final double containerSize = fontSize * 1.5; // 90px for 60px font
    final double center = containerSize / 2;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: fontSize, // Smaller size for better appearance
        backgroundColor: Colors.transparent,
      ),
      text: emoji,
    );

    TextPainter painter =
        TextPainter(textDirection: TextDirection.ltr, text: span);
    painter.layout();

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);

    // Draw a subtle background circle
    final backgroundPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(center, center), containerSize * 0.4, backgroundPaint);

    // Calculate position to center the emoji
    final double textX = (containerSize - painter.width) / 2;
    final double textY = (containerSize - painter.height) / 2;

    // Draw the emoji centered
    painter.paint(canvas, Offset(textX, textY));

    // Use the calculated container size
    final img = await pictureRecorder
        .endRecording()
        .toImage(containerSize.round(), containerSize.round());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(pngBytes);
  }

// Add this variable to store the custom marker icon
  BitmapDescriptor? _customPinIcon;

  void _onSearchTextChanged() {
    final addressViewController =
        Provider.of<MainAddressViewController>(context, listen: false);

    if (_searchController.text.isEmpty) {
      // Directly set hasData to false and clear the address
      addressViewController.disposeDialog(); // This should set _hasData = false
    }
  }

  @override
  void initState() {
    _initialPosition = widget.currentLatLng ?? _initialPosition;
    _mapType = widget.mapType;
    _searchController = widget.searchController ?? _searchController;
    _searchController.addListener(_onSearchTextChanged);

    // Initialize the custom pin icon
    _initializeCustomMarker();

    super.initState();
  }

  Future<void> _initializeCustomMarker() async {
    _customPinIcon = await _createCustomPinMarker();
    setState(() {}); // Trigger rebuild once marker is loaded
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
    final markers = Set<Marker>.from(additionalMarkers);

// Remove the old current_location marker and add the new one
    markers
        .removeWhere((marker) => marker.markerId.value == "current_location");
    markers.add(Marker(
      markerId: const MarkerId("current_location"),
      position: _initialPosition,
      icon: _customPinIcon ??
          BitmapDescriptor.defaultMarker, // Use custom pin or fallback
      infoWindow: InfoWindow(
        title: _address,
        snippet: "Selected location",
      ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: GooglePlacesSuggestionsAutoCompleteField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100], // Light gray background
                    hintText: "Search address", // Placeholder text
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16.0,
                      fontFamily: 'Poppins',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none, // No border for cleaner look
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Colors.grey[100]!, width: 1.0),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    prefixIcon: Icon(
                      Icons.search, // Magnifying glass icon
                      color: Colors.black54,
                      size: 25.0,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close, // X icon
                              color: Colors.grey[800],
                              size: 25.0,
                            ),
                            onPressed: () {
                              _searchController.clear();

                              // Also clear the address controller data if needed
                              final addressViewController =
                                  Provider.of<MainAddressViewController>(
                                      context,
                                      listen: false);
                              addressViewController.disposeDialog();
                            },
                          )
                        : null,
                  ),
                  suggestionBackgroundColor: Colors.white,

                  suggestionDividerColor:
                      Colors.black45, // Divider color between the suggestions
                  suggestionTextStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      backgroundColor: Colors.white),
                  controller: _searchController,
                  googleAPIKey: widget.apiKey,
                  countries: "za",
                  onPlaceSelected: (place) async {
                    FocusScope.of(context).unfocus();
                    // When a place is selected, move the map to that location
                    final lat = place.latitude;
                    final lng = place.longitude;

                    // Update the initial position
                    _initialPosition = LatLng(lat!, lng!);

                    // Move the map camera to the selected location
                    final controller = await _controller.future;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _initialPosition,
                          zoom: _zoom,
                        ),
                      ),
                    );

                    // Decode the address for the selected location
                    _decodeAddress(_initialPosition, context);

                    // Update the address in the controller
                    final addressViewController =
                        Provider.of<MainAddressViewController>(context,
                            listen: false);
                    addressViewController.onAddressAutocomplete(
                      place.streetAddress ?? "Address not available",
                      lat,
                      lng,
                    );

                    // Trigger widget rebuild to show the new marker
                    setState(() {});
                  },
                ),
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
                      _decodeAddress(position, context); // Updated call
                      setState(() {});
                    },
                    onMapCreated: (GoogleMapController controller) async {
                      _controller.complete(controller);
                    },
                    markers: markers,
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
                                _decodeAddress(latLng, context); // Updated call
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
                      addressViewController.hasData &&
                              _searchController.text.isNotEmpty
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    super.dispose();
  }
}
