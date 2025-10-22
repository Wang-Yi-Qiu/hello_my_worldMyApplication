# 数据模型设计：智能计算器 SmartCalc

**项目：** 智能计算器 SmartCalc  
**版本：** 1.0.0  
**日期：** 2025-10-22  
**分支：** 001-smartcalc-app

---

## 1. 数据模型概览

SmartCalc 采用双层数据架构：本地 SQLite 数据库（离线优先）+ 云端 Supabase 数据库（多设备同步）。

### 1.1 核心实体关系图

```
User (用户)
  ├─ 1:N → Formula (公式)
  ├─ 1:N → HistoryRecord (历史记录)
  ├─ 1:N → GraphRecord (图像记录)
  └─ 1:1 → UserSettings (用户设置)

Formula (公式)
  └─ 1:N → GraphRecord (图像记录)
```

---

## 2. 本地数据模型（SQLite）

### 2.1 Formula（公式）

**用途：** 存储用户保存的数学公式和表达式

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地唯一标识 |
| user_id | TEXT | | 用户 ID（离线时可为空） |
| name | TEXT | NOT NULL | 公式名称 |
| expression | TEXT | NOT NULL | 公式表达式 |
| description | TEXT | | 公式描述或备注 |
| category | TEXT | DEFAULT 'general' | 公式分类（general/algebra/calculus/geometry等） |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 创建时间（ISO 8601） |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 最后更新时间（ISO 8601） |
| sync_state | INTEGER | DEFAULT 0 | 同步状态（0=未同步，1=已同步） |
| cloud_id | TEXT | | 云端对应记录的 UUID |

**索引：**
- `idx_formulas_user` ON (user_id)
- `idx_formulas_sync` ON (sync_state)
- `idx_formulas_category` ON (category)

**唯一约束：**
- UNIQUE(user_id, name) - 同一用户的公式名称不能重复

**验证规则：**
- name：长度 1-100 字符，不能为空
- expression：长度 1-500 字符，必须是有效数学表达式
- category：枚举值（general/algebra/calculus/geometry/trigonometry/statistics）

**状态转换：**
- 新建：sync_state = 0
- 同步后：sync_state = 1
- 修改后：sync_state = 0（触发重新同步）

---

### 2.2 HistoryRecord（历史记录）

**用途：** 存储所有计算历史记录

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地唯一标识 |
| user_id | TEXT | | 用户 ID（离线时可为空） |
| expression | TEXT | NOT NULL | 输入的表达式 |
| result | TEXT | NOT NULL | 计算结果 |
| calc_type | TEXT | DEFAULT 'basic' | 计算类型（basic/equation/calculus/matrix/graph） |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 计算时间（ISO 8601） |
| sync_state | INTEGER | DEFAULT 0 | 同步状态（0=未同步，1=已同步） |
| cloud_id | TEXT | | 云端对应记录的 UUID |

**索引：**
- `idx_history_user` ON (user_id)
- `idx_history_date` ON (created_at DESC)
- `idx_history_type` ON (calc_type)

**验证规则：**
- expression：长度 1-1000 字符
- result：长度 1-1000 字符
- calc_type：枚举值（basic/equation/calculus/matrix/graph/conversion）

**数据保留策略：**
- 默认保留最近 1000 条记录
- 超过限制时自动清理最旧记录（用户可配置）

---

### 2.3 GraphRecord（图像记录）

**用途：** 存储函数图像的配置和路径

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地唯一标识 |
| user_id | TEXT | | 用户 ID（离线时可为空） |
| formula_id | INTEGER | FOREIGN KEY | 关联的公式 ID |
| expression | TEXT | NOT NULL | 函数表达式 |
| x_min | REAL | DEFAULT -10 | X 轴最小值 |
| x_max | REAL | DEFAULT 10 | X 轴最大值 |
| y_min | REAL | | Y 轴最小值（自动计算） |
| y_max | REAL | | Y 轴最大值（自动计算） |
| color | TEXT | DEFAULT '#1890ff' | 图像颜色（十六进制） |
| image_path | TEXT | | 本地图像文件路径 |
| cloud_url | TEXT | | 云端图像 URL |
| created_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 创建时间（ISO 8601） |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 最后更新时间（ISO 8601） |
| sync_state | INTEGER | DEFAULT 0 | 同步状态（0=未同步，1=已同步） |
| cloud_id | TEXT | | 云端对应记录的 UUID |

**索引：**
- `idx_graphs_user` ON (user_id)
- `idx_graphs_formula` ON (formula_id)

**外键约束：**
- FOREIGN KEY(formula_id) REFERENCES formulas(id) ON DELETE CASCADE

**验证规则：**
- expression：长度 1-500 字符，必须是有效函数表达式
- x_min < x_max
- color：必须是有效的十六进制颜色代码

---

### 2.4 UserSettings（用户设置）

