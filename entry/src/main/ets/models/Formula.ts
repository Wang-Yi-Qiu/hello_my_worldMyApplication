/**
 * 公式模型
 */
import { FormulaCategory, SyncState } from '../utils/Constants';

export interface Formula {
  id?: number;
  user_id?: string;
  name: string;
  expression: string;
  description?: string;
  category?: string;
  created_at?: string;
  updated_at?: string;
  sync_state?: number;
  cloud_id?: string;
}

export class FormulaModel {
  id?: number;
  userId?: string;
  name: string;
  expression: string;
  description: string;
  category: string;
  createdAt: string;
  updatedAt: string;
  syncState: SyncState;
  cloudId?: string;

  constructor(data: Formula) {
    this.id = data.id;
    this.userId = data.user_id;
    this.name = data.name;
    this.expression = data.expression;
    this.description = data.description || '';
    this.category = data.category || FormulaCategory.GENERAL;
    this.createdAt = data.created_at || new Date().toISOString();
    this.updatedAt = data.updated_at || new Date().toISOString();
    this.syncState = data.sync_state !== undefined ? data.sync_state : SyncState.UNSYNCED;
    this.cloudId = data.cloud_id;
  }

  /**
   * 转换为数据库格式
   */
  toDatabase(): Formula {
    return {
      id: this.id,
      user_id: this.userId,
      name: this.name,
      expression: this.expression,
      description: this.description,
      category: this.category,
      created_at: this.createdAt,
      updated_at: this.updatedAt,
      sync_state: this.syncState,
      cloud_id: this.cloudId
    };
  }

  /**
   * 从数据库格式创建
   */
  static fromDatabase(data: Formula): FormulaModel {
    return new FormulaModel(data);
  }
}

