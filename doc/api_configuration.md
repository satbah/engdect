# API Configuration Documentation

This document describes the API configurations used in the English Dictation Practice application.

## Google Gemini API

### Purpose
Used for AI-generated content creation, allowing users to generate custom practice units based on specified keywords.

### Configuration
- **API Key**: Stored in `.env` file as `GEMINI_API_KEY` or configured in Settings
- **Model**: `gemini-2.0-flash-exp` or `gemini-2.5-flash` (stored in `.env` as `GEMINI_MODEL`)
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`

### Environment Setup
Create a `.env` file in the project root directory:

```
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-2.5-flash
API_TYPE=gemini
```

**Important**: The `.env` file must be:
1. Located in the project root directory (same level as `pubspec.yaml`)
2. Listed in `pubspec.yaml` under the `assets` section:
   ```yaml
   flutter:
     assets:
       - .env
   ```

Get your API key from: https://makersuite.google.com/app/apikey

### Settings UI Configuration
Alternatively, configure API settings through the Settings screen in the app:
1. Open **Settings**
2. Select **API Type** (Google Gemini or OpenAI Compatible)
3. Enter **API Key**
4. Enter **Model Name**
5. Click **Save Settings**

Settings configured through the UI take precedence over `.env` file values.

### Rate Limiting
The app includes automatic retry logic with exponential backoff:
- **Max Retries**: 5 attempts
- **Backoff**: 5s, 10s, 20s, 40s, 80s
- Gemini free tier: 15 requests per minute (RPM)

### Security Notes
- The `.env` file is excluded from version control via `.gitignore`
- Never commit API keys to the repository
- API keys are loaded using the `flutter_dotenv` package
- The `.env` file is bundled with the app during build
- User preferences are stored locally using `shared_preferences`

## OpenAI Compatible APIs

### Purpose
Support for local and self-hosted AI models using OpenAI-compatible API format.

### Supported Platforms
- **Ollama**: Local LLM server
- **LM Studio**: Desktop AI application
- **Anaconda AI Navigator**: Enterprise AI platform
- **vLLM, LocalAI**: Self-hosted inference servers
- **OpenAI**: Official OpenAI API

### Configuration

#### Via Settings UI (Recommended)
1. Open **Settings**
2. Select **API Type** → **OpenAI Compatible**
3. Enter **API Endpoint**: e.g., `http://192.168.1.4:8080/v1/chat/completions`
4. Enter **API Key** (optional for local servers)
5. Enter **Model Name**: e.g., `llama3.2`, `qwen2.5`
6. Click **Save Settings**

#### Via .env File
```
API_TYPE=openai
API_ENDPOINT=http://localhost:11434/v1/chat/completions
GEMINI_API_KEY=your_api_key_if_needed
GEMINI_MODEL=llama3.2
```

### Examples

**Ollama (Local)**
```
API Endpoint: http://localhost:11434/v1/chat/completions
Model Name: llama3.2
API Key: (leave empty)
```

**Anaconda AI Navigator**
```
API Endpoint: http://192.168.1.4:PORT/v1/chat/completions
Model Name: (your model name)
API Key: (if required)
```

**LM Studio**
```
API Endpoint: http://localhost:1234/v1/chat/completions
Model Name: (model loaded in LM Studio)
API Key: (leave empty)
```

### Benefits
- No rate limits (for local servers)
- Privacy-focused (data stays local)
- Cost-effective (no API fees)
- Supports various model sizes based on hardware

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

## Platform-Specific Configuration

### macOS
For macOS builds, network access must be enabled in the entitlements files:

**Debug/Profile** (`macos/Runner/DebugProfile.entitlements`):
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

**Release** (`macos/Runner/Release.entitlements`):
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

These permissions are required for:
- API calls to Google Gemini
- TTS audio downloads from Google Translate
- Any other network operations
