import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Use geocoding package
import '../../services/map_function.dart';
import 'package:flutter/services.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../live/view/address_view/view_widgets/map_location_picker.dart';

// Custom classes to replace Prediction and PlacesDetailsResponse
class CustomPrediction {
  final String? placeId;
  final String? description;
  final String? mainText;
  final String? secondaryText;

  CustomPrediction({
    this.placeId,
    this.description,
    this.mainText,
    this.secondaryText,
  });

  factory CustomPrediction.fromJson(Map<String, dynamic> json) {
    return CustomPrediction(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']?['main_text'],
      secondaryText: json['structured_formatting']?['secondary_text'],
    );
  }
}

class CustomPlacesDetails {
  final String? formattedAddress;
  final double? lat;
  final double? lng;

  CustomPlacesDetails({
    this.formattedAddress,
    this.lat,
    this.lng,
  });

  factory CustomPlacesDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']?['location'];
    return CustomPlacesDetails(
      formattedAddress: json['formatted_address'],
      lat: geometry?['lat'],
      lng: geometry?['lng'],
    );
  }
}

class AddressSearch extends StatefulWidget {
  @override
  State<AddressSearch> createState() => _AddressSearchState();
}

class _AddressSearchState extends State<AddressSearch> {
  String address = "null";
  String autocompletePlace = "null";
  CustomPrediction? initialValue;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Color(0Xff353839), size: 30),
        titleTextStyle:
            TextStyle(color: Colors.black, fontSize: Dimensions.font26),
        title: Text('Addresses'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Replace with your custom autocomplete widget or use a simpler approach
          _buildCustomSearchField(),

          OutlinedButton(
            child: Text('show dialog'.toUpperCase()),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Example'),
                    content: _buildCustomSearchDialog(),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Google Map Location Picker\nMade By Arvind 😃 with Flutter 🚀",
              textAlign: TextAlign.center,
              textScaleFactor: 1.2,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Clipboard.setData(
              const ClipboardData(text: "https://www.mohesu.com"),
            ).then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Copied to Clipboard"),
                ),
              ),
            ),
            child: const Text("https://www.mohesu.com"),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              child: const Text('Pick location'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MapLocationPicker(
                        apiKey: AppConstants.PLACES_API,
                        canPopOnNextButtonTaped: true,
                        currentLatLng: const LatLng(29.121599, 76.396698),
                        onNext: (dynamic result) {
                          // Use dynamic or CustomGeocodingResult
                          if (result != null) {
                            setState(() {
                              // Handle the result based on your CustomGeocodingResult structure
                              if (result is CustomGeocodingResult) {
                                address = result.formattedAddress ?? "";
                              }
                            });
                          }
                        },
                        onSuggestionSelected: (dynamic result) {
                          if (result != null) {
                            setState(() {
                              // Handle the result
                              autocompletePlace = result.toString();
                            });
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          ListTile(
            title: Text("Geocoded Address: $address"),
          ),
          ListTile(
            title: Text("Autocomplete Address: $autocompletePlace"),
          ),
          const Spacer(
            flex: 3,
          ),
        ],
      ),
    );
  }

  // Custom search field implementation
  Widget _buildCustomSearchField() {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search for an address...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          // Implement your custom search logic here
          _performSearch(value);
        },
      ),
    );
  }

  // Custom search dialog
  Widget _buildCustomSearchDialog() {
    return Container(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search place...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Implement search logic
              _performSearch(value);
            },
          ),
          SizedBox(height: 16),
          // You can add search results here
          _buildSearchResults(),
        ],
      ),
    );
  }

  // Placeholder for search results
  Widget _buildSearchResults() {
    return Container(
      height: 200,
      child: ListView(
        children: [
          ListTile(
            title: Text("Sample Result 1"),
            onTap: () {
              setState(() {
                autocompletePlace = "Sample Result 1";
                address = "123 Sample Street, City";
              });
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text("Sample Result 2"),
            onTap: () {
              setState(() {
                autocompletePlace = "Sample Result 2";
                address = "456 Example Ave, Town";
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Implement your search logic here
  void _performSearch(String query) async {
    if (query.isEmpty) return;

    // You can implement:
    // 1. Direct geocoding API call using http package
    // 2. Use the geocoding package for local searches
    // 3. Implement your own search service

    try {
      // Example using geocoding package for local search
      if (query.length > 2) {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          // Handle the results
          print("Found locations: $locations");
        }
      }
    } catch (e) {
      print("Search error: $e");
    }
  }
}
