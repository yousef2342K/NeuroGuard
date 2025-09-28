/*
 * NeuroGuard Firestore Integration - محاكاة نظام مراقبة طبية مع Firestore
 * ESP32 Firmware للاتصال بـ Firestore Database
 * متوافق مع تطبيقات الجوال
 */

// ============ المكتبات المطلوبة ============
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h>
#include <time.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ============ إعدادات WiFi ============
const char* WIFI_SSID = "Mina1";
const char* WIFI_PASSWORD = "M01281691888";

// ============ إعدادات Firebase ============
#define API_KEY "AIzaSyB7ZoWbyTEsmB396UAB5pQs2uYxdw_Vo3c"
#define PROJECT_ID "neuroguard-82e63d"
#define USER_EMAIL "minayougr@gmail.com"
#define USER_PASSWORD "Minayou123?"

// ============ كائنات Firebase ============
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ============ تعريف المتغيرات العامة ============
unsigned long lastUpdate = 0;
unsigned long lastFirestoreUpdate = 0;
const unsigned long updateInterval = 2000; // تحديث كل 2 ثانية
const unsigned long firestoreInterval = 10000; // إرسال لـ Firestore كل 10 ثواني

// ============ متغيرات الحساسات ============
int heartRate = 75;
int spO2 = 98;
float accelX = 0.0, accelY = 0.0, accelZ = 0.0;
float gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;
float eegSignal = 0.0;
float emgSignal = 0.0;

// ============ متغيرات التنبيهات ============
bool alertSent = false;
unsigned long lastAlertTime = 0;
const unsigned long alertCooldown = 15000;

// ============ متغيرات Firestore ============
bool firestoreConnected = false;
const String deviceID = "ESP32_NeuroGuard_001";
const String patientID = "patient_001";
int dataCounter = 0;
String sessionID = "";

// ============ إعداد النظام الأولي ============
void setup() {
  Serial.begin(115200);
  delay(2000);

  printStartupMessage();
  randomSeed(analogRead(0));

  // إنشاء Session ID فريد
  sessionID = deviceID + "_" + String(millis());

  initializeSensors();
  connectToWiFi();
  initializeFirestore();

  // تهيئة الوقت
  configTime(3 * 3600, 0, "pool.ntp.org", "time.nist.gov");

  Serial.println("✅ جميع الأنظمة جاهزة للعمل");
  Serial.println("📱 جاهز للاتصال مع التطبيق");
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

// ============ الحلقة الرئيسية ============
void loop() {
  unsigned long currentTime = millis();

  // تحديث قراءات الحساسات
  if (currentTime - lastUpdate >= updateInterval) {
    updateAllSensors();
    displaySensorData();
    checkForAlerts();
    lastUpdate = currentTime;
  }

  // إرسال البيانات لـ Firestore
  if (currentTime - lastFirestoreUpdate >= firestoreInterval) {
    if (WiFi.status() == WL_CONNECTED && Firebase.ready()) {
      sendDataToFirestore();
    } else {
      reconnectSystems();
    }
    lastFirestoreUpdate = currentTime;
  }

  delay(100);
}

// ============ طباعة رسالة البداية ============
void printStartupMessage() {
  Serial.println("\n╔══════════════════════════════════════════════════╗");
  Serial.println("║ 🔥 NeuroGuard Firestore Edition 🔥 ║");
  Serial.println("║ نظام المراقبة العصبية ║");
  Serial.println("║ ESP32 + Firestore + Mobile App ║");
  Serial.println("╚══════════════════════════════════════════════════╝");
  Serial.println();
}

// ============ الاتصال بـ WiFi ============
void connectToWiFi() {
  Serial.println("🌐 الاتصال بشبكة WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ تم الاتصال بـ WiFi بنجاح!");
    Serial.println(" 📡 IP Address: " + WiFi.localIP().toString());
    Serial.println(" 📶 Signal: " + String(WiFi.RSSI()) + " dBm");
  } else {
    Serial.println("\n❌ فشل الاتصال بـ WiFi");
  }
}

