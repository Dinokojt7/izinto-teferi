import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:izinto/logger.dart';

// Custom classes to replace Prediction and Component
class CustomPrediction {
  final String? placeId;
  final String? description;
  final String? mainText;
  final String? secondaryText;
  final Map<String, dynamic>? structuredFormatting;

  CustomPrediction({
    this.placeId,
    this.description,
    this.mainText,
    this.secondaryText,
    this.structuredFormatting,
  });

  factory CustomPrediction.fromJson(Map<String, dynamic> json) {
    return CustomPrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']?['main_text'],
      secondaryText: json['structured_formatting']?['secondary_text'],
      structuredFormatting: json['structured_formatting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': description,
      'structured_formatting': structuredFormatting,
    };
  }
}

class CustomComponent {
  final String component;
  final String value;

  CustomComponent(this.component, this.value);

  String toString() => '$component:$value';
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

  /// void future function to get the autocomplete results.
  Future<List<CustomPrediction>> search(
    String query,
    String apiKey, {
    /// Session token for Google Places API
    String? sessionToken,

    /// Offset for pagination of results
    num? offset,

    /// Origin location for calculating distance from results
    String? origin,

    /// Location bounds for restricting results to a radius around a location
    String? location,

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
      if (origin != null) params['origin'] = origin;
      if (location != null) params['location'] = location;
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

        // Handle API errors
        final status = data['status'];
        if (status != 'OK' && status != 'ZERO_RESULTS') {
          final errorMessage = data['error_message'] ?? status;
          logger.e('Places API error: $errorMessage');

          // Map API status to readable messages
          if (status == 'OVER_QUERY_LIMIT') {
            logger.e('Over query limit - check your API key and billing');
          } else if (status == 'REQUEST_DENIED') {
            logger.e('Request denied - check your API key');
          } else if (status == 'INVALID_REQUEST') {
            logger.e('Invalid request - check your parameters');
          }

          return [];
        }

        // Parse predictions
        if (data['predictions'] != null) {
          final predictionsList = data['predictions'] as List;
          predictions =
              predictionsList.map((p) => CustomPrediction.fromJson(p)).toList();
        } else {
          predictions = [];
        }

        logger.d('Found ${predictions.length} predictions');
        logger.d(predictions.map((e) => e.toJson()).toList());
        return predictions;
      } else {
        logger.e('HTTP error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (err) {
      /// Log the error
      logger.e('Autocomplete search error: $err');
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
          return data['result'];
        } else {
          final errorMessage = data['error_message'] ?? data['status'];
          logger.e('Place details error: $errorMessage');
          return null;
        }
      } else {
        logger.e('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (err) {
      logger.e('Place details error: $err');
      return null;
    }
  }

  /// Helper method to format location for API
  static String formatLocation(double lat, double lng) {
    return '$lat,$lng';
  }

  /// Helper method to format origin for API
  static String formatOrigin(double lat, double lng) {
    return '$lat,$lng';
  }
}
