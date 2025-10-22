/**
 * 函数图像页面
 * 使用 Canvas 绘制函数图像
 */
import { Logger } from '../utils/Logger';
import { ChartGenerator, ChartData, Point } from '../modules/ChartGenerator';
import { ExpressionEngine } from '../modules/ExpressionEngine';
import promptAction from '@ohos.promptAction';

interface FunctionPlot {
  expression: string;
  color: string;
}

@Component
export struct GraphPage {
  @State functions: FunctionPlot[] = [{ expression: 'x*x', color: '#1890ff' }];
  @State currentExpression: string = '';
  @State xMin: number = -10;
  @State xMax: number = 10;
  @State yMin: number = -10;
  @State yMax: number = 10;
  @State isDrawing: boolean = false;
  
  private chartGenerator: ChartGenerator = new ChartGenerator();
  private expressionEngine: ExpressionEngine = new ExpressionEngine();
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private colors: string[] = ['#1890ff', '#52c41a', '#ff4d4f', '#fa8c16', '#722ed1', '#13c2c2'];
  
  aboutToAppear() {
    Logger.info('GraphPage loaded');
  }
  
  build() {
    Column() {
      // 输入区域
      Column() {
        Text('函数图像绘制')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 })
        
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
                  .height(24)
                  .backgroundColor('#ff4d4f')
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
        Row() {
          Text('f(x) = ')
            .fontSize(14)
            .fontColor('#333')
            .width(60)
          
          TextInput({ text: this.currentExpression, placeholder: '输入函数表达式，如：x*x, sin(x)' })
            .fontSize(14)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.currentExpression = value;
            })
          
          Button('添加')
            .fontSize(14)
            .height(40)
            .backgroundColor('#52c41a')
            .margin({ left: 8 })
            .onClick(() => {
              this.addFunction();
            })
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
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.xMin = parseFloat(value) || -10;
                })
              
              Text(' ~ ')
                .fontSize(12)
                .margin({ left: 5, right: 5 })
              
              TextInput({ text: this.xMax.toString(), placeholder: '10' })
                .fontSize(12)
                .width(70)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.xMax = parseFloat(value) || 10;
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
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.yMin = parseFloat(value) || -10;
                })
              
              Text(' ~ ')
                .fontSize(12)
                .margin({ left: 5, right: 5 })
              
              TextInput({ text: this.yMax.toString(), placeholder: '10' })
                .fontSize(12)
                .width(70)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.yMax = parseFloat(value) || 10;
                })
            }
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 10 })
        
        // 绘制按钮
        Button('绘制图像')
          .fontSize(16)
          .width('100%')
          .backgroundColor('#1890ff')
          .onClick(() => {
            this.drawGraph();
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')
      
      // Canvas 绘图区域
      Column() {
        Canvas(this.context)
          .width('100%')
          .height('100%')
          .backgroundColor('#fafafa')
          .onReady(() => {
            Logger.info('Canvas ready');
            this.canvasWidth = this.context.width;
            this.canvasHeight = this.context.height;
            this.drawGraph();
          })
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
    this.clearCanvas();
    this.drawGrid();
    this.drawAxes();
  }
  
  /**
   * 清除画布
   */
  private clearCanvas() {
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.context.fillStyle = '#fafafa';
    this.context.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }
  
  /**
   * 绘制网格
   */
  private drawGrid() {
    this.context.strokeStyle = '#e0e0e0';
    this.context.lineWidth = 0.5;
    
    const grid = this.chartGenerator.generateGrid(
      [this.xMin, this.xMax],
      [this.yMin, this.yMax],
      1, 1
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
    
    // X 轴
    const xStart = this.worldToScreen(axes.xAxis[0]);
    const xEnd = this.worldToScreen(axes.xAxis[1]);
    this.context.beginPath();
    this.context.moveTo(xStart.x, xStart.y);
    this.context.lineTo(xEnd.x, xEnd.y);
    this.context.stroke();
    
    // Y 轴
    const yStart = this.worldToScreen(axes.yAxis[0]);
    const yEnd = this.worldToScreen(axes.yAxis[1]);
    this.context.beginPath();
    this.context.moveTo(yStart.x, yStart.y);
    this.context.lineTo(yEnd.x, yEnd.y);
    this.context.stroke();
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
      Logger.info(`Drawing ${this.functions.length} graphs`);
      this.isDrawing = true;
      
      // 重新绘制背景
      this.drawInitialGrid();
      
      if (this.functions.length === 0) {
        this.isDrawing = false;
        return;
      }
      
      // 绘制每个函数
      this.functions.forEach((funcPlot, index) => {
        try {
          // 创建函数
          const f = this.createFunction(funcPlot.expression);
          
          // 生成数据
          const data = this.chartGenerator.generateFunctionData(f, {
            xMin: this.xMin,
            xMax: this.xMax,
            yMin: this.yMin,
            yMax: this.yMax
          });
          
          if (data.points.length === 0) {
            Logger.warn(`No points generated for function: ${funcPlot.expression}`);
            return;
          }
          
          // 绘制函数曲线
          this.drawCurve(data.points, funcPlot.color);
          
        } catch (error) {
          Logger.error(`Error drawing function ${index}`, error);
        }
      });
      
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
   */
  private createFunction(expression: string): (x: number) => number {
    return (x: number): number => {
      try {
        // 替换 x 变量
        const expr = expression.replace(/\bx\b/g, `(${x})`);
        const result = this.expressionEngine.evaluate(expr);
        if (result.success && result.result) {
          return parseFloat(result.result);
        } else {
          throw new Error('表达式无效');
        }
      } catch (error) {
        throw new Error('表达式无效');
      }
    };
  }
  
  /**
   * 绘制曲线
   */
  private drawCurve(points: Point[], color: string) {
    this.context.strokeStyle = color;
    this.context.lineWidth = 2;
    this.context.beginPath();
    
    let isFirstPoint = true;
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
      } else {
        this.context.lineTo(screenPoint.x, screenPoint.y);
      }
    });
    
    this.context.stroke();
  }
  
  /**
   * 世界坐标转屏幕坐标
   */
  private worldToScreen(point: Point): Point {
    const x = ((point.x - this.xMin) / (this.xMax - this.xMin)) * this.canvasWidth;
    const y = ((this.yMax - point.y) / (this.yMax - this.yMin)) * this.canvasHeight;
    return { x, y };
  }
}

