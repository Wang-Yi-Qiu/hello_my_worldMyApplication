/**
 * 后端 API 类型定义
 */

/**
 * 后端健康检查响应
 */
export interface BackendHealthResponse {
  success: boolean;
  data?: BackendHealthData;
  error?: string;
}

/**
 * 后端健康数据
 */
export interface BackendHealthData {
  status?: string;
  version?: string;
  service?: string;
}

/**
 * 后端计算响应
 */
export interface BackendCalculationResponse {
  success: boolean;
  result?: string;
  error?: string;
}

/**
 * 后端响应数据
 */
export interface BackendResponseData {
  result?: string;
  output?: string;
  data?: string;
}

/**
 * 通用后端响应
 */
export interface BackendAPIResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
}

/**
 * 后端请求配置
 */
export interface BackendRequestConfig<T = unknown> {
  url: string;
  method: string;
  data?: T;
}

