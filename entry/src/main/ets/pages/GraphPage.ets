/**
 * 函数图像页面
 * 使用 Canvas 绘制函数图像
 */
import { Logger } from '../utils/Logger';
import { ChartGenerator, ChartData, Point, TangentLine, DerivativeData } from '../modules/ChartGenerator';
import { EquationSolver, CriticalPoint, IntersectionPoint } from '../modules/EquationSolver';
import { ExpressionEngine } from '../modules/ExpressionEngine';
import { promptAction } from '@kit.ArkUI';

interface FunctionPlot {
  expression: string;
  color: string;
}

@Component
export struct GraphPage {
  @State functions: FunctionPlot[] = [];
  @State currentExpression: string = '';
  @State xMin: number = -10;
  @State xMax: number = 10;
  @State yMin: number = -10;
  @State yMax: number = 10;
  @State isDrawing: boolean = false;
  @State canvasReady: boolean = false;
  @State inputError: string = '';
  @State isValidating: boolean = false;
  @State showCoordinates: boolean = false;
  @State currentX: number = 0;
  @State currentY: number = 0;
  @State touchX: number = 0;
  @State touchY: number = 0;
  
  // 分析功能状态
  @State showDerivative: boolean = false;
  @State showZeros: boolean = false;
  @State showExtrema: boolean = false;
  @State showTangent: boolean = false;
  @State tangentX: number = 0;
  @State analysisResults: string = '';
  @State zeros: number[] = [];
  @State extrema: CriticalPoint[] = [];
  
  private chartGenerator: ChartGenerator = new ChartGenerator();
  private equationSolver: EquationSolver = new EquationSolver();
  private expressionEngine: ExpressionEngine = new ExpressionEngine();
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private colors: string[] = ['#1890ff', '#52c41a', '#ff4d4f', '#fa8c16', '#722ed1', '#13c2c2'];
  
  // 交互状态
  private lastPinchScale: number = 1;
  private lastPanX: number = 0;
  private lastPanY: number = 0;
  private isPanning: boolean = false;
  
  aboutToAppear() {
    Logger.info('GraphPage loaded');
  }
  
  build() {
    Column() {
      // 输入区域
      Column() {
        Text('函数图像绘制')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 16 })
        
        // 已添加的函数列表
        if (this.functions.length > 0) {
          Column() {
            ForEach(this.functions, (func: FunctionPlot, index: number) => {
              Row() {
                Circle({ width: 12, height: 12 })
                  .fill(func.color)
                  .margin({ right: 8 })
                
                Text(`f${index + 1}(x) = ${func.expression}`)
                  .fontSize(14)
                  .fontColor('#333')
                  .layoutWeight(1)
                
                Button('删除')
                  .fontSize(12)
                  .height(28)
                  .backgroundColor('#FF4D4F')
                  .borderRadius(6)
                  .onClick(() => {
                    this.removeFunction(index);
                  })
              }
              .width('100%')
              .padding(8)
              .backgroundColor('#f0f0f0')
              .borderRadius(4)
              .margin({ bottom: 5 })
            }, (func: FunctionPlot, index: number) => `${index}_${func.expression}`)
          }
          .width('100%')
          .margin({ bottom: 10 })
        }
        
        // 表达式输入
        Column() {
          Row() {
            Text('f(x) = ')
              .fontSize(14)
              .fontColor('#333')
              .width(60)
            
            TextInput({ 
              text: this.currentExpression, 
              placeholder: '输入函数表达式，例如：x^2, sin(x), log(x^3+1)' 
            })
              .fontSize(14)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.currentExpression = value;
                // 实时验证表达式
                this.validateExpression(value);
              })
            
            Button('添加')
              .fontSize(14)
              .height(40)
              .backgroundColor(this.inputError ? '#D9D9D9' : '#52C41A')
              .borderRadius(8)
              .margin({ left: 8 })
              .enabled(!this.inputError)
              .onClick(() => {
                this.addFunction();
              })
          }
          .width('100%')
          
