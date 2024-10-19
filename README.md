# Grocery Store Route Optimization App

This repository contains an iOS application designed to aid with navigation through a grocery store with the optimal store route. The app provides AI-assisted guidance throughout the store and features human-like navigation instructions from Cartesia AI.

## Features
- **Create Optimal Store Routes**: Enter your list and store address, get a route image.
- **Voice-Guided Navigation**: Use Cartesia AI for directions and navigation.
- **Real-Time Location Tracking**: Track your position inside the store (optional).
- **Account Management**: Store user preferences and shopping frequency.

## Installation for Local Development
1. Clone the repository and open in Xcode.
2. Add your API key in `TASImageView.swift`.
3. Build and run the app on an iOS 17.5 device.

## Shopping App Structure
- **TASContentView.swift**: Main view where users input grocery lists and store details.
- **TASImageView.swift**: Displays the route image returned by the API.
- **TASDirectionsView.swift**: Voice navigation for in-store guidance.
- **TASAccountView.swift**: User account settings (temporary structure).
- **TASNavigationView.swift**: Tracks the user’s movement using CoreLocation.

## Usage
1. Open the app and enter your grocery list and store address.
2. Generate the optimal route, which will be displayed as an image.
3. Follow voice instructions for navigation through the store.
4. Track your path in real-time as you shop.

## API Integration
- **Route Creation API**: Uses a POST request to generate an image of the optimized route based on the state, address, and grocery list.

### API Example Request:
```json
POST https://oj35b6kjt7.execute-api.us-west-2.amazonaws.com/default/create_route
{
  "state": "california",
  "address": "16858 Golden Valley Pkwy, Lathrop, CA 95330-8535",
  "grocery_list": ["bedding", "baby", "snacks", "pets"]
}
```

## Notes
This project is licensed under the MIT License. Requirements for running this includes having iOS 14.0+, Swift 5.0+, and Xcode 12.0+
