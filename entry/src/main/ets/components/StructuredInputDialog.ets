/**
 * 结构化输入对话框组件
 * 为定积分、极限等数学操作提供引导式输入界面
 */
import { Logger } from '../utils/Logger';
import { promptAction } from '@kit.ArkUI';

export enum InputType {
  DEFINITE_INTEGRAL = 'definite_integral',
  INDEFINITE_INTEGRAL = 'indefinite_integral',
  DERIVATIVE = 'derivative',
  LIMIT = 'limit',
  PARTIAL_DERIVATIVE = 'partial_derivative'
}

export interface StructuredInputData {
  function?: string;
  variable?: string;
  lowerLimit?: string;
  upperLimit?: string;
  approachValue?: string;
  direction?: string;
  order?: number;
}

export interface StructuredInputResult {
  success: boolean;
  expression: string;
  data?: StructuredInputData;
}

@CustomDialog
export struct StructuredInputDialog {
  @State inputType: InputType = InputType.DEFINITE_INTEGRAL;
  @State functionInput: string = '';
  @State variableInput: string = 'x';
  @State lowerLimitInput: string = '';
  @State upperLimitInput: string = '';
  @State approachValueInput: string = '';
  @State directionInput: string = 'both';
  @State orderInput: number = 1;
  @State errorMessage: string = '';
  
  controller: CustomDialogController;
  onConfirm?: (result: StructuredInputResult) => void;
  
