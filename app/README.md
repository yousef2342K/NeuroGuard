# NeuroGuard - Epilepsy Monitoring & Alert System

A comprehensive Flutter-based mobile application for real-time epilepsy monitoring and emergency response management, designed to enhance patient safety and care coordination.

## Overview

NeuroGuard is a multi-role healthcare platform that connects epilepsy patients, caregivers, and clinicians through real-time monitoring, intelligent alerting, and coordinated emergency response. The app simulates continuous vital signs monitoring (EEG, heart rate, SpO₂) and provides automated seizure detection with escalation protocols.

## Key Features

### For Patients
- **Real-time Vital Monitoring**: Live dashboard displaying EEG activity, heart rate, SpO₂, and motion data
- **Visual Health Trends**: Interactive charts showing historical vital signs
- **Emergency SOS Button**: Instant alert triggering to caregivers and medical team
- **Seizure Prediction Score**: AI-powered risk assessment display
- **Medical Reports**: Auto-generated health summaries for clinical review

### For Caregivers
- **Active Alert Management**: Real-time notifications for patient emergencies
- **Quick Response Actions**: 
  - One-tap acknowledgment
  - "I'm on my way" status updates
  - Direct call to patient
- **Patient Overview**: Live vital signs and event history access
- **Location Tracking**: Patient location during emergencies (simulated)

### For Clinicians
- **Patient Dashboard**: Manage multiple patients from one interface
- **Clinical Timeline**: Complete event history with vital sign data
- **Medical Notes**: Add clinical observations to seizure events
- **Event Classification**: Mark events as true/false positives for ML training
- **Live Vitals Monitoring**: Real-time access to patient health data

### System Features
- **Automated Escalation**: SMS/call alerts if caregiver doesn't respond within timeout
- **Multi-role Authentication**: Separate interfaces for patients, caregivers, clinicians, and admins
- **Telemetry Simulation**: Realistic vital signs generation for demo/testing
- **Offline-first Architecture**: Works without external dependencies

## Technical Stack

- **Framework**: Flutter 3.x (Dart)
- **State Management**: ValueNotifier pattern
- **Architecture**: Clean separation with modular file structure
- **UI Design**: Material Design 3 with custom gradients
- **Charts**: Custom Canvas-based sparkline visualizations
- **No External Packages**: Self-contained for easy deployment

## Project Structure


## Demo Accounts

- **Patient**: `sara@example.com` / `password123`
- **Caregiver**: `mona@example.com` / `password123`
- **Clinician**: `dr.ali@clinic.com` / `password123`
- **Admin**: `admin@neuroguard.com` / `password123`

## Installation & Setup

1. Clone the repository
2. Ensure Flutter SDK is installed (3.0+)
3. Run `flutter pub get` (no external dependencies required)
4. Run `flutter run` or test on FlutLab/online IDE

## Use Cases

- **Epilepsy patient monitoring** with family/caregiver coordination
- **Clinical research** for seizure detection algorithms
- **Healthcare demonstrations** and medical training
- **IoT wearable integration** (ready for real device connectivity)
- **Emergency response protocol** testing

## Future Enhancements

- Firebase backend integration for real data persistence
- BLE connectivity for actual EEG/vital sign devices
- Google Maps integration for real-time location tracking
- Push notifications via FCM
- Machine learning model integration for seizure prediction
- Multi-language support
- HIPAA compliance features

## Note

This is a **demonstration/prototype** application with simulated telemetry and mock services. For production use, replace mock services with:
- Real Bluetooth/BLE device connectivity
- Firebase/backend API integration
- Actual notification services
- HIPAA-compliant data storage
- Medical device certification compliance


