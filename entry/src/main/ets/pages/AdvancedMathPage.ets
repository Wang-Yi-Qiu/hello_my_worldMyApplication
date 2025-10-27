/**
 * 高等数学页面
 * LaTeX输入和绘图界面
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { promptAction } from '@kit.ArkUI';
import { CalculusEngine, DerivativeResult, IntegralResult, LimitResult } from '../modules/CalculusEngine';
import { EquationSolver, SolveResult } from '../modules/EquationSolver';
import { MathSymbolKeyboard } from '../components/MathSymbolKeyboard';
import { StructuredInputDialog, InputType, StructuredInputResult, StructuredInputData } from '../components/StructuredInputDialog';
import { LaTeXRenderer } from '../components/LaTeXRenderer';
import { DataManager } from '../modules/DataManager';
import { backendAPI } from '../services/BackendAPIService';

@Component
export struct AdvancedMathPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @State latexInput: string = '';
  @State selectedFunction: string = '';
  @State showSteps: boolean = false;
  @State showGraph: boolean = false;
  @State showKeyboard: boolean = false;
  @State result: string = '';
  @State resultLatex: string = '';
  @State steps: string[] = [];
  @State errorMessage: string = '';
  @State inputValidationMessage: string = '';
  @State structuredData: StructuredInputData | null = null;
  
  private calculusEngine: CalculusEngine = new CalculusEngine();
  private equationSolver: EquationSolver = new EquationSolver();
  private dataManager: DataManager = new DataManager();
  private functionButtons: string[] = ['求导', '积分', '极限', '方程'];
  
  // 结构化输入对话框控制器
  private structuredInputDialogController: CustomDialogController | null = null;
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('高等数学')
          .fontSize(AppTheme.FONT_SIZE_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))

      Scroll() {
        Column() {
          // LaTeX 输入区域
          Column() {
            Row() {
              Text('输入公式')
                .fontSize(AppTheme.FONT_SIZE_MEDIUM)
                .fontWeight(FontWeight.Normal)
                .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
              
              Blank()
              
              Button('数学键盘')
                .fontSize(AppTheme.FONT_SIZE_SMALL)
                .height(32)
                .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
                .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
                .borderRadius(AppTheme.BORDER_RADIUS_LARGE)
                .padding({ left: AppTheme.SPACING_MEDIUM, right: AppTheme.SPACING_MEDIUM })
                .onClick(() => {
                  this.showKeyboard = !this.showKeyboard;
                })
            }
            .width('100%')
            .margin({ bottom: AppTheme.SPACING_NORMAL })
            
            TextArea({ 
              placeholder: '输入数学表达式，或点击下方按钮使用引导式输入',
              text: this.latexInput
            })
              .width('100%')
              .height(120)
              .fontSize(AppTheme.FONT_SIZE_NORMAL)
              .backgroundColor(this.currentTheme === 'dark' ? AppTheme.CARD_BG_DARK : AppTheme.DIVIDER_COLOR_LIGHT)
              .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
              .borderRadius(AppTheme.BORDER_RADIUS_MEDIUM)
              .padding(AppTheme.SPACING_MEDIUM)
              .onChange((value: string) => {
                this.latexInput = value;
                this.errorMessage = '';
                this.validateInputRealtime(value);
              })
            
            // 实时验证提示
            if (this.inputValidationMessage) {
              Row() {
                Text('💡 ' + this.inputValidationMessage)
                  .fontSize(AppTheme.FONT_SIZE_SMALL)
                  .fontColor(AppTheme.SUCCESS_COLOR)
                  .lineHeight(18)
              }
              .width('100%')
              .padding({ top: AppTheme.SPACING_SMALL })
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20 })
          .margin({ bottom: 16 })
          
          // 数学符号键盘（可收起/展开）
          if (this.showKeyboard) {
            Column() {
              Row() {
                Text('数学符号键盘')
                  .fontSize(AppTheme.FONT_SIZE_MEDIUM)
                  .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
                  .layoutWeight(1)
                
                Button('收起')
                  .fontSize(AppTheme.FONT_SIZE_SMALL)
                  .height(28)
                  .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
                  .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
                  .borderRadius(AppTheme.BORDER_RADIUS_LARGE)
                  .padding({ left: AppTheme.SPACING_NORMAL, right: AppTheme.SPACING_NORMAL })
                  .onClick(() => {
                    this.showKeyboard = false;
                  })
              }
              .width('100%')
              .margin({ bottom: AppTheme.SPACING_SMALL })
              
              MathSymbolKeyboard({ inputText: $latexInput })
                .width('100%')
            }
            .width('100%')
            .padding({ 
              left: AppTheme.SPACING_LARGE, 
              right: AppTheme.SPACING_LARGE, 
              top: AppTheme.SPACING_NORMAL, 
              bottom: AppTheme.SPACING_NORMAL 
            })
            .backgroundColor(this.currentTheme === 'dark' ? AppTheme.CARD_BG_DARK : '#F9F9F9')
            .borderRadius(AppTheme.BORDER_RADIUS_MEDIUM)
            .margin({ bottom: AppTheme.SPACING_MEDIUM })
            .animation({
              duration: AppTheme.ANIMATION_DURATION_SLOW,
              curve: Curve.EaseInOut
            })
          }

          // 引导式输入按钮
          Column() {
            Row() {
              Text('引导式输入')
                .fontSize(AppTheme.FONT_SIZE_MEDIUM)
                .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
                .margin({ bottom: AppTheme.SPACING_SMALL })
            }
            .width('100%')
            
            Scroll() {
              Row() {
                this.buildGuidedInputButton('定积分 ∫ᵃᵇ', InputType.DEFINITE_INTEGRAL)
                this.buildGuidedInputButton('不定积分 ∫', InputType.INDEFINITE_INTEGRAL)
                this.buildGuidedInputButton('导数 d/dx', InputType.DERIVATIVE)
                this.buildGuidedInputButton('极限 lim', InputType.LIMIT)
                this.buildGuidedInputButton('偏导数 ∂/∂x', InputType.PARTIAL_DERIVATIVE)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
          .padding({ left: AppTheme.SPACING_LARGE, right: AppTheme.SPACING_LARGE })
          .margin({ bottom: AppTheme.SPACING_MEDIUM })
          
          // 操作类型选择提示
          if (!this.selectedFunction && this.latexInput) {
            Row() {
              Text('👉 请选择下方的计算类型（如求导、积分）以继续')
                .fontSize(13)
                .fontColor('#FF6B00')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ bottom: 10 })
          }
          
          // 快捷功能按钮
          Row() {
            ForEach(this.functionButtons, (btn: string) => {
              Button(btn)
                .fontSize(14)
                .height(40)
                .backgroundColor(this.selectedFunction === btn ? '#1890FF' : '#F0F0F0')
                .fontColor(this.selectedFunction === btn ? '#FFFFFF' : '#333333')
                .borderRadius(20)
                .layoutWeight(1)
                .border({
                  width: this.selectedFunction === btn ? 2 : 0,
                  color: '#1890FF'
                })
                .animation({
                  duration: 200,
                  curve: Curve.EaseInOut
                })
                .onClick(() => {
                  this.selectedFunction = btn;
                  this.errorMessage = '';
                  Logger.info(`Selected function: ${btn}`);
                })
            }, (btn: string) => btn)
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 20 })

          // 计算按钮和清除按钮
          Row() {
            Button('清除')
              .width(100)
              .height(56)
              .fontSize(16)
              .backgroundColor('#FF6B6B')
              .fontColor('#FFFFFF')
              .borderRadius(28)
              .onClick(() => {
                this.clearAll();
              })
            
            Blank()
            
            Button('计算')
              .layoutWeight(1)
              .height(56)
              .fontSize(16)
              .backgroundColor('#52C41A')
              .fontColor('#FFFFFF')
              .borderRadius(28)
              .margin({ left: 12 })
              .onClick(() => {
                this.calculate();
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 24 })
          
          // 错误提示（人性化改进）
          if (this.errorMessage) {
            Column() {
              Row() {
                Text('💡 ')
                  .fontSize(16)
                Text('温馨提示')
                  .fontSize(14)
                  .fontColor('#FF4D4F')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .margin({ bottom: 8 })
              
              Text(this.errorMessage)
                .fontSize(14)
                .fontColor('#333')
                .lineHeight(22)
                .width('100%')
              
              // 如果是极限不存在，添加额外说明
              if (this.errorMessage.includes('DNE') || this.errorMessage.includes('不存在')) {
                Column() {
                  Text('💭 这是什么意思？')
                    .fontSize(13)
                    .fontColor('#666')
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: 12, bottom: 6 })
                  
                  Text('DNE = Does Not Exist，表示极限不存在。这通常发生在函数振荡、左右极限不等或趋向不同无穷大的情况。')
                    .fontSize(12)
                    .fontColor('#999')
                    .lineHeight(18)
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#FFF7E6')
                .borderRadius(6)
                .margin({ top: 8 })
              }
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .backgroundColor('#FFF1F0')
            .borderRadius(12)
            .border({ width: 2, color: '#FFCCC7' })
            .margin({ left: 20, right: 20, bottom: 16 })
          }

          // 解题步骤区域（人性化改进）
          if (this.showSteps && this.steps.length > 0) {
            Column() {
              Row() {
                Text('📚 ')
                  .fontSize(18)
                Text('详细解题步骤')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .width('100%')
              .margin({ bottom: 16 })

              Column() {
                ForEach(this.steps, (step: string, index: number) => {
                  this.buildEnhancedStepItem(step, index);
                }, (step: string, index: number) => `step_${index}`)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F0F9FF')
              .borderRadius(12)
              .border({ width: 1, color: '#BAE7FF' })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ bottom: 24 })
            .alignItems(HorizontalAlign.Start)
          }

          // 结果绘制区域
          if (this.showGraph) {
            Column() {
              Row() {
                Text('结果绘制')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 图形显示区域
              Column() {
                Text('📊')
                  .fontSize(48)
                  .margin({ bottom: 8 })
                Text('函数图形将在这里显示')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(200)
              .backgroundColor('#F5F5F5')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ bottom: 24 })
            .alignItems(HorizontalAlign.Start)
          }

          // 结果显示
          if (this.result) {
            Column() {
              // 标题栏
              Row() {
                Text('✅ ')
                  .fontSize(18)
                  .fontColor('#52C41A')
                
                Text('计算结果')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .width('100%')
              .margin({ bottom: 16 })

              Column() {
                // 输入信息卡片
                Column() {
                  Row() {
                    Text('📝 ')
                      .fontSize(14)
                    Text('输入信息')
                      .fontSize(13)
                      .fontColor('#666')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })
                  
                  Row() {
                    Text('表达式：')
                      .fontSize(13)
                      .fontColor('#999')
                      .width(70)
                    
                    Text(this.latexInput)
                      .fontSize(13)
                      .fontColor('#333')
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .margin({ bottom: 6 })
                  
                  Row() {
                    Text('计算类型：')
                      .fontSize(13)
                      .fontColor('#999')
                      .width(70)
                    
                    Text(this.selectedFunction)
                      .fontSize(13)
                      .fontColor('#1890FF')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .margin({ bottom: 16 })
                
                // 结果卡片
                Column() {
                  Row() {
                    Text('🎯 ')
                      .fontSize(16)
                    Text('计算结果')
                      .fontSize(14)
                      .fontColor('#52C41A')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                  .margin({ bottom: 12 })
                  
                  // 人性化说明文字
                  Text(this.result.split('\n')[0])
                    .fontSize(15)
                    .fontColor('#333')
                    .lineHeight(24)
                    .width('100%')
                    .margin({ bottom: 12 })
                  
                  // 数学公式（如果有）
                  if (this.result.includes('\n')) {
                    Column() {
                      if (this.resultLatex) {
                        LaTeXRenderer({ latex: this.resultLatex })
                          .width('100%')
                      } else {
                        Text(this.result.split('\n')[1])
                          .fontSize(16)
                          .fontColor('#52C41A')
                          .fontWeight(FontWeight.Bold)
                          .width('100%')
                          .textAlign(TextAlign.Center)
                          .lineHeight(32)
                      }
                    }
                    .width('100%')
                    .padding(16)
                    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
                    .borderRadius(8)
                    .border({ width: 1, color: '#D9F7BE', style: BorderStyle.Dashed })
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#F6FFED')
                .borderRadius(12)
                .border({ width: 2, color: '#B7EB8F' })
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ bottom: 40 })
            .alignItems(HorizontalAlign.Start)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }
  
  /**
   * 构建引导式输入按钮
   */
  @Builder buildGuidedInputButton(label: string, inputType: InputType) {
    Button(label)
      .fontSize(AppTheme.FONT_SIZE_SMALL)
      .height(36)
      .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
      .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
      .borderRadius(AppTheme.BORDER_RADIUS_LARGE)
      .padding({ left: AppTheme.SPACING_MEDIUM, right: AppTheme.SPACING_MEDIUM })
      .margin({ right: AppTheme.SPACING_SMALL })
      .border({
        width: 1,
        color: AppTheme.PRIMARY_COLOR
      })
      .onClick(() => {
        this.showStructuredInput(inputType);
      })
  }

  /**
   * 构建步骤项（保留用于向后兼容）
   */
  @Builder buildStepItem(text: string) {
    Row() {
      Text(text)
        .fontSize(14)
        .fontColor('#333333')
        .lineHeight(28)
        .width('100%')
    }
    .width('100%')
    .margin({ top: 6 })
  }
  
  /**
   * 构建增强的步骤项（人性化改进）
   */
  @Builder buildEnhancedStepItem(step: string, index: number) {
    Row() {
      // 步骤编号
      Column() {
        Text(`${index + 1}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(24)
      .height(24)
      .backgroundColor(index === this.steps.length - 1 ? '#52C41A' : '#1890FF')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })
      
      // 步骤内容
      Column() {
        Text(step)
          .fontSize(14)
          .fontColor('#333')
          .lineHeight(22)
          .width('100%')
        
        // 如果是最后一步，添加特殊标记
        if (index === this.steps.length - 1 && step.includes('结果')) {
          Text('✨ 计算完成')
            .fontSize(12)
            .fontColor('#52C41A')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(index === this.steps.length - 1 ? '#F6FFED' : '#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: index < this.steps.length - 1 ? 8 : 0 })
    .border({
      width: 1,
      color: index === this.steps.length - 1 ? '#B7EB8F' : '#E8F4FF'
    })
  }

  /**
   * 显示结构化输入对话框
   */
  showStructuredInput(inputType: InputType) {
    this.structuredInputDialogController = new CustomDialogController({
      builder: StructuredInputDialog({
        inputType: inputType,
        onConfirm: (result: StructuredInputResult) => {
          if (result.success) {
            this.latexInput = result.expression;
            this.structuredData = result.data || null;
            
            // 自动选择对应的计算类型
            switch (inputType) {
              case InputType.DEFINITE_INTEGRAL:
              case InputType.INDEFINITE_INTEGRAL:
                this.selectedFunction = '积分';
                break;
              case InputType.DERIVATIVE:
              case InputType.PARTIAL_DERIVATIVE:
                this.selectedFunction = '求导';
                break;
              case InputType.LIMIT:
                this.selectedFunction = '极限';
                break;
            }
            
            promptAction.showToast({
              message: '输入完成，点击计算按钮开始计算'
            });
          }
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    
    this.structuredInputDialogController.open();
  }
  
  /**
   * 实时验证输入
   */
  validateInputRealtime(input: string) {
    this.inputValidationMessage = '';
    
    if (!input || input.trim() === '') {
      return;
    }
    
    // 检查括号匹配
    const openParens = (input.match(/\(/g) || []).length;
    const closeParens = (input.match(/\)/g) || []).length;
    if (openParens !== closeParens) {
      this.inputValidationMessage = '括号不匹配';
      return;
    }
    
    // 检查常见错误
    if (input.includes('//')) {
      this.inputValidationMessage = '包含连续除号';
      return;
    }
    
    if (input.includes('**')) {
      this.inputValidationMessage = '幂运算请使用 ^ 符号';
      return;
    }
    
    // 检查是否包含未定义的字符
    const validChars = /^[a-zA-Z0-9+\-*/^().,\s\[\]πe∫∂√∑∏αβγδεθλμσφω<>=!]+$/;
    if (!validChars.test(input)) {
      this.inputValidationMessage = '包含不支持的字符';
      return;
    }
    
    // 验证通过
    this.inputValidationMessage = '输入格式正确 ✓';
  }
  
  /**
   * 清除所有内容
   */
  clearAll() {
    this.latexInput = '';
    this.result = '';
    this.resultLatex = '';
    this.steps = [];
    this.showSteps = false;
    this.showGraph = false;
    this.errorMessage = '';
    this.inputValidationMessage = '';
    this.selectedFunction = '';
    this.structuredData = null;
    
    promptAction.showToast({
      message: '已清除'
    });
  }

  /**
   * 计算
   */
  async calculate() {
    // 重置状态
    this.result = '';
    this.resultLatex = '';
    this.steps = [];
    this.showSteps = false;
    this.showGraph = false;
    this.errorMessage = '';
    
    // 验证输入
    if (!this.latexInput || this.latexInput.trim() === '') {
      this.errorMessage = '请输入公式';
      promptAction.showToast({
        message: '请输入公式'
      });
      return;
    }

    if (!this.selectedFunction) {
      this.errorMessage = '请选择计算类型';
      promptAction.showToast({
        message: '请选择计算类型'
      });
      return;
    }

    Logger.info(`Calculating: ${this.latexInput} with function: ${this.selectedFunction}`);
    
    try {
      switch (this.selectedFunction) {
        case '求导':
          await this.calculateDerivative();
          break;
        case '积分':
          await this.calculateIntegral();
          break;
        case '极限':
          this.calculateLimit();
          break;
        case '方程':
          this.solveEquation();
          break;
        default:
          this.errorMessage = '未知的计算类型';
      }
      
      if (this.result) {
        promptAction.showToast({
          message: '计算完成'
        });
      }
    } catch (error) {
      Logger.error('Calculation error', error);
      this.errorMessage = '计算出错，请检查输入格式';
      promptAction.showToast({
        message: '计算出错'
      });
    }
  }
  
  /**
   * 保存到历史记录
   */
  private async saveToHistory(expression: string, result: string, category: string) {
    try {
      await this.dataManager.saveHistory({
        expression,
        result,
        calc_type: category,
        category: category
      });
      Logger.info(`Saved to history: ${category}`);
    } catch (error) {
      Logger.error('Failed to save history', error);
    }
  }

  /**
   * 计算导数
   */
  private async calculateDerivative() {
    const expression: string = this.latexInput.trim();
    const variable: string = this.structuredData?.variable || 'x';
    const order: number = this.structuredData?.order || 1;
    
    Logger.info(`Calculating derivative: ${expression} with respect to ${variable}, order=${order}`);
    
    try {
      // 预处理表达式，将 ^ 转换为 ** (Python幂运算符)
      const processedExpression = this.preprocessExpression(expression);
      
      // 使用后端API进行符号求导
      const response = await backendAPI.differentiate(processedExpression, variable);
      
      Logger.info('Backend API response:', JSON.stringify(response));
      
      if (response.success && response.data) {
        const derivative = response.data.result || '';
        
        Logger.info('Derivative result:', derivative);
        
        if (!derivative || derivative.trim() === '') {
          this.errorMessage = '计算结果为空，请检查表达式格式';
          Logger.error('Empty derivative result');
          return;
        }
        
        // 使用数学符号美化显示
        const orderSymbol = order === 1 ? "'" : order === 2 ? "''" : `^(${order})`;
        const explanation = `函数 ${expression} 的${order}阶导数为：`;
        const formula = `\nf${orderSymbol}(${variable}) = ${this.beautifyMathExpression(derivative)}`;
        this.result = explanation + formula;
        
        // 生成LaTeX
        this.resultLatex = response.data.latex || `f${orderSymbol}(${variable}) = ${this.toLatex(derivative)}`;
        
        // 生成详细步骤
        this.steps = [
          `原函数: f(${variable}) = ${expression}`,
          `预处理表达式: ${processedExpression}`,
          `求 ${order} 阶导数`,
          `使用SymPy符号计算`,
          `最终结果: f${orderSymbol}(${variable}) = ${derivative}`
        ];
        this.showSteps = true;
        
        // 保存到历史记录
        this.saveToHistory(expression, derivative, 'derivative');
        
        Logger.info('Derivative calculation completed successfully');
      } else {
        this.errorMessage = response.error || '求导失败';
        Logger.error('Derivative calculation failed:', response.error);
        Logger.error('Full response:', JSON.stringify(response));
      }
    } catch (error) {
      Logger.error('Derivative calculation error:', error);
      this.errorMessage = `计算出错: ${error instanceof Error ? error.message : '未知错误'}。请检查表达式格式或网络连接。`;
    }
  }
  
  /**
   * 预处理数学表达式（转换符号格式）
   */
  private preprocessExpression(expr: string): string {
    let processed = expr.trim();
    
    // 替换 ^ 为 ** (Python幂运算符)
    processed = processed.replace(/\^/g, '**');
    
    // 去掉空格
    processed = processed.replace(/\s+/g, '');
    
    return processed;
  }

  /**
   * 计算积分
   */
  private async calculateIntegral() {
    const expression: string = this.latexInput.trim();
    const variable: string = this.structuredData?.variable || 'x';
    
    // 检查是否为定积分（包含积分限）
    const definiteMatch: RegExpMatchArray | null = expression.match(/\[([^,]+),\s*([^\]]+)\]/);
    
    if (definiteMatch || this.structuredData?.lowerLimit) {
      // 定积分 - 使用后端API
      const from: string = this.structuredData?.lowerLimit || definiteMatch![1];
      const to: string = this.structuredData?.upperLimit || definiteMatch![2];
      let expr: string = this.structuredData?.function || expression.replace(/\[.*?\]/, '').trim();
      
      // 预处理表达式
      expr = this.preprocessExpression(expr);
      
      // 解析数值
      const fromNum = this.parseValue(from);
      const toNum = this.parseValue(to);
      
      Logger.info(`Calculating definite integral using backend: ∫[${fromNum}, ${toNum}] ${expr} d${variable}`);
      
      try {
        const response = await backendAPI.integrate(expr, fromNum, toNum, variable);
        
        if (response.success && response.data) {
          const integralValue = response.data.result || '';
          const fromStr = from === 'π' || from === 'pi' ? 'π' : from;
          const toStr = to === 'π' || to === 'pi' ? 'π' : to;
          
          const explanation = `计算从 ${fromStr} 到 ${toStr} 的定积分：`;
          const formula = `\n∫[${fromStr}, ${toStr}] ${this.beautifyMathExpression(expr)} d${variable} = ${integralValue}`;
          
          this.result = explanation + formula;
          
          // 生成LaTeX
          this.resultLatex = `\\int_{${fromStr}}^{${toStr}} ${this.toLatex(expr)} \\, d${variable} = ${integralValue}`;
          
          this.steps = [
            `原函数: f(${variable}) = ${expr}`,
            `积分区间: [${fromStr}, ${toStr}]`,
            `使用数值积分方法（Simpson）`,
            `结果: ${integralValue}`
          ];
          this.showSteps = true;
          
          // 保存到历史记录
          this.saveToHistory(`${expr}[${fromStr}, ${toStr}]`, integralValue, 'integral');
        } else {
          this.errorMessage = response.error || '积分计算失败';
          Logger.error('Integral calculation failed:', response.error);
        }
      } catch (error) {
        Logger.error('Integral calculation error:', error);
        this.errorMessage = '计算出错，请检查表达式格式';
      }
    } else {
      // 不定积分 - 暂不支持，使用本地引擎
      const expr: string = this.structuredData?.function || expression;
      const result: IntegralResult = this.calculusEngine.indefiniteIntegral(expr, variable);
      
      if (result.success && result.integral) {
        const explanation = `函数 ${expr} 的不定积分为：`;
        const formula = `\n∫ ${this.beautifyMathExpression(expr)} d${variable} = ${this.beautifyMathExpression(result.integral)} + C`;
        
        this.result = explanation + formula;
        
        this.resultLatex = `\\int ${this.toLatex(expr)} \\, d${variable} = ${this.toLatex(result.integral)} + C`;
        
        this.steps = result.steps || [];
        this.showSteps = true;
      } else {
        this.errorMessage = result.error || '积分计算失败';
        this.steps = result.steps || [];
        this.showSteps = true;
      }
    }
  }
  
  /**
   * 解析数值（支持π、∞等常数）
   */
  private parseValue(value: string): number {
    const trimmed = value.trim().toLowerCase();
    if (trimmed === 'π' || trimmed === 'pi') {
      return Math.PI;
    }
    if (trimmed === 'e') {
      return Math.E;
    }
    if (trimmed === '∞' || trimmed === 'inf' || trimmed === 'infinity') {
      return Infinity;
    }
    if (trimmed === '-∞' || trimmed === '-inf' || trimmed === '-infinity') {
      return -Infinity;
    }
    return parseFloat(trimmed);
  }
  
  /**
   * 计算极限
   */
  private calculateLimit() {
    const expression: string = this.latexInput.trim();
    const variable: string = this.structuredData?.variable || 'x';
    
    let expr: string;
    let approachValue: number;
    let direction: string = this.structuredData?.direction || 'both';
    
    if (this.structuredData?.function) {
      // 使用结构化输入数据
      expr = this.structuredData.function;
      approachValue = this.parseValue(this.structuredData.approachValue || '0');
    } else {
      // 简单解析极限表达式，例如: "x^2, x->2"
      const parts: string[] = expression.split(',');
      if (parts.length < 2) {
        this.errorMessage = '请使用格式: 表达式, x->值 (例如: x^2, x->2) 或使用引导式输入';
        return;
      }
      
      expr = parts[0].trim();
      const limitPart: string = parts[1].trim();
      const limitMatch: RegExpMatchArray | null = limitPart.match(/([a-zA-Z])\s*->\s*([^\s]+)/);
      
      if (!limitMatch) {
        this.errorMessage = '极限格式错误，请使用 x->值';
        return;
      }
      
      approachValue = this.parseValue(limitMatch[2]);
    }
    
    const result: LimitResult = this.calculusEngine.limit(expr, variable, approachValue);
    
    if (result.success && result.limit !== undefined) {
      const directionSymbol = direction === 'left' ? '⁻' : direction === 'right' ? '⁺' : '';
      const approachStr = approachValue === Infinity ? '∞' : approachValue.toString();
      
      // 生成人性化的结果说明
      const humanReadableResult = this.generateHumanReadableLimitResult(expr, variable, approachStr, result.limit);
      
      this.result = humanReadableResult;
      
      // 生成LaTeX
      this.resultLatex = `\\lim_{${variable} \\to ${approachStr}${directionSymbol}} ${this.toLatex(expr)} = ${result.limit}`;
      
      // 生成详细步骤
      this.steps = result.steps || [];
      this.showSteps = true;
    } else {
      this.errorMessage = result.error || '极限计算失败';
      this.steps = result.steps || [];
      this.showSteps = true;
    }
  }
  
  /**
   * 生成人性化的极限结果说明
   */
  private generateHumanReadableLimitResult(expr: string, variable: string, approachStr: string, limitValue: string): string {
    let explanation = '';
    
    // 根据极限值生成不同的说明
    if (limitValue === '+∞') {
      explanation = `当 ${variable} 趋向 ${approachStr} 时，函数 ${expr} 趋向正无穷大 (+∞)`;
    } else if (limitValue === '-∞') {
      explanation = `当 ${variable} 趋向 ${approachStr} 时，函数 ${expr} 趋向负无穷大 (-∞)`;
    } else if (limitValue === '0' || limitValue === '0.000000') {
      explanation = `当 ${variable} 趋向 ${approachStr} 时，函数 ${expr} 趋向 0`;
    } else if (limitValue === '1' || limitValue === '1.000000') {
      explanation = `当 ${variable} 趋向 ${approachStr} 时，函数 ${expr} 趋向 1`;
    } else {
      explanation = `当 ${variable} 趋向 ${approachStr} 时，函数 ${expr} 趋向 ${limitValue}`;
    }
    
    // 添加数学公式
    const formula = `\nlim(${variable}→${approachStr}) ${this.beautifyMathExpression(expr)} = ${limitValue}`;
    
    return explanation + formula;
  }
  
  /**
   * 美化数学表达式显示
   */
  private beautifyMathExpression(expr: string): string {
    let beautified = expr;
    
    // 替换幂运算符为上标符号
    beautified = beautified.replace(/\^2/g, '²');
    beautified = beautified.replace(/\^3/g, '³');
    beautified = beautified.replace(/\^(\d+)/g, '^$1');
    
    // 替换乘号
    beautified = beautified.replace(/\*/g, '·');
    
    // 替换除号
    beautified = beautified.replace(/\//g, '÷');
    
    return beautified;
  }
  
  /**
   * 转换为LaTeX格式
   */
  private toLatex(expr: string): string {
    let latex = expr;
    
    // 替换幂运算
    latex = latex.replace(/\^(\d+)/g, '^{$1}');
    latex = latex.replace(/\^([a-zA-Z])/g, '^{$1}');
    
    // 替换分数
    latex = latex.replace(/\(([^)]+)\)\/\(([^)]+)\)/g, '\\frac{$1}{$2}');
    
    // 替换函数
    latex = latex.replace(/sqrt\(/g, '\\sqrt{');
    latex = latex.replace(/sin\(/g, '\\sin(');
    latex = latex.replace(/cos\(/g, '\\cos(');
    latex = latex.replace(/tan\(/g, '\\tan(');
    latex = latex.replace(/log\(/g, '\\log(');
    latex = latex.replace(/ln\(/g, '\\ln(');
    latex = latex.replace(/exp\(/g, '\\exp(');
    
    // 替换常数
    latex = latex.replace(/π/g, '\\pi');
    latex = latex.replace(/pi/g, '\\pi');
    
    return latex;
  }
  
  /**
   * 求解方程
   */
  private solveEquation() {
    const expression = this.latexInput.trim();
    
    // 解析方程类型
    // 一元二次方程: ax^2 + bx + c = 0
    const quadraticMatch = expression.match(/(-?\d*)\*?x\^2\s*([+-]?\s*\d*)\*?x?\s*([+-]?\s*\d+)\s*=\s*0/);
    
    if (quadraticMatch) {
      const a = parseFloat(quadraticMatch[1] || '1');
      const b = parseFloat(quadraticMatch[2]?.replace(/\s/g, '') || '0');
      const c = parseFloat(quadraticMatch[3]?.replace(/\s/g, '') || '0');
      
      const result: SolveResult = this.equationSolver.solveQuadratic(a, b, c);
      
      if (result.success && result.solutions) {
        if (result.solutions.length === 1) {
          this.result = `x = ${result.solutions[0]}`;
        } else {
          this.result = `x₁ = ${result.solutions[0]}\nx₂ = ${result.solutions[1]}`;
        }
        this.steps = result.steps || [];
        this.showSteps = true;
      } else {
        this.errorMessage = result.error || '方程求解失败';
        this.steps = result.steps || [];
        this.showSteps = true;
      }
      return;
    }
    
    // 一元一次方程: ax + b = 0
    const linearMatch = expression.match(/(-?\d*)\*?x\s*([+-]?\s*\d+)\s*=\s*0/);
    
    if (linearMatch) {
      const a = parseFloat(linearMatch[1] || '1');
      const b = parseFloat(linearMatch[2]?.replace(/\s/g, '') || '0');
      
      const result: SolveResult = this.equationSolver.solveLinear(a, b);
      
      if (result.success && result.solutions) {
        this.result = `x = ${result.solutions[0]}`;
        this.steps = result.steps || [];
        this.showSteps = true;
      } else {
        this.errorMessage = result.error || '方程求解失败';
        this.steps = result.steps || [];
        this.showSteps = true;
      }
      return;
    }
    
    this.errorMessage = '暂不支持该类型方程，请使用标准格式 (例如: x^2 + 2*x + 1 = 0)';
  }
}
