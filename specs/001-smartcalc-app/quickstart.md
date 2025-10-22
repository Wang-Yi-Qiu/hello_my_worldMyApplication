# 快速开始指南：智能计算器 SmartCalc

**项目：** 智能计算器 SmartCalc  
**版本：** 1.0.0  
**日期：** 2025-10-22  
**分支：** 001-smartcalc-app

---

## 1. 环境准备

### 1.1 必需软件

1. **DevEco Studio** (版本 ≥ 4.0)
   - 下载：https://developer.harmonyos.com/cn/develop/deveco-studio
   - HarmonyOS SDK（API 10+）

2. **Node.js** (版本 ≥ 16.0)
   - 下载：https://nodejs.org/

3. **Git**
   - 下载：https://git-scm.com/

### 1.2 可选软件

- **Supabase CLI**（用于本地开发和测试）
  ```bash
  npm install -g supabase
  ```

---

## 2. 项目初始化

### 2.1 克隆项目

```bash
git clone <repository-url>
cd hello_my_worldMyApplication
git checkout 001-smartcalc-app
```

### 2.2 安装依赖

```bash
# 安装 HarmonyOS 依赖
ohpm install

# 或使用 npm（如果项目配置支持）
npm install
```

### 2.3 配置环境变量

创建 `entry/src/main/resources/rawfile/config.json`：

```json
{
  "supabase": {
    "url": "https://your-project.supabase.co",
    "anonKey": "your-anon-key"
  },
  "app": {
    "version": "1.0.0",
    "env": "development"
  }
}
```

---

## 3. 项目结构

```
entry/
├── src/
│   ├── main/
│   │   ├── ets/
│   │   │   ├── pages/                    # 页面组件
│   │   │   │   ├── Index.ets             # 主页（计算器）
│   │   │   │   ├── CalculatorPage.ets    # 计算器页面
│   │   │   │   ├── GraphPage.ets         # 图像页面
│   │   │   │   ├── FormulaPage.ets       # 公式管理页面
│   │   │   │   └── HistoryPage.ets       # 历史记录页面
│   │   │   │
│   │   │   ├── components/               # 可复用组件
│   │   │   │   ├── CalculatorButton.ets  # 计算器按钮
│   │   │   │   ├── FormulaListItem.ets   # 公式列表项
│   │   │   │   └── GraphCanvas.ets       # 图像画布
│   │   │   │
│   │   │   ├── modules/                  # 业务逻辑模块
│   │   │   │   ├── ExpressionEngine.ts   # 表达式引擎
│   │   │   │   ├── ChartGenerator.ts     # 图表生成器
│   │   │   │   ├── DataManager.ts        # 数据管理器
│   │   │   │   ├── SyncService.ts        # 同步服务
│   │   │   │   └── AuthService.ts        # 认证服务
│   │   │   │
│   │   │   ├── utils/                    # 工具类
│   │   │   │   ├── Validator.ts          # 验证工具
│   │   │   │   ├── Formatter.ts          # 格式化工具
│   │   │   │   └── Logger.ts             # 日志工具
│   │   │   │
│   │   │   ├── models/                   # 数据模型
│   │   │   │   ├── Formula.ts            # 公式模型
│   │   │   │   ├── HistoryRecord.ts      # 历史记录模型
│   │   │   │   └── UserSettings.ts       # 用户设置模型
│   │   │   │
│   │   │   ├── entryability/             # 应用入口
│   │   │   │   └── EntryAbility.ets      # 主入口
│   │   │   │
│   │   │   └── workers/                  # 后台任务
│   │   │       └── CalcWorker.ts         # 计算 Worker
│   │   │
│   │   ├── resources/                    # 资源文件
│   │   │   ├── base/
│   │   │   │   ├── element/              # 字符串、颜色等
│   │   │   │   ├── media/                # 图片资源
│   │   │   │   └── profile/              # 配置文件
│   │   │   ├── dark/                     # 深色主题资源
│   │   │   └── rawfile/                  # 原始文件（配置等）
│   │   │
│   │   └── module.json5                  # 模块配置
│   │
│   ├── ohosTest/                         # 测试代码
│   │   └── ets/
│   │       └── test/
│   │           ├── ExpressionEngine.test.ets
│   │           ├── DataManager.test.ets
│   │           └── SyncService.test.ets
│   │
│   └── mock/                             # Mock 数据
│       └── mock-config.json5
│
├── build-profile.json5                   # 构建配置
├── hvigorfile.ts                         # 构建脚本
└── oh-package.json5                      # 依赖配置
```

---

## 4. 核心模块开发

### 4.1 表达式引擎（ExpressionEngine）

**文件：** `entry/src/main/ets/modules/ExpressionEngine.ts`

