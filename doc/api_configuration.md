# API Configuration Documentation

This document describes the API configurations used in the English Dictation Practice application.

## Google Gemini API

### Purpose
Used for AI-generated content creation, allowing users to generate custom practice units based on specified keywords.

### Configuration
- **API Key**: Stored in `.env` file as `GEMINI_API_KEY`
- **Model**: `gemini-1.5-flash` (stored in `.env` as `GEMINI_MODEL`)
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`

### Environment Setup
Create a `.env` file in the project root:

```
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-1.5-flash
```

### Security Notes
- The `.env` file is excluded from version control via `.gitignore`
- Never commit API keys to the repository
- API keys are loaded using the `flutter_dotenv` package

## Text-to-Speech (TTS)

### Implementation
Uses Google Translate TTS API for audio generation:
- **URL**: `https://translate.google.com/translate_tts`
- **Parameters**:
  - `ie`: UTF-8
  - `client`: tw-ob
  - `q`: Text to speak (URL encoded)
  - `tl`: Language code (e.g., en)
  - `ttsspeed`: Speech speed (1.0 = normal)

### Audio Playback
- Generated MP3 files are cached temporarily
- Uses `audioplayers` package for playback
- Supports play, pause, resume, stop operations

## Original Python Configuration

The Flutter app uses the same API configurations as the original Python implementation:

### Python config.json equivalent
```json
{
  "gemini": {
    "api_key": "your_api_key_here",
    "model": "gemini-1.5-flash"
  }
}
```

### TTS Settings
- Language: en-US (default)
- Speed: 1.0 (configurable per unit)
- Audio format: MP3

## Error Handling

- API failures are caught and logged
- Graceful fallback for TTS failures
- User-friendly error messages in the UI