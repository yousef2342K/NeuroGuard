/*
 * NeuroGuard - Medical monitoring system
 * ESP32 + Firebase RTDB integration
 * Works with mobile app
 */

// Libraries
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h>
#include <time.h>
#include <SPIFFS.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// Function declarations
void initializeSensors();
void updateAllSensors();
void displaySensorData();
void checkForAlerts();
void sendDataToRTDB();
void reconnectSystems();
void createPatientDocument();
void updateLatestReadings();
void updatePatientStats();
void sendAlert(String message);
void sendPushNotificationTrigger(String message);
void sendDeviceStatus(String status);
String getTimestamp();
String getHeartRateStatus();
String getSpO2Status();
String getSeverityLevel();
String calculateActivityLevel();
void tokenStatusCallback(TokenInfo info);
void printStartupMessage();

// WiFi config
const char *WIFI_SSID = "Mina1";
const char *WIFI_PASSWORD = "M01281691888?";

// Firebase setup
#define API_KEY "AIzaSyCLt5tygvSlsL_XEiU1-HUiUI0T3Yx5nBQ"
#define FIREBASE_PROJECT_ID "neuroguard-82e63"
#define DATABASE_URL "https://neuroguard-82e63-default-rtdb.firebaseio.com/" // <-- update if your RTDB URL is different
#define USER_EMAIL "ms2@neuroguard.com"
#define USER_PASSWORD "menasaad1"

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Global vars
unsigned long lastUpdate = 0;
unsigned long lastRTDBUpdate = 0;
const unsigned long updateInterval = 2000; // 2 sec update
const unsigned long rtdbInterval = 10000;  // 10 sec upload

// Sensor data
int heartRate = 75;
int spO2 = 98;
float accelX = 0.0, accelY = 0.0, accelZ = 0.0;
float gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;
float eegSignal = 0.0;
float emgSignal = 0.0;

// Alert stuff
bool alertSent = false;
unsigned long lastAlertTime = 0;
const unsigned long alertCooldown = 15000;

// Database vars
bool rtdbConnected = false;
String deviceID = "ESP32_NeuroGuard_001";
String patientID = "patient_001";
int dataCounter = 0;
String sessionID = "";

