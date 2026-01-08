# Application Usage Guide

This guide explains how to use the English Dictation Practice application.

## Getting Started

### Prerequisites
- Flutter SDK installed
- API keys configured (see API Configuration documentation)

### Running the Application
```bash
flutter pub get
flutter run -d windows  # For Windows
flutter run -d macos   # For macOS
```

## User Interface

### Home Screen
- **Practice Existing Units**: Select from pre-loaded practice units
- **AI Generated Units**: Create custom units using AI
- **Random Practice**: Practice exercises randomly from all units
- **Choice-Based Practice**: Multiple choice format (mobile-friendly)
- **Listening Repeat Mode**: Audio-only practice

### Practice Screen
1. **Unit Selection**: Choose a unit from the list
2. **Exercise Display**: Shows current exercise number
3. **Audio Playback**: Click "Play Audio" to hear the dictation
4. **Answer Input**: Type what you heard in the text field
5. **Submission**: Click "Submit" to check your answer and proceed

## Practice Modes

### Existing Units Practice
- Select from available units
- Follow standard dictation flow
- Immediate feedback on answers

### AI Generated Units
- Input keywords for custom content
- AI generates relevant exercises
- Same practice flow as existing units

### Random Practice
- Exercises selected randomly from all units
- Good for comprehensive review

### Choice-Based Practice
- Multiple choice answers instead of typing
- Easier for mobile devices
- Still requires listening comprehension

### Listening Repeat Mode
- Audio-only practice
- Focus on listening without writing
- Useful for initial exposure to content

## Audio Features

### Playback Controls
- **Play**: Start audio playback
- **Stop**: Stop current playback
- **Repeat**: Limited number of replays per exercise (configurable)

### TTS Settings
- Voice language: Configurable per unit
- Speech speed: Adjustable for difficulty
- Audio quality: MP3 format

## Settings

Access the Settings screen from the main menu to configure:

### AI Configuration
1. **API Type**: Choose between Google Gemini or OpenAI Compatible
   - **Google Gemini**: Cloud-based AI service
   - **OpenAI Compatible**: Local or self-hosted AI servers

2. **API Endpoint** (OpenAI Compatible only)
   - Enter the full endpoint URL
   - Examples:
     - Ollama: `http://localhost:11434/v1/chat/completions`
     - Anaconda AI Navigator: `http://192.168.1.4:PORT/v1/chat/completions`
     - LM Studio: `http://localhost:1234/v1/chat/completions`

3. **API Key**
   - For Gemini: Get from https://makersuite.google.com/app/apikey
   - For local servers: Usually not required (leave empty)
   - Toggle visibility with the eye icon

4. **Model Name**
   - Gemini examples: `gemini-2.5-flash`, `gemini-2.0-flash-exp`
   - Local model examples: `llama3.2`, `qwen2.5`

### Display Options
- **Show Japanese translation in results**: Toggle Japanese translation display

### Saving Settings
Click **Save Settings** to apply changes. Settings configured here take precedence over `.env` file values.

## Data Management

### Unit Storage
- Units stored in `assets/units.json`
- JSON format compatible with Python version
- Can be extended with additional units

### Progress Tracking
- Current implementation tracks exercise progress
- Future versions may include detailed statistics

## Troubleshooting

### Common Issues

#### App won't start
- Check `.env` file exists with correct API keys
- Ensure `flutter pub get` has been run
- Check console for error messages

#### No audio playback
- Verify internet connection for TTS
- Check audio permissions on device
- Try different TTS settings

#### API errors
- Verify API keys are correct
- Check API quotas and limits
- Ensure stable internet connection

### Debug Mode
Run with verbose logging:
```bash
flutter run -d windows --verbose
```

## Development

### Adding New Units
1. Edit `assets/units.json`
2. Follow the unit data format specification
3. Restart the app to load new units

### Customizing TTS
- Modify `lib/services/tts_service.dart`
- Adjust Google TTS parameters
- Consider alternative TTS providers

### Extending Practice Modes
- Add new modes in `lib/screens/home_screen.dart`
- Implement corresponding logic in practice screen
- Update navigation routes