# Unit Data Format Documentation

This document describes the data format for English dictation practice units used in the application.

## Overview

The application uses JSON format to store dictation practice units. Each unit contains exercises with text, hints, and difficulty levels.

## JSON Structure

### Unit Object

```json
{
  "unit_id": "string",
  "title": "string",
  "level": "string",
  "description": "string",
  "exercises": [Exercise],
  "settings": Settings
}
```

### Exercise Object

```json
{
  "id": number,
  "text": "string",
  "hint": "string",
  "japanese": "string (optional)",
  "difficulty": "string"
}
```

### Settings Object

```json
{
  "voice": "string",
  "speed": number,
  "repeat_allowed": number
}
```

## Field Descriptions

### Unit Fields
- `unit_id`: Unique identifier for the unit
- `title`: Display title of the unit
- `level`: Difficulty level (beginner, intermediate, advanced)
- `description`: Brief description of the unit content
- `exercises`: Array of exercise objects
- `settings`: TTS and playback settings

### Exercise Fields
- `id`: Sequential number within the unit
- `text`: The text to be dictated (spoken)
- `hint`: Hint text to help the learner
- `japanese`: Japanese translation (optional, shown when enabled in settings)
- `difficulty`: Difficulty level (easy, medium, hard)

### Settings Fields
- `voice`: Language code for TTS (e.g., "en-US")
- `speed`: Speech rate (1.0 = normal speed)
- `repeat_allowed`: Number of times audio can be replayed

## Example Unit

```json
{
  "unit_id": "001",
  "title": "Basic Greetings",
  "level": "beginner",
  "description": "Daily greeting expressions",
  "exercises": [
    {
      "id": 1,
      "text": "Hello, how are you?",
      "hint": "Basic greeting",
      "japanese": "こんにちは、お元気ですか？",
      "difficulty": "easy"
    },
    {
      "id": 2,
      "text": "Nice to meet you.",
      "hint": "Introduction",
      "japanese": "お会いできて嬉しいです。",
      "difficulty": "easy"
    }
  ],
  "settings": {
    "voice": "en-US",
    "speed": 1.0,
    "repeat_allowed": 3
  }
}
```

## File Location

Units are stored in `assets/units.json` as an array of unit objects.

## Compatibility

This format is compatible with the original Python implementation and supports all practice modes including AI-generated units with Japanese translations.