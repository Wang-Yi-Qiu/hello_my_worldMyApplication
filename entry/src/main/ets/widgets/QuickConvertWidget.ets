/**
 * 极速转换卡片组件
 * 支持单位转换和货币换算
 */
import { Logger } from '../utils/Logger';
import { ConvertConfig, ConvertType } from '../models/HistoryRecord';

@Entry
@Component
struct QuickConvertWidget {
  @State inputValue: string = '1';
  @State fromUnit: string = 'USD';
  @State toUnit: string = 'CNY';
  @State result: string = '7.2';
  @State convertType: ConvertType = ConvertType.CURRENCY;
  @State isLoading: boolean = false;
  @State showKeypad: boolean = false;
  @State availableUnits: string[] = [];
  
  private convertConfigs: ConvertConfig[] = [];
  
  aboutToAppear() {
    Logger.info('QuickConvertWidget loaded');
    this.initializeWidget();
  }
  
  initializeWidget() {
    try {
      this.createDefaultConfigs();
      // 设置默认输入值
      this.inputValue = '1';
      this.performConversion();
    } catch (error) {
      Logger.error('Widget initialization error:', error);
    }
  }
  
  
  createDefaultConfigs() {
    this.convertConfigs = [
      // 货币转换
      {
        id: 'usd_to_cny',
        fromUnit: 'USD',
        toUnit: 'CNY',
        rate: 7.2,
        type: ConvertType.CURRENCY,
        category: 'currency',
        isEnabled: true
      },
      {
        id: 'cny_to_usd',
        fromUnit: 'CNY',
        toUnit: 'USD',
        rate: 0.14,
        type: ConvertType.CURRENCY,
        category: 'currency',
        isEnabled: true
      },
      {
        id: 'usd_to_eur',
        fromUnit: 'USD',
        toUnit: 'EUR',
        rate: 0.92,
        type: ConvertType.CURRENCY,
        category: 'currency',
        isEnabled: true
      },
      {
        id: 'cny_to_eur',
        fromUnit: 'CNY',
        toUnit: 'EUR',
        rate: 0.13,
        type: ConvertType.CURRENCY,
        category: 'currency',
        isEnabled: true
      },
      
      // 长度转换
      {
        id: 'm_to_ft',
        fromUnit: 'm',
        toUnit: 'ft',
        rate: 3.28084,
        type: ConvertType.LENGTH,
        category: 'length',
        isEnabled: true
      },
      {
        id: 'm_to_km',
        fromUnit: 'm',
        toUnit: 'km',
        rate: 0.001,
        type: ConvertType.LENGTH,
        category: 'length',
        isEnabled: true
      },
      {
        id: 'km_to_mi',
        fromUnit: 'km',
        toUnit: 'mi',
        rate: 0.621371,
        type: ConvertType.LENGTH,
        category: 'length',
        isEnabled: true
      },
      {
        id: 'cm_to_in',
        fromUnit: 'cm',
        toUnit: 'in',
        rate: 0.393701,
        type: ConvertType.LENGTH,
        category: 'length',
        isEnabled: true
      },
      
      // 重量转换
      {
        id: 'kg_to_lb',
        fromUnit: 'kg',
        toUnit: 'lb',
        rate: 2.20462,
        type: ConvertType.WEIGHT,
        category: 'weight',
        isEnabled: true
      },
      {
        id: 'kg_to_g',
        fromUnit: 'kg',
        toUnit: 'g',
        rate: 1000,
        type: ConvertType.WEIGHT,
        category: 'weight',
        isEnabled: true
      },
      {
        id: 'lb_to_oz',
        fromUnit: 'lb',
        toUnit: 'oz',
        rate: 16,
        type: ConvertType.WEIGHT,
        category: 'weight',
        isEnabled: true
      },
      {
        id: 'g_to_oz',
        fromUnit: 'g',
        toUnit: 'oz',
        rate: 0.035274,
        type: ConvertType.WEIGHT,
        category: 'weight',
        isEnabled: true
      },
      
      // 温度转换
      {
        id: 'c_to_f',
        fromUnit: '°C',
        toUnit: '°F',
        rate: 1.8,
        offset: 32,
        type: ConvertType.TEMPERATURE,
        category: 'temperature',
        isEnabled: true
      },
      {
        id: 'f_to_c',
        fromUnit: '°F',
        toUnit: '°C',
        rate: 0.555556,
        offset: -32,
        type: ConvertType.TEMPERATURE,
        category: 'temperature',
        isEnabled: true
      },
      
      // 时间转换
      {
        id: 'hr_to_min',
        fromUnit: 'hr',
        toUnit: 'min',
        rate: 60,
        type: ConvertType.TIME,
        category: 'time',
        isEnabled: true
      },
      {
        id: 'min_to_sec',
        fromUnit: 'min',
        toUnit: 'sec',
        rate: 60,
        type: ConvertType.TIME,
        category: 'time',
        isEnabled: true
      },
      {
        id: 'day_to_hr',
        fromUnit: 'day',
        toUnit: 'hr',
        rate: 24,
        type: ConvertType.TIME,
        category: 'time',
        isEnabled: true
      },
      {
        id: 'week_to_day',
        fromUnit: 'week',
        toUnit: 'day',
        rate: 7,
        type: ConvertType.TIME,
        category: 'time',
        isEnabled: true
      },
      
      // 面积转换
      {
        id: 'm2_to_ft2',
        fromUnit: 'm²',
        toUnit: 'ft²',
        rate: 10.7639,
        type: ConvertType.AREA,
        category: 'area',
        isEnabled: true
      },
      {
        id: 'm2_to_km2',
        fromUnit: 'm²',
        toUnit: 'km²',
        rate: 0.000001,
        type: ConvertType.AREA,
        category: 'area',
        isEnabled: true
      },
      {
        id: 'km2_to_mi2',
        fromUnit: 'km²',
        toUnit: 'mi²',
        rate: 0.386102,
        type: ConvertType.AREA,
        category: 'area',
        isEnabled: true
      },
      {
        id: 'ha_to_acre',
        fromUnit: 'ha',
        toUnit: 'acre',
        rate: 2.47105,
        type: ConvertType.AREA,
        category: 'area',
        isEnabled: true
      },
      
      // 体积转换
      {
        id: 'm3_to_ft3',
        fromUnit: 'm³',
        toUnit: 'ft³',
        rate: 35.3147,
        type: ConvertType.VOLUME,
        category: 'volume',
        isEnabled: true
      },
      {
        id: 'm3_to_l',
        fromUnit: 'm³',
        toUnit: 'L',
        rate: 1000,
        type: ConvertType.VOLUME,
        category: 'volume',
        isEnabled: true
      },
      {
        id: 'l_to_ml',
        fromUnit: 'L',
        toUnit: 'mL',
        rate: 1000,
        type: ConvertType.VOLUME,
        category: 'volume',
        isEnabled: true
      },
      {
        id: 'gal_to_l',
        fromUnit: 'gal',
        toUnit: 'L',
        rate: 3.78541,
        type: ConvertType.VOLUME,
        category: 'volume',
        isEnabled: true
      }
    ];
  }
  
