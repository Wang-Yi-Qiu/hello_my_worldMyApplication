/**
 * 高等数学页面
 * 包含方程求解、微积分等功能
 */
import { Logger } from '../utils/Logger';
import { EquationSolver, SolveResult, LinearSystemResult } from '../modules/EquationSolver';
import { CalculusEngine, DerivativeResult, IntegralResult } from '../modules/CalculusEngine';
import promptAction from '@ohos.promptAction';

@Component
export struct AdvancedMathPage {
  @State currentTab: number = 0;
  @State currentEquationType: string = '';
  @State showEquationSolver: boolean = false;
  @State currentCalculusType: string = '';
  @State showCalculusSolver: boolean = false;
  
  private tabNames: string[] = ['方程求解', '微积分', '矩阵运算'];
  
  build() {
    Column() {
      // Tab 切换栏
      Row() {
        ForEach(this.tabNames, (name: string, index: number) => {
          Text(name)
            .fontSize(16)
            .fontColor(this.currentTab === index ? '#1890ff' : '#666')
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            .padding(10)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.currentTab = index;
              this.showEquationSolver = false;
              this.showCalculusSolver = false;
              Logger.info(`Switched to tab: ${name}`);
            })
            .border({
              width: { bottom: this.currentTab === index ? 2 : 0 },
              color: '#1890ff'
            })
        }, (name: string) => name)
      }
      .width('100%')
      .backgroundColor('#fff')
      
