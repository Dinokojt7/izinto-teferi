import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:izinto/logger.dart';

// Custom classes to replace google_maps_webservice types
class CustomPrediction {
  final String? placeId;
  final String? description;
  final String? mainText;
  final String? secondaryText;
  final Map<String, dynamic>? structuredFormatting;
  final List<String>? types;
  final List<dynamic>? matchedSubstrings;

  CustomPrediction({
    this.placeId,
    this.description,
    this.mainText,
    this.secondaryText,
    this.structuredFormatting,
    this.types,
    this.matchedSubstrings,
  });

  factory CustomPrediction.fromJson(Map<String, dynamic> json) {
    return CustomPrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']?['main_text'],
      secondaryText: json['structured_formatting']?['secondary_text'],
      structuredFormatting: json['structured_formatting'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      matchedSubstrings: json['matched_substrings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': description,
      'structured_formatting': structuredFormatting,
      'types': types,
      'matched_substrings': matchedSubstrings,
    };
  }
}

class CustomComponent {
  final String component;
  final String value;

  CustomComponent(this.component, this.value);

  String toString() => '$component:$value';
}

class CustomLocation {
  final double lat;
  final double lng;

  CustomLocation({required this.lat, required this.lng});

  String toString() => '$lat,$lng';

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class AutoCompleteState {
  AutoCompleteState({
    this.httpClient,
    this.apiHeaders,
    this.baseUrl,
  });

  /// httpClient is used to make network requests.
  final http.Client? httpClient;

  /// apiHeader is used to add headers to the request.
  final Map<String, String>? apiHeaders;

  /// baseUrl is used to build the url for the request.
  final String? baseUrl;

  /// The current state of the autocomplete.
  List<CustomPrediction> predictions = [];

  /// Future function to get the autocomplete results using direct HTTP calls.
  Future<List<CustomPrediction>> search(
    String query,
    String apiKey, {
    /// Session token for Google Places API
    String? sessionToken,

    /// Offset for pagination of results
    num? offset,

    /// Origin location for calculating distance from results
    CustomLocation? origin,

    /// Location bounds for restricting results to a radius around a location
    CustomLocation? location,

    /// Radius for restricting results to a radius around a location
    /// radius: Radius in meters
    num? radius,

    /// Language code for Places API results
    String? language,

    /// Types for restricting results to a set of place types
    List<String> types = const [],

    /// Components set results to be restricted to a specific area
    List<CustomComponent> components = const [],

    /// Bounds for restricting results to a set of bounds
    bool strictbounds = false,

    /// Region for restricting results to a set of regions
    String? region,
  }) async {
    try {
      // Build the API URL
      final baseUrl = this.baseUrl ?? 'https://maps.googleapis.com';
      final endpoint = '$baseUrl/maps/api/place/autocomplete/json';

      // Build query parameters
      final params = <String, String>{
        'input': query,
        'key': apiKey,
      };

      // Add optional parameters
      if (sessionToken != null) params['sessiontoken'] = sessionToken;
      if (offset != null) params['offset'] = offset.toString();
      if (origin != null) params['origin'] = origin.toString();
      if (location != null) params['location'] = location.toString();
      if (radius != null) params['radius'] = radius.toString();
      if (language != null) params['language'] = language;
      if (types.isNotEmpty) params['types'] = types.join('|');
      if (components.isNotEmpty) {
        params['components'] = components.map((c) => c.toString()).join('|');
      }
      if (region != null) params['region'] = region;
      if (strictbounds) params['strictbounds'] = 'true';

      final uri = Uri.parse(endpoint).replace(queryParameters: params);

      // Make the HTTP request
      final client = httpClient ?? http.Client();
      final response = await client.get(uri, headers: apiHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle API errors with detailed logging
        final status = data['status'];
        switch (status) {
          case 'OK':
            // Success - parse predictions
            if (data['predictions'] != null) {
              final predictionsList = data['predictions'] as List;
              predictions = predictionsList
                  .map((p) => CustomPrediction.fromJson(p))
                  .toList();

              logger.d(
                  'Found ${predictions.length} predictions for query: "$query"');
              logger.d(predictions.map((e) => e.toJson()).toList());
              return predictions;
            } else {
              logger.w('No predictions array in response for query: "$query"');
              return [];
            }

          case 'ZERO_RESULTS':
            logger.i('No results found for query: "$query"');
            return [];

          case 'OVER_QUERY_LIMIT':
            final errorMessage = data['error_message'] ?? 'API quota exceeded';
            logger.e('OVER_QUERY_LIMIT: $errorMessage for query: "$query"');
            return [];

          case 'REQUEST_DENIED':
            final errorMessage =
                data['error_message'] ?? 'Request denied - check API key';
            logger.e('REQUEST_DENIED: $errorMessage for query: "$query"');
            return [];

          case 'INVALID_REQUEST':
            final errorMessage =
                data['error_message'] ?? 'Invalid request parameters';
            logger.e('INVALID_REQUEST: $errorMessage for query: "$query"');
            return [];

          case 'UNKNOWN_ERROR':
            final errorMessage =
                data['error_message'] ?? 'Unknown server error';
            logger.e('UNKNOWN_ERROR: $errorMessage for query: "$query"');
            return [];

          default:
            final errorMessage =
                data['error_message'] ?? 'Unexpected status: $status';
            logger.e(
                'Unexpected API status ($status): $errorMessage for query: "$query"');
            return [];
        }
      } else {
        // HTTP error
        logger.e(
            'HTTP error ${response.statusCode} for query: "$query" - ${response.body}');
        return [];
      }
    } catch (err) {
      /// Log the error with context
      logger.e('Autocomplete search error for query: "$query" - $err');
      return [];
    }
  }

  /// Additional method to get place details
  Future<Map<String, dynamic>?> getPlaceDetails(
    String placeId,
    String apiKey, {
    String? sessionToken,
    String? language,
    List<String> fields = const [],
  }) async {
    try {
      final baseUrl = this.baseUrl ?? 'https://maps.googleapis.com';
      final endpoint = '$baseUrl/maps/api/place/details/json';

      final params = <String, String>{
        'place_id': placeId,
        'key': apiKey,
      };

      if (sessionToken != null) params['sessiontoken'] = sessionToken;
      if (language != null) params['language'] = language;
      if (fields.isNotEmpty) params['fields'] = fields.join(',');

      final uri = Uri.parse(endpoint).replace(queryParameters: params);

      final client = httpClient ?? http.Client();
      final response = await client.get(uri, headers: apiHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          logger.d('Successfully retrieved details for place: $placeId');
          return data['result'];
        } else {
          final errorMessage = data['error_message'] ?? data['status'];
          logger.e('Place details error for $placeId: $errorMessage');
          return null;
        }
      } else {
        logger
            .e('HTTP error ${response.statusCode} for place details: $placeId');
        return null;
      }
    } catch (err) {
      logger.e('Place details error for $placeId: $err');
      return null;
    }
  }