// ============ تهيئة Firestore ============
void initializeFirestore() {
  Serial.println("🔥 تهيئة Firestore Database...");

  // إعداد Firebase Config
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // إعداد callback functions
  config.token_status_callback = tokenStatusCallback;

  // بدء Firebase
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("⏳ انتظار المصادقة...");

  // انتظار المصادقة
  unsigned long ms = millis();
  while (!Firebase.ready() && (millis() - ms < 30000)) {
    delay(300);
    Serial.print(".");
  }

  if (Firebase.ready()) {
    firestoreConnected = true;
    Serial.println("\n✅ تم الاتصال بـ Firestore بنجاح!");
    Serial.println(" 🆔 Project ID: " + String(PROJECT_ID));
    Serial.println(" 👤 User: " + String(USER_EMAIL));

    // إرسال رسالة بداية التشغيل
    sendDeviceStatus("online");
    createPatientDocument();
  } else {
    firestoreConnected = false;
    Serial.println("\n❌ فشل الاتصال بـ Firestore");
    Serial.println(" 🔍 تحقق من: API Key, Project ID, User Credentials");
  }
}

// ============ إنشاء مستند المريض ============
void createPatientDocument() {
  Serial.println("👤 إنشاء/تحديث بيانات المريض...");

  FirebaseJson patientData;
  patientData.set("patientID", patientID);
  patientData.set("deviceID", deviceID);
  patientData.set("patientName", "مريض تجريبي");
  patientData.set("age", 35);
  patientData.set("gender", "male");
  patientData.set("createdAt", getTimestamp());
  patientData.set("lastActive", getTimestamp());
  patientData.set("status", "active");
  patientData.set("deviceInfo/model", "ESP32");
  patientData.set("deviceInfo/version", "1.0.0");
  patientData.set("deviceInfo/ipAddress", WiFi.localIP().toString());

  String documentPath = "patients/" + patientID;

  if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", documentPath, patientData.raw(), "patientID,deviceID,lastActive,status,deviceInfo")) {
    Serial.println("✅ تم إنشاء/تحديث بيانات المريض");
  } else {
    Serial.println("❌ فشل إنشاء بيانات المريض: " + fbdo.errorReason());
  }
}

// ============ تهيئة الحساسات ============
void initializeSensors() {
  Serial.println("🔧 تهيئة الحساسات...");

  heartRate = random(60, 100);
  spO2 = random(95, 100);
  accelX = random(-100, 100) / 100.0;
  accelY = random(-100, 100) / 100.0;
  accelZ = random(80, 120) / 100.0;
  eegSignal = random(-50, 50) / 1000.0;
  emgSignal = random(0, 100) / 1000.0;

  Serial.println(" ✓ جميع الحساسات جاهزة");
  delay(1000);
}

// ============ تحديث الحساسات ============
void updateAllSensors() {
  // Simulated MAX30102 (HR/SpO2)
  int hrChange = random(-5, 6);
  heartRate += hrChange;
  heartRate = constrain(heartRate, 50, 150);

  int spo2Change = random(-2, 3);
  spO2 += spo2Change;
  spO2 = constrain(spO2, 85, 100);

  // Simulated MPU6050 (Accelerometer/Gyroscope)
  accelX = random(-200, 200) / 100.0;
  accelY = random(-200, 200) / 100.0;
  accelZ = random(80, 120) / 100.0;
  gyroX = random(-50, 50) / 10.0;
  gyroY = random(-50, 50) / 10.0;
  gyroZ = random(-50, 50) / 10.0;

  // Simulated BioAmp (EEG/EMG)
  eegSignal = random(-100, 100) / 1000.0;
  emgSignal = random(0, 500) / 1000.0;
}

