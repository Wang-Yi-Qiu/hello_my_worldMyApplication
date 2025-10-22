# 技术研究文档：智能计算器 SmartCalc

**项目：** 智能计算器 SmartCalc  
**版本：** 1.0.0  
**日期：** 2025-10-22  
**分支：** 001-smartcalc-app

---

## 1. 高精度数学计算

### 决策：使用 BigNumber.js 或 math.js 库

**理由：**
- **BigNumber.js**：轻量级（~6KB），专注高精度任意精度算术运算
- **math.js**：功能全面（~500KB），支持复数、矩阵、单位转换、符号计算
- **推荐选择**：math.js - 满足项目需求的高级数学功能

**实现方案：**
- 支持至少 100 位有效数字的精度配置
- 自定义配置：`math.config({ precision: 100, number: 'BigNumber' })`
- 对用户输入进行精度验证和格式化

**替代方案：**
- decimal.js：专注十进制运算，适合金融计算
- big.js：更轻量，但功能有限
- 自行实现高精度库：开发成本高，不推荐

---

## 2. 数学表达式解析引擎

### 决策：基于 math.js 的表达式解析器

**理由：**
- math.js 内置强大的表达式解析和求值功能
- 支持变量、函数、自定义运算符
- 支持符号计算（通过 algebra.js 扩展）
- 性能优异，满足 1 秒内计算要求

**实现方案：**
```typescript
// 伪代码示例
import * as math from 'mathjs';

class ExpressionEngine {
  private parser: math.Parser;
  
  constructor() {
    this.parser = math.parser();
    math.config({ precision: 100, number: 'BigNumber' });
  }
  
  evaluate(expression: string): string {
    try {
      const result = this.parser.evaluate(expression);
      return math.format(result, { notation: 'auto' });
    } catch (error) {
      throw new Error(`表达式错误: ${error.message}`);
    }
  }
  
  solveEquation(equation: string, variable: string): string[] {
    // 使用 math.js 的 solve 函数
    const solutions = math.solve(equation, variable);
    return solutions.map(sol => math.format(sol));
  }
}
```

**替代方案：**
- expr-eval：轻量级表达式求值库
- algebrite：符号计算库（JavaScript 版 Maxima）
- 自行实现解析器：使用 PEG.js 或递归下降解析

---

## 3. 函数图像生成

### 决策：使用 Canvas + ECharts 组合

**理由：**
- **Canvas**：HarmonyOS 原生支持，性能优异
- **ECharts**：强大的图表库，支持函数绘图、交互、导出
- ECharts 支持 HarmonyOS（通过 eChart-ohos 适配）

**实现方案：**
```typescript
// ChartGenerator.ts 伪代码
import * as echarts from 'echarts';

class ChartGenerator {
  private chart: echarts.ECharts;
  
  generateFunctionGraph(expression: string, range: [number, number]): void {
    const xData = this.generateXValues(range);
    const yData = xData.map(x => this.evaluateFunction(expression, x));
    
    const option = {
      xAxis: { type: 'value' },
      yAxis: { type: 'value' },
      series: [{
        type: 'line',
        data: xData.map((x, i) => [x, yData[i]]),
        smooth: true
      }]
    };
    
    this.chart.setOption(option);
  }
  
  exportToPNG(): Blob {
    return this.chart.getDataURL({ type: 'png', pixelRatio: 2 });
  }
  
  exportToSVG(): string {
    return this.chart.renderToSVGString();
  }
}
```

**替代方案：**
- D3.js：功能强大但学习曲线陡峭
- Chart.js：简单易用但功能有限
- 自绘 Canvas：性能最优但开发成本高

---

## 4. 本地数据存储

### 决策：使用 @ohos.data.relationalStore (SQLite)

**理由：**
- HarmonyOS 官方推荐的关系型数据库方案
- 支持 ACID 事务，数据可靠性高
- 性能优异，支持索引和查询优化
- 支持数据加密

**数据库表结构：**

#### 表：formulas（公式）
```sql
CREATE TABLE formulas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  name TEXT NOT NULL,
  expression TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'general',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  sync_state INTEGER DEFAULT 0,
  UNIQUE(user_id, name)
);

CREATE INDEX idx_formulas_user ON formulas(user_id);
CREATE INDEX idx_formulas_sync ON formulas(sync_state);
```

