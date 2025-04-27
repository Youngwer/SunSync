#include <WiFiNINA.h>         // Use WiFiNINA library for MKR1010
#include <PubSubClient.h>
#include <NTPClient.h>        // For retrieving network time
#include <WiFiUdp.h>          // UDP required for NTP
#include "arduino_secrets.h"

// WiFi and MQTT configuration
const char* ssid          = SECRET_SSID;
const char* password      = SECRET_PASS;
const char* mqtt_username = SECRET_MQTTUSER;
const char* mqtt_password = SECRET_MQTTPASS;
const char* mqtt_server   = "mqtt.cetools.org";
const int   mqtt_port     = 1884;

// Separate MQTT topics
const char* topic_light    = "student/SunSync/realtime/light";
const char* topic_suggest  = "student/SunSync/realtime/suggestion";
const char* topic_time     = "student/SunSync/realtime/time";
const char* topic_highest_light = "student/SunSync/highest_light"; // New: Record daily highest light level

WiFiClient wifiClient;
PubSubClient client(wifiClient);
WiFiUDP ntpUDP;
// Set directly to GMT+1 (daylight saving time)
NTPClient timeClient(ntpUDP, "pool.ntp.org", 3600, 60000); // 3600s offset = GMT+1

// Light sensor configuration
const int lightSensorPin = A0;
const int minReading = 0;
const int maxReading = 1023;
const int LOW_LIGHT_THRESHOLD = 30;
const int HIGH_LIGHT_THRESHOLD = 90;

// Track highest light level and date
int highestLightToday = 0;
int lastDay = -1; // Initialize to -1 to ensure update on first check

void setup() {
  Serial.begin(115200);
  while (!Serial);
  
  Serial.println("MKR1010 Light Monitoring System");
  Serial.println("------------------------");

  // Initialize WiFi
  connectToWiFi();
  
  // Initialize NTP
  timeClient.begin();
  timeClient.update();
  
  // Initialize MQTT
  client.setServer(mqtt_server, mqtt_port);
  
  // Get current date and set lastDay
  lastDay = timeClient.getDay();
}

void loop() {
  // Check connection status
  if (!client.connected()) {
    reconnectMQTT();
  }
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }
  client.loop();

  // Update time
  timeClient.update();
  
  // Check if the date has changed (new day), reset highest light record if so
  int currentDay = timeClient.getDay();
  if (currentDay != lastDay) {
    highestLightToday = 0;
    lastDay = currentDay;
    Serial.println("New day started, resetting highest light record");
    
    // Publish reset message
    client.publish(topic_highest_light, "0");
  }

  // Read and process light data
  int rawValue = analogRead(lightSensorPin);
  int range = maxReading - minReading;
  int lightPercentage = ((rawValue - minReading) * 100) / range;
  lightPercentage = constrain(lightPercentage, 0, 100);

  // Update highest light record
  if (lightPercentage > highestLightToday) {
    highestLightToday = lightPercentage;
    
    // Publish new highest light value
    char highestLightStr[4];
    itoa(highestLightToday, highestLightStr, 10);
    client.publish(topic_highest_light, highestLightStr);
    
    Serial.print("Updated today's highest light: ");
    Serial.println(highestLightToday);
  }

  // Determine light condition and suggestion
  String lightCondition;
  String actionSuggestion;
  
  if (lightPercentage < LOW_LIGHT_THRESHOLD) {
    lightCondition = "Low light";
    actionSuggestion = "Please turn on more lights";
  } else if (lightPercentage > HIGH_LIGHT_THRESHOLD) {
    lightCondition = "High light";
    actionSuggestion = "Suggest closing curtains";
  } else {
    lightCondition = "Optimal light";
    actionSuggestion = "Suitable for work or reading";
  }

  // Get formatted time
  String formattedTime = timeClient.getFormattedTime();
  
  // Convert to char arrays for publishing
  char lightStr[4];
  char timeStr[32];
  char highestLightStr[4];
  itoa(lightPercentage, lightStr, 10);
  itoa(highestLightToday, highestLightStr, 10);
  formattedTime.toCharArray(timeStr, 32);

  // Publish to separate topics
  client.publish(topic_light, lightStr);
  client.publish(topic_suggest, actionSuggestion.c_str());
  client.publish(topic_time, timeStr);
  client.publish(topic_highest_light, highestLightStr);

  // Print local information
  Serial.print("Light intensity: ");
  Serial.print(lightPercentage);
  Serial.print("% | Status: ");
  Serial.print(lightCondition);
  Serial.print(" | Suggestion: ");
  Serial.print(actionSuggestion);
  Serial.print(" | Time: ");
  Serial.println(formattedTime);
  Serial.print("Today's highest light: ");
  Serial.print(highestLightToday);
  Serial.println("%");
  Serial.println("------------------------");

  delay(5000); // Update every 5 seconds
}

// WiFi connection function
void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

// MQTT reconnection function
void reconnectMQTT() {
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }
  
  while (!client.connected()) {
    Serial.print("Connecting to MQTT...");
    String clientId = "MKR1010_LightSensor_";
    clientId += String(random(0xffff), HEX);
    
    if (client.connect(clientId.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("Connected to MQTT broker");
      
      // Publish current highest light value upon successful connection
      char highestLightStr[4];
      itoa(highestLightToday, highestLightStr, 10);
      client.publish(topic_highest_light, highestLightStr);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" - Retrying in 5 seconds");
      delay(5000);
    }
  }
}