**用途：** 存储用户偏好设置

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地唯一标识 |
| user_id | TEXT | UNIQUE NOT NULL | 用户 ID |
| theme | TEXT | DEFAULT 'light' | 主题（light/dark） |
| layout_mode | TEXT | DEFAULT 'compact' | 布局模式（pocket/compact/expanded） |
| precision | INTEGER | DEFAULT 10 | 显示精度（小数位数） |
| angle_unit | TEXT | DEFAULT 'degree' | 角度单位（degree/radian） |
| auto_sync | INTEGER | DEFAULT 1 | 自动同步（0=关闭，1=开启） |
| history_limit | INTEGER | DEFAULT 1000 | 历史记录保留数量 |
| updated_at | TEXT | DEFAULT CURRENT_TIMESTAMP | 最后更新时间（ISO 8601） |
| sync_state | INTEGER | DEFAULT 0 | 同步状态（0=未同步，1=已同步） |

**验证规则：**
- theme：枚举值（light/dark）
- layout_mode：枚举值（pocket/compact/expanded）
- precision：范围 0-100
- angle_unit：枚举值（degree/radian）
- auto_sync：布尔值（0/1）
- history_limit：范围 100-10000

---

## 3. 云端数据模型（Supabase PostgreSQL）

### 3.1 users（用户）

**用途：** 存储用户账号信息（由 Supabase Auth 管理）

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | UUID | PRIMARY KEY | 用户唯一标识（由 Supabase Auth 生成） |
| email | TEXT | UNIQUE NOT NULL | 用户邮箱 |
| phone | TEXT | UNIQUE | 用户手机号 |
| username | TEXT | UNIQUE | 用户名 |
| created_at | TIMESTAMP | DEFAULT NOW() | 注册时间 |
| last_login | TIMESTAMP | | 最后登录时间 |

**RLS 策略：**
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_access ON users FOR ALL USING (auth.uid() = id);
```

---

### 3.2 cloud_formulas（云端公式）

**用途：** 存储用户公式的云端副本

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | UUID | PRIMARY KEY DEFAULT uuid_generate_v4() | 云端唯一标识 |
| user_id | UUID | NOT NULL REFERENCES users(id) ON DELETE CASCADE | 所属用户 |
| name | TEXT | NOT NULL | 公式名称 |
| expression | TEXT | NOT NULL | 公式表达式 |
| description | TEXT | | 公式描述 |
| category | TEXT | DEFAULT 'general' | 公式分类 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 最后更新时间 |

**索引：**
- `idx_cloud_formulas_user` ON (user_id)
- `idx_cloud_formulas_updated` ON (updated_at DESC)

**唯一约束：**
- UNIQUE(user_id, name)

**RLS 策略：**
```sql
ALTER TABLE cloud_formulas ENABLE ROW LEVEL SECURITY;
CREATE POLICY formula_access ON cloud_formulas FOR ALL USING (auth.uid() = user_id);
```

---

### 3.3 cloud_history（云端历史）

**用途：** 存储用户历史记录的云端副本

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | UUID | PRIMARY KEY DEFAULT uuid_generate_v4() | 云端唯一标识 |
| user_id | UUID | NOT NULL REFERENCES users(id) ON DELETE CASCADE | 所属用户 |
| expression | TEXT | NOT NULL | 输入表达式 |
| result | TEXT | NOT NULL | 计算结果 |
| calc_type | TEXT | DEFAULT 'basic' | 计算类型 |
| created_at | TIMESTAMP | DEFAULT NOW() | 计算时间 |

**索引：**
- `idx_cloud_history_user` ON (user_id, created_at DESC)

**RLS 策略：**
```sql
ALTER TABLE cloud_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY history_access ON cloud_history FOR ALL USING (auth.uid() = user_id);
```

---

### 3.4 cloud_graphs（云端图像）

**用途：** 存储函数图像的云端副本

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | UUID | PRIMARY KEY DEFAULT uuid_generate_v4() | 云端唯一标识 |
| user_id | UUID | NOT NULL REFERENCES users(id) ON DELETE CASCADE | 所属用户 |
| formula_id | UUID | REFERENCES cloud_formulas(id) ON DELETE SET NULL | 关联公式 |
| expression | TEXT | NOT NULL | 函数表达式 |
| settings | JSONB | | 图像设置（坐标范围、颜色等） |
| image_url | TEXT | | Supabase Storage 图像 URL |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 最后更新时间 |

**索引：**
- `idx_cloud_graphs_user` ON (user_id)
- `idx_cloud_graphs_updated` ON (updated_at DESC)

**settings JSONB 结构：**
```json
{
  "x_min": -10,
  "x_max": 10,
  "y_min": -5,
  "y_max": 5,
  "color": "#1890ff",
  "line_width": 2,
  "grid": true
}
```

**RLS 策略：**
```sql
ALTER TABLE cloud_graphs ENABLE ROW LEVEL SECURITY;
CREATE POLICY graph_access ON cloud_graphs FOR ALL USING (auth.uid() = user_id);
```

---

### 3.5 cloud_settings（云端设置）

**用途：** 存储用户设置的云端副本

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | UUID | PRIMARY KEY DEFAULT uuid_generate_v4() | 云端唯一标识 |
| user_id | UUID | UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE | 所属用户 |
| theme | TEXT | DEFAULT 'light' | 主题 |
| layout_mode | TEXT | DEFAULT 'compact' | 布局模式 |
| precision | INTEGER | DEFAULT 10 | 显示精度 |
| angle_unit | TEXT | DEFAULT 'degree' | 角度单位 |
| auto_sync | BOOLEAN | DEFAULT true | 自动同步 |
| history_limit | INTEGER | DEFAULT 1000 | 历史记录保留数量 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 最后更新时间 |

**RLS 策略：**
```sql
ALTER TABLE cloud_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY settings_access ON cloud_settings FOR ALL USING (auth.uid() = user_id);
```

---

## 4. 数据同步模型

### 4.1 同步状态机

```
[未同步] (sync_state = 0)
    ↓ 触发同步
