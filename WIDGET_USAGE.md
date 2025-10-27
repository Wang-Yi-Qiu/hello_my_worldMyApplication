# Widget使用说明

## 📦 Widget安装和使用

### 1. 编译应用
在DevEco Studio中编译并安装应用后，Widget会自动注册到系统中。

### 2. 添加Widget到桌面
1. 长按桌面空白区域
2. 选择"小工具"（Widget）
3. 找到"极速转换卡片"
4. 添加到桌面

### 3. Widget功能
- **货币转换**：USD、CNY、EUR之间互转
- **长度转换**：米、英尺、千米、英里、厘米、英寸
- **重量转换**：千克、磅、克、盎司
- **温度转换**：摄氏度 ↔ 华氏度
- **时间转换**：小时、分钟、秒、天、周

### 4. 使用方法
- **输入数字**：点击数字按钮0-9
- **切换类别**：点击顶部的"货币"、"长度"等按钮
- **切换单位**：点击数值下方的单位标签
- **清除**：点击C按钮
- **退格**：点击⌫按钮

### 5. Widget尺寸
支持的尺寸：
- 1×1、1×2、2×2
- 2×3、3×3、2×4
- 4×4、6×4

默认尺寸：2×2

## ⚙️ 技术实现

### Widget配置文件
- `module.json5` - 注册Widget扩展能力
- `form_config.json` - Widget卡片配置
- `QuickConvertWidget.ets` - Widget组件代码

### 核心功能
1. **20种转换配置**：覆盖常用单位转换
2. **智能单位切换**：自动过滤无效单位组合
3. **实时计算**：输入即时显示结果
4. **支持偏移量**：温度转换等需要偏移的计算

## 🔧 可能遇到的问题

### 1. Widget无法添加
- 确保应用已正确安装
- 检查module.json5中的配置
- 重新编译应用

### 2. Widget无法显示
- 确保form_config.json配置正确
- 检查Widget代码是否有语法错误
- 查看日志文件

### 3. 交互无响应
- 检查点击事件是否正确绑定
- 确保状态变量正确更新
- 查看控制台日志

## 📝 开发说明

### 添加新的转换类型
在`createDefaultConfigs()`方法中添加新的配置：
```typescript
{
  id: 'new_conversion',
  fromUnit: '单位A',
  toUnit: '单位B',
  rate: 转换率,
  type: ConvertType.类型,
  category: '分类',
  isEnabled: true
}
```

### 自定义转换逻辑
对于需要偏移量的转换（如温度），添加offset字段：
```typescript
{
  id: 'c_to_f',
  fromUnit: '°C',
  toUnit: '°F',
  rate: 1.8,
  offset: 32,  // 偏移量
  type: ConvertType.TEMPERATURE,
  category: 'temperature',
  isEnabled: true
}
```

## 🎯 未来改进

- [ ] 支持用户自定义转换规则
- [ ] 实时汇率更新（需要网络权限）
- [ ] Widget主题切换
- [ ] 多语言支持
- [ ] 历史记录功能

