// 光敏电阻连接的模拟引脚
const int lightSensorPin = A0;

// 固定观察范围
const int minReading = 0;    // 最小值
const int maxReading = 1023; // 最大值

// 光照条件阈值
const int LOW_LIGHT_THRESHOLD = 30;   // 低于此值提醒开灯
const int HIGH_LIGHT_THRESHOLD = 90;  // 高于此值提醒拉窗帘

void setup() {
  // 初始化串口通信
  Serial.begin(9600);
  while (!Serial);
  
  Serial.println("简化版室内光照强度测试");
  Serial.println("------------------------");
  Serial.println("关注三种主要光照状态：光线不足、适宜和过强");
  Serial.println("------------------------");
}

void loop() {
  // 读取原始光照值 (0-1023)
 int rawValue = analogRead(lightSensorPin);
  
  // 确保有足够大的范围以便更好地区分光照变化
  int range = maxReading - minReading;
 
  
  // 计算相对光照强度百分比 (基于观察到的最小/最大值)
  int lightPercentage = ((rawValue - minReading) * 100) / range;
  
  // 限制百分比在0-100范围内
  lightPercentage = constrain(lightPercentage, 0, 100);
  // 简化的室内光照条件分类（三种状态）
  String lightCondition;
  String actionSuggestion;
  
  if (lightPercentage < LOW_LIGHT_THRESHOLD) {
    lightCondition = "光线不足";
    actionSuggestion = "建议开灯";
  } else if (lightPercentage > HIGH_LIGHT_THRESHOLD) {
    lightCondition = "光线过强";
    actionSuggestion = "建议拉窗帘，减少眩光";
  } else {
    lightCondition = "光线适宜";
    actionSuggestion = "适合办公阅读";
  }
  
  // 打印结果
  Serial.print("原始读数: ");
  Serial.print(rawValue);
  Serial.print(" / 1023");
  Serial.println();
  
  Serial.print("相对光照强度: ");
  Serial.print(lightPercentage);
  Serial.println("%");
  
  Serial.print("光照状态: ");
  Serial.println(lightCondition);
  
  Serial.print("建议操作: ");
  Serial.println(actionSuggestion);
  
  Serial.println("------------------------");
  
  // 延迟1秒
  delay(1000);
}