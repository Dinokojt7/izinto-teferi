// TODO(god-file): ~750 lines. There are now two files named
// map_location_picker.dart (this one under services/, another under
// live/view/address_view/view_widgets/) — confirm which is actually live,
// delete the other, and split the survivor's map/search/geocoding concerns
// apart.
// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart' hide ErrorBuilder;
// import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
// import 'package:http/http.dart' as http;
// import 'package:izinto/live/view/address_view/controller/address_dropdown_controller.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:provider/provider.dart';
//
// import '../utils/dimensions.dart';
// import 'map_function.dart';
// import 'package:izinto/logger.dart';
// import 'dart:convert';
//
// // Custom classes to replace google_maps_webservice types
// class CustomPrediction {
//   final String? placeId;
//   final String? description;
//   final String? mainText;
//   final String? secondaryText;
//   final Map<String, dynamic>? structuredFormatting;
//
//   CustomPrediction({
//     this.placeId,
//     this.description,
//     this.mainText,
//     this.secondaryText,
//     this.structuredFormatting,
//   });
//
//   factory CustomPrediction.fromJson(Map<String, dynamic> json) {
//     return CustomPrediction(
//       placeId: json['place_id'],
//       description: json['description'],
//       mainText: json['structured_formatting']?['main_text'],
//       secondaryText: json['structured_formatting']?['secondary_text'],
//       structuredFormatting: json['structured_formatting'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'place_id': placeId,
//       'description': description,
//       'structured_formatting': structuredFormatting,
//     };
//   }
// }
//
// class CustomComponent {
//   final String component;
//   final String value;
//
//   CustomComponent(this.component, this.value);
//
//   String toString() => '$component:$value';
// }
//
// class CustomPlacesDetails {
//   final String? formattedAddress;
//   final Map<String, dynamic>? geometry;
//   final String? name;
//   final String? placeId;
//
//   CustomPlacesDetails({
//     this.formattedAddress,
//     this.geometry,
//     this.name,
//     this.placeId,
//   });
//
//   factory CustomPlacesDetails.fromJson(Map<String, dynamic> json) {
//     return CustomPlacesDetails(
//       formattedAddress: json['formatted_address'],
//       geometry: json['geometry'],
//       name: json['name'],
//       placeId: json['place_id'],
//     );
//   }
// }
//
// class PlacesAutocomplete extends StatelessWidget {
//   /// API key for the map & places
//   final String apiKey;
//
//   /// Top card margin
//   final EdgeInsetsGeometry topCardMargin;
//
//   /// Top card color
//   final Color? topCardColor;
//
//   /// Top card shape
//   final ShapeBorder topCardShape;
//
//   /// Top card text field border radius
//   final BorderRadius? borderRadius;
//
//   /// Top card text field hint text
//   final String searchHintText;
//
//   /// Show back button (default: true)
//   final bool showBackButton;
//
//   /// Back button replacement when [showBackButton] is false and [backButton] is not null
//   final Widget? backButton;
//
//   /// httpClient is used to make network requests.
//   final http.Client? placesHttpClient;
//
//   /// apiHeader is used to add headers to the request.
//   final Map<String, String>? placesApiHeaders;
//
//   /// baseUrl is used to build the url for the request.
//   final String? placesBaseUrl;
//
//   /// Session token for Google Places API
//   final String? sessionToken;
//
//   /// Offset for pagination of results
//   /// offset: int,
//   final num? offset;
//
//   /// Origin location for calculating distance from results
//   final String? origin;
//
//   /// Location bounds for restricting results to a radius around a location
//   final String? location;
//
//   /// Radius for restricting results to a radius around a location
//   /// radius: Radius in meters
//   final num? radius;
//
//   /// Language code for Places API results
//   /// language: 'en',
//   final String? language;
//
//   /// Types for restricting results to a set of place types
//   final List<String> types;
//
//   /// Components set results to be restricted to a specific area
//   final List<CustomComponent> components;
//
//   /// Bounds for restricting results to a set of bounds
//   final bool strictbounds;
//
//   /// Region for restricting results to a set of regions
//   /// region: "us"
//   final String? region;
//
//   /// fields
//   final List<String> fields;
//
//   /// On get details callback
//   final void Function(CustomPlacesDetails?)? onGetDetailsByPlaceId;
//
//   /// On suggestion selected callback
//   final void Function(CustomPrediction)? onSuggestionSelected;
//
//   /// Search text field controller
//   ///
//   /// Controls the text being edited.
//   ///
//   /// If null, this widget will create its own [TextEditingController].
//   final TextEditingController? searchController;
//
//   /// Is widget mounted
//   final bool mounted;
//
//   /// Can show clear button on search text field
//   final bool showClearButton;
//
//   /// suffix icon for search text field. You can use [showClearButton] to show clear button or replace with suffix icon
//   final Widget? suffixIcon;
//
//   /// Initial value for search text field (optional)
//   /// [initialValue] not in use when [searchController] is not null.
//   final CustomPrediction? initialValue;
//
//   /// Validator for search text field (optional)
//   final String? Function(CustomPrediction?)? validator;
//
//   /// Called for each suggestion returned by [suggestionsCallback] to build the
//   /// corresponding widget.
//   ///
//   /// This callback must not be null. It is called by the TypeAhead widget for
//   /// each suggestion, and expected to build a widget to display this
//   /// suggestion's info. For example:
//   ///
//   /// ```dart
//   /// itemBuilder: (context, suggestion) {
//   ///   return ListTile(
//   ///     title: Text(suggestion['name']),
//   ///     subtitle: Text('USD' + suggestion['price'].toString())
//   ///   );
//   /// }
//   /// ```
//   final Widget Function(BuildContext, CustomPrediction)? itemBuilder;
//
//   /// The decoration of the material sheet that contains the suggestions.
//   ///
//   /// If null, default decoration with an elevation of 4.0 is used
//   final SuggestionsBoxDecoration suggestionsBoxDecoration;
//
//   /// Used to control the `_SuggestionsBox`. Allows manual control to
//   /// open, close, toggle, or resize the `_SuggestionsBox`.
//   final SuggestionsBoxController? suggestionsBoxController;
//
//   /// The duration to wait after the user stops typing before calling
//   /// [suggestionsCallback]
//   ///
//   /// This is useful, because, if not set, a request for suggestions will be
//   /// sent for every character that the user types.
//   ///
//   /// This duration is set by default to 300 milliseconds
//   final Duration debounceDuration;
//
//   /// Called when waiting for [suggestionsCallback] to return.
//   ///
//   /// It is expected to return a widget to display while waiting.
//   /// For example:
//   /// ```dart
//   /// (BuildContext context) {
//   ///   return Text('Loading...');
//   /// }
//   /// ```
//   ///
//   /// If not specified, a [CircularProgressIndicator](https://docs.flutter.io/flutter/material/CircularProgressIndicator-class.html) is shown
//   final WidgetBuilder? loadingBuilder;
//
//   /// Called when [suggestionsCallback] returns an empty array.
//   ///
//   /// It is expected to return a widget to display when no suggestions are
//   /// available.
//   /// For example:
//   /// ```dart
//   /// (BuildContext context) {
//   ///   return Text('No Items Found!');
//   /// }
//   /// ```
//   ///
//   /// If not specified, a simple text is shown
//   final WidgetBuilder? noItemsFoundBuilder;
//
//   /// Called when [suggestionsCallback] throws an exception.
//   ///
//   /// It is called with the error object, and expected to return a widget to
//   /// display when an exception is thrown
//   /// For example:
//   /// ```dart
//   /// (BuildContext context, error) {
//   ///   return Text('$error');
//   /// }
//   /// ```
//   ///
//   /// If not specified, the error is shown in [ThemeData.errorColor](https://docs.flutter.io/flutter/material/ThemeData/errorColor.html)
//   final ErrorBuilder? errorBuilder;
//
//   /// Called to display animations when [suggestionsCallback] returns suggestions
//   ///
//   /// It is provided with the suggestions box instance and the animation
//   /// controller, and expected to return some animation that uses the controller
//   /// to display the suggestion box.
//   ///
//   /// For example:
//   /// ```dart
//   /// transitionBuilder: (context, suggestionsBox, animationController) {
//   ///   return FadeTransition(
//   ///     child: suggestionsBox,
//   ///     opacity: CurvedAnimation(
//   ///       parent: animationController,
//   ///       curve: Curves.fastOutSlowIn
//   ///     ),
//   ///   );
//   /// }
//   /// ```
//   /// This argument is best used with [animationDuration] and [animationStart]
//   /// to fully control the animation.
//   ///
//   /// To fully remove the animation, just return `suggestionsBox`
//   ///
//   /// If not specified, a [SizeTransition](https://docs.flutter.io/flutter/widgets/SizeTransition-class.html) is shown.
//   final AnimationTransitionBuilder? transitionBuilder;
//
//   /// The duration that [transitionBuilder] animation takes.
//   ///
//   /// This argument is best used with [transitionBuilder] and [animationStart]
//   /// to fully control the animation.
//   ///
//   /// Defaults to 500 milliseconds.
//   final Duration animationDuration;
//
//   /// Determine the [SuggestionBox]'s direction.
//   ///
//   /// If [AxisDirection.down], the [SuggestionBox] will be below the [TextField]
//   /// and the [_SuggestionsList] will grow **down**.
//   ///
//   /// If [AxisDirection.up], the [SuggestionBox] will be above the [TextField]
//   /// and the [_SuggestionsList] will grow **up**.
//   ///
//   /// [AxisDirection.left] and [AxisDirection.right] are not allowed.
//   final AxisDirection direction;
//
//   /// The value at which the [transitionBuilder] animation starts.
//   ///
//   /// This argument is best used with [transitionBuilder] and [animationDuration]
//   /// to fully control the animation.
//   ///
//   /// Defaults to 0.25.
//   final double animationStart;
//
//   /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
//   /// that the TypeAhead widget displays
//   final TextFieldConfiguration textFieldConfiguration;
//
//   /// How far below the text field should the suggestions box be
//   ///
//   /// Defaults to 5.0
//   final double suggestionsBoxVerticalOffset;
//
//   /// If set to true, suggestions will be fetched immediately when the field is
//   /// added to the view.
//   ///
//   /// But the suggestions box will only be shown when the field receives focus.
//   /// To make the field receive focus immediately, you can set the `autofocus`
//   /// property in the [textFieldConfiguration] to true
//   ///
//   /// Defaults to false
//   final bool getImmediateSuggestions;
//
//   /// If set to true, no loading box will be shown while suggestions are
//   /// being fetched. [loadingBuilder] will also be ignored.
//   ///
//   /// Defaults to false.
//   final bool hideOnLoading;
//
//   /// If set to true, nothing will be shown if there are no results.
//   /// [noItemsFoundBuilder] will also be ignored.
//   ///
//   /// Defaults to false.
//   final bool hideOnEmpty;
//
//   /// If set to true, nothing will be shown if there is an error.
//   /// [errorBuilder] will also be ignored.
//   ///
//   /// Defaults to false.
//   final bool hideOnError;
//
//   /// If set to false, the suggestions box will stay opened after
//   /// the keyboard is closed.
//   ///
//   /// Defaults to true.
//   final bool hideSuggestionsOnKeyboardHide;
//
//   /// If set to false, the suggestions box will show a circular
//   /// progress indicator when retrieving suggestions.
//   ///
//   /// Defaults to true.
//   final bool keepSuggestionsOnLoading;
//
//   /// If set to true, the suggestions box will remain opened even after
//   /// selecting a suggestion.
//   ///
//   /// Note that if this is enabled, the only way
//   /// to close the suggestions box is either manually via the
//   /// `SuggestionsBoxController` or when the user closes the software
//   /// keyboard if `hideSuggestionsOnKeyboardHide` is set to true. Users
//   /// with a physical keyboard will be unable to close the
//   /// box without a manual way via `SuggestionsBoxController`.
//   ///
//   /// Defaults to false.
//   final bool keepSuggestionsOnSuggestionSelected;
//
//   /// If set to true, in the case where the suggestions box has less than
//   /// _SuggestionsBoxController.minOverlaySpace to grow in the desired [direction], the direction axis
//   /// will be temporarily flipped if there's more room available in the opposite
//   /// direction.
//   ///
//   /// Defaults to false
//   final bool autoFlipDirection;
//
//   /// Controls the text being edited.
//   ///
//   /// If null, this widget will create its own [TextEditingController].
//   final TextEditingController? controller;
//
//   /// Hide the keyboard when a suggestion is selected
//   final bool hideKeyboard;
//
//   /// The suggestions box controller
//   final ScrollController? scrollController;
//
//   /// Input decoration for the text field
//   final InputDecoration? decoration;
//
//   /// value transformer
//   final dynamic Function(CustomPrediction?)? valueTransformer;
//
//   /// Text input enabler
//   final bool enabled;
//
//   /// Auto-validate mode for the text field
//   final AutovalidateMode autovalidateMode;
//
//   /// on change callback
//   final void Function(CustomPrediction?)? onChanged;
//
//   /// on reset callback
//   final void Function()? onReset;
//
//   /// on form save callback
//   final void Function(CustomPrediction?)? onSaved;
//
//   /// Focus node for the text field
//   final FocusNode? focusNode;
//
//   const PlacesAutocomplete({
//     Key? key,
//     required this.apiKey,
//     this.language,
//     this.topCardMargin =
//     const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
//     this.topCardColor,
//     this.topCardShape = const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(12)),
//     ),
//     this.borderRadius = const BorderRadius.all(Radius.circular(12)),
//     this.searchHintText = "Start typing to search",
//     this.showBackButton = true,
//     this.backButton,
//     this.placesHttpClient,
//     this.placesApiHeaders,
//     this.placesBaseUrl,
//     this.sessionToken,
//     this.offset,
//     this.origin,
//     this.location,
//     this.radius,
//     this.region,
//     this.fields = const [],
//     this.types = const [],
//     this.components = const [],
//     this.strictbounds = false,
//     this.hideSuggestionsOnKeyboardHide = false,
//     this.searchController,
//     required this.mounted,
//     this.onGetDetailsByPlaceId,
//     this.onSuggestionSelected,
//     this.showClearButton = true,
//     this.suffixIcon,
//     this.initialValue,
//     this.validator,
//     this.itemBuilder,
//     this.animationDuration = const Duration(milliseconds: 500),
//     this.animationStart = 0.25,
//     this.autoFlipDirection = false,
//     this.controller,
//     this.debounceDuration = const Duration(milliseconds: 300),
//     this.direction = AxisDirection.down,
//     this.errorBuilder,
//     this.getImmediateSuggestions = false,
//     this.hideKeyboard = false,
//     this.hideOnEmpty = false,
//     this.hideOnError = false,
//     this.hideOnLoading = false,
//     this.keepSuggestionsOnLoading = true,
//     this.keepSuggestionsOnSuggestionSelected = false,
//     this.loadingBuilder,
//     this.noItemsFoundBuilder,
//     this.scrollController,
//     this.suggestionsBoxController,
//     this.suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
//     this.suggestionsBoxVerticalOffset = 5.0,
//     this.textFieldConfiguration = const TextFieldConfiguration(),
//     this.transitionBuilder,
//     this.decoration,
//     this.valueTransformer,
//     this.enabled = true,
//     this.autovalidateMode = AutovalidateMode.disabled,
//     this.onChanged,
//     this.onReset,
//     this.onSaved,
//     this.focusNode,
//   }) : super(key: key);
//
//   /// Get address details from place id using direct HTTP call
//   Future<void> _getDetailsByPlaceId(String placeId, BuildContext context) async {
//     try {
//       final baseUrl = placesBaseUrl ?? 'https://maps.googleapis.com';
//       final endpoint = '$baseUrl/maps/api/place/details/json';
//
//       final params = <String, String>{
//         'place_id': placeId,
//         'key': apiKey,
//       };
//
//       if (sessionToken != null) params['sessiontoken'] = sessionToken;
//       if (language != null) params['language'] = language;
//       if (fields.isNotEmpty) params['fields'] = fields.join(',');
//
//       final uri = Uri.parse(endpoint).replace(queryParameters: params);
//
//       final client = placesHttpClient ?? http.Client();
//       final response = await client.get(uri, headers: placesApiHeaders);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['status'] == 'OK') {
//           final placeDetails = CustomPlacesDetails.fromJson(data['result']);
//           onGetDetailsByPlaceId?.call(placeDetails);
//         } else {
//           final errorMessage = data['error_message'] ?? data['status'];
//           logger.e('Place details error: $errorMessage');
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(errorMessage),
//               ),
//             );
//           }
//         }
//       } else {
//         logger.e('HTTP error: ${response.statusCode}');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Network error: ${response.statusCode}'),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       logger.e('Place details error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to get place details: $e'),
//           ),
//         );
//       }
//     }
//   }
//
//   /// Get suggestions using direct HTTP call
//   Future<List<CustomPrediction>> _getSuggestions(String query) async {
//     try {
//       final baseUrl = placesBaseUrl ?? 'https://maps.googleapis.com';
//       final endpoint = '$baseUrl/maps/api/place/autocomplete/json';
//
//       final params = <String, String>{
//         'input': query,
//         'key': apiKey,
//       };
//
//       // Add optional parameters
//       if (sessionToken != null) params['sessiontoken'] = sessionToken;
//       if (offset != null) params['offset'] = offset.toString();
//       if (origin != null) params['origin'] = origin!;
//       if (location != null) params['location'] = location!;
//       if (radius != null) params['radius'] = radius.toString();
//       if (language != null) params['language'] = language;
//       if (types.isNotEmpty) params['types'] = types.join('|');
//       if (components.isNotEmpty) {
//         params['components'] = components.map((c) => c.toString()).join('|');
//       }
//       if (region != null) params['region'] = region;
//       if (strictbounds) params['strictbounds'] = 'true';
//
//       final uri = Uri.parse(endpoint).replace(queryParameters: params);
//
//       final client = placesHttpClient ?? http.Client();
//       final response = await client.get(uri, headers: placesApiHeaders);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
//           if (data['predictions'] != null) {
//             final predictionsList = data['predictions'] as List;
//             return predictionsList
//                 .map((p) => CustomPrediction.fromJson(p))
//                 .toList();
//           }
//         } else {
//           final errorMessage = data['error_message'] ?? data['status'];
//           logger.e('Autocomplete error: $errorMessage');
//         }
//       } else {
//         logger.e('HTTP error: ${response.statusCode}');
//       }
//     } catch (err) {
//       logger.e('Autocomplete search error: $err');
//     }
//     return [];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     /// Get text controller from [searchController] or create new instance of [TextEditingController] if [searchController] is null or empty
//     final textController = ValueNotifier<TextEditingController>(
//         searchController ?? TextEditingController());
//
//     final addressViewController =
//     Provider.of<MainAddressViewController>(context, listen: false);
//     return SafeArea(
//       child: Card(
//         margin: topCardMargin,
//         shape: topCardShape,
//         color: topCardColor,
//         elevation: 0,
//         child: ListTile(
//           minVerticalPadding: 0,
//           contentPadding: const EdgeInsets.only(right: 4, left: 4),
//           leading: showBackButton ? const BackButton() : backButton,
//           title: ClipRRect(
//             borderRadius:
//             BorderRadius.all(Radius.circular(Dimensions.radius15)),
//             child: FormBuilderTypeAhead<CustomPrediction>(
//               decoration: decoration ??
//                   InputDecoration(
//                     prefixIcon: IconButton(
//                       icon: Icon(
//                         Icons.search_sharp,
//                         color: Colors.black87,
//                       ),
//                       onPressed: null,
//                     ),
//                     hintText: searchHintText,
//                     hintStyle: TextStyle(
//                         fontSize: Dimensions.font20 / 1.2,
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w300,
//                         color: Colors.black87),
//                     border: InputBorder.none,
//                     filled: true,
//                     suffixIcon: (showClearButton && initialValue == null)
//                         ? IconButton(
//                         icon: const Icon(
//                           Icons.close,
//                           color: Colors.black,
//                         ),
//                         onPressed: () {
//                           textController.value.clear();
//                           addressViewController.disposeDialog();
//                         })
//                         : suffixIcon,
//                   ),
//               name: 'Search',
//               controller: initialValue == null ? textController.value : null,
//               selectionToTextTransformer: (result) {
//                 return result.description ?? "";
//               },
//               itemBuilder: itemBuilder ??
//                       (context, prediction) {
//                     // Split the string into a list
//                     List<String>? elements = prediction.description?.split(',');
//
//                     String? streetAndSuburb = '';
//                     if (elements != null && elements.length > 1) {
//                       streetAndSuburb =
//                       '${elements[0].trim()}, ${elements[1].trim()}';
//                     }
//
//                     String city = elements != null && elements.length > 2 ? elements[2].trim() : '';
//                     return Container(
//                       height: Dimensions.height45 * 1.6,
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: Colors.grey.shade300,
//                             width: 1.0,
//                           ),
//                         ),
//                       ),
//                       child: ListTile(
//                         leading: Text(
//                           '\u{1F4CD}', // Pin emoji
//                           style: TextStyle(fontSize: Dimensions.font26),
//                         ),
//                         title: Text(
//                           streetAndSuburb ?? "",
//                           style: TextStyle(
//                             fontFamily: 'Poppins',
//                             overflow: TextOverflow.ellipsis,
//                             fontSize: Dimensions.font20 / 1.3,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         subtitle: Text(
//                           city ?? "",
//                           style: TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: Dimensions.font20 / 1.3,
//                             fontWeight: FontWeight.w300,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//               suggestionsCallback: _getSuggestions,
//               onSuggestionSelected: (value) async {
//                 textController.value.selection = TextSelection.collapsed(
//                     offset: textController.value.text.length);
//                 _getDetailsByPlaceId(value.placeId ?? "", context);
//                 onSuggestionSelected?.call(value);
//               },
//               hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
//               initialValue: initialValue,
//               validator: validator,
//               suggestionsBoxDecoration: suggestionsBoxDecoration,
//               scrollController: scrollController,
//               animationDuration: animationDuration,
//               animationStart: animationStart,
//               autoFlipDirection: autoFlipDirection,
//               debounceDuration: debounceDuration,
//               direction: direction,
//               errorBuilder: errorBuilder,
//               focusNode: focusNode,
//               getImmediateSuggestions: getImmediateSuggestions,
//               hideKeyboard: hideKeyboard,
//               hideOnEmpty: false,
//               hideOnError: hideOnError,
//               hideOnLoading: false,
//               keepSuggestionsOnLoading: true,
//               keepSuggestionsOnSuggestionSelected:
//               keepSuggestionsOnSuggestionSelected,
//               loadingBuilder: loadingBuilder,
//               noItemsFoundBuilder: noItemsFoundBuilder,
//               suggestionsBoxController: suggestionsBoxController,
//               suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
//               textFieldConfiguration: textFieldConfiguration,
//               transitionBuilder: transitionBuilder,
//               valueTransformer: valueTransformer,
//               enabled: enabled,
//               autovalidateMode: autovalidateMode,
//               onChanged: onChanged,
//               onReset: onReset,
//               onSaved: onSaved,
//               key: key,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
