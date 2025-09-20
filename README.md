# Arduino Project Hub - Flutter

A comprehensive Flutter application for managing and controlling multiple Arduino projects from a single interface.

## Features

- 📱 **Project Management**: Create, edit, delete, and duplicate Arduino projects
- 🎛️ **Dynamic UI Controls**: Buttons, sliders, switches, and more based on JSON configuration
- 🔌 **USB Communication**: Direct control via USB Type-C connection
- 📊 **Real-time Monitoring**: Activity logs and status monitoring
- 🔄 **Firmware Updates**: Upload new firmware to Arduino (planned)
- 🔍 **Search & Filter**: Easily find your projects
- 💾 **Local Database**: SQLite storage for offline functionality

## Architecture

The app follows a clean architecture pattern with:

- **UI Layer**: Flutter widgets with Material Design
- **State Management**: Provider pattern for reactive UI
- **Data Layer**: SQLite database with Room-like abstraction
- **Communication Layer**: USB Serial communication service
- **Models**: Strongly typed data models

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   └── project.dart                    # Data models
├── providers/
│   └── project_provider.dart           # State management
├── services/
│   ├── database_service.dart           # SQLite operations
│   └── arduino_communication_service.dart # Arduino communication
├── screens/
│   ├── home_screen.dart                # Main project list
│   ├── add_project_screen.dart         # Add/edit projects
│   └── project_control_screen.dart     # Control interface
└── widgets/
    ├── project_card.dart               # Project list item
    └── dynamic_ui_widget.dart          # Dynamic controls
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Android SDK (for Android development)
- Arduino IDE (for compiling sketches)

### Installation

1. **Clone the project files**:
   Create a new Flutter project and replace the files with the provided code.

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Android permissions**:
   - Copy the provided `AndroidManifest.xml` to `android/app/src/main/`
   - Create the `device_filter.xml` file in `android/app/src/main/res/xml/`

4. **Run the app**:
   ```bash
   flutter run
   ```

### Sample Arduino Sketch

Here's a basic Arduino sketch that works with the sample projects:

```cpp
String command = "";

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.println("Arduino ready");
}

void loop() {
  if (Serial.available()) {
    command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command == "LED_ON") {
      digitalWrite(LED_BUILTIN, HIGH);
      Serial.println("LED ON");
    }
    else if (command == "LED_OFF") {
      digitalWrite(LED_BUILTIN, LOW);
      Serial.println("LED OFF");
    }
    else if (command.startsWith("BRIGHTNESS:")) {
      int brightness = command.substring(11).toInt();
      analogWrite(LED_BUILTIN, brightness);
      Serial.println("Brightness: " + String(brightness));
    }
    else if (command == "MOTOR_START") {
      Serial.println("Motor started");
    }
    else if (command == "MOTOR_STOP") {
      Serial.println("Motor stopped");
    }
    else if (command.startsWith("SPEED:")) {
      int speed = command.substring(6).toInt();
      Serial.println("Speed: " + String(speed));
    }
  }
}
```

## UI Configuration Format

Projects use JSON to define their control interface:

```json
{
  "controls": [
    {
      "type": "button",
      "label": "LED On",
      "command": "LED_ON"
    },
    {
      "type": "button",
      "label": "LED Off", 
      "command": "LED_OFF"
    },
    {
      "type": "slider",
      "label": "Brightness",
      "command_prefix": "BRIGHTNESS:",
      "min_value": 0,
      "max_value": 255,
      "default_value": 128
    },
    {
      "type": "switch",
      "label": "Motor Direction",
      "command_on": "DIR_FORWARD",
      "command_off": "DIR_REVERSE"
    }
  ]
}
```

### Control Types

- **Button**: Sends a single command when pressed
- **Slider**: Sends commands with values (e.g., "SPEED:50")
- **Switch**: Toggles between two commands

## Development Phases

### ✅ Phase 1: Project Management
- Local SQLite database
- CRUD operations for projects
- Search and filtering

### ✅ Phase 2: Dynamic UI
- JSON-based UI configuration
- Dynamic control rendering
- State management

### ✅ Phase 3: USB Communication
- USB Host API integration
- Serial communication
- Device detection

### 🚧 Phase 4: Firmware Updates (Planned)
- File picker for .hex/.bin files
- Upload to Arduino via USB
- Progress tracking

### 🚧 Phase 5: Additional Features (Planned)
- Bluetooth communication
- Wi-Fi/WebSocket support
- Real-time sensor data display
- Export/import projects

## Adding New Features

The app is designed to be easily extensible:

### Adding New Control Types

1. Add the control type to the `UIControl` model
2. Implement the widget in `DynamicUIWidget`
3. Update the JSON schema documentation

### Adding Communication Methods

1. Extend `ArduinoCommunicationService`
2. Add new connection methods
3. Update the UI to support selection

### Adding Database Fields

1. Update the `Project` model
2. Modify the database schema in `DatabaseService`
3. Handle migration if needed

## Supported Arduino Boards

- Arduino Uno
- Arduino Nano
- Arduino Mega 2560
- Arduino Leonardo
- ESP32 development boards
- ESP8266 development boards
- Most Arduino-compatible boards with USB-to-serial chips

## Troubleshooting

### USB Connection Issues
- Ensure USB debugging is enabled on Android
- Check if the device appears in Android's USB settings
- Try different USB cables
- Grant USB permissions when prompted

### App Crashes
- Check Flutter and Dart versions
- Clear app data and restart
- Check device logs: `flutter logs`

### Build Issues
- Run `flutter clean && flutter pub get`
- Update dependencies: `flutter pub upgrade`
- Check Android SDK configuration

## Contributing

This is a foundational implementation that can be extended with:

- Additional Arduino board support
- More UI control types
- Advanced communication protocols
- Cloud sync capabilities
- Project sharing features

## License

This project is provided as a learning resource and foundation for Arduino project management apps. Modify and extend as needed for your specific requirements.