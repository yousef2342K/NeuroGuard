📖 NeuroGuard ESP32 Firestore Integration

This project demonstrates a wearable seizure-monitoring system prototype running on ESP32, connected to Google Firestore for real-time data storage, monitoring, and mobile app integration.

It simulates readings from biomedical sensors such as:

🫀 MAX30102 – Heart Rate (HR) & SpO₂

🧠 BioAmp – EEG & EMG

🌀 MPU6050 – Accelerometer & Gyroscope

and sends them periodically to Firestore for analysis, visualization, and alerting.

🚀 Features

✅ WiFi Connectivity – Secure connection to your WiFi network
✅ Firestore Integration – Stores medical data in Firestore collections:

patients/ → patient metadata

medical_data/ → periodic sensor readings

latest_readings/ → most recent vitals

patient_stats/ → aggregate statistics

alerts/ → triggered emergency alerts

device_status/ → device online/offline state

push_notifications/ → trigger mobile push alerts

✅ Simulated Sensor Data – Randomized HR, SpO₂, EEG, EMG, motion signals
✅ Real-time Alerts – Automatic detection of abnormal HR/SpO₂
✅ Push Notifications – Triggers Firestore entries for mobile app notifications
✅ Arabic/English Console Logs – Clear serial monitor messages
✅ Fault Recovery – Auto-reconnect to WiFi & Firestore if connection drops

🛠 Hardware Requirements

ESP32 Dev Board (any variant with WiFi)

(Optional for real sensors)

MAX30102 (Heart Rate & SpO₂)

MPU6050 (Accelerometer/Gyroscope)

BioAmp EXG (EEG/EMG signals)


⚙️ Setup Instructions
1️⃣ Install Arduino IDE & ESP32 Support

Install Arduino IDE

Add ESP32 board support:

In File → Preferences, paste in:

https://dl.espressif.com/dl/package_esp32_index.json


Install ESP32 by Espressif Systems via Boards Manager

2️⃣ Install Required Libraries

Install the following via Arduino Library Manager (Sketch → Include Library → Manage Libraries):

Firebase ESP Client by Mobizt

ArduinoJson

WiFi (included with ESP32 core)

3️⃣ Configure WiFi & Firebase Credentials

Edit these lines in your code:

// WiFi
const char* WIFI_SSID = "YOUR_WIFI_NAME";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// Firebase
#define API_KEY       "YOUR_FIREBASE_API_KEY"
#define PROJECT_ID    "your-project-id"
#define USER_EMAIL    "your-firebase-user-email"
#define USER_PASSWORD "your-firebase-user-password"


⚠️ Make sure your Firebase project has Firestore enabled and your email/password is registered as a user.

4️⃣ Upload to ESP32

Select ESP32 Dev Module in Arduino IDE

Connect your board via USB

Upload the sketch

5️⃣ Monitor Output

Open Serial Monitor at 115200 baud to view logs:

Connection status

Sensor readings

Alerts

Firestore update confirmations

🔔 Alerts & Notifications

HR > 120 BPM → triggers a warning alert

SpO₂ < 90% → triggers a warning alert

HR > 140 BPM or SpO₂ < 85% → triggers a critical alert

Alerts are pushed to Firestore under alerts/ and mirrored to push_notifications/ for mobile apps.

✅ Successfully connected to WiFi!
🔥 Initializing Firestore Database...
✅ Successfully connected to Firestore!
📊 Sensor Readings - 20s
🫀 HR: 78 | 🫁 SpO₂: 98% | 🧠 EEG: 12.3 μV
🌐 WiFi: ✅ | 🔥 Firestore: ✅
🔥 Medical data sent successfully!
🚨 Urgent Medical Alert! 🚨
⚠️ High heart rate detected: 135 BPM



📌 Future Improvements

Replace simulated signals with real sensor drivers (MAX30102, MPU6050, BioAmp)

Add ML inference on ESP32 (TensorFlow Lite Micro) for seizure prediction

Expand alerts to include fall detection, arrhythmias, and multi-patient monitoring