# Izinto - Flutter On-Demand Services App

A comprehensive Flutter application for on-demand home services, built with modern architecture patterns and cloud services.

## 🏗️ Architecture Overview

### Data Flow Architecture

API Call: home_items_repo.dart
↓
Processing: home_items_controller.dart
↓
Parsing: popular_specialty_model.dart
↓
State Update: home_items_controller.dart
↓
UI Update: light_theme_home.dart → specialty_widget.dart

This project is a starting point for a Flutter application.

## Tech Stack

Frontend: Flutter with Dart

State Management: Provider + GetX

Backend: Node.js/Express API hosted on Netlify

Database: Firebase (Firestore, Auth, Storage)

Authentication: Firebase Auth + Phone Verification

## 📱 Core Features

### Service Categories

🧺 Laundry & Dry Cleaning

⛽ Gas Refill & Exchange

🐾 Pet Care & Grooming

🧹 Home Cleaning Services

🚗 Mobile Car Wash

👟 Sneaker & Blanket Cleaning

### Key Functionalities

Real-time service booking

Live order tracking

Secure in-app payments

Multi-service cart management

Push notifications

Location-based services

## 🔧 Technical Implementation

### Dependency Management

dependencies:
get: ^4.6.1                    # State management
provider: ^6.0.4               # State management
firebase_core: 4.2.0           # Firebase integration
firebase_auth: 6.1.1           # Authentication
cloud_firestore: 6.0.3         # Database
http: ^1.5.0                   # API calls
shared_preferences: ^2.0.13    # Local storage

## API Structure

Backend endpoints served via Netlify Functions:

/recommended - Featured services

/laundry - Laundry services

/gas-refill - Gas delivery

/pet-care - Pet services

/home-items - Main categories

And 10+ additional service endpoints

## 🗂️ Project Structure

lib/
├── controllers/                 # Business logic & state management
│   ├── home_items_controller.dart
│   ├── pet_care_specialty_controller.dart
│   ├── gas_refill_specialty_controller.dart
│   └── new_cart_controller.dart
├── helpers/data/
│   ├── repository/             # API data repositories
│   │   ├── home_items_repo.dart
│   │   ├── pet_care_specialty_repo.dart
│   │   └── cart_repo.dart
│   └── api/
│       └── api_client.dart     # HTTP client configuration
├── models/                     # Data models
│   ├── new_specialty_model.dart
│   ├── popular_specialty_model.dart
│   └── new_cart_model.dart
├── live/view/                  # UI screens
│   ├── home_view/
│   ├── cart_view/
│   ├── auth_view/
│   └── checkout_view/
└── utils/
├── dimensions.dart         # Responsive sizing
└── app_constants.dart      # App constants & URLs

## 🔄 State Management Pattern

### Provider + GetX Hybrid Approach

// Provider for app-wide state
Provider<AuthService>(
create: (_) => AuthService(),
child: MyApp(),
)

// GetX for feature-specific controllers
Get.lazyPut(() => HomeItemsController(homeItemsRepo: Get.find()))
Get.lazyPut(() => PetCareSpecialtyController(petCareRepo: Get.find()))

### Controller Lifecycle

class PetCareSpecialtyController extends GetxController {
final RxList<NewSpecialtyModel> _petCareSpecialtyList = <NewSpecialtyModel>[].obs;
final RxBool _isLoaded = false.obs;

@override
void onInit() {
super.onInit();
getPetCareSpecialtyList();
}

Future<void> getPetCareSpecialtyList() async {
// API call implementation
}
}

## 🌐 Backend API Integration

### Express.js Server on Netlify

// Netlify functions structure
router.get("/pet-care", (req, res) => {
res.send(importPetCare);
});

router.get("/gas-refill", (req, res) => {
res.send(importGasRefill);
});

app.use("/.netlify/functions/api", router);

### Flutter API Client

class ApiClient extends GetxService {
final String appBaseUrl;
final SharedPreferences sharedPreferences;

Future<Response> getData(String uri) async {
try {
Response response = await http.get(
Uri.parse(appBaseUrl + uri),
headers: _mainHeaders,
);
return response;
} catch (e) {
return Response(statusCode: 1, statusText: e.toString());
}
}
}

## 📊 Data Models

### Specialty Service Model

class NewSpecialtyModel {
int? id;
String? name;
String? introduction;
List<int>? price;
List<String>? size;
String? img;
String? type;
String? material;
String? provider;

// Size variant support
String? selectedSize;
bool? isSizeVariant;
int? originalId;
}

### Cart Management

class NewCartModel {
int? id;
String? name;
int? price;
String? img;
String? type;
int? quantity;
dynamic specialty; // Can be NewSpecialtyModel or Map
}

## 🎨 UI/UX Features

### Responsive Design

Custom dimension system using Dimensions.dart

Adaptive layouts for various screen sizes

Consistent spacing and typography

### Navigation Flow

Home → Category View → Service Details → Cart → Checkout
↘ Auth Flow ↗          ↘ Favorite ↗

### Custom Widgets

GenericWhiteContainer - Reusable card container

ServiceWidget - Service display component

CartProductView - Cart item display

SafePetCareWidget - Error-boundary wrapper


## 🔒 Authentication & Security

### Firebase Auth Integration

Phone number authentication

User profile management

Secure session handling

Guest mode support

### Data Security

Firebase Security Rules

Input validation

Error boundary implementation

Safe controller access patterns

## 🚀 Performance Optimizations

### Lazy Loading

Get.lazyPut(() => HomeItemsController(homeItemsRepo: Get.find()));

### Environment Setup

environment:
sdk: ">=3.0.0 <4.0.0"

flutter_native_splash:
color: "#ffffff"
image: assets/splash/splash.jpg

## 🔧 Development Setup

### Prerequisites

Flutter SDK 3.0+

Firebase project configuration

Node.js for backend development

### Installation

Clone the repository

Run flutter pub get

Configure Firebase

Set up environment variables

Run flutter run

## 📝 Key Features Implementation

### Multi-Service Cart

Support for different service types

Size variant handling

Quantity management

Price calculation

### Real-time Updates

Firebase listeners

State synchronization

Offline capability with local storage

### Error Handling

Network error recovery

Controller lifecycle management

User-friendly error messages

## 🔮 Future Enhancements

Advanced analytics integration

Advanced payment options

*Built with Flutter, Firebase, and modern development practices for reliable on-demand service delivery.*

