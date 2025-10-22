/**
 * 函数图像页面
 * 使用 Canvas 绘制函数图像
 */
import { Logger } from '../utils/Logger';
import { ChartGenerator, ChartData, Point } from '../modules/ChartGenerator';
import promptAction from '@ohos.promptAction';

@Component
export struct GraphPage {
  @State expression: string = 'x*x';
  @State xMin: number = -10;
  @State xMax: number = 10;
  @State yMin: number = -10;
  @State yMax: number = 10;
  @State isDrawing: boolean = false;
  
  private chartGenerator: ChartGenerator = new ChartGenerator();
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
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
        
        // 表达式输入
        Row() {
          Text('f(x) = ')
            .fontSize(14)
            .fontColor('#333')
            .width(60)
          
          TextInput({ text: this.expression, placeholder: '输入函数表达式，如：x*x, sin(x)' })
            .fontSize(14)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.expression = value;
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
            this.drawInitialGrid();
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
   * 绘制函数图像
   */
  private drawGraph() {
    try {
      Logger.info(`Drawing graph for: ${this.expression}`);
      this.isDrawing = true;
      
      // 重新绘制背景
      this.drawInitialGrid();
      
      // 创建函数
      const f = (x: number): number => {
        try {
          // 简单的表达式求值（实际应使用 math.js）
          return eval(this.expression.replace(/x/g, x.toString()));
        } catch (error) {
          throw new Error('表达式无效');
        }
      };
      
      // 生成数据
      const data = this.chartGenerator.generateFunctionData(f, {
        xMin: this.xMin,
        xMax: this.xMax,
        yMin: this.yMin,
        yMax: this.yMax
      });
      
      if (data.points.length === 0) {
        promptAction.showToast({
          message: '无法生成图像数据'
        });
        return;
      }
      
      // 绘制函数曲线
      this.context.strokeStyle = '#1890ff';
      this.context.lineWidth = 2;
      this.context.beginPath();
      
      data.points.forEach((point, index) => {
        const screenPoint = this.worldToScreen(point);
        if (index === 0) {
          this.context.moveTo(screenPoint.x, screenPoint.y);
        } else {
          this.context.lineTo(screenPoint.x, screenPoint.y);
        }
      });
      
      this.context.stroke();
      
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
   * 世界坐标转屏幕坐标
   */
  private worldToScreen(point: Point): Point {
    const x = ((point.x - this.xMin) / (this.xMax - this.xMin)) * this.canvasWidth;
    const y = ((this.yMax - point.y) / (this.yMax - this.yMin)) * this.canvasHeight;
    return { x, y };
  }
}