#### 表：history_records（历史记录）
```sql
CREATE TABLE history_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  expression TEXT NOT NULL,
  result TEXT NOT NULL,
  calc_type TEXT DEFAULT 'basic',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  sync_state INTEGER DEFAULT 0
);

CREATE INDEX idx_history_user ON history_records(user_id);
CREATE INDEX idx_history_date ON history_records(created_at DESC);
```

#### 表：graph_records（图像记录）
```sql
CREATE TABLE graph_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,
  formula_id INTEGER,
  expression TEXT NOT NULL,
  x_min REAL DEFAULT -10,
  x_max REAL DEFAULT 10,
  y_min REAL,
  y_max REAL,
  color TEXT DEFAULT '#1890ff',
  image_path TEXT,
  cloud_url TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  sync_state INTEGER DEFAULT 0,
  FOREIGN KEY(formula_id) REFERENCES formulas(id) ON DELETE CASCADE
);

CREATE INDEX idx_graphs_user ON graph_records(user_id);
CREATE INDEX idx_graphs_formula ON graph_records(formula_id);
```

#### 表：user_settings（用户设置）
```sql
CREATE TABLE user_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT UNIQUE NOT NULL,
  theme TEXT DEFAULT 'light',
  layout_mode TEXT DEFAULT 'compact',
  precision INTEGER DEFAULT 10,
  angle_unit TEXT DEFAULT 'degree',
  auto_sync INTEGER DEFAULT 1,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**替代方案：**
- @ohos.data.preferences：轻量级键值存储，不适合复杂数据
- IndexedDB（如果 Web 版本）：浏览器端数据库
- 自定义文件存储：管理复杂，不推荐

---

## 5. 云端存储和同步

### 决策：使用 Supabase（PostgreSQL + Auth + Storage）

**理由：**
- 开源、免费套餐充足
- 提供完整的后端服务：数据库、认证、文件存储、实时订阅
- RESTful API 和 TypeScript SDK
- 支持 RLS（Row Level Security）数据隔离
- 易于集成和部署

**云端数据库表结构：**

#### 表：users（用户）
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  phone TEXT UNIQUE,
  username TEXT UNIQUE,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP
);

-- RLS 策略：用户只能访问自己的数据
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_access ON users FOR ALL USING (auth.uid() = id);
```

#### 表：cloud_formulas（云端公式）
```sql
CREATE TABLE cloud_formulas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  expression TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'general',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, name)
);

CREATE INDEX idx_cloud_formulas_user ON cloud_formulas(user_id);
ALTER TABLE cloud_formulas ENABLE ROW LEVEL SECURITY;
CREATE POLICY formula_access ON cloud_formulas FOR ALL USING (auth.uid() = user_id);
```

#### 表：cloud_history（云端历史）
```sql
CREATE TABLE cloud_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  expression TEXT NOT NULL,
  result TEXT NOT NULL,
  calc_type TEXT DEFAULT 'basic',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cloud_history_user ON cloud_history(user_id, created_at DESC);
ALTER TABLE cloud_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY history_access ON cloud_history FOR ALL USING (auth.uid() = user_id);
```

#### 表：cloud_graphs（云端图像）
```sql
CREATE TABLE cloud_graphs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  formula_id UUID REFERENCES cloud_formulas(id) ON DELETE SET NULL,
  expression TEXT NOT NULL,
  settings JSONB,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cloud_graphs_user ON cloud_graphs(user_id);
ALTER TABLE cloud_graphs ENABLE ROW LEVEL SECURITY;
CREATE POLICY graph_access ON cloud_graphs FOR ALL USING (auth.uid() = user_id);
```

**同步策略：**
```typescript
class SyncService {
  private lastSyncTime: Date;
  
  async syncToCloud(): Promise<void> {
    // 1. 获取本地未同步数据（sync_state = 0）
    const localFormulas = await this.getUnsyncedFormulas();
    const localHistory = await this.getUnsyncedHistory();
    
    // 2. 上传到云端
    await this.uploadFormulas(localFormulas);
    await this.uploadHistory(localHistory);
    
    // 3. 更新本地 sync_state = 1
    await this.markAsSynced(localFormulas, localHistory);
  }
  
  async syncFromCloud(): Promise<void> {
    // 1. 获取云端自上次同步后的变更数据
    const cloudFormulas = await this.fetchCloudFormulas(this.lastSyncTime);
    const cloudHistory = await this.fetchCloudHistory(this.lastSyncTime);
    
    // 2. 合并到本地（基于 updated_at 时间戳）
    await this.mergeFormulas(cloudFormulas);
    await this.mergeHistory(cloudHistory);
    
    // 3. 更新最后同步时间
    this.lastSyncTime = new Date();
  }
  
  async handleConflict(localItem: any, cloudItem: any): Promise<any> {
    // 冲突解决策略：保留最新版本
    return localItem.updated_at > cloudItem.updated_at ? localItem : cloudItem;
  }
}
```