// ============ إرسال البيانات إلى Firestore ============
void sendDataToFirestore() {
  Serial.println("\n🔥 إرسال البيانات إلى Firestore...");

  FirebaseJson sensorData;

  // معلومات أساسية
  sensorData.set("deviceID", deviceID);
  sensorData.set("patientID", patientID);
  sensorData.set("sessionID", sessionID);
  sensorData.set("timestamp", getTimestamp());
  sensorData.set("recordID", dataCounter++);
  sensorData.set("location", "home");

  // العلامات الحيوية
  sensorData.set("vitalSigns/heartRate", heartRate);
  sensorData.set("vitalSigns/spO2", spO2);
  sensorData.set("vitalSigns/heartRateStatus", getHeartRateStatus());
  sensorData.set("vitalSigns/spO2Status", getSpO2Status());

  // بيانات الحركة
  sensorData.set("motion/accelerometer/x", round(accelX * 100) / 100.0);
  sensorData.set("motion/accelerometer/y", round(accelY * 100) / 100.0);
  sensorData.set("motion/accelerometer/z", round(accelZ * 100) / 100.0);
  sensorData.set("motion/gyroscope/x", round(gyroX * 10) / 10.0);
  sensorData.set("motion/gyroscope/y", round(gyroY * 10) / 10.0);
  sensorData.set("motion/gyroscope/z", round(gyroZ * 10) / 10.0);
  sensorData.set("motion/activityLevel", calculateActivityLevel());

  // الإشارات الحيوية العصبية
  sensorData.set("bioSignals/eeg", round(eegSignal * 1000 * 10) / 10.0);
  sensorData.set("bioSignals/emg", round(emgSignal * 1000 * 10) / 10.0);
  sensorData.set("bioSignals/eegStatus", "normal"); // Add ML-based status later
  sensorData.set("bioSignals/emgStatus", "normal");

  // معلومات النظام
  sensorData.set("systemInfo/freeHeap", ESP.getFreeHeap());
  sensorData.set("systemInfo/uptime", millis() / 1000);
  sensorData.set("systemInfo/wifiRSSI", WiFi.RSSI());
  sensorData.set("systemInfo/batteryLevel", random(70, 100));

  // حالة التنبيهات
  sensorData.set("alertStatus", (heartRate > 120 || spO2 < 90) ? "warning" : "normal");

  // إرسال إلى collection المناسب
  String documentPath = "medical_data/" + patientID + "_" + String(dataCounter);

  if (Firebase.Firestore.createDocument(&fbdo, PROJECT_ID, "", documentPath, sensorData.raw())) {
    Serial.println("✅ تم إرسال البيانات الطبية بنجاح!");
    Serial.println(" 📄 Document: " + documentPath);

    // تحديث آخر القراءات
    updateLatestReadings();

    // تحديث إحصائيات المريض
    updatePatientStats();
  } else {
    Serial.println("❌ فشل إرسال البيانات:");
    Serial.println(" 🔍 Error: " + fbdo.errorReason());
  }
}

// ============ تحديث آخر القراءات ============
void updateLatestReadings() {
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

  String latestPath = "latest_readings/" + patientID;
  if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", latestPath, latestData.raw(), "lastUpdate,heartRate,spO2,alertStatus,connectionStatus")) {
    Serial.println("✅ تم تحديث آخر القراءات");
  }
}

// ============ تحديث إحصائيات المريض ============
void updatePatientStats() {
  static int totalReadings = 0;
  static int totalAlerts = 0;
  totalReadings++;

  FirebaseJson statsData;
  statsData.set("totalReadings", totalReadings);
  statsData.set("totalAlerts", totalAlerts + ((heartRate > 120 || spO2 < 90) ? 1 : 0));
  statsData.set("lastReading", getTimestamp());
  statsData.set("avgHeartRate", heartRate); // Simplified; use running average in production
  statsData.set("avgSpO2", spO2);
  statsData.set("deviceUptime", millis() / 1000);

  String statsPath = "patient_stats/" + patientID;
  if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", statsPath, statsData.raw(), "totalReadings,totalAlerts,lastReading")) {
    Serial.println("✅ تم تحديث إحصائيات المريض");
  }
}