  /// Helper method to clear predictions
  void clearPredictions() {
    predictions.clear();
  }

  /// Helper method to check if there are predictions
  bool get hasPredictions => predictions.isNotEmpty;

  /// Helper method to get prediction by index
  CustomPrediction? getPrediction(int index) {
    if (index >= 0 && index < predictions.length) {
      return predictions[index];
    }
    return null;
  }

  /// Helper method to find prediction by place ID
  CustomPrediction? findPredictionByPlaceId(String placeId) {
    return predictions.firstWhere(
      (prediction) => prediction.placeId == placeId,
      orElse: () =>
          throw StateError('No prediction found with placeId: $placeId'),
    );
  }
}

// Extension methods for easier usage
extension CustomPredictionExtensions on CustomPrediction {
  String get displayText => description ?? '';
  String get primaryText => mainText ?? description ?? '';
  String get secondaryDisplayText => secondaryText ?? '';

  bool get hasLocation => structuredFormatting != null;

  /// Check if this prediction matches a specific type
  bool isType(String type) {
    return types?.contains(type) == true;
  }

  /// Get the first type, if available
  String? get firstType => types?.isNotEmpty == true ? types!.first : null;
}

// Utility class for common component configurations
class ComponentBuilder {
  static CustomComponent country(String countryCode) {
    return CustomComponent('country', countryCode);
  }

  static CustomComponent postalCode(String postalCode) {
    return CustomComponent('postal_code', postalCode);
  }

  static CustomComponent locality(String locality) {
    return CustomComponent('locality', locality);
  }

  static CustomComponent administrativeArea(String area) {
    return CustomComponent('administrative_area', area);
  }
}
