# API 契约文档：智能计算器 SmartCalc

**项目：** 智能计算器 SmartCalc  
**版本：** 1.0.0  
**日期：** 2025-10-22  
**分支：** 001-smartcalc-app

---

## 1. 概述

本文档定义了 SmartCalc 的所有内部模块接口和云端 API 接口契约。

### 1.1 接口分类

- **本地模块接口**：应用内部模块间的接口（TypeScript）
- **云端 REST API**：与 Supabase 后端的接口（HTTP/REST）
- **数据同步接口**：本地与云端的数据同步接口

---

## 2. 本地模块接口

### 2.1 ExpressionEngine（表达式引擎）

#### 接口：evaluate()

**功能：** 计算数学表达式的值

```typescript
interface EvaluateOptions {
  precision?: number; // 精度，默认 10
  angleUnit?: 'degree' | 'radian'; // 角度单位，默认 'degree'
}

interface EvaluateResult {
  success: boolean;
  result?: string;
  error?: string;
}

function evaluate(
  expression: string,
  options?: EvaluateOptions
): EvaluateResult;
```

**示例：**
```typescript
const engine = new ExpressionEngine();

// 成功案例
const result1 = engine.evaluate('1 + 2');
// { success: true, result: '3' }

const result2 = engine.evaluate('sin(30)', { angleUnit: 'degree' });
// { success: true, result: '0.5' }

// 失败案例
const result3 = engine.evaluate('1 / 0');
// { success: false, error: '除以零错误' }
```

---

#### 接口：solveEquation()

**功能：** 求解方程

```typescript
interface SolveOptions {
  variable: string; // 求解变量，默认 'x'
  precision?: number; // 精度，默认 10
}

interface SolveResult {
  success: boolean;
  solutions?: string[]; // 解的数组
  error?: string;
}

function solveEquation(
  equation: string,
  options?: SolveOptions
): SolveResult;
```

**示例：**
```typescript
// 一元二次方程
const result = engine.solveEquation('x^2 - 4 = 0', { variable: 'x' });
// { success: true, solutions: ['-2', '2'] }

// 线性方程组（未来支持）
```

---

#### 接口：differentiate()

**功能：** 计算导数

```typescript
interface DifferentiateOptions {
  variable: string; // 求导变量，默认 'x'
  simplify?: boolean; // 是否化简，默认 true
}

interface DifferentiateResult {
  success: boolean;
  derivative?: string; // 导数表达式
  error?: string;
}

function differentiate(
  expression: string,
  options?: DifferentiateOptions
): DifferentiateResult;
```

**示例：**
```typescript
const result = engine.differentiate('x^2 + 3*x + 5', { variable: 'x' });
// { success: true, derivative: '2*x + 3' }
```

---

#### 接口：integrate()

**功能：** 计算积分

```typescript
interface IntegrateOptions {
  variable: string; // 积分变量，默认 'x'
  from?: number; // 定积分下限
  to?: number; // 定积分上限
}

interface IntegrateResult {
  success: boolean;
  integral?: string; // 不定积分表达式或定积分值
  error?: string;
}

function integrate(
  expression: string,
  options: IntegrateOptions
): IntegrateResult;
```

**示例：**
```typescript
// 不定积分
const result1 = engine.integrate('x^2', { variable: 'x' });
// { success: true, integral: '(1/3)*x^3 + C' }

// 定积分
const result2 = engine.integrate('x^2', { variable: 'x', from: 0, to: 1 });
// { success: true, integral: '0.3333...' }
```

---

### 2.2 ChartGenerator（图表生成器）

#### 接口：generateGraph()

**功能：** 生成函数图像

```typescript
interface GraphOptions {
  xMin?: number; // X 轴最小值，默认 -10
  xMax?: number; // X 轴最大值，默认 10
  yMin?: number; // Y 轴最小值，自动计算
  yMax?: number; // Y 轴最大值，自动计算
  color?: string; // 线条颜色，默认 '#1890ff'
  lineWidth?: number; // 线条宽度，默认 2
  grid?: boolean; // 显示网格，默认 true
  points?: number; // 采样点数，默认 500
}

interface GraphResult {
  success: boolean;
  graphData?: {
    xData: number[];
    yData: number[];
    xRange: [number, number];
    yRange: [number, number];
  };
  error?: string;
}

function generateGraph(
  expression: string,
  options?: GraphOptions
): GraphResult;
```

