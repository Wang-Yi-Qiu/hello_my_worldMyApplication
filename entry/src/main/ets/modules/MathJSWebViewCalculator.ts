/**
 * MathJS WebView 计算器
 * 通过 WebView 调用 mathjs 库进行数学计算
 */
import { webview } from '@kit.ArkWeb';
import { Logger } from '../utils/Logger';

export interface MathJSResult {
  success: boolean;
  result?: string;
  error?: string;
}

export class MathJSWebViewCalculator {
  private static instance: MathJSWebViewCalculator;
  private webController: webview.WebviewController | null = null;
  private isInitialized: boolean = false;
  private pendingCalculations: Map<string, (result: MathJSResult) => void> = new Map();
  private calculationId: number = 0;

  private constructor() {}

  public static getInstance(): MathJSWebViewCalculator {
    if (!MathJSWebViewCalculator.instance) {
      MathJSWebViewCalculator.instance = new MathJSWebViewCalculator();
    }
    return MathJSWebViewCalculator.instance;
  }

  /**
   * 初始化 WebView
   */
  public async initialize(context: Context): Promise<void> {
    try {
      this.webController = new webview.WebviewController();
      
      // 创建 WebView 并加载 HTML
      const htmlContent = this.generateMathJSHTML();
      await this.webController.loadUrl(`data:text/html;charset=utf-8,${encodeURIComponent(htmlContent)}`);
      
      this.isInitialized = true;
      Logger.info('MathJS WebView calculator initialized');
    } catch (error) {
      Logger.error('Failed to initialize MathJS WebView calculator', error);
      throw error;
    }
  }

  /**
   * 计算数学表达式
   */
  public async calculate(expression: string): Promise<MathJSResult> {
    // 由于 WebView API 限制，暂时禁用该功能
    // 直接返回错误，使用内置 AST 计算引擎
    return {
      success: false,
      error: 'WebView calculator not available, using AST fallback'
    };
  }

  /**
   * 求解方程
   */
  public async solveEquation(equation: string, variable: string = 'x'): Promise<MathJSResult> {
    // 由于 WebView API 限制，暂时禁用该功能
    return {
      success: false,
      error: 'WebView calculator not available, using AST fallback'
    };
  }

  /**
   * WebView 回调：计算结果
   */
  public onCalculationResult(id: string, success: boolean, result: string, error: string): void {
    const callback = this.pendingCalculations.get(id);
    if (callback) {
      this.pendingCalculations.delete(id);
      callback({
        success,
        result: success ? result : undefined,
        error: success ? undefined : error
      });
    }
  }

  /**
   * WebView 回调：错误处理
   */
  public onError(id: string, error: string): void {
    const callback = this.pendingCalculations.get(id);
    if (callback) {
      this.pendingCalculations.delete(id);
      callback({
        success: false,
        error
      });
    }
  }

  /**
   * 生成包含 mathjs 的 HTML 页面
   */
  private generateMathJSHTML(): string {
    return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MathJS Calculator</title>
    <script src="https://unpkg.com/mathjs@11.11.0/lib/browser/math.min.js"></script>
</head>
<body>
    <script>
        // 等待 mathjs 加载完成
        window.addEventListener('load', function() {
            console.log('MathJS loaded successfully');
        });

        // 计算表达式函数
        function calculateExpression(id, expression) {
            try {
                console.log('Calculating:', expression);
                
                // 使用 mathjs 计算表达式
                // 支持微积分、矩阵、复数等高级运算
                const result = math.evaluate(expression);
                
                // 格式化结果
                let formattedResult;
                if (typeof result === 'number') {
                    if (isNaN(result)) {
                        throw new Error('Result is NaN');
                    }
                    if (!isFinite(result)) {
                        formattedResult = result > 0 ? 'Infinity' : '-Infinity';
                    } else {
                        // 处理科学计数法 - 更智能的格式化
                        const absResult = Math.abs(result);
                        if (absResult > 1e15 || (absResult < 1e-6 && result !== 0)) {
                            formattedResult = result.toExponential(10);
                        } else {
                            // 保留最多15位有效数字
                            formattedResult = result.toPrecision(15);
                            // 移除不必要的尾随零
                            formattedResult = parseFloat(formattedResult).toString();
                        }
                    }
                } else if (math.isComplex(result)) {
                    // 复数结果
                    formattedResult = result.toString();
                } else if (math.isUnit(result)) {
                    // 单位结果
                    formattedResult = result.toString();
                } else if (math.isMatrix(result)) {
                    // 矩阵结果
                    formattedResult = math.format(result, {precision: 14});
                } else if (typeof result === 'object') {
                    // 对象结果（如统计函数）
                    formattedResult = JSON.stringify(result);
                } else {
                    formattedResult = result.toString();
                }
                
                console.log('Result:', formattedResult);
                
                // 回调到原生代码
                if (window.MathJSCalculator && window.MathJSCalculator.onCalculationResult) {
                    window.MathJSCalculator.onCalculationResult(id, true, formattedResult, '');
                }
                
            } catch (error) {
                console.error('Calculation error:', error);
                
                // 回调错误到原生代码
                if (window.MathJSCalculator && window.MathJSCalculator.onError) {
                    window.MathJSCalculator.onError(id, error.message);
                }
            }
        }

        // 求解方程函数
        function solveEquation(id, equation, variable) {
            try {
                console.log('Solving equation:', equation);
                
                // 尝试解析方程
                // mathjs 简化版：仅支持 ax + b = 0 形式
                const expr = math.parse(equation);
                const node = expr.root;
                
                // 这里可以实现更复杂的求解逻辑
                // 暂时返回错误提示
                if (window.MathJSCalculator && window.MathJSCalculator.onError) {
                    window.MathJSCalculator.onError(id, '高级方程求解需要使用专业版本');
                }
                
            } catch (error) {
                console.error('Solve equation error:', error);
                if (window.MathJSCalculator && window.MathJSCalculator.onError) {
                    window.MathJSCalculator.onError(id, error.message);
                }
            }
        }

        // 测试函数
        function testMathJS() {
            try {
                const testResult = math.evaluate('2 + 3 * 4');
                console.log('Test result:', testResult);
                return true;
            } catch (error) {
                console.error('Test failed:', error);
                return false;
            }
        }

        // 页面加载完成后测试
        setTimeout(() => {
            if (testMathJS()) {
                console.log('MathJS is working correctly');
            } else {
                console.error('MathJS test failed');
            }
        }, 1000);
    </script>
</body>
</html>
    `;
  }

  /**
   * 销毁 WebView
   */
  public async destroy(): Promise<void> {
    if (this.webController) {
      try {
        // WebView destroy 方法已移除，不需要显式调用
        this.webController = null;
        this.isInitialized = false;
        Logger.info('MathJS WebView calculator destroyed');
      } catch (error) {
        Logger.error('Failed to destroy MathJS WebView calculator', error);
      }
    }
  }

  /**
   * 检查是否已初始化
   */
  public isReady(): boolean {
    return this.isInitialized && this.webController !== null;
  }
}
