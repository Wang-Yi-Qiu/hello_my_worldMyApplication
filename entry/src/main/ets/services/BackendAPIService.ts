/**
 * 后端 API 服务
 * 用于调用 Python 后端进行计算服务
 */
import { Logger } from '../utils/Logger';

/**
 * 后端配置
 */
const BACKEND_CONFIG = {
  // ⚡ 本地开发配置（模拟器上用这个）
  // baseURL: 'http://localhost:8888',
  
  // 💡 手机访问电脑，改成你电脑的 IP 地址
  // 查看方法：在电脑上运行 ifconfig（Mac/Linux）或 ipconfig（Windows）
  baseURL: 'http://172.19.229.151:8888',  // ⚠️ 你的电脑 IP 地址
  
  timeout: 30000
};

/**
 * API 请求接口
 */
interface APIRequest {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  data?: Record<string, unknown>;
  headers?: Record<string, string>;
}

/**
 * API 响应接口
 */
interface APIResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

/**
 * 多项式根请求
 */
interface PolynomialRootsRequest extends Record<string, unknown> {
  coefficients: number[];
  variable?: string;
}

/**
 * 复数运算请求
 */
interface ComplexOperationRequest extends Record<string, unknown> {
  real1: number;
  imag1: number;
  real2?: number;
  imag2?: number;
  operation: 'add' | 'multiply' | 'power' | 'sqrt' | 'magnitude' | 'argument';
}

/**
 * 后端 API 服务类
 */
export class BackendAPIService {
  private static instance: BackendAPIService;
  
  private constructor() {
    Logger.info('BackendAPIService initialized');
  }
  
  /**
   * 获取单例
   */
  public static getInstance(): BackendAPIService {
    if (!BackendAPIService.instance) {
      BackendAPIService.instance = new BackendAPIService();
    }
    return BackendAPIService.instance;
  }
  
  /**
   * 通用 HTTP 请求
   * 注意：由于网络模块导入问题，暂时使用模拟实现
   * 根据HarmonyOS官方文档，网络模块可能需要特定的SDK版本或配置
   */
  public async request<T>(config: APIRequest): Promise<APIResponse<T>> {
    try {
      Logger.info(`API Request: ${config.method} ${config.url}`);
      Logger.warn('Network module not available, returning failure status');
      
      // 检查后端服务是否运行
      const backendUrl = `${BACKEND_CONFIG.baseURL}${config.url}`;
      Logger.info(`Would request: ${backendUrl}`);
      
      // 返回失败状态，提示用户网络功能不可用
      return {
        success: false,
        error: '网络功能暂不可用，请使用本地计算引擎。如需使用网络功能，请确保HarmonyOS SDK版本支持网络模块。'
      };
      
    } catch (error) {
      Logger.error('API Request Error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '网络请求失败'
      };
    }
  }
  
  /**
   * 健康检查
   */
  async healthCheck(): Promise<APIResponse<{ status: string, version?: string, service?: string }>> {
    return this.request({
      url: '/health',
      method: 'GET'
    });
  }
  
  /**
   * 获取 API 统计信息
   */
  async getAPIStats(): Promise<APIResponse<{ version?: string, endpoints?: string[] }>> {
    return this.request({
      url: '/api/stats',
      method: 'GET'
    });
  }
  
  /**
   * 多项式求根
   */
  async findPolynomialRoots(request: PolynomialRootsRequest): Promise<APIResponse<{
    roots: Array<{ real: number, imag: number }>;
    num_roots: number;
  }>> {
    return this.request({
      url: '/polynomial/roots',
      method: 'POST',
      data: request
    });
  }
  
  /**
   * 多项式求导
   */
  async polynomialDerivative(coefficients: number[], variable: string = 'x'): Promise<APIResponse<{
    derivative: string;
    latex: string;
  }>> {
    return this.request({
      url: '/polynomial/derivative',
      method: 'POST',
      data: { coefficients, variable }
    });
  }
  
  /**
   * 复数运算
   */
  async complexOperation(request: ComplexOperationRequest): Promise<APIResponse<Record<string, unknown>>> {
    return this.request({
      url: '/complex/operations',
      method: 'POST',
      data: request
    });
  }
  