**示例：**
```typescript
const generator = new ChartGenerator();

const result = generator.generateGraph('sin(x)', {
  xMin: -Math.PI * 2,
  xMax: Math.PI * 2,
  color: '#1890ff'
});

// {
//   success: true,
//   graphData: {
//     xData: [-6.28, -6.26, ..., 6.28],
//     yData: [0, 0.02, ..., 0],
//     xRange: [-6.28, 6.28],
//     yRange: [-1, 1]
//   }
// }
```

---

#### 接口：exportToPNG()

**功能：** 导出图像为 PNG 格式

```typescript
interface ExportOptions {
  filename?: string; // 文件名，默认生成时间戳
  width?: number; // 宽度，默认 800
  height?: number; // 高度，默认 600
}

interface ExportResult {
  success: boolean;
  filePath?: string; // 本地文件路径
  error?: string;
}

async function exportToPNG(
  options?: ExportOptions
): Promise<ExportResult>;
```

---

#### 接口：exportToSVG()

**功能：** 导出图像为 SVG 格式

```typescript
async function exportToSVG(
  options?: ExportOptions
): Promise<ExportResult>;
```

---

### 2.3 DataManager（数据管理器）

#### 接口：saveFormula()

**功能：** 保存公式

```typescript
interface Formula {
  id?: number; // 本地 ID（更新时提供）
  name: string;
  expression: string;
  description?: string;
  category?: string;
}

interface SaveResult {
  success: boolean;
  id?: number; // 保存后的 ID
  error?: string;
}

async function saveFormula(formula: Formula): Promise<SaveResult>;
```

**示例：**
```typescript
const manager = new DataManager();

const result = await manager.saveFormula({
  name: '勾股定理',
  expression: 'a^2 + b^2 = c^2',
  description: '直角三角形的边长关系',
  category: 'geometry'
});

// { success: true, id: 1 }
```

---

#### 接口：getFormulas()

**功能：** 获取公式列表

```typescript
interface FormulaQuery {
  category?: string; // 按分类筛选
  keyword?: string; // 按名称或表达式搜索
  limit?: number; // 限制返回数量，默认 100
  offset?: number; // 分页偏移，默认 0
}

interface GetFormulasResult {
  success: boolean;
  formulas?: Formula[];
  total?: number; // 总数
  error?: string;
}

async function getFormulas(
  query?: FormulaQuery
): Promise<GetFormulasResult>;
```

---

#### 接口：deleteFormula()

**功能：** 删除公式

```typescript
interface DeleteResult {
  success: boolean;
  error?: string;
}

async function deleteFormula(id: number): Promise<DeleteResult>;
```

---

#### 接口：saveHistory()

**功能：** 保存历史记录

```typescript
interface HistoryRecord {
  expression: string;
  result: string;
  calcType: string;
}

async function saveHistory(
  record: HistoryRecord
): Promise<SaveResult>;
```

---

#### 接口：getHistory()

**功能：** 获取历史记录

```typescript
interface HistoryQuery {
  calcType?: string; // 按类型筛选
  keyword?: string; // 按表达式或结果搜索
  fromDate?: string; // 开始日期（ISO 8601）
  toDate?: string; // 结束日期（ISO 8601）
  limit?: number; // 限制返回数量，默认 100
  offset?: number; // 分页偏移，默认 0
}

interface GetHistoryResult {
  success: boolean;
  history?: HistoryRecord[];
  total?: number;
  error?: string;
}

async function getHistory(
  query?: HistoryQuery
): Promise<GetHistoryResult>;
```

---

#### 接口：clearHistory()

**功能：** 清空历史记录

```typescript
interface ClearOptions {
  olderThan?: string; // 删除指定日期之前的记录（ISO 8601）
  calcType?: string; // 删除指定类型的记录
}

async function clearHistory(
  options?: ClearOptions
): Promise<DeleteResult>;
```

---

### 2.4 SyncService（同步服务）

#### 接口：syncToCloud()

**功能：** 将本地数据同步到云端