```typescript
import * as math from 'mathjs';

export class ExpressionEngine {
  private parser: math.Parser;
  
  constructor() {
    this.parser = math.parser();
    math.config({ 
      precision: 100, 
      number: 'BigNumber' 
    });
  }
  
  /**
   * 计算表达式
   */
  evaluate(expression: string, options?: EvaluateOptions): EvaluateResult {
    try {
      // 设置角度单位
      if (options?.angleUnit === 'degree') {
        this.parser.set('deg', math.unit(1, 'deg'));
      }
      
      const result = this.parser.evaluate(expression);
      const formatted = math.format(result, { 
        notation: 'auto',
        precision: options?.precision || 10
      });
      
      return { success: true, result: formatted };
    } catch (error) {
      return { 
        success: false, 
        error: `计算错误: ${error.message}` 
      };
    }
  }
  
  /**
   * 求解方程
   */
  solveEquation(equation: string, options?: SolveOptions): SolveResult {
    try {
      const variable = options?.variable || 'x';
      const solutions = math.solve(equation, variable);
      const formatted = solutions.map(sol => 
        math.format(sol, { precision: options?.precision || 10 })
      );
      
      return { success: true, solutions: formatted };
    } catch (error) {
      return { 
        success: false, 
        error: `求解错误: ${error.message}` 
      };
    }
  }
}
```

---

### 4.2 数据管理器（DataManager）

**文件：** `entry/src/main/ets/modules/DataManager.ts`

```typescript
import relationalStore from '@ohos.data.relationalStore';

export class DataManager {
  private db: relationalStore.RdbStore;
  
  async initialize() {
    const config: relationalStore.StoreConfig = {
      name: 'SmartCalc.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    
    this.db = await relationalStore.getRdbStore(
      globalThis.abilityContext,
      config
    );
    
    await this.createTables();
  }
  
  private async createTables() {
    // 创建公式表
    await this.db.executeSql(`
      CREATE TABLE IF NOT EXISTS formulas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        name TEXT NOT NULL,
        expression TEXT NOT NULL,
        description TEXT,
        category TEXT DEFAULT 'general',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_state INTEGER DEFAULT 0,
        cloud_id TEXT,
        UNIQUE(user_id, name)
      )
    `);
    
    // 创建索引
    await this.db.executeSql(`
      CREATE INDEX IF NOT EXISTS idx_formulas_user 
      ON formulas(user_id)
    `);
    
    // 创建历史记录表
    await this.db.executeSql(`
      CREATE TABLE IF NOT EXISTS history_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        calc_type TEXT DEFAULT 'basic',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        sync_state INTEGER DEFAULT 0,
        cloud_id TEXT
      )
    `);
    
    // ... 其他表
  }
  
  /**
   * 保存公式
   */
  async saveFormula(formula: Formula): Promise<SaveResult> {
    try {
      const valueBucket: relationalStore.ValuesBucket = {
        name: formula.name,
        expression: formula.expression,
        description: formula.description || '',
        category: formula.category || 'general',
        sync_state: 0
      };
      
      if (formula.id) {
        // 更新
        await this.db.update('formulas', valueBucket, 
          'id = ?', [formula.id.toString()]);
        return { success: true, id: formula.id };
      } else {
        // 插入
        const rowId = await this.db.insert('formulas', valueBucket);
        return { success: true, id: Number(rowId) };
      }
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
  
  /**
   * 获取公式列表
   */
  async getFormulas(query?: FormulaQuery): Promise<GetFormulasResult> {
    try {
      let sql = 'SELECT * FROM formulas WHERE 1=1';
      const params: string[] = [];
      
      if (query?.category) {
        sql += ' AND category = ?';
        params.push(query.category);
      }
      
      if (query?.keyword) {
        sql += ' AND (name LIKE ? OR expression LIKE ?)';
        params.push(`%${query.keyword}%`, `%${query.keyword}%`);
      }
      
      sql += ' ORDER BY updated_at DESC';
      sql += ` LIMIT ${query?.limit || 100}`;
      sql += ` OFFSET ${query?.offset || 0}`;
      
      const resultSet = await this.db.querySql(sql, params);
      const formulas: Formula[] = [];
      
      while (resultSet.goToNextRow()) {
        formulas.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          expression: resultSet.getString(resultSet.getColumnIndex('expression')),
          description: resultSet.getString(resultSet.getColumnIndex('description')),
          category: resultSet.getString(resultSet.getColumnIndex('category')),
          createdAt: resultSet.getString(resultSet.getColumnIndex('created_at')),
          updatedAt: resultSet.getString(resultSet.getColumnIndex('updated_at'))
        });
      }
      
      resultSet.close();
      
      return { success: true, formulas, total: formulas.length };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}
```

---

### 4.3 同步服务（SyncService）

**文件：** `entry/src/main/ets/modules/SyncService.ts`