// Setup
void setup()
{
  Serial.begin(115200);
  delay(2000);
  printStartupMessage();
  randomSeed(analogRead(0));

  // File system init
  if (!SPIFFS.begin(true))
  {
    Serial.println("Failed to initialize SPIFFS");
    // Stop if SPIFFS fails
    return;
  }

  // Generate session ID
  sessionID = deviceID + "_" + String(millis());

  // Setup everything
  initializeSensors();
  connectToWiFi();
  initializeFirestore();

  // Time setup
  configTime(3 * 3600, 0, "pool.ntp.org", "time.nist.gov");

  Serial.println("System ready");
  Serial.println("Mobile app connection ready");
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

// Main loop
void loop()
{
  unsigned long currentTime = millis();

  // Read sensors
  if (currentTime - lastUpdate >= updateInterval)
  {
    updateAllSensors();
    displaySensorData();
    checkForAlerts();
    lastUpdate = currentTime;
  }

  // Upload data
  if (currentTime - lastRTDBUpdate >= rtdbInterval)
  {
    if (WiFi.status() == WL_CONNECTED && Firebase.ready())
    {
      sendDataToRTDB();
    }
    else
    {
      reconnectSystems();
    }
    lastRTDBUpdate = currentTime;
  }

  delay(100);
}

// Startup banner
void printStartupMessage()
{
  Serial.println("\n╔══════════════════════════════════════════════════╗");
  Serial.println("║              NeuroGuard v1.0              ║");
  Serial.println("║         Medical Monitoring System         ║");
  Serial.println("║            ESP32 + Firebase              ║");
  Serial.println("╚══════════════════════════════════════════════════╝");
  Serial.println();
}

// Connect to WiFi
void connectToWiFi()
{
  Serial.println("WiFi connecting...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20)
  {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED)
  {
    Serial.println("\nWiFi connected!");
    Serial.println("   IP Address: " + WiFi.localIP().toString());
    Serial.println("   Signal: " + String(WiFi.RSSI()) + " dBm");
  }
  else
  {
    Serial.println("\nWiFi failed");
  }
}

// Firebase init
void initializeFirestore()
{
  Serial.println("Firebase setup...");

  // Firebase config
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL; // for Realtime Database
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.token_status_callback = tokenStatusCallback;

  // Start Firebase
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("⏳ Firebase auth...");
  Serial.println("🔎 Token debug: token request may take a few seconds...");
}

// Create patient record
void createPatientDocument()
{
  Serial.println("Patient data...");

  FirebaseJson patientData;
  patientData.set("patientID", patientID);
  patientData.set("deviceID", deviceID);
  patientData.set("patientName", "Test Patient");
  patientData.set("age", 35);
  patientData.set("gender", "male");
  patientData.set("createdAt", getTimestamp());
  patientData.set("lastActive", getTimestamp());
  patientData.set("status", "active");
  patientData.set("deviceInfo/model", "ESP32");
  patientData.set("deviceInfo/version", "1.0.0");
  patientData.set("deviceInfo/ipAddress", WiFi.localIP().toString());

  String nodePath = "/patients/" + patientID;

  if (Firebase.RTDB.setJSON(&fbdo, nodePath.c_str(), &patientData))
  {
    Serial.println("Patient data saved");
  }
  else
  {
    Serial.println("Patient data failed: " + fbdo.errorReason());
  }
}

// Sensor setup
void initializeSensors()
{
  Serial.println("Sensors...");

  heartRate = random(60, 100);
  spO2 = random(95, 100);
  accelX = random(-100, 100) / 100.0;
  accelY = random(-100, 100) / 100.0;
  accelZ = random(80, 120) / 100.0;
  eegSignal = random(-50, 50) / 1000.0;
  emgSignal = random(0, 100) / 1000.0;

  Serial.println("   Ready");
  delay(1000);
}

// Read sensors
void updateAllSensors()
{
  // MAX30102
  int hrChange = random(-5, 6);
  heartRate += hrChange;
  heartRate = constrain(heartRate, 50, 150);

  int spo2Change = random(-2, 3);
  spO2 += spo2Change;
  spO2 = constrain(spO2, 85, 100);

  // MPU6050
  accelX = random(-200, 200) / 100.0;
  accelY = random(-200, 200) / 100.0;
  accelZ = random(80, 120) / 100.0;
  gyroX = random(-50, 50) / 10.0;
  gyroY = random(-50, 50) / 10.0;
  gyroZ = random(-50, 50) / 10.0;

  // BioAmp
  eegSignal = random(-100, 100) / 1000.0;
  emgSignal = random(0, 500) / 1000.0;
}

// Send to database
void sendDataToRTDB()
{
  Serial.println("\nDatabase upload...");

  // Build data packet
  FirebaseJson sensorData;

  // Basic info
  sensorData.set("deviceID", deviceID);
  sensorData.set("patientID", patientID);
  sensorData.set("sessionID", sessionID);
  sensorData.set("timestamp", getTimestamp());
  sensorData.set("recordID", dataCounter++);
  sensorData.set("location", "home"); // Can be changed as needed

  // Vitals
  sensorData.set("vitalSigns/heartRate", heartRate);
  sensorData.set("vitalSigns/spO2", spO2);
  sensorData.set("vitalSigns/heartRateStatus", getHeartRateStatus());
  sensorData.set("vitalSigns/spO2Status", getSpO2Status());

  // Movement
  sensorData.set("motion/accelerometer/x", round(accelX * 100) / 100.0);
  sensorData.set("motion/accelerometer/y", round(accelY * 100) / 100.0);
  sensorData.set("motion/accelerometer/z", round(accelZ * 100) / 100.0);
  sensorData.set("motion/gyroscope/x", round(gyroX * 10) / 10.0);
  sensorData.set("motion/gyroscope/y", round(gyroY * 10) / 10.0);
  sensorData.set("motion/gyroscope/z", round(gyroZ * 10) / 10.0);
  sensorData.set("motion/activityLevel", calculateActivityLevel());

  // Bio signals
  sensorData.set("bioSignals/eeg", round(eegSignal * 1000 * 10) / 10.0);
  sensorData.set("bioSignals/emg", round(emgSignal * 1000 * 10) / 10.0);
  sensorData.set("bioSignals/eegStatus", "normal");
  sensorData.set("bioSignals/emgStatus", "normal");

  // System info
  sensorData.set("systemInfo/freeHeap", ESP.getFreeHeap());
  sensorData.set("systemInfo/uptime", millis() / 1000);
  sensorData.set("systemInfo/wifiRSSI", WiFi.RSSI());
  sensorData.set("systemInfo/batteryLevel", random(70, 100)); // Simulate battery

  // Alert check
  sensorData.set("alertStatus", (heartRate > 120 || spO2 < 90) ? "warning" : "normal");

  // Upload to database
  String nodePath = "/medical_data/" + patientID + "_" + String(dataCounter);

  if (Firebase.RTDB.setJSON(&fbdo, nodePath.c_str(), &sensorData))
  {
    Serial.println("Data uploaded!");
    Serial.println("   Node: " + nodePath);

    // Update latest
    updateLatestReadings();

    // Update patient stats
    updatePatientStats();
  }
  else
  {
    Serial.println("Upload failed:");
    Serial.println("   Error: " + fbdo.errorReason());
  }
}

// Update latest data
void updateLatestReadings()
{
  FirebaseJson latestData;

  latestData.set("patientID", patientID);
  latestData.set("deviceID", deviceID);
  latestData.set("lastUpdate", getTimestamp());
  latestData.set("heartRate", heartRate);
  latestData.set("spO2", spO2);
  latestData.set("eeg", round(eegSignal * 1000 * 10) / 10.0);
  latestData.set("emg", round(emgSignal * 1000 * 10) / 10.0);
  latestData.set("alertStatus", (heartRate > 120 || spO2 < 90) ? "warning" : "normal");
  latestData.set("connectionStatus", "online");
  latestData.set("batteryLevel", random(70, 100));

  String latestPath = "/latest_readings/" + patientID;
  if (Firebase.RTDB.updateNode(&fbdo, latestPath.c_str(), &latestData))
  {
    Serial.println("Latest data updated");
  }
  else
  {
    Serial.println("Latest update failed: " + fbdo.errorReason());
  }
}

// Update stats
void updatePatientStats()
{
  FirebaseJson statsData;

  // Simple stats calc
  static int totalReadings = 0;
  static int totalAlerts = 0;
  totalReadings++;

  if (heartRate > 120 || spO2 < 90)
  {
    totalAlerts++;
  }

  statsData.set("totalReadings", totalReadings);
  statsData.set("totalAlerts", totalAlerts);
  statsData.set("lastReading", getTimestamp());
  statsData.set("avgHeartRate", heartRate); // Simplified for testing
  statsData.set("avgSpO2", spO2);
  statsData.set("deviceUptime", millis() / 1000);

  String statsPath = "/patient_stats/" + patientID;
  if (Firebase.RTDB.updateNode(&fbdo, statsPath.c_str(), &statsData))
  {
    Serial.println("Stats updated");
  }
  else
  {
    Serial.println("Stats failed: " + fbdo.errorReason());
  }
}

// Send alerts
void sendAlert(String message)
{
  Serial.println("\nMEDICAL ALERT!");
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

  // Send alert
  FirebaseJson alertData;

  alertData.set("alertID", deviceID + "_" + String(millis()));
  alertData.set("patientID", patientID);
  alertData.set("deviceID", deviceID);
  alertData.set("alertType", "medical");
  alertData.set("severity", getSeverityLevel());
  alertData.set("message", message);
  alertData.set("timestamp", getTimestamp());
  alertData.set("status", "active");
  alertData.set("acknowledged", false);
  alertData.set("responseRequired", true);

  // Current data
  alertData.set("currentReadings/heartRate", heartRate);
  alertData.set("currentReadings/spO2", spO2);
  alertData.set("currentReadings/eeg", round(eegSignal * 1000 * 10) / 10.0);
  alertData.set("currentReadings/emg", round(emgSignal * 1000 * 10) / 10.0);

  // Location info
  alertData.set("location", "home");
  alertData.set("emergencyContact", "+966501234567");
  alertData.set("doctorContact", "+966509876543");

  String alertPath = "alerts/" + deviceID + "_" + String(millis());
  String alertNode = "/alerts/" + deviceID + "_" + String(millis());

  if (Firebase.RTDB.setJSON(&fbdo, alertNode.c_str(), &alertData))
  {
    Serial.println("Alert sent!");
    Serial.println("   App notified");
    Serial.println("   Emergency contacted");

    // Push notification (app handles this)
    sendPushNotificationTrigger(message);
  }
  else
  {
    Serial.println("Alert failed: " + fbdo.errorReason());
  }

  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

// Push notification
void sendPushNotificationTrigger(String message)
{
  FirebaseJson notificationData;

  notificationData.set("patientID", patientID);
  notificationData.set("message", message);
  notificationData.set("type", "medical_alert");
  notificationData.set("priority", "high");
  notificationData.set("timestamp", getTimestamp());
  notificationData.set("action", "immediate_attention");

  String notificationNode = "/push_notifications/" + String(millis());
  Firebase.RTDB.setJSON(&fbdo, notificationNode.c_str(), &notificationData);
}

// Device status
void sendDeviceStatus(String status)
{
  FirebaseJson statusData;

  statusData.set("deviceID", deviceID);
  statusData.set("patientID", patientID);
  statusData.set("status", status);
  statusData.set("timestamp", getTimestamp());
  statusData.set("ipAddress", WiFi.localIP().toString());
  statusData.set("signalStrength", WiFi.RSSI());
  statusData.set("freeMemory", ESP.getFreeHeap());
  statusData.set("uptime", millis() / 1000);

  String statusPath = "/device_status/" + deviceID;
  if (Firebase.RTDB.updateNode(&fbdo, statusPath.c_str(), &statusData))
  {
    Serial.println("Device status updated");
  }
  else
  {
    Serial.println("Status update failed: " + fbdo.errorReason());
  }
}

// Helper functions
String getTimestamp()
{
  time_t now;
  time(&now);
  return String(now);
}

String getHeartRateStatus()
{
  if (heartRate > 120)
    return "high";
  else if (heartRate < 60)
    return "low";
  else
    return "normal";
}

String getSpO2Status()
{
  if (spO2 < 90)
    return "low";
  else if (spO2 < 95)
    return "below_normal";
  else
    return "normal";
}

String getSeverityLevel()
{
  if (heartRate > 140 || spO2 < 85)
    return "critical";
  else if (heartRate > 120 || spO2 < 90)
    return "high";
  else
    return "medium";
}

String calculateActivityLevel()
{
  float totalAccel = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  if (totalAccel > 1.5)
    return "high";
  else if (totalAccel > 1.1)
    return "medium";
  else
    return "low";
}

void checkForAlerts()
{
  bool needAlert = false;
  String alertMessage = "";

  if (heartRate > 120)
  {
    needAlert = true;
    alertMessage += "High HR: " + String(heartRate) + " BPM ";
  }

  if (spO2 < 90)
  {
    needAlert = true;
    alertMessage += "Low O2: " + String(spO2) + "% ";
  }

  if (needAlert && (millis() - lastAlertTime > alertCooldown))
  {
    sendAlert(alertMessage);
    lastAlertTime = millis();
  }
}

void reconnectSystems()
{
  Serial.println("Retry...");

  if (WiFi.status() != WL_CONNECTED)
  {
    Serial.println("WiFi retry...");
    WiFi.reconnect();
    delay(5000);
  }

  if (!Firebase.ready())
  {
    Serial.println("Firebase retry...");
    Firebase.begin(&config, &auth);
  }
}

void displaySensorData()
{
  Serial.println("\nData - " + String(millis() / 1000) + "s");
  Serial.println("HR: " + String(heartRate) + " | SpO2: " + String(spO2) + "% | EEG: " + String(eegSignal * 1000, 1) + "μV");
  Serial.println("WiFi: " + String(WiFi.status() == WL_CONNECTED ? "Connected" : "Disconnected") +
                 " | RTDB: " + String(Firebase.ready() ? "Connected" : "Disconnected"));
}
