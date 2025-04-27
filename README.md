# SunSync - Smart Daylight Activity Manager ☀️


  <p align="center">
    <strong>Harmonize your daily routine with natural light cycles</strong>
  </p>

  <p align="center">
    A Flutter-based mobile application integrated with IoT light sensors to help users maintain healthy lifestyle habits by leveraging natural sunlight patterns.
  </p>
</div>

## ✨ Key Features

<table>
  <tr>
    <td align="center" width="33%">
      <img src="assets/weather_icon.png" alt="Weather" width="80"><br>
      <strong>Real-time Weather</strong><br>
      Live weather data and sun position tracking
    </td>
    <td align="center" width="33%">
      <img src="assets/sensor_icon.png" alt="IoT Sensor" width="80"><br>
      <strong>IoT Light Monitoring</strong><br>
      MKR1010 + Light sensor integration
    </td>
    <td align="center" width="33%">
      <img src="assets/reminder_icon.png" alt="Reminders" width="80"><br>
      <strong>Smart Reminders</strong><br>
      Sunrise/sunset-synchronized activities
    </td>
  </tr>
</table>

### 🌟 Core Functionalities

- **Dynamic Weather Dashboard**: Animated weather conditions with sunrise/sunset times
- **Real-time Light Monitoring**: Track indoor light levels using IoT sensors
- **Activity Reminders**: Set reminders based on natural light cycles
- **Light History Visualization**: Beautiful charts showing daily light patterns
- **Smart Recommendations**: Personalized activity suggestions based on light conditions
- **Cloud Synchronization**: Firebase integration for data persistence

## 📱 Screenshots

<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/home.png" alt="Home Screen" width="250"/><br>
      <b>Weather Dashboard</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/light.png" alt="Light Screen" width="250"/><br>
      <b>Light Monitoring</b>
    </td>
    <td align="center">
      <img src="assets/screenshots/reminder.png" alt="Reminder Screen" width="250"/><br>
      <b>Activity Reminders</b>
    </td>
  </tr>
</table>

## 🛠 Technology Stack

### Mobile Application
- **Framework**: Flutter 3.7.2+
- **State Management**: Provider
- **Database**: Firebase Cloud Firestore
- **Authentication**: Firebase Anonymous Auth
- **Charts**: Custom Canvas Drawing
- **Weather Data**: OpenMeteo Free API

### IoT Hardware
- **Microcontroller**: Arduino MKR1010
- **Sensor**: Light Dependent Resistor (LDR)
- **Protocol**: MQTT (mqtt.cetools.org)
- **Data Format**: Percentage (0-100%)

## 📦 Dependencies

```yaml
dependencies:
  # State Management
  provider: ^6.1.4
  
  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.2
  cloud_firestore: ^5.6.6
  
  # Network
  http: ^0.13.5
  mqtt_client: ^10.8.0
  
  # Location
  geolocator: ^9.0.2
  
  # Time & Date
  intl: ^0.19.0
  timezone: ^0.9.2
  
  # UI
  cupertino_icons: ^1.0.8
  permission_handler: ^11.0.1
  flutter_dotenv: ^5.0.2
```

## 🚀 Installation

### Prerequisites

- Flutter SDK: >=3.7.2
- Dart SDK: >=3.0.0
- Android Studio / VS Code
- Arduino IDE (for hardware setup)

### Mobile App Setup

1. **Clone the repository**
   ```bash
   git clone 
   https://github.com/Youngwer/SunSync
   cd sunsync
   ```
   
2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Anonymous Authentication
   - Create Firestore database
   - Download `google-services.json` and place in `android/app/`
   - Run Firebase configuration:
     ```bash
     flutterfire configure
     ```
   
4. **Run the app**
   ```bash
   flutter run
   ```

### IoT Sensor Setup

1. **Hardware Requirements**
   - Arduino MKR1010
   - Light Dependent Resistor (LDR)
   - 10KΩ Resistor
   - Breadboard and jumper wires

2. **Circuit Diagram**
   ```
   MKR1010 [A0] ----+---- LDR ---- 3.3V
                    |
                    +---- 10KΩ ---- GND
   ```

3. **Upload Arduino Code**
   - Open `SunSync.ino` in Arduino IDE
   - Configure WiFi credentials in `arduino_secrets.h`
   - Select Arduino MKR1010 board
   - Upload the code

## 🗂 Project Structure

```
lib/
├── main.dart                    # Application entry point
├── firebase_options.dart        # Firebase configuration
│
├── models/                      # Data models
│   ├── reminder_model.dart      # Activity reminder model
│   ├── light_history_model.dart # Light data model
│   └── weather_data.dart        # Weather information model
│
├── providers/                   # State management
│   ├── weather_provider.dart    # Weather data provider
│   ├── light_provider.dart      # Light sensor data provider
│   └── reminder_provider.dart   # Reminders state management
│
├── screens/                     # App screens
│   ├── home_screen.dart         # Weather dashboard
│   ├── light_screen.dart        # Light monitoring
│   └── reminder_screen/         # Reminder management
│       ├── reminder_screen.dart
│       ├── new_reminder_screen.dart
│       └── my_reminders_screen.dart
│
├── services/                    # Business logic
│   ├── weather_service.dart     # Weather API integration
│   ├── mqtt_service.dart        # MQTT communication
│   ├── firebase_service.dart    # Firebase operations
│   ├── location_service.dart    # Geolocation
│   └── simple_notification_manager.dart
│
└── widgets/                     # Reusable UI components
    ├── weather_widget.dart      # Animated weather display
    ├── sunrise_sunset_widget.dart
    ├── simple_light_chart.dart  # Light history chart
    └── activity_suggestion_widget.dart
```

## 🔧 Configuration

### Weather API
The app uses the free OpenMeteo API for weather data. 

No API key required.

### Environment Variables
Create a `.env` file in the root directory:
```
MQTT_USER=your_mqtt_username
MQTT_PASS=your_mqtt_password
```

## 🔄 Future Improvements

- [ ] Complete quick reminder setting from activity recommendations
- [ ] Add user profile and settings
- [ ] Implement push notifications
- [ ] Add weather alerts
- [ ] Support for multiple IoT sensors
- [ ] Dark mode theme

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgments

- OpenMeteo for free weather API
- UCL CASA for educational support
- Firebase for backend services
- Flutter community for excellent packages

---

<div align="center">
  Made with ❤️ for UCL CASA0015 Module<br>
  Connected Environments | Mobile Systems & Interactions
</div>