  performConversion() {
    const config = this.convertConfigs.find(c => 
      c.fromUnit === this.fromUnit && c.toUnit === this.toUnit
    );
    
    if (config) {
      const inputNum = parseFloat(this.inputValue) || 0;
      // 支持带偏移量的转换（如温度转换）
      const result = config.offset !== undefined 
        ? (inputNum * config.rate) + config.offset 
        : inputNum * config.rate;
      this.result = result.toFixed(2);
    }
  }
  
  // 在 form 应用中，输入值由外部设置
  setInputValue(value: string) {
    this.inputValue = value;
    this.performConversion();
  }
  
  onFromUnitChange(unit: string) {
    this.fromUnit = unit;
    this.performConversion();
  }
  
  onToUnitChange(unit: string) {
    this.toUnit = unit;
    this.performConversion();
  }
  
  onConvertTypeChange(type: ConvertType) {
    this.convertType = type;
    this.updateUnitsForType();
  }
  
  updateUnitsForType() {
    const typeConfigs = this.convertConfigs.filter(c => c.type === this.convertType);
    if (typeConfigs.length > 0) {
      this.fromUnit = typeConfigs[0].fromUnit;
      this.toUnit = typeConfigs[0].toUnit;
      // 更新可用单位列表
      this.availableUnits = Array.from(new Set(typeConfigs.map(c => c.fromUnit)));
      this.performConversion();
    }
  }

  /**
   * 添加数字到输入
   */
  appendNumber(num: string) {
    if (this.inputValue === '0' || this.inputValue === '1') {
      this.inputValue = num;
    } else {
      this.inputValue += num;
    }
    this.performConversion();
  }

  /**
   * 清除输入
   */
  clearInput() {
    this.inputValue = '1';
    this.performConversion();
  }

  /**
   * 退格
   */
  backspace() {
    if (this.inputValue.length > 1) {
      this.inputValue = this.inputValue.slice(0, -1);
    } else {
      this.inputValue = '1';
    }
    this.performConversion();
  }

  /**
   * 循环切换源单位
   */
  cycleFromUnit() {
    const typeConfigs = this.convertConfigs.filter(c => c.type === this.convertType);
    const units = Array.from(new Set(typeConfigs.map(c => c.fromUnit)));
    const currentIndex = units.indexOf(this.fromUnit);
    const nextIndex = (currentIndex + 1) % units.length;
    this.fromUnit = units[nextIndex];
    
    // 同时更新目标单位（如果该单位对不可用）
    const availableToUnits = this.getAvailableToUnits(this.fromUnit);
    if (!availableToUnits.includes(this.toUnit)) {
      this.toUnit = availableToUnits[0];
    }
    this.performConversion();
  }