```typescript
interface SyncOptions {
  force?: boolean; // 强制同步所有数据，默认 false（增量同步）
}

interface SyncResult {
  success: boolean;
  uploaded?: {
    formulas: number;
    history: number;
    graphs: number;
  };
  error?: string;
}

async function syncToCloud(
  options?: SyncOptions
): Promise<SyncResult>;
```

**示例：**
```typescript
const syncService = new SyncService();

const result = await syncService.syncToCloud();
// {
//   success: true,
//   uploaded: {
//     formulas: 5,
//     history: 20,
//     graphs: 2
//   }
// }
```

---

#### 接口：syncFromCloud()

**功能：** 从云端同步数据到本地

```typescript
interface SyncFromCloudResult {
  success: boolean;
  downloaded?: {
    formulas: number;
    history: number;
    graphs: number;
  };
  error?: string;
}

async function syncFromCloud(
  options?: SyncOptions
): Promise<SyncFromCloudResult>;
```

---

#### 接口：getLastSyncTime()

**功能：** 获取最后同步时间

```typescript
async function getLastSyncTime(): Promise<Date | null>;
```

---

#### 接口：getSyncStatus()

**功能：** 获取同步状态

```typescript
interface SyncStatus {
  isSyncing: boolean; // 是否正在同步
  lastSyncTime: Date | null; // 最后同步时间
  unsyncedCount: {
    formulas: number;
    history: number;
    graphs: number;
  };
}

async function getSyncStatus(): Promise<SyncStatus>;
```

---

### 2.5 AuthService（认证服务）

#### 接口：signUp()

**功能：** 用户注册

```typescript
interface SignUpData {
  email: string;
  password: string;
  username?: string;
}

interface AuthResult {
  success: boolean;
  user?: {
    id: string;
    email: string;
    username?: string;
  };
  session?: {
    accessToken: string;
    refreshToken: string;
    expiresAt: number;
  };
  error?: string;
}

async function signUp(data: SignUpData): Promise<AuthResult>;
```

---

#### 接口：signIn()

**功能：** 用户登录

```typescript
interface SignInData {
  email: string;
  password: string;
}

async function signIn(data: SignInData): Promise<AuthResult>;
```

---

#### 接口：signOut()

**功能：** 用户登出

```typescript
async function signOut(): Promise<{ success: boolean; error?: string }>;
```

---

#### 接口：getSession()

**功能：** 获取当前会话

```typescript
async function getSession(): Promise<AuthResult['session'] | null>;
```

---

#### 接口：refreshSession()

**功能：** 刷新会话令牌

```typescript
async function refreshSession(): Promise<AuthResult>;
```

---

## 3. 云端 REST API

### 3.1 基础信息

**Base URL：** `https://[your-project].supabase.co/rest/v1/`  
**认证：** Bearer Token（JWT）  
**Content-Type：** `application/json`

---

### 3.2 认证接口

#### POST /auth/v1/signup

**功能：** 用户注册

**请求体：**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**响应：** 200 OK
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2025-10-22T10:00:00Z"
  },
  "session": {
    "access_token": "jwt_token",
    "refresh_token": "refresh_token",
    "expires_at": 1729598400
  }
}
```

---

#### POST /auth/v1/token?grant_type=password

**功能：** 用户登录

**请求体：**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**响应：** 200 OK（同注册接口）

---

#### POST /auth/v1/logout

**功能：** 用户登出

**请求头：**
```
Authorization: Bearer {access_token}
```

**响应：** 204 No Content

---

### 3.3 公式接口

#### GET /cloud_formulas

**功能：** 获取用户公式列表

**请求头：**
```
Authorization: Bearer {access_token}
apikey: {supabase_anon_key}
```

**查询参数：**
- `category=eq.{category}` - 按分类筛选
- `name=ilike.%{keyword}%` - 按名称搜索
- `order=updated_at.desc` - 排序
- `limit={limit}` - 限制数量
- `offset={offset}` - 分页偏移

**响应：** 200 OK
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "name": "勾股定理",
    "expression": "a^2 + b^2 = c^2",
    "description": "直角三角形的边长关系",
    "category": "geometry",
    "created_at": "2025-10-22T10:00:00Z",
    "updated_at": "2025-10-22T10:00:00Z"
  }
]
```

---

#### POST /cloud_formulas

**功能：** 创建公式