```typescript
import { createClient } from '@supabase/supabase-js';
import { DataManager } from './DataManager';

export class SyncService {
  private supabase;
  private dataManager: DataManager;
  private lastSyncTime: Date | null = null;
  
  constructor(supabaseUrl: string, supabaseKey: string) {
    this.supabase = createClient(supabaseUrl, supabaseKey);
    this.dataManager = new DataManager();
  }
  
  /**
   * 同步到云端
   */
  async syncToCloud(options?: SyncOptions): Promise<SyncResult> {
    try {
      // 1. 获取未同步的本地数据
      const unsyncedFormulas = await this.getUnsyncedFormulas();
      const unsyncedHistory = await this.getUnsyncedHistory();
      
      // 2. 上传到云端
      let uploadedFormulas = 0;
      for (const formula of unsyncedFormulas) {
        const { data, error } = await this.supabase
          .from('cloud_formulas')
          .upsert({
            id: formula.cloud_id,
            name: formula.name,
            expression: formula.expression,
            description: formula.description,
            category: formula.category,
            updated_at: formula.updatedAt
          });
        
        if (!error) {
          // 更新本地 sync_state
          await this.dataManager.updateFormulaSync State(formula.id, 1, data[0].id);
          uploadedFormulas++;
        }
      }
      
      // 同样处理历史记录...
      
      this.lastSyncTime = new Date();
      
      return {
        success: true,
        uploaded: {
          formulas: uploadedFormulas,
          history: 0,
          graphs: 0
        }
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
  
  /**
   * 从云端同步
   */
  async syncFromCloud(options?: SyncOptions): Promise<SyncFromCloudResult> {
    try {
      // 1. 获取云端自上次同步后的数据
      const { data: cloudFormulas, error } = await this.supabase
        .from('cloud_formulas')
        .select('*')
        .gt('updated_at', this.lastSyncTime?.toISOString() || '1970-01-01')
        .order('updated_at', { ascending: true });
      
      if (error) throw error;
      
      // 2. 合并到本地
      let downloadedFormulas = 0;
      for (const cloudFormula of cloudFormulas) {
        await this.dataManager.saveFormula({
          name: cloudFormula.name,
          expression: cloudFormula.expression,
          description: cloudFormula.description,
          category: cloudFormula.category
        });
        downloadedFormulas++;
      }
      
      this.lastSyncTime = new Date();
      
      return {
        success: true,
        downloaded: {
          formulas: downloadedFormulas,
          history: 0,
          graphs: 0
        }
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}
```

---

## 5. 运行和测试

### 5.1 运行应用

1. **连接设备或启动模拟器**
   - 真机：通过 USB 连接并开启开发者模式
   - 模拟器：在 DevEco Studio 中启动

2. **运行应用**
   - 点击 DevEco Studio 的 Run 按钮
   - 或使用命令行：`hvigorw assembleHap`

### 5.2 运行测试

```bash
# 运行所有测试
hvigorw test

# 运行特定测试文件
hvigorw test --tests ExpressionEngine.test.ets
```

### 5.3 调试

1. **使用 DevEco Studio 调试器**
   - 设置断点
   - 点击 Debug 按钮

2. **查看日志**
   ```typescript
   import hilog from '@ohos.hilog';
   
   hilog.info(0x0000, 'SmartCalc', 'Expression evaluated: %{public}s', result);
   ```

---

## 6. 构建和发布

### 6.1 构建 HAP 包

```bash
# 构建 Debug 版本
hvigorw assembleHap

# 构建 Release 版本
hvigorw assembleHap --mode release
```

输出路径：`entry/build/default/outputs/default/entry-default-unsigned.hap`

### 6.2 签名

1. **生成密钥和证书**（在 DevEco Studio 中）
2. **配置签名**
   - Build → Generate Signed Bundle/APK
   - 选择证书和密钥

### 6.3 发布到应用市场

1. **准备应用资料**
   - 应用图标、截图、描述
   - 隐私政策和用户协议

2. **上传到华为应用市场**
   - 登录 AppGallery Connect
   - 创建应用并上传 HAP 包
   - 填写应用信息并提交审核

---

## 7. 常见问题

### Q1: 如何配置 Supabase？

**A:** 在 Supabase 控制台创建项目，获取 URL 和 Anon Key，配置到 `config.json` 文件中。

### Q2: 如何处理离线模式？

**A:** 应用默认使用本地数据库，网络可用时自动触发同步。

### Q3: 如何调试数学计算错误？

**A:** 使用 `hilog` 记录表达式和结果，检查 math.js 的错误信息。

### Q4: 如何优化应用启动速度？

**A:** 使用懒加载、预加载常用数据、优化资源打包。

---

## 8. 下一步

- ✅ 完成核心模块开发
- ✅ 编写单元测试
- ✅ 实现 UI 界面
- ✅ 集成云端服务
- ✅ 性能优化
- ✅ 用户测试

---

**祝你开发顺利！** 🎉

如有问题，请查阅：
- [HarmonyOS 开发文档](https://developer.harmonyos.com/)
- [Supabase 文档](https://supabase.com/docs)
- [math.js 文档](https://mathjs.org/docs/)
