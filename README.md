# Plan-S Mobile 🛰️

Satellite tracking and pass prediction mobile application built with Flutter.

## Features

- 🔐 User authentication (admin & user roles)
- 🛰️ Satellite tracking with real-time positioning
- 🌍 Interactive 3D globe visualization
- 📡 Pass prediction calculations
- 🔄 Automatic TLE updates from SpaceTrack
- 📊 Satellite information and orbit data

## Architecture

- **Design Pattern:** Atomic Design + Clean Architecture
- **State Management:** Provider
- **API Integration:** REST API with WebSocket support

## Project Structure

```
lib/
├── components/
│   ├── atoms/          # Basic UI elements
│   ├── molecules/      # Component groups
│   ├── organisms/      # Complex components
│   └── templates/      # Page layouts
├── screens/            # Complete pages
├── providers/          # State management
├── services/           # API services
├── models/             # Data models
└── core/               # Core utilities
```

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [Atomic Design Structure](docs/ATOMIC_DESIGN_STRUCTURE.md)
- [Templates Documentation](docs/TEMPLATES_DOCUMENTATION.md)
- [API Integration](docs/INTEGRATION_GUIDE.md)

---

**Made with Flutter** 💙