          // 实时错误提示
          if (this.inputError) {
            Row() {
              Text('⚠️ ' + this.inputError)
                .fontSize(12)
                .fontColor('#FF4D4F')
                .margin({ top: 4, left: 60 })
            }
            .width('100%')
          }
        }
        .width('100%')
        .margin({ bottom: 10 })
        
        // 范围设置
        Row() {
          Column() {
            Text('X 范围')
              .fontSize(12)
              .fontColor('#666')
              .margin({ bottom: 5 })
            
            Row() {
              TextInput({ text: this.xMin.toString(), placeholder: '-10' })
                .fontSize(12)
                .width(70)
                .onChange((value: string) => {
                  const num = parseFloat(value);
                  if (!isNaN(num)) {
                    this.xMin = num;
                  }
                })
              
              Text(' ~ ')
                .fontSize(12)
                .margin({ left: 5, right: 5 })
              
              TextInput({ text: this.xMax.toString(), placeholder: '10' })
                .fontSize(12)
                .width(70)
                .onChange((value: string) => {
                  const num = parseFloat(value);
                  if (!isNaN(num)) {
                    this.xMax = num;
                  }
                })
            }
          }
          .layoutWeight(1)
          
          Column() {
            Text('Y 范围')
              .fontSize(12)
              .fontColor('#666')
              .margin({ bottom: 5 })
            
            Row() {
              TextInput({ text: this.yMin.toString(), placeholder: '-10' })
                .fontSize(12)
                .width(70)
                .onChange((value: string) => {
                  const num = parseFloat(value);
                  if (!isNaN(num)) {
                    this.yMin = num;
                  }
                })
              
              Text(' ~ ')
                .fontSize(12)
                .margin({ left: 5, right: 5 })
              
              TextInput({ text: this.yMax.toString(), placeholder: '10' })
                .fontSize(12)
                .width(70)
                .onChange((value: string) => {
                  const num = parseFloat(value);
                  if (!isNaN(num)) {
                    this.yMax = num;
                  }
                })
            }
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 10 })
        
        // 操作按钮
        Row() {
          Button('绘制图像')
            .fontSize(16)
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#1890FF')
            .borderRadius(8)
            .onClick(() => {
              this.drawGraph();
            })
          
          Button('保存图像')
            .fontSize(16)
            .width(100)
            .height(44)
            .backgroundColor('#52C41A')
            .borderRadius(8)
            .margin({ left: 10 })
            .enabled(this.functions.length > 0)
            .onClick(() => {
              this.saveImage();
            })
        }
        .width('100%')
        
        // 分析工具栏
        if (this.functions.length > 0) {
          Column() {
            Text('分析工具')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666')
              .margin({ bottom: 8 })
            
            // 第一行工具按钮
            Row() {
              Button(this.showZeros ? '✓ 零点' : '零点')
                .fontSize(12)
                .height(32)
                .layoutWeight(1)
                .backgroundColor(this.showZeros ? '#52C41A' : '#E8E8E8')
                .fontColor(this.showZeros ? '#FFF' : '#333')
                .borderRadius(6)
                .onClick(() => {
                  this.toggleZeros();
                })
              
              Button(this.showExtrema ? '✓ 极值' : '极值')
                .fontSize(12)
                .height(32)
                .layoutWeight(1)
                .backgroundColor(this.showExtrema ? '#52C41A' : '#E8E8E8')
                .fontColor(this.showExtrema ? '#FFF' : '#333')
                .borderRadius(6)
                .margin({ left: 5 })
                .onClick(() => {
                  this.toggleExtrema();
                })
              
              Button(this.showDerivative ? '✓ 导数' : '导数')
                .fontSize(12)
                .height(32)
                .layoutWeight(1)
                .backgroundColor(this.showDerivative ? '#52C41A' : '#E8E8E8')
                .fontColor(this.showDerivative ? '#FFF' : '#333')
                .borderRadius(6)
                .margin({ left: 5 })
                .onClick(() => {
                  this.toggleDerivative();
                })
              
              Button(this.showTangent ? '✓ 切线' : '切线')
                .fontSize(12)
                .height(32)
                .layoutWeight(1)
                .backgroundColor(this.showTangent ? '#FA8C16' : '#E8E8E8')
                .fontColor(this.showTangent ? '#FFF' : '#333')
                .borderRadius(6)
                .margin({ left: 5 })
                .onClick(() => {
                  this.toggleTangent();
                })
            }
            .width('100%')
            
            // 分析结果显示
            if (this.analysisResults) {
              Column() {
                Text('分析结果')
                  .fontSize(12)
                  .fontColor('#666')
                  .margin({ top: 8, bottom: 4 })
                
                Text(this.analysisResults)
                  .fontSize(11)
                  .fontColor('#333')
                  .lineHeight(16)
                  .maxLines(5)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding(8)
              .backgroundColor('#F5F5F5')
              .borderRadius(6)
              .margin({ top: 8 })
            }
          }
          .width('100%')
          .margin({ top: 10 })
          .padding(10)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')
      
      // Canvas 绘图区域
      Stack() {
        Canvas(this.context)
          .width('100%')
          .height('100%')
          .backgroundColor('#fafafa')
          .onReady(() => {
            Logger.info('Canvas ready');
            Logger.info(`Canvas size: ${this.context.width} x ${this.context.height}`);
            this.canvasWidth = this.context.width;
            this.canvasHeight = this.context.height;
            this.canvasReady = true;
            
            // 如果有函数，重新绘制
            if (this.functions.length > 0) {
              this.drawGraph();
            } else {
              // 绘制初始网格
              this.drawInitialGrid();
            }
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down || event.type === TouchType.Move) {
              // 获取触摸点坐标
              const touch = event.touches[0];
              this.touchX = touch.x;
              this.touchY = touch.y;
              
              // 转换为世界坐标
              const worldCoord = this.screenToWorld({ x: touch.x, y: touch.y });
              this.currentX = worldCoord.x;
              this.currentY = worldCoord.y;
              this.showCoordinates = true;
            } else if (event.type === TouchType.Up) {
              // 如果在切线模式，绘制切线
              if (this.showTangent && this.functions.length > 0) {
                const worldCoord = this.screenToWorld({ x: this.touchX, y: this.touchY });
                this.tangentX = worldCoord.x;
                this.drawGraph();
                this.drawTangentLine(this.tangentX);
              }
              
              // 延迟隐藏坐标显示
              setTimeout(() => {
                this.showCoordinates = false;
              }, 1000);
            } else if (event.type === TouchType.Cancel) {
              // 延迟隐藏坐标显示
              setTimeout(() => {
                this.showCoordinates = false;
              }, 1000);
            }
          })
          .gesture(
            // 双指缩放手势
            PinchGesture({ fingers: 2 })
              .onActionUpdate((event: GestureEvent) => {
                if (event.scale && event.scale !== this.lastPinchScale) {
                  this.handleZoom(event.scale / this.lastPinchScale);
                  this.lastPinchScale = event.scale;
                }
              })
              .onActionEnd(() => {
                this.lastPinchScale = 1;
              })
          )
          .gesture(
            // 拖动平移手势
            PanGesture({ fingers: 1 })
              .onActionStart(() => {
                this.isPanning = true;
              })
              .onActionUpdate((event: GestureEvent) => {
                if (event.offsetX !== undefined && event.offsetY !== undefined) {
                  const deltaX = event.offsetX - this.lastPanX;
                  const deltaY = event.offsetY - this.lastPanY;
                  this.handlePan(deltaX, deltaY);
                  this.lastPanX = event.offsetX;
                  this.lastPanY = event.offsetY;
                }
              })
              .onActionEnd(() => {
                this.isPanning = false;
                this.lastPanX = 0;
                this.lastPanY = 0;
              })
          )
        
        // 坐标显示浮窗
        if (this.showCoordinates) {
          Column() {
            Text(`x: ${this.currentX.toFixed(3)}`)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ bottom: 2 })
            Text(`y: ${this.currentY.toFixed(3)}`)
              .fontSize(12)
              .fontColor('#FFFFFF')
          }
          .padding(8)
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .borderRadius(6)
          .position({ x: this.touchX + 10, y: this.touchY - 40 })
        }
        
        // 加载状态提示
        if (this.isDrawing) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#1890FF')
              .margin({ bottom: 10 })
            
            Text('正在计算并绘制图像...')
              .fontSize(14)
              .fontColor('#666')
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(255, 255, 255, 0.9)')
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .padding(10)
      
      // 底部提示
      Text('常用函数：x*x, sin(x), cos(x), exp(x), log(x)')
        .fontSize(12)
        .fontColor('#999')
        .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  /**
   * 绘制初始网格
   */
  private drawInitialGrid() {
    Logger.info('Drawing initial grid');
    this.clearCanvas();
    this.drawGrid();
    this.drawAxes();
  }
  
  /**
   * 清除画布
   */
  private clearCanvas() {
    Logger.info(`Clearing canvas: ${this.canvasWidth}x${this.canvasHeight}`);
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.context.fillStyle = '#fafafa';
    this.context.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }
  
  /**
   * 计算合适的网格间距
   */
  private calculateGridStep(range: number): number {
    // 目标网格数量（大约10-15条线）
    const targetGrids = 10;
    const rawStep = range / targetGrids;
    
    // 将步长规范化为 1, 2, 5 的倍数
    const magnitude = Math.pow(10, Math.floor(Math.log10(rawStep)));
    const normalized = rawStep / magnitude;
    
    let step: number;
    if (normalized <= 1) {
      step = 1 * magnitude;
    } else if (normalized <= 2) {
      step = 2 * magnitude;
    } else if (normalized <= 5) {
      step = 5 * magnitude;
    } else {
      step = 10 * magnitude;
    }
    
    return step;
  }
  
  /**
   * 绘制网格
   */
  private drawGrid() {
    this.context.strokeStyle = '#e0e0e0';
    this.context.lineWidth = 0.5;
    
    // 自动计算网格间距
    const xRange = this.xMax - this.xMin;
    const yRange = this.yMax - this.yMin;
    const xStep = this.calculateGridStep(xRange);
    const yStep = this.calculateGridStep(yRange);
    
    Logger.info(`Grid steps: x=${xStep}, y=${yStep}`);
    
    const grid = this.chartGenerator.generateGrid(
      [this.xMin, this.xMax],
      [this.yMin, this.yMax],
      xStep, yStep
    );
    
    // 绘制垂直线
    grid.verticalLines.forEach(line => {
      const start = this.worldToScreen(line[0]);
      const end = this.worldToScreen(line[1]);
      
      this.context.beginPath();
      this.context.moveTo(start.x, start.y);
      this.context.lineTo(end.x, end.y);
      this.context.stroke();
    });
    
    // 绘制水平线
    grid.horizontalLines.forEach(line => {
      const start = this.worldToScreen(line[0]);
      const end = this.worldToScreen(line[1]);
      
      this.context.beginPath();
      this.context.moveTo(start.x, start.y);
      this.context.lineTo(end.x, end.y);
      this.context.stroke();
    });
    
    // 绘制网格刻度标签
    this.drawGridLabels(xStep, yStep);
  }
  
  /**
   * 绘制网格刻度标签
   */
  private drawGridLabels(xStep: number, yStep: number) {
    this.context.fillStyle = '#666';
    this.context.font = '10px sans-serif';
    this.context.textAlign = 'center';
    this.context.textBaseline = 'top';
    
    // X 轴刻度
    for (let x = Math.ceil(this.xMin / xStep) * xStep; x <= this.xMax; x += xStep) {
      if (Math.abs(x) < xStep / 100) continue; // 跳过原点
      const screenPoint = this.worldToScreen({ x, y: 0 });
      
      // 确保标签在画布内
      if (screenPoint.x >= 0 && screenPoint.x <= this.canvasWidth) {
        // 格式化数字（避免过长的小数）
        const label = this.formatNumber(x);
        this.context.fillText(label, screenPoint.x, screenPoint.y + 5);
      }
    }
    
    // Y 轴刻度
    this.context.textAlign = 'right';
    this.context.textBaseline = 'middle';
    for (let y = Math.ceil(this.yMin / yStep) * yStep; y <= this.yMax; y += yStep) {
      if (Math.abs(y) < yStep / 100) continue; // 跳过原点
      const screenPoint = this.worldToScreen({ x: 0, y });
      
      // 确保标签在画布内
      if (screenPoint.y >= 0 && screenPoint.y <= this.canvasHeight) {
        const label = this.formatNumber(y);
        this.context.fillText(label, screenPoint.x - 5, screenPoint.y);
      }
    }
    
    // 绘制原点标签
    const origin = this.worldToScreen({ x: 0, y: 0 });
    if (origin.x >= 0 && origin.x <= this.canvasWidth &&
        origin.y >= 0 && origin.y <= this.canvasHeight) {
      this.context.textAlign = 'right';
      this.context.textBaseline = 'top';
      this.context.fillText('0', origin.x - 5, origin.y + 5);
    }
  }
  
  /**
   * 格式化数字显示
   */
  private formatNumber(num: number): string {
    if (Math.abs(num) < 0.01 || Math.abs(num) > 10000) {
      return num.toExponential(1);
    } else if (Math.abs(num) < 1) {
      return num.toFixed(2);
    } else if (Math.abs(num) < 100) {
      return num.toFixed(1);
    } else {
      return num.toFixed(0);
    }
  }
  
  /**
   * 绘制坐标轴
   */
  private drawAxes() {
    this.context.strokeStyle = '#333';
    this.context.lineWidth = 2;
    
    const axes = this.chartGenerator.generateAxes(
      [this.xMin, this.xMax],
      [this.yMin, this.yMax]
    );
    
    // X 轴 - 只在 Y=0 在范围内时绘制
    if (this.yMin <= 0 && this.yMax >= 0) {
      const xStart = this.worldToScreen(axes.xAxis[0]);
      const xEnd = this.worldToScreen(axes.xAxis[1]);
      this.context.beginPath();
      this.context.moveTo(xStart.x, xStart.y);
      this.context.lineTo(xEnd.x, xEnd.y);
      this.context.stroke();
      
      // 添加箭头
      this.drawArrow(xEnd.x - 10, xEnd.y, xEnd.x, xEnd.y);
    }
    
    // Y 轴 - 只在 X=0 在范围内时绘制
    if (this.xMin <= 0 && this.xMax >= 0) {
      const yStart = this.worldToScreen(axes.yAxis[0]);
      const yEnd = this.worldToScreen(axes.yAxis[1]);
      this.context.beginPath();
      this.context.moveTo(yStart.x, yStart.y);
      this.context.lineTo(yEnd.x, yEnd.y);
      this.context.stroke();
      
      // 添加箭头
      this.drawArrow(yEnd.x, yEnd.y + 10, yEnd.x, yEnd.y);
    }
  }
  
  /**
   * 绘制箭头
   */
  private drawArrow(fromX: number, fromY: number, toX: number, toY: number) {
    const headLength = 8;
    const angle = Math.atan2(toY - fromY, toX - fromX);
    
    this.context.beginPath();
    this.context.moveTo(toX, toY);
    this.context.lineTo(
      toX - headLength * Math.cos(angle - Math.PI / 6),
      toY - headLength * Math.sin(angle - Math.PI / 6)
    );
    this.context.moveTo(toX, toY);
    this.context.lineTo(
      toX - headLength * Math.cos(angle + Math.PI / 6),
      toY - headLength * Math.sin(angle + Math.PI / 6)
    );
    this.context.stroke();
  }
  
  /**
   * 验证表达式
   */
  private validateExpression(expr: string) {
    // 清空之前的错误
    this.inputError = '';
    
    if (!expr || expr.trim() === '') {
      return;
    }
    
    // 检查括号匹配
    let openCount = 0;
    for (let char of expr) {
      if (char === '(') openCount++;
      if (char === ')') openCount--;
      if (openCount < 0) {
        this.inputError = '括号不匹配：右括号多于左括号';
        return;
      }
    }
    if (openCount > 0) {
      this.inputError = '括号不匹配：缺少右括号';
      return;
    }
    
    // 检查是否包含未知字符
    const validPattern = /^[0-9x+\-*\/^().\s,sincotagexplogqrtbh]+$/i;
    if (!validPattern.test(expr)) {
      this.inputError = '包含无效字符，请检查输入';
      return;
    }
    
    // 检查是否包含变量 x
    if (!expr.toLowerCase().includes('x')) {
      this.inputError = '表达式必须包含变量 x';
      return;
    }
    
    // 尝试测试表达式
    try {
      const testFunc = this.createFunction(expr);
      // 创建函数现在返回同步函数
      const testValue = testFunc(1);
      if (!isFinite(testValue)) {
        this.inputError = '表达式在 x=1 处无定义或为无穷大';
        return;
      }
    } catch (error) {
      this.inputError = '表达式无效：' + (error as Error).message;
      return;
    }
  }
  
  /**
   * 添加函数
   */
  private addFunction() {
    if (!this.currentExpression || this.currentExpression.trim() === '') {
      promptAction.showToast({
        message: '请输入函数表达式'
      });
      return;
    }
    
    if (this.inputError) {
      promptAction.showToast({
        message: '请修正表达式错误'
      });
      return;
    }
    
    if (this.functions.length >= 6) {
      promptAction.showToast({
        message: '最多支持6个函数'
      });
      return;
    }
    
    const color = this.colors[this.functions.length % this.colors.length];
    this.functions.push({
      expression: this.currentExpression,
      color: color
    });
    
    this.currentExpression = '';
    this.inputError = '';
    this.drawGraph();
  }
  
  /**
   * 删除函数
   */
  private removeFunction(index: number) {
    this.functions.splice(index, 1);
    this.drawGraph();
  }
  
  /**
   * 绘制函数图像
   */
  private drawGraph() {
    try {
      if (!this.canvasReady || this.canvasWidth === 0 || this.canvasHeight === 0) {
        Logger.warn(`Canvas not ready: ready=${this.canvasReady}, size=${this.canvasWidth}x${this.canvasHeight}`);
        promptAction.showToast({
          message: 'Canvas 未准备好，请稍后重试'
        });
        return;
      }
      
      // 验证范围有效性
      if (this.xMin >= this.xMax) {
        promptAction.showToast({
          message: 'X 范围无效：最小值必须小于最大值'
        });
        return;
      }
      
      if (this.yMin >= this.yMax) {
        promptAction.showToast({
          message: 'Y 范围无效：最小值必须小于最大值'
        });
        return;
      }
      
      // 如果没有添加的函数但有当前输入，先添加它
      if (this.functions.length === 0 && this.currentExpression && this.currentExpression.trim() !== '') {
        Logger.info('Auto-adding current expression before drawing');
        this.addFunction();
        return; // addFunction 会自动调用 drawGraph
      }
      
      Logger.info(`Drawing ${this.functions.length} graphs on canvas ${this.canvasWidth}x${this.canvasHeight}`);
      Logger.info(`X range: [${this.xMin}, ${this.xMax}], Y range: [${this.yMin}, ${this.yMax}]`);
      this.isDrawing = true;
      
      // 重新绘制背景
      this.drawInitialGrid();
      
      if (this.functions.length === 0) {
        this.isDrawing = false;
        promptAction.showToast({
          message: '请先输入函数表达式'
        });
        return;
      }
      
      // 绘制每个函数
      let hasValidPoints = false;
      this.functions.forEach((funcPlot, index) => {
        try {
          Logger.info(`Drawing function ${index}: ${funcPlot.expression}`);
          
          // 创建函数
          const f = this.createFunction(funcPlot.expression);
          
          // 生成数据（不限制 Y 范围，让它自动计算）
          const data = this.chartGenerator.generateFunctionData(f, {
            xMin: this.xMin,
            xMax: this.xMax
          });
          
          if (data.points.length === 0) {
            Logger.warn(`No valid points for ${funcPlot.expression} in range X ∈ [${this.xMin}, ${this.xMax}]`);
            promptAction.showToast({
              message: `函数 ${funcPlot.expression} 无有效数据点\n（可能包含无穷大或未定义的值）`,
              duration: 3000
            });
            return;
          }
          
          // 检查数据的 Y 范围是否与用户设置的范围差距太大
          const actualYMin = data.yRange[0];
          const actualYMax = data.yRange[1];
          Logger.info(`Function ${funcPlot.expression}: Y ∈ [${actualYMin.toFixed(2)}, ${actualYMax.toFixed(2)}]`);
          Logger.info(`User specified Y range: [${this.yMin}, ${this.yMax}]`);
          
          // 过滤在 Y 范围内的点
          const visiblePoints = data.points.filter(p => p.y >= this.yMin && p.y <= this.yMax);
          
          if (visiblePoints.length === 0) {
            Logger.warn(`All points outside Y range for ${funcPlot.expression}`);
            promptAction.showToast({
              message: `函数 ${funcPlot.expression} 的值都超出 Y 范围\n实际范围：Y ∈ [${this.formatNumber(actualYMin)}, ${this.formatNumber(actualYMax)}]\n当前设置：Y ∈ [${this.yMin}, ${this.yMax}]`,
              duration: 4000
            });
            return;
          }
          
          Logger.info(`Generated ${data.points.length} points, ${visiblePoints.length} visible for ${funcPlot.expression}`);
          hasValidPoints = true;
          
          // 绘制函数曲线（使用所有点，包括超出范围的，让裁剪算法处理）
          this.drawCurve(data.points, funcPlot.color);
          
        } catch (error) {
          Logger.error(`Error drawing function ${index}`, error);
          promptAction.showToast({
            message: `函数 ${funcPlot.expression} 绘制失败：${(error as Error).message}`
          });
        }
      });
      
      if (!hasValidPoints) {
        Logger.warn('No valid points to draw');
        return;
      }
      
      // 绘制分析功能的标记
      this.drawDerivativeCurves();
      this.drawZeroMarkers();
      this.drawExtremaMarkers();
      
      promptAction.showToast({
        message: '图像绘制完成'
      });
    } catch (error) {
      Logger.error('Graph drawing error', error);
      promptAction.showToast({
        message: '绘制失败：' + (error as Error).message
      });
    } finally {
      this.isDrawing = false;
    }
  }
  
  /**
   * 创建函数
   * 使用同步计算避免 ChartGenerator 的异步问题
   */
  private createFunction(expression: string): (x: number) => number {
    return (x: number): number => {
      try {
        // 替换 x 变量
        const expr = expression.replace(/\bx\b/g, `(${x})`);
        // 使用同步的 safeEval 方法（简化版表达式计算）
        const result = this.syncEvaluate(expr);
        return result;
      } catch (error) {
        Logger.error('Function evaluation error', error);
        throw new Error('表达式无效');
      }
    };
  }
  
  /**
   * 同步计算表达式（简化版）
   * 用于图像绘制，不需要完整的 ExpressionEngine 功能
   */
  private syncEvaluate(expression: string): number {
    // 移除空格
    let sanitized = expression.replace(/\s/g, '');
    
    // 替换运算符
    sanitized = sanitized.replace(/×/g, '*');
    sanitized = sanitized.replace(/÷/g, '/');
    
    // 替换数学函数
    sanitized = this.replaceMathFunctionsSync(sanitized);
    
    // 验证表达式
    if (!/^[0-9+\-*\/.()A-Za-z,^]+$/.test(sanitized)) {
      throw new Error('Invalid expression');
    }
    
    try {
      // 使用 Function 构造函数安全地求值
      const func = new Function('return ' + sanitized) as () => number;
      const result: number = func();
      
      if (typeof result !== 'number' || isNaN(result) || !isFinite(result)) {
        throw new Error('Invalid result');
      }
      
      return result;
    } catch (error) {
      throw new Error('Calculation failed');
    }
  }
  
  /**
   * 同步替换数学函数
   */
  private replaceMathFunctionsSync(expr: string): string {
    let result = expr;
    
    // 替换幂运算符
    result = result.replace(/\^/g, '**');
    
    // 替换数学常数
    result = result.replace(/\bpi\b/gi, 'Math.PI');
    result = result.replace(/\be\b/g, 'Math.E');
    
    // 替换三角函数（度转弧度）
    // 注意：需要找到完整的函数调用并替换参数部分
    result = this.replaceTrigFunctionSync(result, 'sin');
    result = this.replaceTrigFunctionSync(result, 'cos');
    result = this.replaceTrigFunctionSync(result, 'tan');
    
    // 反三角函数（弧度转度）
    result = this.replaceInverseTrigFunctionSync(result, 'asin');
    result = this.replaceInverseTrigFunctionSync(result, 'acos');
    result = this.replaceInverseTrigFunctionSync(result, 'atan');
    
    // 双曲函数
    result = result.replace(/\bsinh\(/g, 'Math.sinh(');
    result = result.replace(/\bcosh\(/g, 'Math.cosh(');
    result = result.replace(/\btanh\(/g, 'Math.tanh(');
    
    // 其他数学函数
    const mathFunctions = ['sqrt', 'abs', 'ceil', 'floor', 'round', 'pow', 'log', 'exp'];
    mathFunctions.forEach(func => {
      const regex = new RegExp(`\\b${func}\\(`, 'g');
      result = result.replace(regex, `Math.${func}(`);
    });
    
    // ln 转换为 log
    result = result.replace(/\bln\(/g, 'Math.log(');
    
    return result;
  }
  
  /**
   * 替换三角函数（同步版本）
   */
  private replaceTrigFunctionSync(expr: string, funcName: string): string {
    const regex = new RegExp(`\\b${funcName}\\(`, 'g');
    let result = expr;
    
    // 找到所有函数调用
    let match: RegExpExecArray | null = null;
    const re = new RegExp(`\\b${funcName}\\(`, 'g');
    
    while ((match = re.exec(expr)) !== null) {
      // 找到匹配的右括号
      let parenCount = 1;
      let endPos = match.index + funcName.length + 1;
      
      while (endPos < expr.length && parenCount > 0) {
        if (expr[endPos] === '(') parenCount++;
        if (expr[endPos] === ')') parenCount--;
        endPos++;
      }
      
      if (parenCount === 0) {
        // 提取参数
        const arg = expr.substring(match.index + funcName.length + 1, endPos - 1);
        // 构建新的表达式
        const replacement = `Math.${funcName}((Math.PI/180)*(${arg}))`;
        result = result.replace(`${funcName}(${arg})`, replacement);
      }
    }
    
    return result;
  }
  
  /**
   * 替换反三角函数（同步版本）
   */
  private replaceInverseTrigFunctionSync(expr: string, funcName: string): string {
    let result = expr;
    
    // 找到所有函数调用
    let match: RegExpExecArray | null = null;
    const re = new RegExp(`\\b${funcName}\\(`, 'g');
    
    while ((match = re.exec(expr)) !== null) {
      // 找到匹配的右括号
      let parenCount = 1;
      let endPos = match.index + funcName.length + 1;
      
      while (endPos < expr.length && parenCount > 0) {
        if (expr[endPos] === '(') parenCount++;
        if (expr[endPos] === ')') parenCount--;
        endPos++;
      }
      
      if (parenCount === 0) {
        // 提取参数
        const arg = expr.substring(match.index + funcName.length + 1, endPos - 1);
        // 构建新的表达式
        const replacement = `((180/Math.PI)*Math.${funcName}(${arg}))`;
        result = result.replace(`${funcName}(${arg})`, replacement);
      }
    }
    
    return result;
  }
  
  /**
   * 绘制曲线
   */
  private drawCurve(points: Point[], color: string) {
    Logger.info(`Drawing curve with ${points.length} points, color: ${color}`);
    
    this.context.strokeStyle = color;
    this.context.lineWidth = 2;
    this.context.beginPath();
    
    let isFirstPoint = true;
    let drawnPoints = 0;
    
    points.forEach((point, index) => {
      const screenPoint = this.worldToScreen(point);
      
      // 检查点是否在屏幕范围内
      if (screenPoint.x < -100 || screenPoint.x > this.canvasWidth + 100 ||
          screenPoint.y < -100 || screenPoint.y > this.canvasHeight + 100) {
        // 点太远，重新开始路径
        if (!isFirstPoint) {
          this.context.stroke();
          this.context.beginPath();
          isFirstPoint = true;
        }
        return;
      }
      
      if (isFirstPoint) {
        this.context.moveTo(screenPoint.x, screenPoint.y);
        isFirstPoint = false;
        drawnPoints++;
      } else {
        this.context.lineTo(screenPoint.x, screenPoint.y);
        drawnPoints++;
      }
    });
    
    this.context.stroke();
    Logger.info(`Drew ${drawnPoints} points on canvas`);
  }
  
  /**
   * 世界坐标转屏幕坐标
   */
  private worldToScreen(point: Point): Point {
    const xRange = this.xMax - this.xMin;
    const yRange = this.yMax - this.yMin;
    
    // 防止除以零
    if (xRange === 0 || yRange === 0) {
      Logger.error('Invalid coordinate range: xRange or yRange is zero');
      return { x: 0, y: 0 };
    }
    
    const x = ((point.x - this.xMin) / xRange) * this.canvasWidth;
    const y = ((this.yMax - point.y) / yRange) * this.canvasHeight;
    return { x, y };
  }
  
  /**
   * 屏幕坐标转世界坐标
   */
  private screenToWorld(point: Point): Point {
    const xRange = this.xMax - this.xMin;
    const yRange = this.yMax - this.yMin;
    
    // 防止除以零
    if (xRange === 0 || yRange === 0 || this.canvasWidth === 0 || this.canvasHeight === 0) {
      Logger.error('Invalid coordinate range or canvas size');
      return { x: 0, y: 0 };
    }
    
    const x = this.xMin + (point.x / this.canvasWidth) * xRange;
    const y = this.yMax - (point.y / this.canvasHeight) * yRange;
    return { x, y };
  }
  
  /**
   * 处理缩放
   */
  private handleZoom(scaleFactor: number) {
    if (!this.canvasReady) return;
    
    // 计算中心点
    const centerX = (this.xMin + this.xMax) / 2;
    const centerY = (this.yMin + this.yMax) / 2;
    
    // 计算新的范围
    const xRange = (this.xMax - this.xMin) / scaleFactor;
    const yRange = (this.yMax - this.yMin) / scaleFactor;
    
    // 更新范围（保持中心点不变）
    this.xMin = centerX - xRange / 2;
    this.xMax = centerX + xRange / 2;
    this.yMin = centerY - yRange / 2;
    this.yMax = centerY + yRange / 2;
    
    // 重新绘制
    this.drawGraph();
  }
  
  /**
   * 处理平移
   */
  private handlePan(deltaX: number, deltaY: number) {
    if (!this.canvasReady || this.canvasWidth === 0 || this.canvasHeight === 0) return;
    
    // 将屏幕坐标转换为世界坐标的偏移量
    const xRange = this.xMax - this.xMin;
    const yRange = this.yMax - this.yMin;
    
    const worldDeltaX = -(deltaX / this.canvasWidth) * xRange;
    const worldDeltaY = (deltaY / this.canvasHeight) * yRange;
    
    // 更新范围
    this.xMin += worldDeltaX;
    this.xMax += worldDeltaX;
    this.yMin += worldDeltaY;
    this.yMax += worldDeltaY;
    
    // 重新绘制
    this.drawGraph();
  }
  
  /**
   * 切换零点显示
   */
  private toggleZeros() {
    this.showZeros = !this.showZeros;
    
    if (this.showZeros) {
      this.analyzeZeros();
    } else {
      this.analysisResults = '';
      this.drawGraph();
    }
  }
  
  /**
   * 切换极值显示
   */
  private toggleExtrema() {
    this.showExtrema = !this.showExtrema;
    
    if (this.showExtrema) {
      this.analyzeExtrema();
    } else {
      this.analysisResults = '';
      this.drawGraph();
    }
  }
  
  /**
   * 切换导数显示
   */
  private toggleDerivative() {
    this.showDerivative = !this.showDerivative;
    this.drawGraph();
    
    if (this.showDerivative) {
      promptAction.showToast({
        message: '已显示导数曲线（虚线）'
      });
    }
  }
  
  /**
   * 切换切线模式
   */
  private toggleTangent() {
    this.showTangent = !this.showTangent;
    
    if (this.showTangent) {
      promptAction.showToast({
        message: '切线模式：点击图像上的点绘制切线',
        duration: 3000
      });
    } else {
      this.drawGraph();
    }
  }
  
  /**
   * 分析零点
   */
  private analyzeZeros() {
    if (this.functions.length === 0) return;
    
    try {
      this.zeros = [];
      let results = '【零点分析】\n';
      
      this.functions.forEach((funcPlot, index) => {
        const f = this.createFunction(funcPlot.expression);
        const zeros = this.equationSolver.findAllZeros(f, this.xMin, this.xMax);
        
        if (zeros.length > 0) {
          results += `f${index + 1}(x) = ${funcPlot.expression}\n`;
          zeros.forEach((zero, i) => {
            results += `  零点${i + 1}: x = ${zero.toFixed(4)}\n`;
            this.zeros.push(zero);
          });
        } else {
          results += `f${index + 1}(x): 在范围内无零点\n`;
        }
      });
      
      this.analysisResults = results;
      this.drawGraph();
      
    } catch (error) {
      Logger.error('Zero analysis error', error);
      promptAction.showToast({
        message: '零点分析失败'
      });
    }
  }
  
  /**
   * 分析极值
   */
  private analyzeExtrema() {
    if (this.functions.length === 0) return;
    
    try {
      this.extrema = [];
      let results = '【极值分析】\n';
      
      this.functions.forEach((funcPlot, index) => {
        const f = this.createFunction(funcPlot.expression);
        const extrema = this.equationSolver.findCriticalPoints(f, this.xMin, this.xMax);
        
        if (extrema.length > 0) {
          results += `f${index + 1}(x) = ${funcPlot.expression}\n`;
          extrema.forEach((point, i) => {
            const typeStr = point.type === 'maximum' ? '极大值' : 
                           point.type === 'minimum' ? '极小值' : '拐点';
            results += `  ${typeStr}: (${point.x.toFixed(3)}, ${point.y.toFixed(3)})\n`;
            this.extrema.push(point);
          });
        } else {
          results += `f${index + 1}(x): 在范围内无极值点\n`;
        }
      });
      
      this.analysisResults = results;
      this.drawGraph();
      
    } catch (error) {
      Logger.error('Extrema analysis error', error);
      promptAction.showToast({
        message: '极值分析失败'
      });
    }
  }
  
  /**
   * 绘制零点标记
   */
  private drawZeroMarkers() {
    if (!this.showZeros || this.zeros.length === 0) return;
    
    this.context.fillStyle = '#FF4D4F';
    
    this.zeros.forEach(zero => {
      const screenPoint = this.worldToScreen({ x: zero, y: 0 });
      
      // 绘制圆点
      this.context.beginPath();
      this.context.arc(screenPoint.x, screenPoint.y, 5, 0, 2 * Math.PI);
      this.context.fill();
      
      // 绘制标签
      this.context.fillStyle = '#FF4D4F';
      this.context.font = '10px sans-serif';
      this.context.textAlign = 'center';
      this.context.fillText(`x=${zero.toFixed(2)}`, screenPoint.x, screenPoint.y - 10);
    });
  }
  
  /**
   * 绘制极值标记
   */
  private drawExtremaMarkers() {
    if (!this.showExtrema || this.extrema.length === 0) return;
    
    this.extrema.forEach(point => {
      const screenPoint = this.worldToScreen({ x: point.x, y: point.y });
      
      // 根据类型选择颜色
      if (point.type === 'maximum') {
        this.context.fillStyle = '#52C41A';
        this.context.strokeStyle = '#52C41A';
      } else if (point.type === 'minimum') {
        this.context.fillStyle = '#1890FF';
        this.context.strokeStyle = '#1890FF';
      } else {
        this.context.fillStyle = '#FA8C16';
        this.context.strokeStyle = '#FA8C16';
      }
      
      // 绘制三角形标记
      this.context.beginPath();
      if (point.type === 'maximum') {
        // 向上三角形
        this.context.moveTo(screenPoint.x, screenPoint.y - 8);
        this.context.lineTo(screenPoint.x - 6, screenPoint.y + 4);
        this.context.lineTo(screenPoint.x + 6, screenPoint.y + 4);
      } else {
        // 向下三角形
        this.context.moveTo(screenPoint.x, screenPoint.y + 8);
        this.context.lineTo(screenPoint.x - 6, screenPoint.y - 4);
        this.context.lineTo(screenPoint.x + 6, screenPoint.y - 4);
      }
      this.context.closePath();
      this.context.fill();
      
      // 绘制标签
      this.context.font = '9px sans-serif';
      this.context.textAlign = 'center';
      const label = `(${point.x.toFixed(2)}, ${point.y.toFixed(2)})`;
      this.context.fillText(label, screenPoint.x, screenPoint.y + 
        (point.type === 'maximum' ? 18 : -12));
    });
  }
  
  /**
   * 绘制导数曲线
   */
  private drawDerivativeCurves() {
    if (!this.showDerivative) return;
    
    this.functions.forEach((funcPlot, index) => {
      try {
        const f = this.createFunction(funcPlot.expression);
        const derivativeData = this.chartGenerator.generateDerivativeData(f, {
          xMin: this.xMin,
          xMax: this.xMax,
          yMin: this.yMin,
          yMax: this.yMax
        }, 1); // 一阶导数
        
        if (derivativeData.points.length > 0) {
          // 使用虚线绘制导数
          this.context.strokeStyle = funcPlot.color;
          this.context.lineWidth = 1.5;
          this.context.setLineDash([5, 5]); // 虚线样式
          
          this.context.beginPath();
          let isFirst = true;
          
          derivativeData.points.forEach(point => {
            const screenPoint = this.worldToScreen(point);
            
            if (screenPoint.x < -100 || screenPoint.x > this.canvasWidth + 100 ||
                screenPoint.y < -100 || screenPoint.y > this.canvasHeight + 100) {
              if (!isFirst) {
                this.context.stroke();
                this.context.beginPath();
                isFirst = true;
              }
              return;
            }
            
            if (isFirst) {
              this.context.moveTo(screenPoint.x, screenPoint.y);
              isFirst = false;
            } else {
              this.context.lineTo(screenPoint.x, screenPoint.y);
            }
          });
          
          this.context.stroke();
          this.context.setLineDash([]); // 恢复实线
        }
      } catch (error) {
        Logger.error(`Failed to draw derivative for function ${index}`, error);
      }
    });
  }
  
  /**
   * 绘制切线
   */
  private drawTangentLine(x: number) {
    if (this.functions.length === 0) return;
    
    try {
      // 只为第一个函数绘制切线
      const funcPlot = this.functions[0];
      const f = this.createFunction(funcPlot.expression);
      
      const tangentData = this.chartGenerator.generateTangentLine(
        f, 
        x, 
        [this.xMin, this.xMax]
      );
      
      if (tangentData.linePoints.length > 0) {
        // 绘制切线
        this.context.strokeStyle = '#FA8C16';
        this.context.lineWidth = 2;
        this.context.setLineDash([10, 5]);
        
        this.context.beginPath();
        const startPoint = this.worldToScreen(tangentData.linePoints[0]);
        this.context.moveTo(startPoint.x, startPoint.y);
        
        tangentData.linePoints.forEach((point: Point) => {
          const screenPoint = this.worldToScreen(point);
          this.context.lineTo(screenPoint.x, screenPoint.y);
        });
        
        this.context.stroke();
        this.context.setLineDash([]);
        
        // 标记切点
        const y = f(x);
        const cutPoint = this.worldToScreen({ x, y });
        this.context.fillStyle = '#FA8C16';
        this.context.beginPath();
        this.context.arc(cutPoint.x, cutPoint.y, 5, 0, 2 * Math.PI);
        this.context.fill();
        
        // 显示切线信息
        this.analysisResults = `【切线信息】\n` +
          `切点: (${x.toFixed(3)}, ${y.toFixed(3)})\n` +
          `斜率: ${tangentData.slope.toFixed(3)}\n` +
          `切线方程: y - ${y.toFixed(2)} = ${tangentData.slope.toFixed(2)}(x - ${x.toFixed(2)})`;
      }
    } catch (error) {
      Logger.error('Failed to draw tangent line', error);
      promptAction.showToast({
        message: '切线绘制失败'
      });
    }
  }
  
  /**
   * 保存图像
   */
  private async saveImage() {
    try {
      // 获取Canvas的像素数据
      const pixelMap = await this.context.getPixelMap(0, 0, this.canvasWidth, this.canvasHeight);
      
      // 生成文件名（使用时间戳）
      const timestamp = new Date().getTime();
      const fileName = `graph_${timestamp}.png`;
      
      // 保存到图库（需要权限）
      // 这里简化实现，实际需要使用 @ohos.file.photoAccessHelper
      Logger.info(`Image would be saved as: ${fileName}`);
      
      promptAction.showToast({
        message: '图像保存功能需要存储权限，请在设置中授权'
      });
      
      // TODO: 实现实际的图像保存逻辑
      // 1. 请求存储权限
      // 2. 使用 photoAccessHelper 保存到相册
      // 3. 或使用 file.fs 保存到应用目录
      
    } catch (error) {
      Logger.error('Failed to save image', error);
      promptAction.showToast({
        message: '保存图像失败'
      });
    }
  }
}