**替代方案：**
- 华为云 CloudDB：HarmonyOS 官方方案，但需要华为开发者账号
- Firebase：功能全面，但在中国访问受限
- 自建后端（Node.js + PostgreSQL）：灵活但维护成本高

---

## 6. 用户认证

### 决策：使用 Supabase Auth

**理由：**
- 与 Supabase 数据库无缝集成
- 支持多种认证方式：邮箱、手机号、OAuth（Google、GitHub 等）
- 内置 JWT 令牌管理
- 支持 RLS（Row Level Security）实现数据隔离

**实现方案：**
```typescript
import { createClient } from '@supabase/supabase-js';

class AuthService {
  private supabase;
  
  constructor() {
    this.supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
  }
  
  async signUp(email: string, password: string): Promise<User> {
    const { data, error } = await this.supabase.auth.signUp({
      email,
      password
    });
    
    if (error) throw new Error(error.message);
    return data.user;
  }
  
  async signIn(email: string, password: string): Promise<Session> {
    const { data, error } = await this.supabase.auth.signInWithPassword({
      email,
      password
    });
    
    if (error) throw new Error(error.message);
    return data.session;
  }
  
  async signOut(): Promise<void> {
    await this.supabase.auth.signOut();
  }
  
  async getSession(): Promise<Session | null> {
    const { data } = await this.supabase.auth.getSession();
    return data.session;
  }
}
```

**替代方案：**
- 华为账号系统：HarmonyOS 原生支持，但限制较多
- 自建认证系统（JWT + bcrypt）：灵活但安全风险高
- Auth0：第三方认证服务，功能强大但成本较高

---

## 7. UI 框架和布局

### 决策：使用 ArkUI 声明式框架

**理由：**
- HarmonyOS 官方 UI 框架，性能最优
- 声明式语法，类似 React/Flutter
- 内置响应式布局和适配能力
- 丰富的组件库

**多布局适配方案：**
```typescript
// 使用媒体查询和断点实现响应式布局
@Entry
@Component
struct CalculatorPage {
  @State layoutMode: string = 'compact';
  
  aboutToAppear() {
    // 根据屏幕尺寸判断布局模式
    const width = display.getDefaultDisplay().width;
    if (width < 600) {
      this.layoutMode = 'pocket';
    } else if (width < 900) {
      this.layoutMode = 'compact';
    } else {
      this.layoutMode = 'expanded';
    }
  }
  
  build() {
    if (this.layoutMode === 'pocket') {
      // Pocket 布局：仅基础按键
      this.buildPocketLayout();
    } else if (this.layoutMode === 'compact') {
      // Compact 布局：手机全功能
      this.buildCompactLayout();
    } else {
      // Expanded 布局：平板分栏
      this.buildExpandedLayout();
    }
  }
  
  @Builder buildExpandedLayout() {
    Row() {
      // 左侧：计算区
      Column() { /* ... */ }.width('60%');
      // 右侧：历史/公式/图像
      Column() { /* ... */ }.width('40%');
    }
  }
}
```

**替代方案：**
- 无替代方案（HarmonyOS 必须使用 ArkUI）

---

## 8. 图像导出

### 决策：Canvas 转 PNG/SVG

**理由：**
- Canvas 原生支持 toDataURL（PNG 格式）
- ECharts 提供 renderToSVGString（SVG 格式）
- 使用 @ohos.file.fs 保存到本地

