/**
 * 单位转换页面
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { router } from '@kit.ArkUI';

// 定义转换类别和单位
const conversionTypes = [
  { name: '长度', units: ['米', '公里', '英里', '英尺'] },
  { name: '重量', units: ['公斤', '克', '磅', '盎司'] },
  { name: '温度', units: ['摄氏度', '华氏度', '开尔文'] }
];

// 转换因子（相对于基础单位）
const lengthConversions = {
  '米': 1,
  '公里': 1000,
  '英里': 1609.34,
  '英尺': 0.3048
};

const weightConversions = {
  '公斤': 1,
  '克': 0.001,
  '磅': 0.453592,
  '盎司': 0.0283495
};

@Entry
@Component
struct UnitConversionPage {
  @State currentTheme: string = AppStorage.Get('currentTheme') || 'light';
  @State selectedCategoryIndex: number = 0;
  @State fromUnitIndex: number = 0;
  @State toUnitIndex: number = 1;
  @State inputValue: string = '1';
  @State outputValue: string = '';

  aboutToAppear() {
    this.convert();
  }

  // 转换逻辑
  convert() {
    const category = conversionTypes[this.selectedCategoryIndex];
    const fromUnit = category.units[this.fromUnitIndex];
    const toUnit = category.units[this.toUnitIndex];
    const value = parseFloat(this.inputValue);

    if (isNaN(value)) {
      this.outputValue = '';
      return;
    }

    let result: number = 0;

    if (category.name === '长度') {
      const baseValue = value * lengthConversions[fromUnit];
      result = baseValue / lengthConversions[toUnit];
    } else if (category.name === '重量') {
      const baseValue = value * weightConversions[fromUnit];
      result = baseValue / weightConversions[toUnit];
    } else if (category.name === '温度') {
      if (fromUnit === '摄氏度') {
        if (toUnit === '华氏度') result = (value * 9/5) + 32;
        else if (toUnit === '开尔文') result = value + 273.15;
        else result = value;
      } else if (fromUnit === '华氏度') {
        if (toUnit === '摄氏度') result = (value - 32) * 5/9;
        else if (toUnit === '开尔文') result = ((value - 32) * 5/9) + 273.15;
        else result = value;
      } else if (fromUnit === '开尔文') {
        if (toUnit === '摄氏度') result = value - 273.15;
        else if (toUnit === '华氏度') result = ((value - 273.15) * 9/5) + 32;
        else result = value;
      } else {
        result = value;
      }
    } else {
      result = value;
    }

    this.outputValue = result.toFixed(4);
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.left'))
          .width(24).height(24).margin({ left: AppTheme.SPACING_MEDIUM })
          .onClick(() => router.back())
        Text('单位转换')
          .fontSize(AppTheme.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .layoutWeight(1).textAlign(TextAlign.Center).margin({ right: AppTheme.SPACING_MEDIUM + 24 })
      }
      .width('100%').height(56).backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
      .border({ width: { bottom: 0.5 }, color: AppTheme.getDividerColor(this.currentTheme === 'dark') })

      // 内容区域
      Scroll() {
        Column() {
          // 类别选择
          Row() {
            Text('类别:').fontSize(AppTheme.FONT_SIZE_NORMAL).margin({ right: AppTheme.SPACING_MEDIUM })
            Select(conversionTypes.map(t => ({ value: t.name })))
              .selected(this.selectedCategoryIndex)
              .onSelect((index) => {
                this.selectedCategoryIndex = index;
                this.fromUnitIndex = 0;
                this.toUnitIndex = 1;
                this.convert();
              })
          }.padding(AppTheme.SPACING_MEDIUM)

          // 输入和输出
          Column() {
            this.buildUnitRow(true)
            this.buildUnitRow(false)
          }.padding({ horizontal: AppTheme.SPACING_MEDIUM })

        }.width('100%')
      }.layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }

  @Builder buildUnitRow(isFrom: boolean) {
    Row() {
      TextInput({
        text: isFrom ? this.inputValue : this.outputValue,
        placeholder: '0'
      })
        .type(InputType.Number)
        .layoutWeight(1)
        .onChange((val) => {
          if (isFrom) {
            this.inputValue = val;
            this.convert();
          }
        })

      Select(conversionTypes[this.selectedCategoryIndex].units.map(u => ({ value: u })))
        .selected(isFrom ? this.fromUnitIndex : this.toUnitIndex)
        .onSelect((index) => {
          if (isFrom) this.fromUnitIndex = index;
          else this.toUnitIndex = index;
          this.convert();
        })
        .width('40%')
    }
    .width('100%')
    .margin({ bottom: AppTheme.SPACING_MEDIUM })
  }
}
