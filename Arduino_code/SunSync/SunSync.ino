#include <WiFiNINA.h>         // MKR1010使用WiFiNINA库
#include <PubSubClient.h>
#include <NTPClient.h>        // 用于获取网络时间
#include <WiFiUdp.h>          // NTP需要UDP
#include "arduino_secrets.h"

// WiFi和MQTT配置
const char* ssid          = SECRET_SSID;
const char* password      = SECRET_PASS;
const char* mqtt_username = SECRET_MQTTUSER;
const char* mqtt_password = SECRET_MQTTPASS;
const char* mqtt_server   = "mqtt.cetools.org";
const int   mqtt_port     = 1884;

// 分离的MQTT主题
const char* topic_light    = "student/SunSync/realtime/light";
const char* topic_suggest  = "student/SunSync/realtime/suggestion";
const char* topic_time     = "student/SunSync/realtime/time";
const char* topic_highest_light = "student/SunSync/highest_light"; // 新增: 记录当日最高光照

WiFiClient wifiClient;
PubSubClient client(wifiClient);
WiFiUDP ntpUDP;
// 直接设置为GMT+1（夏令时）
NTPClient timeClient(ntpUDP, "pool.ntp.org", 3600, 60000); // 3600秒偏移 = GMT+1

// 光敏电阻配置
const int lightSensorPin = A0;
const int minReading = 0;
const int maxReading = 1023;
const int LOW_LIGHT_THRESHOLD = 30;
const int HIGH_LIGHT_THRESHOLD = 90;

// 跟踪最高光照和日期
int highestLightToday = 0;
int lastDay = -1; // 初始化为-1，确保第一次检查时会更新

void setup() {
  Serial.begin(115200);
  while (!Serial);
  
  Serial.println("MKR1010光照监测系统");
  Serial.println("------------------------");

  // 初始化WiFi
  connectToWiFi();
  
  // 初始化NTP
  timeClient.begin();
  timeClient.update();
  
  // 初始化MQTT
  client.setServer(mqtt_server, mqtt_port);
  
  // 获取当前日期并设置lastDay
  lastDay = timeClient.getDay();
}

void loop() {
  // 检查连接状态
  if (!client.connected()) {
    reconnectMQTT();
  }
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }
  client.loop();

  // 更新时间
  timeClient.update();
  
  // 检查日期是否改变（第二天），如果是则重置最高光照记录
  int currentDay = timeClient.getDay();
  if (currentDay != lastDay) {
    highestLightToday = 0;
    lastDay = currentDay;
    Serial.println("新的一天开始了，重置最高光照记录");
    
    // 发布重置消息
    client.publish(topic_highest_light, "0");
  }

  // 读取和处理光照数据
  int rawValue = analogRead(lightSensorPin);
  int range = maxReading - minReading;
  int lightPercentage = ((rawValue - minReading) * 100) / range;
  lightPercentage = constrain(lightPercentage, 0, 100);

  // 更新最高光照记录
  if (lightPercentage > highestLightToday) {
    highestLightToday = lightPercentage;
    
    // 发布新的最高光照值
    char highestLightStr[4];
    itoa(highestLightToday, highestLightStr, 10);
    client.publish(topic_highest_light, highestLightStr);
    
    Serial.print("更新今日最高光照: ");
    Serial.println(highestLightToday);
  }

  // 确定光照条件和建议
  String lightCondition;
  String actionSuggestion;
  
  if (lightPercentage < LOW_LIGHT_THRESHOLD) {
    lightCondition = "光线不足";
    actionSuggestion = "请打开更多灯光";
  } else if (lightPercentage > HIGH_LIGHT_THRESHOLD) {
    lightCondition = "光线过强";
    actionSuggestion = "建议拉窗帘";
  } else {
    lightCondition = "光线适宜";
    actionSuggestion = "适合办公阅读";
  }

  // 获取格式化的时间
  String formattedTime = timeClient.getFormattedTime();
  
  // 转换为字符数组用于发布
  char lightStr[4];
  char timeStr[32];
  char highestLightStr[4];
  itoa(lightPercentage, lightStr, 10);
  itoa(highestLightToday, highestLightStr, 10);
  formattedTime.toCharArray(timeStr, 32);

  // 发布到分离的主题
  client.publish(topic_light, lightStr);
  client.publish(topic_suggest, actionSuggestion.c_str());
  client.publish(topic_time, timeStr);
  client.publish(topic_highest_light, highestLightStr);

  // 打印本地信息
  Serial.print("光照强度: ");
  Serial.print(lightPercentage);
  Serial.print("% | 状态: ");
  Serial.print(lightCondition);
  Serial.print(" | 建议: ");
  Serial.print(actionSuggestion);
  Serial.print(" | 时间: ");
  Serial.println(formattedTime);
  Serial.print("今日最高光照: ");
  Serial.print(highestLightToday);
  Serial.println("%");
  Serial.println("------------------------");

  delay(5000); // 每5秒更新一次
}

// WiFi连接函数
void connectToWiFi() {
  Serial.print("连接WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi已连接");
  Serial.print("IP地址: ");
  Serial.println(WiFi.localIP());
}

// MQTT重连函数
void reconnectMQTT() {
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }
  
  while (!client.connected()) {
    Serial.print("连接MQTT...");
    String clientId = "MKR1010_LightSensor_";
    clientId += String(random(0xffff), HEX);
    
    if (client.connect(clientId.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("已连接到MQTT broker");
      
      // 连接成功后立即发布当前最高光照值
      char highestLightStr[4];
      itoa(highestLightToday, highestLightStr, 10);
      client.publish(topic_highest_light, highestLightStr);
    } else {
      Serial.print("失败, rc=");
      Serial.print(client.state());
      Serial.println(" - 5秒后重试");
      delay(5000);
    }
  }
}