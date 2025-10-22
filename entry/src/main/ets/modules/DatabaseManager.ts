/**
 * 数据库管理器
 * 负责 SQLite 数据库的初始化和管理
 */
import relationalStore from '@ohos.data.relationalStore';
import { Logger } from '../utils/Logger';
import { DB_NAME, DB_VERSION } from '../utils/Constants';

export class DatabaseManager {
  private static instance: DatabaseManager;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  /**
   * 初始化数据库
   */
  async initialize(context: Context): Promise<void> {
    try {
      Logger.info('Initializing database...');
      
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.store = await relationalStore.getRdbStore(context, config);
      Logger.info('Database store created');

      await this.createTables();
      Logger.info('Database initialized successfully');
    } catch (error) {
      Logger.error('Failed to initialize database', error);
      throw error;
    }
  }

  /**
   * 创建所有数据表
   */
  private async createTables(): Promise<void> {
    if (!this.store) {
      throw new Error('Database not initialized');
    }

    try {
      // 创建公式表
      await this.store.executeSql(`
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
      Logger.info('Table formulas created');

      // 创建索引
      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_formulas_user ON formulas(user_id)
      `);
      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_formulas_sync ON formulas(sync_state)
      `);
      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_formulas_category ON formulas(category)
      `);

      // 创建历史记录表
      await this.store.executeSql(`
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
      Logger.info('Table history_records created');

      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_history_user ON history_records(user_id)
      `);
      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_history_date ON history_records(created_at DESC)
      `);
      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_history_type ON history_records(calc_type)
      `);

      // 创建图像记录表
      await this.store.executeSql(`
        CREATE TABLE IF NOT EXISTS graph_records (
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
          cloud_id TEXT,
          FOREIGN KEY(formula_id) REFERENCES formulas(id) ON DELETE CASCADE
        )
      `);
      Logger.info('Table graph_records created');

      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_graphs_user ON graph_records(user_id)
      `);
      await this.store.executeSql(`
        CREATE INDEX IF NOT EXISTS idx_graphs_formula ON graph_records(formula_id)
      `);

      // 创建用户设置表
      await this.store.executeSql(`
        CREATE TABLE IF NOT EXISTS user_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT UNIQUE NOT NULL,
          theme TEXT DEFAULT 'light',
          layout_mode TEXT DEFAULT 'compact',
          precision INTEGER DEFAULT 10,
          angle_unit TEXT DEFAULT 'degree',
          auto_sync INTEGER DEFAULT 1,
          history_limit INTEGER DEFAULT 1000,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
          sync_state INTEGER DEFAULT 0
        )
      `);
      Logger.info('Table user_settings created');

      Logger.info('All tables created successfully');
    } catch (error) {
      Logger.error('Failed to create tables', error);
      throw error;
    }
  }

  /**
   * 获取数据库实例
   */
  getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database not initialized. Call initialize() first.');
    }
    return this.store;
  }

  /**
   * 关闭数据库
   */
  async close(): Promise<void> {
    if (this.store) {
      // HarmonyOS RdbStore 没有显式的 close 方法
      this.store = null;
      Logger.info('Database closed');
    }
  }
}