  /**
   * 循环切换目标单位
   */
  cycleToUnit() {
    const availableToUnits = this.getAvailableToUnits(this.fromUnit);
    const currentIndex = availableToUnits.indexOf(this.toUnit);
    const nextIndex = (currentIndex + 1) % availableToUnits.length;
    this.toUnit = availableToUnits[nextIndex];
    this.performConversion();
  }

  /**
   * 获取可用的目标单位
   */
  getAvailableToUnits(fromUnit: string): string[] {
    const configs = this.convertConfigs.filter(c => c.fromUnit === fromUnit);
    return Array.from(new Set(configs.map(c => c.toUnit)));
  }
  
  getUnitsForType(type: ConvertType): string[] {
    return this.convertConfigs
      .filter(c => c.type === type)
      .map(c => c.fromUnit)
      .filter((value, index, self) => self.indexOf(value) === index);
  }
  
  build() {
    Column() {
      // 标题
      Text('极速转换')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })
      
      // 转换类型选择（Flex布局）
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        Button('货币')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.CURRENCY ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.CURRENCY ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.CURRENCY))
          .margin({ right: 6, bottom: 6 })
        
        Button('长度')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.LENGTH ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.LENGTH ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.LENGTH))
          .margin({ right: 6, bottom: 6 })
        
        Button('重量')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.WEIGHT ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.WEIGHT ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.WEIGHT))
          .margin({ right: 6, bottom: 6 })
        
        Button('温度')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.TEMPERATURE ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.TEMPERATURE ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.TEMPERATURE))
          .margin({ right: 6, bottom: 6 })
        
        Button('时间')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.TIME ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.TIME ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.TIME))
          .margin({ right: 6, bottom: 6 })
        
        Button('面积')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.AREA ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.AREA ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.AREA))
          .margin({ right: 6, bottom: 6 })
        
        Button('体积')
          .fontSize(11)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor(this.convertType === ConvertType.VOLUME ? '#007DFF' : '#F0F0F0')
          .fontColor(this.convertType === ConvertType.VOLUME ? '#FFFFFF' : '#333333')
          .borderRadius(12)
          .onClick(() => this.onConvertTypeChange(ConvertType.VOLUME))
          .margin({ right: 6, bottom: 6 })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 单位选择矩阵
      this.buildUnitMatrix()
      
      // 输入区域
      Column() {
        Row() {
          Column() {
            Text(this.inputValue || '1')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            
            Text(this.fromUnit)
              .fontSize(10)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          
          Text('=')
            .fontSize(16)
            .fontColor('#333333')
            .margin({ left: 8, right: 8 })
          
          Column() {
            Text(this.result)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007DFF')
            
            Text(this.toUnit)
              .fontSize(10)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })
        
        // 迷你数字键盘
        Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 'C', 0, '⌫'], (item: number | string) => {
            Button(item.toString())
              .fontSize(12)
              .width(24)
              .height(24)
              .backgroundColor('#F5F5F5')
              .fontColor('#333333')
              .borderRadius(4)
              .onClick(() => {
                if (typeof item === 'number') {
                  this.appendNumber(item.toString());
                } else if (item === 'C') {
                  this.clearInput();
                } else if (item === '⌫') {
                  this.backspace();
                }
              })
              .margin(2)
          })
        }
        .margin({ top: 4 })
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  /**
   * 构建单位选择矩阵
   */
  @Builder buildUnitMatrix() {
    Column() {
      Text('选择单位')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ bottom: 6 })
      
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
        ForEach(this.getAvailableUnits(), (unit: string, index: number) => {
          Button(unit)
            .fontSize(10)
            .padding({ left: 6, right: 6, top: 4, bottom: 4 })
            .backgroundColor(this.fromUnit === unit ? '#007DFF' : '#F8F8F8')
            .fontColor(this.fromUnit === unit ? '#FFFFFF' : '#333333')
            .borderRadius(8)
            .borderWidth(1)
            .borderColor(this.fromUnit === unit ? '#007DFF' : '#E0E0E0')
            .onClick(() => {
              this.fromUnit = unit;
              // 自动选择第一个可用的目标单位
              const toUnits = this.getAvailableToUnits(unit);
              if (toUnits.length > 0) {
                this.toUnit = toUnits[0];
              }
              this.performConversion();
            })
            .margin({ right: 4, bottom: 4 })
        })
      }
      .width('100%')
    }
    .margin({ bottom: 8 })
  }

  /**
   * 获取当前类型的所有可用单位
   */
  getAvailableUnits(): string[] {
    const typeConfigs = this.convertConfigs.filter(c => c.type === this.convertType);
    return Array.from(new Set(typeConfigs.map(c => c.fromUnit)));
  }
}