      // 内容区域
      if (this.currentTab === 0) {
        if (this.showEquationSolver) {
          this.buildEquationSolverDetail();
        } else {
          this.buildEquationSolverTab();
        }
      } else if (this.currentTab === 1) {
        if (this.showCalculusSolver) {
          this.buildCalculusDetail();
        } else {
          this.buildCalculusTab();
        }
      } else {
        this.buildMatrixTab();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  /**
   * 方程求解 Tab
   */
  @Builder buildEquationSolverTab() {
    Column() {
      Text('方程求解器')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
      
      Text('选择方程类型：')
        .fontSize(14)
        .fontColor('#666')
        .margin({ top: 10, bottom: 10 })
      
      // 方程类型选择
      Column() {
        this.buildEquationTypeButton('一元一次方程', 'ax + b = 0');
        this.buildEquationTypeButton('一元二次方程', 'ax² + bx + c = 0');
        this.buildEquationTypeButton('一元三次方程', 'ax³ + bx² + cx + d = 0');
        this.buildEquationTypeButton('二元一次方程组', '2x2 线性方程组');
        this.buildEquationTypeButton('三元一次方程组', '3x3 线性方程组');
      }
      .width('90%')
      .padding(10)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(20)
    .justifyContent(FlexAlign.Start)
  }
  
  /**
   * 微积分 Tab
   */
  @Builder buildCalculusTab() {
    Column() {
      Text('微积分计算')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
      
      Text('选择计算类型：')
        .fontSize(14)
        .fontColor('#666')
        .margin({ top: 10, bottom: 10 })
      
      // 微积分类型选择
      Column() {
        this.buildCalculusTypeButton('求导数', 'd/dx f(x)');
        this.buildCalculusTypeButton('定积分', '∫[a,b] f(x) dx');
        this.buildCalculusTypeButton('不定积分', '∫ f(x) dx');
        this.buildCalculusTypeButton('极限', 'lim f(x) as x → a');
        this.buildCalculusTypeButton('泰勒展开', 'f(x) ≈ Σ...');
      }
      .width('90%')
      .padding(10)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(20)
    .justifyContent(FlexAlign.Start)
  }
  
  /**
   * 矩阵运算 Tab
   */
  @Builder buildMatrixTab() {
    Column() {
      Text('🚧 矩阵运算')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
      
      Text('功能开发中...')
        .fontSize(16)
        .fontColor('#999')
        .margin({ top: 50 })
      
      Text('即将支持：')
        .fontSize(14)
        .fontColor('#666')
        .margin({ top: 20, bottom: 10 })
      
      Column() {
        this.buildFeatureItem('• 矩阵加减乘');
        this.buildFeatureItem('• 行列式计算');
        this.buildFeatureItem('• 矩阵求逆');
        this.buildFeatureItem('• 特征值与特征向量');
        this.buildFeatureItem('• 矩阵分解（LU、QR、SVD）');
      }
      .alignItems(HorizontalAlign.Start)
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(20)
    .justifyContent(FlexAlign.Start)
  }
  
  /**
   * 方程类型按钮
   */
  @Builder buildEquationTypeButton(title: string, description: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
      
      Text(description)
        .fontSize(12)
        .fontColor('#999')
        .margin({ top: 5 })
    }
    .width('100%')
    .padding(15)
    .margin({ bottom: 10 })
    .backgroundColor('#fff')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      Logger.info(`Equation type selected: ${title}`);
      this.currentEquationType = title;
      this.showEquationSolver = true;
    })
  }
  
  /**
   * 微积分类型按钮
   */
  @Builder buildCalculusTypeButton(title: string, formula: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333')
      
      Text(formula)
        .fontSize(12)
        .fontColor('#999')
        .fontFamily('monospace')
        .margin({ top: 5 })
    }
    .width('100%')
    .padding(15)
    .margin({ bottom: 10 })
    .backgroundColor('#fff')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      Logger.info(`Calculus type selected: ${title}`);
      this.currentCalculusType = title;
      this.showCalculusSolver = true;
    })
  }
  
  /**
   * 功能项
   */
  @Builder buildFeatureItem(text: string) {
    Text(text)
      .fontSize(14)
      .fontColor('#666')
      .margin({ bottom: 8 })
  }
  
  /**
   * 方程求解详细界面
   */
  @Builder buildEquationSolverDetail() {
    Column() {
      // 返回按钮
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1890ff')
          .onClick(() => {
            this.showEquationSolver = false;
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')
      
      // 根据不同类型显示不同的求解器
      if (this.currentEquationType === '一元一次方程') {
        this.buildLinearEquationSolver();
      } else if (this.currentEquationType === '一元二次方程') {
        this.buildQuadraticEquationSolver();
      } else if (this.currentEquationType === '一元三次方程') {
        this.buildCubicEquationSolver();
      } else if (this.currentEquationType === '二元一次方程组') {
        this.buildLinearSystem2x2Solver();
      } else if (this.currentEquationType === '三元一次方程组') {
        this.buildLinearSystem3x3Solver();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  /**
   * 微积分计算详细界面
   */
  @Builder buildCalculusDetail() {
    Column() {
      // 返回按钮
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1890ff')
          .onClick(() => {
            this.showCalculusSolver = false;
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')
      
      // 根据不同类型显示不同的计算器
      if (this.currentCalculusType === '求导数') {
        this.buildDerivativeCalculator();
      } else if (this.currentCalculusType === '定积分') {
        this.buildDefiniteIntegralCalculator();
      } else if (this.currentCalculusType === '不定积分') {
        this.buildIndefiniteIntegralCalculator();
      } else if (this.currentCalculusType === '极限') {
        this.buildLimitCalculator();
      } else if (this.currentCalculusType === '泰勒展开') {
        this.buildTaylorSeriesCalculator();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  // ============ 方程求解器实现 ============
  
  /**
   * 一元一次方程求解器
   */
  @Builder buildLinearEquationSolver() {
    LinearEquationSolver()
  }
  
  /**
   * 一元二次方程求解器
   */
  @Builder buildQuadraticEquationSolver() {
    QuadraticEquationSolver()
  }
  
  /**
   * 一元三次方程求解器
   */
  @Builder buildCubicEquationSolver() {
    CubicEquationSolver()
  }
  
  /**
   * 二元一次方程组求解器
   */
  @Builder buildLinearSystem2x2Solver() {
    LinearSystem2x2Solver()
  }
  
  /**
   * 三元一次方程组求解器
   */
  @Builder buildLinearSystem3x3Solver() {
    LinearSystem3x3Solver()
  }
  
  // ============ 微积分计算器实现 ============
  
  /**
   * 导数计算器
   */
  @Builder buildDerivativeCalculator() {
    DerivativeCalculator()
  }
  
  /**
   * 定积分计算器
   */
  @Builder buildDefiniteIntegralCalculator() {
    DefiniteIntegralCalculator()
  }
  
  /**
   * 不定积分计算器
   */
  @Builder buildIndefiniteIntegralCalculator() {
    IndefiniteIntegralCalculator()
  }
  
  /**
   * 极限计算器
   */
  @Builder buildLimitCalculator() {
    LimitCalculator()
  }
  
  /**
   * 泰勒级数计算器
   */
  @Builder buildTaylorSeriesCalculator() {
    TaylorSeriesCalculator()
  }
}

// ============ 子组件实现 ============

/**
 * 一元一次方程求解器组件
 */
@Component
struct LinearEquationSolver {
  @State coeffA: string = '';
  @State coeffB: string = '';
  @State result: SolveResult | null = null;
  private solver: EquationSolver = new EquationSolver();
  
  build() {
    Scroll() {
      Column() {
        Text('一元一次方程求解器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('ax + b = 0')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Row() {
            Text('系数 a:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 a' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffA = value;
              })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          Row() {
            Text('系数 b:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 b' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffB = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Button('求解')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              const a = parseFloat(this.coeffA);
              const b = parseFloat(this.coeffB);
              
              if (isNaN(a) || isNaN(b)) {
                promptAction.showToast({ message: '请输入有效的数字' });
                return;
              }
              
              this.result = this.solver.solveLinear(a, b);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('求解结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success) {
              Text('解：' + (this.result.solutions ? this.result.solutions.join(', ') : ''))
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 10 })
              
              if (this.result.steps && this.result.steps.length > 0) {
                Text('求解步骤：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 10, bottom: 5 })
                
                ForEach(this.result.steps, (step: string, index: number) => {
                  Text(`${index + 1}. ${step}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 5 })
                    .width('100%')
                }, (step: string, index: number) => index.toString())
              }
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 一元二次方程求解器组件
 */
@Component
struct QuadraticEquationSolver {
  @State coeffA: string = '';
  @State coeffB: string = '';
  @State coeffC: string = '';
  @State result: SolveResult | null = null;
  private solver: EquationSolver = new EquationSolver();
  
  build() {
    Scroll() {
      Column() {
        Text('一元二次方程求解器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('ax² + bx + c = 0')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Row() {
            Text('系数 a:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 a' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffA = value;
              })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          Row() {
            Text('系数 b:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 b' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffB = value;
              })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          Row() {
            Text('系数 c:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 c' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffC = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Button('求解')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              const a = parseFloat(this.coeffA);
              const b = parseFloat(this.coeffB);
              const c = parseFloat(this.coeffC);
              
              if (isNaN(a) || isNaN(b) || isNaN(c)) {
                promptAction.showToast({ message: '请输入有效的数字' });
                return;
              }
              
              this.result = this.solver.solveQuadratic(a, b, c);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('求解结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success) {
              if (this.result.solutions && this.result.solutions.length > 0) {
                Text('解：')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 5 })
                
                ForEach(this.result.solutions, (sol: string, index: number) => {
                  Text(`x${index + 1} = ${sol}`)
                    .fontSize(16)
                    .fontColor('#52c41a')
                    .margin({ bottom: 5 })
                }, (sol: string, index: number) => index.toString())
              }
              
              if (this.result.steps && this.result.steps.length > 0) {
                Text('求解步骤：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 10, bottom: 5 })
                
                ForEach(this.result.steps, (step: string, index: number) => {
                  Text(`${index + 1}. ${step}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 5 })
                    .width('100%')
                }, (step: string, index: number) => index.toString())
              }
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 一元三次方程求解器组件
 */
@Component
struct CubicEquationSolver {
  @State coeffA: string = '';
  @State coeffB: string = '';
  @State coeffC: string = '';
  @State coeffD: string = '';
  @State result: SolveResult | null = null;
  private solver: EquationSolver = new EquationSolver();
  
  build() {
    Scroll() {
      Column() {
        Text('一元三次方程求解器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('ax³ + bx² + cx + d = 0')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Row() {
            Text('系数 a:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 a' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffA = value;
              })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          Row() {
            Text('系数 b:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 b' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffB = value;
              })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          Row() {
            Text('系数 c:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 c' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffC = value;
              })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          Row() {
            Text('系数 d:')
              .width(80)
              .fontSize(16)
            TextInput({ placeholder: '请输入 d' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.coeffD = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Button('求解')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              const a = parseFloat(this.coeffA);
              const b = parseFloat(this.coeffB);
              const c = parseFloat(this.coeffC);
              const d = parseFloat(this.coeffD);
              
              if (isNaN(a) || isNaN(b) || isNaN(c) || isNaN(d)) {
                promptAction.showToast({ message: '请输入有效的数字' });
                return;
              }
              
              this.result = this.solver.solveCubic(a, b, c, d);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('求解结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success) {
              if (this.result.solutions && this.result.solutions.length > 0) {
                Text('解：')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 5 })
                
                ForEach(this.result.solutions, (sol: string, index: number) => {
                  Text(`x${index + 1} = ${sol}`)
                    .fontSize(16)
                    .fontColor('#52c41a')
                    .margin({ bottom: 5 })
                }, (sol: string, index: number) => index.toString())
              }
              
              if (this.result.steps && this.result.steps.length > 0) {
                Text('求解步骤：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 10, bottom: 5 })
                
                ForEach(this.result.steps, (step: string, index: number) => {
                  Text(`${index + 1}. ${step}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 5 })
                    .width('100%')
                }, (step: string, index: number) => index.toString())
              }
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 二元一次方程组求解器组件
 */
@Component
struct LinearSystem2x2Solver {
  @State a1: string = '';
  @State b1: string = '';
  @State c1: string = '';
  @State a2: string = '';
  @State b2: string = '';
  @State c2: string = '';
  @State result: LinearSystemResult | null = null;
  private solver: EquationSolver = new EquationSolver();
  
  build() {
    Scroll() {
      Column() {
        Text('二元一次方程组求解器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Column() {
          Text('a₁x + b₁y = c₁')
            .fontSize(16)
            .fontColor('#666')
          Text('a₂x + b₂y = c₂')
            .fontSize(16)
            .fontColor('#666')
        }
        .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Text('第一个方程：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })
          
          Row() {
            Text('a₁:')
              .width(60)
              .fontSize(16)
            TextInput({ placeholder: '系数 a₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.a1 = value;
              })
          }
          .width('100%')
          .margin({ bottom: 10 })
          
          Row() {
            Text('b₁:')
              .width(60)
              .fontSize(16)
            TextInput({ placeholder: '系数 b₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.b1 = value;
              })
          }
          .width('100%')
          .margin({ bottom: 10 })
          
          Row() {
            Text('c₁:')
              .width(60)
              .fontSize(16)
            TextInput({ placeholder: '常数 c₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.c1 = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Text('第二个方程：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })
          
          Row() {
            Text('a₂:')
              .width(60)
              .fontSize(16)
            TextInput({ placeholder: '系数 a₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.a2 = value;
              })
          }
          .width('100%')
          .margin({ bottom: 10 })
          
          Row() {
            Text('b₂:')
              .width(60)
              .fontSize(16)
            TextInput({ placeholder: '系数 b₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.b2 = value;
              })
          }
          .width('100%')
          .margin({ bottom: 10 })
          
          Row() {
            Text('c₂:')
              .width(60)
              .fontSize(16)
            TextInput({ placeholder: '常数 c₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.c2 = value;
              })
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Button('求解')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              const params = [
                parseFloat(this.a1), parseFloat(this.b1), parseFloat(this.c1),
                parseFloat(this.a2), parseFloat(this.b2), parseFloat(this.c2)
              ];
              
              if (params.some(p => isNaN(p))) {
                promptAction.showToast({ message: '请输入有效的数字' });
                return;
              }
              
              this.result = this.solver.solveLinearSystem2x2(
                params[0], params[1], params[2],
                params[3], params[4], params[5]
              );
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('求解结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success && this.result.solution) {
              Text(`x = ${this.result.solution.get('x')}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 5 })
              Text(`y = ${this.result.solution.get('y')}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 5 })
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 三元一次方程组求解器组件
 */
@Component
struct LinearSystem3x3Solver {
  @State a1: string = '';
  @State b1: string = '';
  @State c1: string = '';
  @State d1: string = '';
  @State a2: string = '';
  @State b2: string = '';
  @State c2: string = '';
  @State d2: string = '';
  @State a3: string = '';
  @State b3: string = '';
  @State c3: string = '';
  @State d3: string = '';
  @State result: LinearSystemResult | null = null;
  private solver: EquationSolver = new EquationSolver();
  
  build() {
    Scroll() {
      Column() {
        Text('三元一次方程组求解器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Column() {
          Text('a₁x + b₁y + c₁z = d₁')
            .fontSize(14)
            .fontColor('#666')
          Text('a₂x + b₂y + c₂z = d₂')
            .fontSize(14)
            .fontColor('#666')
          Text('a₃x + b₃y + c₃z = d₃')
            .fontSize(14)
            .fontColor('#666')
        }
        .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          // 第一个方程
          Text('方程 1：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          Row() {
            TextInput({ placeholder: 'a₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.a1 = value; })
              .margin({ right: 5 })
            TextInput({ placeholder: 'b₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.b1 = value; })
              .margin({ right: 5 })
            TextInput({ placeholder: 'c₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.c1 = value; })
              .margin({ right: 5 })
            Text('=')
              .fontSize(16)
              .margin({ right: 5 })
            TextInput({ placeholder: 'd₁' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.d1 = value; })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          // 第二个方程
          Text('方程 2：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          Row() {
            TextInput({ placeholder: 'a₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.a2 = value; })
              .margin({ right: 5 })
            TextInput({ placeholder: 'b₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.b2 = value; })
              .margin({ right: 5 })
            TextInput({ placeholder: 'c₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.c2 = value; })
              .margin({ right: 5 })
            Text('=')
              .fontSize(16)
              .margin({ right: 5 })
            TextInput({ placeholder: 'd₂' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.d2 = value; })
          }
          .width('100%')
          .margin({ bottom: 15 })
          
          // 第三个方程
          Text('方程 3：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          Row() {
            TextInput({ placeholder: 'a₃' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.a3 = value; })
              .margin({ right: 5 })
            TextInput({ placeholder: 'b₃' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.b3 = value; })
              .margin({ right: 5 })
            TextInput({ placeholder: 'c₃' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.c3 = value; })
              .margin({ right: 5 })
            Text('=')
              .fontSize(16)
              .margin({ right: 5 })
            TextInput({ placeholder: 'd₃' })
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => { this.d3 = value; })
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Button('求解')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              const params = [
                parseFloat(this.a1), parseFloat(this.b1), parseFloat(this.c1), parseFloat(this.d1),
                parseFloat(this.a2), parseFloat(this.b2), parseFloat(this.c2), parseFloat(this.d2),
                parseFloat(this.a3), parseFloat(this.b3), parseFloat(this.c3), parseFloat(this.d3)
              ];
              
              if (params.some(p => isNaN(p))) {
                promptAction.showToast({ message: '请输入有效的数字' });
                return;
              }
              
              const matrix = [
                [params[0], params[1], params[2], params[3]],
                [params[4], params[5], params[6], params[7]],
                [params[8], params[9], params[10], params[11]]
              ];
              
              this.result = this.solver.solveLinearSystem3x3(matrix);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('求解结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success && this.result.solution) {
              Text(`x = ${this.result.solution.get('x')}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 5 })
              Text(`y = ${this.result.solution.get('y')}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 5 })
              Text(`z = ${this.result.solution.get('z')}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 5 })
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

// ============ 微积分计算器组件 ============

/**
 * 导数计算器组件
 */
@Component
struct DerivativeCalculator {
  @State expression: string = '';
  @State variable: string = 'x';
  @State result: DerivativeResult | null = null;
  private engine: CalculusEngine = new CalculusEngine();
  
  build() {
    Scroll() {
      Column() {
        Text('导数计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('计算函数的导数')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Text('表达式：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          TextInput({ placeholder: '例如: x^2 或 3x + 5' })
            .width('100%')
            .margin({ bottom: 15 })
            .onChange((value: string) => {
              this.expression = value;
            })
          
          Text('提示：支持基本的多项式函数')
            .fontSize(12)
            .fontColor('#999')
            .margin({ bottom: 20 })
          
          Button('求导')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              if (!this.expression) {
                promptAction.showToast({ message: '请输入表达式' });
                return;
              }
              
              this.result = this.engine.symbolicDerivative(this.expression, this.variable);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('计算结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success) {
              Text(`f'(${this.variable}) = ${this.result.derivative}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 10 })
              
              if (this.result.steps && this.result.steps.length > 0) {
                Text('计算步骤：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 10, bottom: 5 })
                
                ForEach(this.result.steps, (step: string, index: number) => {
                  Text(`${index + 1}. ${step}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 5 })
                    .width('100%')
                }, (step: string, index: number) => index.toString())
              }
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 定积分计算器组件
 */
@Component
struct DefiniteIntegralCalculator {
  @State expression: string = '';
  @State variable: string = 'x';
  @State lowerBound: string = '';
  @State upperBound: string = '';
  @State result: IntegralResult | null = null;
  private engine: CalculusEngine = new CalculusEngine();
  
  build() {
    Scroll() {
      Column() {
        Text('定积分计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('∫[a,b] f(x) dx')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Text('被积函数：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          TextInput({ placeholder: '例如: x*x 或 2*x + 1' })
            .width('100%')
            .margin({ bottom: 15 })
            .onChange((value: string) => {
              this.expression = value;
            })
          
          Row() {
            Column() {
              Text('下限 a:')
                .fontSize(14)
                .margin({ bottom: 5 })
              TextInput({ placeholder: '下限' })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.lowerBound = value;
                })
            }
            .layoutWeight(1)
            .margin({ right: 10 })
            
            Column() {
              Text('上限 b:')
                .fontSize(14)
                .margin({ bottom: 5 })
              TextInput({ placeholder: '上限' })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.upperBound = value;
                })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Button('计算')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              if (!this.expression || !this.lowerBound || !this.upperBound) {
                promptAction.showToast({ message: '请填写完整信息' });
                return;
              }
              
              const lower = parseFloat(this.lowerBound);
              const upper = parseFloat(this.upperBound);
              
              if (isNaN(lower) || isNaN(upper)) {
                promptAction.showToast({ message: '请输入有效的数字' });
                return;
              }
              
              this.result = this.engine.definiteIntegral(this.expression, this.variable, lower, upper);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('计算结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success) {
              Text(`积分值 = ${this.result.value}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 10 })
              
              if (this.result.steps && this.result.steps.length > 0) {
                Text('计算步骤：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 10, bottom: 5 })
                
                ForEach(this.result.steps, (step: string, index: number) => {
                  Text(`${index + 1}. ${step}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 5 })
                    .width('100%')
                }, (step: string, index: number) => index.toString())
              }
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 不定积分计算器组件
 */
@Component
struct IndefiniteIntegralCalculator {
  @State expression: string = '';
  @State variable: string = 'x';
  @State result: IntegralResult | null = null;
  private engine: CalculusEngine = new CalculusEngine();
  
  build() {
    Scroll() {
      Column() {
        Text('不定积分计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('∫ f(x) dx')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Text('被积函数：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          TextInput({ placeholder: '例如: x^2 或 3*x' })
            .width('100%')
            .margin({ bottom: 15 })
            .onChange((value: string) => {
              this.expression = value;
            })
          
          Text('提示：支持基本的多项式函数')
            .fontSize(12)
            .fontColor('#999')
            .margin({ bottom: 20 })
          
          Button('计算')
            .width('100%')
            .height(45)
            .fontSize(16)
            .onClick(() => {
              if (!this.expression) {
                promptAction.showToast({ message: '请输入表达式' });
                return;
              }
              
              this.result = this.engine.indefiniteIntegral(this.expression, this.variable);
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
        .margin({ bottom: 20 })
        
        // 结果显示
        if (this.result !== null) {
          Column() {
            Text('计算结果')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 15 })
            
            if (this.result.success) {
              Text(`∫ ${this.expression} d${this.variable} = ${this.result.integral}`)
                .fontSize(16)
                .fontColor('#52c41a')
                .margin({ bottom: 10 })
              
              if (this.result.steps && this.result.steps.length > 0) {
                Text('计算步骤：')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 10, bottom: 5 })
                
                ForEach(this.result.steps, (step: string, index: number) => {
                  Text(`${index + 1}. ${step}`)
                    .fontSize(14)
                    .fontColor('#666')
                    .margin({ bottom: 5 })
                    .width('100%')
                }, (step: string, index: number) => index.toString())
              }
            } else {
              Text('错误：' + (this.result.error || '未知错误'))
                .fontSize(16)
                .fontColor('#f5222d')
            }
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 极限计算器组件
 */
@Component
struct LimitCalculator {
  @State expression: string = '';
  @State variable: string = 'x';
  @State approachValue: string = '';
  
  build() {
    Scroll() {
      Column() {
        Text('极限计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('lim f(x) as x → a')
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Text('函数表达式：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          TextInput({ placeholder: '例如: (x^2 - 1)/(x - 1)' })
            .width('100%')
            .margin({ bottom: 15 })
            .onChange((value: string) => {
              this.expression = value;
            })
          
          Text(`${this.variable} 趋向于：`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          TextInput({ placeholder: '例如: 0' })
            .width('100%')
            .type(InputType.Number)
            .margin({ bottom: 20 })
            .onChange((value: string) => {
              this.approachValue = value;
            })
          
          Text('提示：该功能需要更完善的数学库支持')
            .fontSize(12)
            .fontColor('#ff9800')
            .margin({ bottom: 15 })
          
          Button('计算')
            .width('100%')
            .height(45)
            .fontSize(16)
            .backgroundColor('#d9d9d9')
            .onClick(() => {
              promptAction.showToast({ message: '极限计算功能开发中...' });
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

/**
 * 泰勒级数计算器组件
 */
@Component
struct TaylorSeriesCalculator {
  @State expression: string = '';
  @State variable: string = 'x';
  @State center: string = '0';
  @State terms: string = '5';
  
  build() {
    Scroll() {
      Column() {
        Text('泰勒级数展开')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 10 })
        
        Text('f(x) ≈ Σ f⁽ⁿ⁾(a)/n! · (x-a)ⁿ')
          .fontSize(14)
          .fontColor('#666')
          .margin({ bottom: 20 })
        
        // 输入区域
        Column() {
          Text('函数表达式：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 5 })
          TextInput({ placeholder: '例如: sin(x) 或 exp(x)' })
            .width('100%')
            .margin({ bottom: 15 })
            .onChange((value: string) => {
              this.expression = value;
            })
          
          Row() {
            Column() {
              Text('展开点 a:')
                .fontSize(14)
                .margin({ bottom: 5 })
              TextInput({ placeholder: '通常为 0' })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.center = value;
                })
            }
            .layoutWeight(1)
            .margin({ right: 10 })
            
            Column() {
              Text('项数:')
                .fontSize(14)
                .margin({ bottom: 5 })
              TextInput({ placeholder: '通常 5-10' })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.terms = value;
                })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 20 })
          
          Text('提示：该功能需要更完善的数学库支持')
            .fontSize(12)
            .fontColor('#ff9800')
            .margin({ bottom: 15 })
          
          Button('计算')
            .width('100%')
            .height(45)
            .fontSize(16)
            .backgroundColor('#d9d9d9')
            .onClick(() => {
              promptAction.showToast({ message: '泰勒展开功能开发中...' });
            })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#fff')
        .borderRadius(12)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
  }
}