[同步中] (sync_state = -1)
    ↓ 成功
[已同步] (sync_state = 1)
    ↓ 本地修改
[未同步] (sync_state = 0)
```

### 4.2 冲突解决策略

**策略：** Last Write Wins（最后写入胜出）

**规则：**
1. 比较本地 `updated_at` 和云端 `updated_at`
2. 保留时间戳较新的版本
3. 如果时间戳相同，保留云端版本（作为权威来源）

**实现：**
```typescript
function resolveConflict(local: Record, cloud: Record): Record {
  const localTime = new Date(local.updated_at).getTime();
  const cloudTime = new Date(cloud.updated_at).getTime();
  
  if (localTime > cloudTime) {
    return local; // 本地较新，上传到云端
  } else {
    return cloud; // 云端较新或相同，下载到本地
  }
}
```

### 4.3 增量同步

**策略：** 仅同步自上次同步后变更的数据

**本地 → 云端（上传）：**
```sql
SELECT * FROM formulas 
WHERE sync_state = 0 
  AND updated_at > last_sync_time;
```

**云端 → 本地（下载）：**
```sql
SELECT * FROM cloud_formulas 
WHERE user_id = ? 
  AND updated_at > last_sync_time;
```

---

## 5. 数据验证规则

### 5.1 通用验证

- 所有 TEXT 字段去除首尾空格
- 所有日期时间使用 ISO 8601 格式（YYYY-MM-DDTHH:mm:ss.sssZ）
- 所有数值字段检查范围
- 所有枚举字段验证合法值

### 5.2 表达式验证

**公式表达式验证：**
```typescript
function validateExpression(expression: string): boolean {
  try {
    math.parse(expression); // 使用 math.js 解析
    return true;
  } catch (error) {
    return false; // 无效表达式
  }
}
```

**函数表达式验证：**
```typescript
function validateFunctionExpression(expression: string): boolean {
  // 必须包含变量 x
  if (!expression.includes('x')) {
    return false;
  }
  
  try {
    math.parse(expression);
    math.evaluate(expression, { x: 0 }); // 测试求值
    return true;
  } catch (error) {
    return false;
  }
}
```

---

## 6. 数据迁移

### 6.1 版本控制

**策略：** 使用数据库版本号进行迁移管理

```typescript
const DB_VERSION = 1;

async function migrateDatabase(oldVersion: number, newVersion: number) {
  if (oldVersion < 1) {
    // 初始化数据库结构
    await createTables();
  }
  
  if (oldVersion < 2) {
    // 版本 2 的迁移逻辑（未来）
    // await addNewColumns();
  }
}
```

### 6.2 数据导入导出

**导出格式（JSON）：**
```json
{
  "version": "1.0.0",
  "export_date": "2025-10-22T10:00:00.000Z",
  "formulas": [ /* ... */ ],
  "history": [ /* ... */ ],
  "graphs": [ /* ... */ ],
  "settings": { /* ... */ }
}
```

---

## 7. 性能优化

### 7.1 索引策略

- 为常用查询字段创建索引（user_id, created_at, updated_at）
- 为外键创建索引（formula_id）
- 定期分析索引效率（ANALYZE）

### 7.2 查询优化

- 使用分页查询（LIMIT + OFFSET）
- 避免 SELECT *，只查询需要的字段
- 使用预编译语句（PreparedStatement）

### 7.3 数据清理

- 定期清理过期历史记录
- 清理未使用的图像文件
- 压缩数据库（VACUUM）

---

## 总结

本数据模型设计文档定义了 SmartCalc 的完整数据结构，包括本地和云端两层架构。所有实体都有清晰的字段定义、验证规则和关系约束，确保数据的完整性和一致性。

**关键特性：**
- ✅ 离线优先：本地数据库支持完全离线使用
- ✅ 云端同步：增量同步策略，高效可靠
- ✅ 数据安全：RLS 策略确保数据隔离
- ✅ 冲突解决：Last Write Wins 策略简单有效
- ✅ 性能优化：合理索引和查询优化

---

**下一步：** 生成 API 契约文档。