  build() {
    Column() {
      // 标题
      Row() {
        Text(this.getTitle())
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ top: 20, bottom: 16, left: 20, right: 20 })
      
      Scroll() {
        Column() {
          // 根据类型显示不同的输入字段
          if (this.inputType === InputType.DEFINITE_INTEGRAL) {
            this.buildDefiniteIntegralInputs();
          } else if (this.inputType === InputType.INDEFINITE_INTEGRAL) {
            this.buildIndefiniteIntegralInputs();
          } else if (this.inputType === InputType.DERIVATIVE) {
            this.buildDerivativeInputs();
          } else if (this.inputType === InputType.LIMIT) {
            this.buildLimitInputs();
          } else if (this.inputType === InputType.PARTIAL_DERIVATIVE) {
            this.buildPartialDerivativeInputs();
          }
          
          // 错误提示
          if (this.errorMessage) {
            Row() {
              Text('⚠️ ' + this.errorMessage)
                .fontSize(13)
                .fontColor('#FF4D4F')
                .lineHeight(20)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
            .margin({ top: 12 })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      
      // 按钮区域
      Row() {
        Button('取消')
          .fontSize(15)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })
        
        Button('确定')
          .fontSize(15)
          .height(44)
          .backgroundColor('#1890FF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ left: 12 })
          .onClick(() => {
            this.handleConfirm();
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 20, left: 20, right: 20 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
  
  /**
   * 获取标题
   */
  private getTitle(): string {
    switch (this.inputType) {
      case InputType.DEFINITE_INTEGRAL:
        return '定积分输入';
      case InputType.INDEFINITE_INTEGRAL:
        return '不定积分输入';
      case InputType.DERIVATIVE:
        return '导数输入';
      case InputType.LIMIT:
        return '极限输入';
      case InputType.PARTIAL_DERIVATIVE:
        return '偏导数输入';
      default:
        return '输入';
    }
  }
  
  /**
   * 构建定积分输入字段
   */
  @Builder buildDefiniteIntegralInputs() {
    Column() {
      // 被积函数 f(x)
      this.buildInputField(
        '① 被积函数 f(x)',
        '例如: x^2, sin(x), x*exp(x)',
        this.functionInput,
        (value: string) => {
          this.functionInput = value;
          this.validateInput();
        }
      );
      
      // 积分变量
      this.buildInputField(
        '② 积分变量',
        '默认为 x',
        this.variableInput,
        (value: string) => {
          this.variableInput = value || 'x';
          this.validateInput();
        }
      );
      
      // 积分下限
      this.buildInputField(
        '③ 下限 a',
        '例如: 0, -1, π',
        this.lowerLimitInput,
        (value: string) => {
          this.lowerLimitInput = value;
          this.validateInput();
        }
      );
      
      // 积分上限
      this.buildInputField(
        '④ 上限 b',
        '例如: 1, 2, π',
        this.upperLimitInput,
        (value: string) => {
          this.upperLimitInput = value;
          this.validateInput();
        }
      );
      
      // 预览
      this.buildPreview(`∫[${this.lowerLimitInput || 'a'}, ${this.upperLimitInput || 'b'}] (${this.functionInput || 'f(x)'}) d${this.variableInput}`);
    }
    .width('100%')
  }
  
  /**
   * 构建不定积分输入字段
   */
  @Builder buildIndefiniteIntegralInputs() {
    Column() {
      // 被积函数 f(x)
      this.buildInputField(
        '① 被积函数 f(x)',
        '例如: x^2, sin(x), x*exp(x)',
        this.functionInput,
        (value: string) => {
          this.functionInput = value;
          this.validateInput();
        }
      );
      
      // 积分变量
      this.buildInputField(
        '② 积分变量',
        '默认为 x',
        this.variableInput,
        (value: string) => {
          this.variableInput = value || 'x';
          this.validateInput();
        }
      );
      
      // 预览
      this.buildPreview(`∫ (${this.functionInput || 'f(x)'}) d${this.variableInput} + C`);
    }
    .width('100%')
  }
  
  /**
   * 构建导数输入字段
   */
  @Builder buildDerivativeInputs() {
    Column() {
      // 函数 f(x)
      this.buildInputField(
        '① 函数 f(x)',
        '例如: x^3, sin(x), ln(x)',
        this.functionInput,
        (value: string) => {
          this.functionInput = value;
          this.validateInput();
        }
      );
      
      // 变量
      this.buildInputField(
        '② 求导变量',
        '默认为 x',
        this.variableInput,
        (value: string) => {
          this.variableInput = value || 'x';
          this.validateInput();
        }
      );
      
      // 阶数
      Row() {
        Text('③ 求导阶数')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 8 })
      }
      .width('100%')
      
      Row() {
        Button('一阶')
          .fontSize(13)
          .height(36)
          .backgroundColor(this.orderInput === 1 ? '#1890FF' : '#F5F5F5')
          .fontColor(this.orderInput === 1 ? '#FFFFFF' : '#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.orderInput = 1;
            this.validateInput();
          })
        
        Button('二阶')
          .fontSize(13)
          .height(36)
          .backgroundColor(this.orderInput === 2 ? '#1890FF' : '#F5F5F5')
          .fontColor(this.orderInput === 2 ? '#FFFFFF' : '#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.orderInput = 2;
            this.validateInput();
          })
        
        Button('三阶')
          .fontSize(13)
          .height(36)
          .backgroundColor(this.orderInput === 3 ? '#1890FF' : '#F5F5F5')
          .fontColor(this.orderInput === 3 ? '#FFFFFF' : '#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.orderInput = 3;
            this.validateInput();
          })
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 预览
      this.buildPreview(`f${this.orderInput === 1 ? "'" : this.orderInput === 2 ? "''" : "'''"}(${this.variableInput}) = d${this.orderInput === 1 ? '' : '^' + this.orderInput}(${this.functionInput || 'f(x)'})/d${this.variableInput}${this.orderInput === 1 ? '' : '^' + this.orderInput}`)
    }
    .width('100%')
  }
  
  /**
   * 构建极限输入字段
   */
  @Builder buildLimitInputs() {
    Column() {
      // 函数 f(x)
      this.buildInputField(
        '① 函数 f(x)',
        '例如: (x^2-1)/(x-1), sin(x)/x',
        this.functionInput,
        (value: string) => {
          this.functionInput = value;
          this.validateInput();
        }
      );
      
      // 变量
      this.buildInputField(
        '② 变量',
        '默认为 x',
        this.variableInput,
        (value: string) => {
          this.variableInput = value || 'x';
          this.validateInput();
        }
      );
      
      // 趋向值
      this.buildInputField(
        '③ 趋向值',
        '例如: 0, 1, ∞ (输入 inf)',
        this.approachValueInput,
        (value: string) => {
          this.approachValueInput = value;
          this.validateInput();
        }
      );
      
      // 方向
      Row() {
        Text('④ 方向')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 8 })
      }
      .width('100%')
      
      Row() {
        Button('双侧')
          .fontSize(13)
          .height(36)
          .backgroundColor(this.directionInput === 'both' ? '#1890FF' : '#F5F5F5')
          .fontColor(this.directionInput === 'both' ? '#FFFFFF' : '#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.directionInput = 'both';
            this.validateInput();
          })
        
        Button('左侧 (x→a⁻)')
          .fontSize(13)
          .height(36)
          .backgroundColor(this.directionInput === 'left' ? '#1890FF' : '#F5F5F5')
          .fontColor(this.directionInput === 'left' ? '#FFFFFF' : '#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.directionInput = 'left';
            this.validateInput();
          })
        
        Button('右侧 (x→a⁺)')
          .fontSize(13)
          .height(36)
          .backgroundColor(this.directionInput === 'right' ? '#1890FF' : '#F5F5F5')
          .fontColor(this.directionInput === 'right' ? '#FFFFFF' : '#666666')
          .borderRadius(8)
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.directionInput = 'right';
            this.validateInput();
          })
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 预览
      this.buildPreview(`lim(${this.variableInput}→${this.approachValueInput || 'a'}${this.directionInput === 'left' ? '⁻' : this.directionInput === 'right' ? '⁺' : ''}) ${this.functionInput || 'f(x)'}`)
    }
    .width('100%')
  }
  
  /**
   * 构建偏导数输入字段
   */
  @Builder buildPartialDerivativeInputs() {
    Column() {
      // 多元函数 f(x,y,...)
      this.buildInputField(
        '① 多元函数',
        '例如: x^2 + y^2, x*y*z',
        this.functionInput,
        (value: string) => {
          this.functionInput = value;
          this.validateInput();
        }
      );
      
      // 求偏导的变量
      this.buildInputField(
        '② 求偏导变量',
        '例如: x, y, z',
        this.variableInput,
        (value: string) => {
          this.variableInput = value || 'x';
          this.validateInput();
        }
      );
      
      // 预览
      this.buildPreview(`∂(${this.functionInput || 'f(x,y)'})/∂${this.variableInput}`);
    }
    .width('100%')
  }
  
  /**
   * 构建输入字段
   */
  @Builder buildInputField(
    label: string,
    placeholder: string,
    value: string,
    onChange: (value: string) => void
  ) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 8 })
      }
      .width('100%')
      
      TextInput({ text: value, placeholder: placeholder })
        .fontSize(14)
        .width('100%')
        .height(44)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .onChange(onChange)
        .margin({ bottom: 16 })
    }
    .width('100%')
  }
  
  /**
   * 构建预览
   */
  @Builder buildPreview(text: string) {
    Column() {
      Row() {
        Text('预览')
          .fontSize(13)
          .fontColor('#999999')
          .margin({ bottom: 8 })
      }
      .width('100%')
      
      Row() {
        Text(text)
          .fontSize(16)
          .fontColor('#1890FF')
          .fontWeight(FontWeight.Medium)
          .lineHeight(24)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F0F9FF')
      .borderRadius(8)
      .border({ width: 1, color: '#91D5FF' })
    }
    .width('100%')
    .margin({ top: 8 })
  }
  
  /**
   * 验证输入
   */
  private validateInput() {
    this.errorMessage = '';
    
    // 验证函数输入
    if (!this.functionInput || this.functionInput.trim() === '') {
      this.errorMessage = '请输入函数表达式';
      return false;
    }
    
    // 根据类型验证特定字段
    if (this.inputType === InputType.DEFINITE_INTEGRAL) {
      if (!this.lowerLimitInput || this.lowerLimitInput.trim() === '') {
        this.errorMessage = '请输入下限';
        return false;
      }
      if (!this.upperLimitInput || this.upperLimitInput.trim() === '') {
        this.errorMessage = '请输入上限';
        return false;
      }
    }
    
    if (this.inputType === InputType.LIMIT) {
      if (!this.approachValueInput || this.approachValueInput.trim() === '') {
        this.errorMessage = '请输入趋向值';
        return false;
      }
    }
    
    // 验证变量名
    if (!this.variableInput || this.variableInput.trim() === '') {
      this.errorMessage = '请输入变量名';
      return false;
    }
    
    // 检查括号匹配
    const openParens = (this.functionInput.match(/\(/g) || []).length;
    const closeParens = (this.functionInput.match(/\)/g) || []).length;
    if (openParens !== closeParens) {
      this.errorMessage = '括号不匹配';
      return false;
    }
    
    return true;
  }
  
  /**
   * 处理确认
   */
  private handleConfirm() {
    if (!this.validateInput()) {
      return;
    }
    
    let expression = '';
    const data: StructuredInputData = {
      function: this.functionInput,
      variable: this.variableInput
    };
    
    // 根据类型构建表达式
    switch (this.inputType) {
      case InputType.DEFINITE_INTEGRAL:
        expression = `${this.functionInput}[${this.lowerLimitInput},${this.upperLimitInput}]`;
        data.lowerLimit = this.lowerLimitInput;
        data.upperLimit = this.upperLimitInput;
        break;
        
      case InputType.INDEFINITE_INTEGRAL:
        expression = this.functionInput;
        break;
        
      case InputType.DERIVATIVE:
        expression = this.functionInput;
        data.order = this.orderInput;
        break;
        
      case InputType.LIMIT:
        expression = `${this.functionInput},${this.variableInput}->${this.approachValueInput}`;
        data.approachValue = this.approachValueInput;
        data.direction = this.directionInput;
        break;
        
      case InputType.PARTIAL_DERIVATIVE:
        expression = this.functionInput;
        break;
    }
    
    const result: StructuredInputResult = {
      success: true,
      expression: expression,
      data: data
    };
    
    if (this.onConfirm) {
      this.onConfirm(result);
    }
    
    this.controller.close();
  }
}

