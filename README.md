# English Dictation Practice App

A Flutter application for practicing English dictation skills with AI-generated content and text-to-speech functionality.

## Features

- **Practice Existing Units**: Select from pre-loaded practice units
- **AI Generated Units**: Create custom units using Google Gemini AI
- **Multiple Practice Modes**:
  - Random practice
  - Choice-based practice (mobile-friendly)
  - Listening repeat mode
- **Text-to-Speech**: Audio playback using Google Translate TTS
- **Settings Management**: Persistent settings storage

## Setup

### Prerequisites
- Flutter SDK installed
- Google Gemini API key

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Create a `.env` file in the root directory:
   ```
   GEMINI_API_KEY=your_api_key_here
   GEMINI_MODEL=gemini-1.5-flash
   ```
4. Run the app: `flutter run -d windows` (or your target platform)

## Documentation

Detailed documentation is available in the `doc/` folder:
- [API Configuration](doc/api_configuration.md)
- [App Usage Guide](doc/app_usage.md)
- [Unit Data Format](doc/unit_data_format.md)

## Getting Started with Flutter

This project is built with Flutter. For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