**实现方案：**
```typescript
import fs from '@ohos.file.fs';

class ImageExporter {
  async exportPNG(canvas: CanvasRenderingContext2D, filename: string): Promise<string> {
    const dataUrl = canvas.canvas.toDataURL('image/png');
    const base64Data = dataUrl.split(',')[1];
    const buffer = Buffer.from(base64Data, 'base64');
    
    const filePath = `${globalThis.abilityContext.filesDir}/${filename}.png`;
    await fs.writeFile(filePath, buffer);
    
    return filePath;
  }
  
  async exportSVG(svgString: string, filename: string): Promise<string> {
    const filePath = `${globalThis.abilityContext.filesDir}/${filename}.svg`;
    await fs.writeFile(filePath, svgString);
    
    return filePath;
  }
}
```

**替代方案：**
- 截图 API：使用 @ohos.screenshot，但无法自定义内容
- 第三方导出库：增加依赖，不推荐

---

## 9. 性能优化策略

### 计算性能优化

**策略：**
- 使用 Web Worker（HarmonyOS 支持 Worker）进行后台计算
- 缓存常用表达式的计算结果
- 对复杂计算使用渐进式渲染

```typescript
// Worker 示例
// main thread
const worker = new worker.ThreadWorker('entry/ets/workers/CalcWorker.ts');
worker.postMessage({ expression: 'sin(x) + cos(x)', x: 3.14 });
worker.onmessage = (event) => {
  console.log('Result:', event.data.result);
};

// CalcWorker.ts
const workerPort = worker.workerPort;
workerPort.onmessage = (event) => {
  const { expression, x } = event.data;
  const result = evaluateExpression(expression, x);
  workerPort.postMessage({ result });
};
```

### 启动性能优化

**策略：**
- 懒加载非核心模块
- 预加载常用数据（公式、设置）
- 优化资源打包（压缩、分包）

### 渲染性能优化

**策略：**
- 使用虚拟列表（历史记录、公式列表）
- 防抖/节流处理用户输入
- 图像绘制使用 requestAnimationFrame

---

## 10. 测试策略

### 单元测试

**工具：** @ohos/hypium（HarmonyOS 官方测试框架）

**测试范围：**
- 数学计算引擎（ExpressionEngine）
- 数据管理（DataManager）
- 同步服务（SyncService）

```typescript
import { describe, it, expect } from '@ohos/hypium';

describe('ExpressionEngine', () => {
  it('should evaluate basic arithmetic', () => {
    const engine = new ExpressionEngine();
    expect(engine.evaluate('1 + 2')).toBe('3');
    expect(engine.evaluate('10 / 3')).toBe('3.333...');
  });
  
  it('should solve equations', () => {
    const engine = new ExpressionEngine();
    const solutions = engine.solveEquation('x^2 - 4 = 0', 'x');
    expect(solutions).toEqual(['-2', '2']);
  });
});
```

### 集成测试

**测试范围：**
- 页面交互流程
- 数据同步流程
- 离线/在线切换

### 性能测试

**测试指标：**
- 启动时间：< 2 秒
- 计算响应：< 1 秒
- 图像生成：< 0.5 秒
- 内存占用：< 200MB

---

## 11. 安全和隐私

### 数据安全

**措施：**
- 本地数据库加密（SQLCipher）
- 网络传输 HTTPS
- 敏感数据（密码）使用 bcrypt 哈希

### 隐私保护

**措施：**
- 遵循 GDPR 和中国个人信息保护法
- 用户可选择完全离线使用
- 云端数据支持删除和导出
- 隐私政策和用户协议

---

## 12. 部署和发布

### 应用打包

**流程：**
1. 使用 DevEco Studio 打包生成 .hap 文件
2. 代码签名（开发者证书）
3. 版本号管理（Semantic Versioning）

### 发布渠道

**平台：**
- 华为应用市场（AppGallery）
- 其他 HarmonyOS 应用商店

### 更新策略

**方案：**
- 应用内检查更新
- 增量更新（减少下载大小）
- 数据库版本迁移

---

## 总结

本研究文档已解决所有技术选型和架构设计问题，为项目实施提供了清晰的技术路径。主要决策包括：

1. **数学计算**：math.js（高精度、功能全面）
2. **图像生成**：Canvas + ECharts（性能优、兼容性好）
3. **本地存储**：SQLite（官方推荐、可靠）
4. **云端服务**：Supabase（开源、功能完整）
5. **UI框架**：ArkUI（HarmonyOS 原生）

所有技术选型都经过充分评估，考虑了性能、可维护性、成本和项目需求。

---

**下一步：** 进入阶段 1，生成数据模型和 API 契约。