**请求体：**
```json
{
  "name": "勾股定理",
  "expression": "a^2 + b^2 = c^2",
  "description": "直角三角形的边长关系",
  "category": "geometry"
}
```

**响应：** 201 Created（返回创建的公式对象）

---

#### PATCH /cloud_formulas?id=eq.{uuid}

**功能：** 更新公式

**请求体：**
```json
{
  "name": "勾股定理（更新）",
  "expression": "a^2 + b^2 = c^2",
  "updated_at": "2025-10-22T11:00:00Z"
}
```

**响应：** 200 OK

---

#### DELETE /cloud_formulas?id=eq.{uuid}

**功能：** 删除公式

**响应：** 204 No Content

---

### 3.4 历史记录接口

#### GET /cloud_history

**功能：** 获取历史记录

**查询参数：**
- `calc_type=eq.{type}` - 按类型筛选
- `created_at=gte.{date}` - 开始日期筛选
- `order=created_at.desc` - 排序
- `limit={limit}` - 限制数量

**响应：** 200 OK
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "expression": "1 + 2",
    "result": "3",
    "calc_type": "basic",
    "created_at": "2025-10-22T10:00:00Z"
  }
]
```

---

#### POST /cloud_history

**功能：** 创建历史记录

**请求体：**
```json
{
  "expression": "1 + 2",
  "result": "3",
  "calc_type": "basic"
}
```

**响应：** 201 Created

---

### 3.5 图像接口

#### GET /cloud_graphs

**功能：** 获取图像记录

**响应：** 200 OK
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "formula_id": "uuid",
    "expression": "sin(x)",
    "settings": {
      "x_min": -10,
      "x_max": 10,
      "color": "#1890ff"
    },
    "image_url": "https://storage.supabase.co/...",
    "created_at": "2025-10-22T10:00:00Z"
  }
]
```

---

#### POST /cloud_graphs

**功能：** 创建图像记录

**请求体：**
```json
{
  "expression": "sin(x)",
  "settings": {
    "x_min": -10,
    "x_max": 10,
    "color": "#1890ff"
  }
}
```

**响应：** 201 Created

---

### 3.6 文件上传接口（Supabase Storage）

#### POST /storage/v1/object/{bucket}/{path}

**功能：** 上传图像文件

**请求头：**
```
Authorization: Bearer {access_token}
Content-Type: image/png
```

**请求体：** Binary（图像文件）

**响应：** 200 OK
```json
{
  "Key": "user-id/graph-id.png"
}
```

---

## 4. 错误处理

### 4.1 错误码定义

| 错误码 | 说明 | HTTP 状态 |
|--------|------|-----------|
| INVALID_EXPRESSION | 无效的数学表达式 | 400 |
| DIVISION_BY_ZERO | 除以零错误 | 400 |
| CALCULATION_ERROR | 计算错误 | 500 |
| UNAUTHORIZED | 未授权 | 401 |
| FORBIDDEN | 禁止访问 | 403 |
| NOT_FOUND | 资源不存在 | 404 |
| DUPLICATE_NAME | 公式名称重复 | 409 |
| SYNC_FAILED | 同步失败 | 500 |
| NETWORK_ERROR | 网络错误 | 503 |

### 4.2 错误响应格式

```typescript
interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
}
```

**示例：**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_EXPRESSION",
    "message": "表达式语法错误",
    "details": {
      "position": 5,
      "token": "^"
    }
  }
}
```

---

## 5. 版本控制

### 5.1 API 版本

- **当前版本：** v1
- **版本策略：** URL 路径版本控制（/v1/, /v2/）
- **向后兼容：** 保持主版本号（v1）向后兼容

### 5.2 数据模型版本

- **当前版本：** 1.0.0
- **版本升级：** 通过数据迁移脚本

---

## 总结

本 API 契约文档定义了 SmartCalc 的所有接口规范，包括本地模块接口和云端 REST API。所有接口都有清晰的输入输出定义、示例和错误处理，确保开发的一致性和可维护性。

**关键特性：**
- ✅ 类型安全：TypeScript 接口定义
- ✅ 统一错误处理：标准化错误格式
- ✅ RESTful 设计：符合 REST 最佳实践
- ✅ 认证授权：JWT 令牌 + RLS 策略

---

**下一步：** 更新 AI 代理上下文，生成快速开始指南。