// ============ إرسال التنبيهات ============
void sendAlert(String message) {
  Serial.println("\n🚨 تنبيه طبي عاجل! 🚨");
  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

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
  alertData.set("currentReadings/heartRate", heartRate);
  alertData.set("currentReadings/spO2", spO2);
  alertData.set("currentReadings/eeg", round(eegSignal * 1000 * 10) / 10.0);
  alertData.set("currentReadings/emg", round(emgSignal * 1000 * 10) / 10.0);
  alertData.set("location", "home");
  alertData.set("emergencyContact", "+966501234567");
  alertData.set("doctorContact", "+966509876543");

  String alertPath = "alerts/" + deviceID + "_" + String(millis());
  if (Firebase.Firestore.createDocument(&fbdo, PROJECT_ID, "", alertPath, alertData.raw())) {
    Serial.println("🔥 تم إرسال التنبيه إلى Firestore!");
    Serial.println(" 📱 التطبيق سيستقبل التنبيه فوراً");
    sendPushNotificationTrigger(message);
  } else {
    Serial.println("❌ فشل إرسال التنبيه: " + fbdo.errorReason());
  }

  Serial.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

// ============ تفعيل Push Notification ============
void sendPushNotificationTrigger(String message) {
  FirebaseJson notificationData;
  notificationData.set("patientID", patientID);
  notificationData.set("message", message);
  notificationData.set("type", "medical_alert");
  notificationData.set("priority", "high");
  notificationData.set("timestamp", getTimestamp());
  notificationData.set("action", "immediate_attention");

  String notificationPath = "push_notifications/" + String(millis());
  if (Firebase.Firestore.createDocument(&fbdo, PROJECT_ID, "", notificationPath, notificationData.raw())) {
    Serial.println("📤 تم إرسال إشعار دفع!");
  }
}

// ============ إرسال حالة الجهاز ============
void sendDeviceStatus(String status) {
  FirebaseJson statusData;
  statusData.set("deviceID", deviceID);
  statusData.set("patientID", patientID);
  statusData.set("status", status);
  statusData.set("timestamp", getTimestamp());
  statusData.set("ipAddress", WiFi.localIP().toString());
  statusData.set("signalStrength", WiFi.RSSI());
  statusData.set("freeMemory", ESP.getFreeHeap());
  statusData.set("uptime", millis() / 1000);

  String statusPath = "device_status/" + deviceID;
  if (Firebase.Firestore.patchDocument(&fbdo, PROJECT_ID, "", statusPath, statusData.raw(), "status,timestamp,signalStrength,freeMemory,uptime")) {
    Serial.println("✅ تم تحديث حالة الجهاز");
  }
}

// ============ وظائف مساعدة ============
String getTimestamp() {
  time_t now;
  time(&now);
  return String(now);
}

String getHeartRateStatus() {
  if (heartRate > 120) return "high";
  else if (heartRate < 60) return "low";
  else return "normal";
}

String getSpO2Status() {
  if (spO2 < 90) return "low";
  else if (spO2 < 95) return "below_normal";
  else return "normal";
}

String getSeverityLevel() {
  if (heartRate > 140 || spO2 < 85) return "critical";
  else if (heartRate > 120 || spO2 < 90) return "high";
  else return "medium";
}

String calculateActivityLevel() {
  float totalAccel = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  if (totalAccel > 1.5) return "high";
  else if (totalAccel > 1.1) return "medium";
  else return "low";
}

void checkForAlerts() {
  bool needAlert = false;
  String alertMessage = "";

  if (heartRate > 120) {
    needAlert = true;
    alertMessage += "⚠️ معدل ضربات القلب مرتفع: " + String(heartRate) + " BPM ";
  }
  if (spO2 < 90) {
    needAlert = true;
    alertMessage += "⚠️ نسبة الأكسجين منخفضة: " + String(spO2) + "% ";
  }

  if (needAlert && (millis() - lastAlertTime > alertCooldown)) {
    sendAlert(alertMessage);
    lastAlertTime = millis();
  }
}

void reconnectSystems() {
  Serial.println("🔄 إعادة الاتصال...");
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("📡 إعادة الاتصال بـ WiFi...");
    WiFi.reconnect();
    delay(5000);
  }
  if (!Firebase.ready()) {
    Serial.println("🔥 إعادة الاتصال بـ Firestore...");
    Firebase.begin(&config, &auth);
  }
}

void displaySensorData() {
  Serial.println("\n📊 قراءات الحساسات - " + String(millis() / 1000) + "s");
  Serial.println("🫀 HR: " + String(heartRate) + " | 🫁 SpO2: " + String(spO2) + "% | 🧠 EEG: " + String(eegSignal * 1000, 1) + "μV");
  Serial.println("🌐 WiFi: " + String(WiFi.status() == WL_CONNECTED ? "✅" : "❌") +
                 " | 🔥 Firestore: " + String(Firebase.ready() ? "✅" : "❌"));
}

// Callback function للتوكن
void tokenStatusCallback(TokenInfo info) {
  if (info.status == token_status_error) {
    Serial.println("❌ Token generation failed");
  } else if (info.status == token_status_on_initialize) {
    Serial.println("🔑 Token generation");
  } else if (info.status == token_status_on_signing) {
    Serial.println("✍️ Token signing");
  } else if (info.status == token_status_on_request) {
    Serial.println("📤 Token request");
  } else if (info.status == token_status_on_refresh) {
    Serial.println("🔄 Token refresh");
  } else if (info.status == token_status_ready) {
    Serial.println("✅ Token ready");
  }
}