  /**
   * 微分方程求解
   */
  async solveODE(params: {
    equationType: string;
    parameters: Record<string, number>;
    initialCondition: Record<string, number>;
    timeRange: number[];
  }): Promise<APIResponse<{
    equation_type: string;
    general_solution: string;
    discriminant?: number;
  }>> {
    return this.request({
      url: '/ode/solve',
      method: 'POST',
      data: {
        equation_type: params.equationType,
        parameters: params.parameters,
        initial_condition: params.initialCondition,
        time_range: params.timeRange
      }
    });
  }
  
  /**
   * 函数优化
   */
  async optimize(params: {
    functionCode: string;
    initialGuess: number[];
    method?: string;
  }): Promise<APIResponse<{
    optimal_point: number[];
    optimal_value: number;
    iterations?: number;
  }>> {
    return this.request({
      url: '/optimize',
      method: 'POST',
      data: {
        function_code: params.functionCode,
        initial_guess: params.initialGuess,
        method: params.method || 'BFGS'
      }
    });
  }
  
  /**
   * 数据插值
   */
  async interpolate(params: {
    points: Array<{ x: number, y: number }>;
    method?: string;
  }): Promise<APIResponse<Record<string, unknown>>> {
    return this.request({
      url: '/interpolate',
      method: 'POST',
      data: {
        points: params.points,
        method: params.method || 'lagrange'
      }
    });
  }
  
  /**
   * 数值求根
   */
  async findRoot(expression: string, method: string = 'newton', initialGuess: number = 0): Promise<APIResponse<{
    method: string;
    root: number;
    value_at_root: number;
  }>> {
    const url = `/root_finding?expression=${encodeURIComponent(expression)}&method=${method}&initial_guess=${initialGuess}`;
    return this.request({
      url: url,
      method: 'POST'
    });
  }
  
  /**
   * 计算定积分
   */
  async integrate(expression: string, lower: number, upper: number, variable: string = 'x'): Promise<APIResponse<{
    result: string;
    error_estimate?: string;
  }>> {
    return this.request({
      url: '/integrate',
      method: 'POST',
      data: { expression, lower, upper, variable }
    });
  }
  
  /**
   * 符号求导
   */
  async differentiate(expression: string, variable: string = 'x'): Promise<APIResponse<{
    result: string;
    latex: string;
  }>> {
    return this.request({
      url: '/differentiate',
      method: 'POST',
      data: { expression, variable }
    });
  }
  
  /**
   * 求解方程
   */
  async solveEquation(equation: string, variable: string = 'x'): Promise<APIResponse<{
    solutions: string[];
  }>> {
    return this.request({
      url: '/solve',
      method: 'POST',
      data: { equation, variable }
    });
  }
  
  /**
   * 化简表达式
   */
  async simplify(expression: string): Promise<APIResponse<{
    result: string;
    latex: string;
  }>> {
    return this.request({
      url: '/simplify',
      method: 'POST',
      data: { expression }
    });
  }
  
  /**
   * 展开表达式
   */
  async expand(expression: string): Promise<APIResponse<{
    result: string;
    latex: string;
  }>> {
    return this.request({
      url: '/expand',
      method: 'POST',
      data: { expression }
    });
  }
  
  /**
   * 因式分解
   */
  async factor(expression: string): Promise<APIResponse<{
    result: string;
    latex: string;
  }>> {
    return this.request({
      url: '/factor',
      method: 'POST',
      data: { expression }
    });
  }
  
  /**
   * 计算极限
   */
  async limit(expression: string, variable: string = 'x', approachValue: string = '0', direction?: string): Promise<APIResponse<{
    result: string;
    latex: string;
  }>> {
    const url = `/limit?expression=${encodeURIComponent(expression)}&variable=${variable}&approach_value=${approachValue}${direction ? `&direction=${direction}` : ''}`;
    return this.request({
      url: url,
      method: 'POST'
    });
  }
}

/**
 * 导出单例
 */
export const backendAPI = BackendAPIService.getInstance();

