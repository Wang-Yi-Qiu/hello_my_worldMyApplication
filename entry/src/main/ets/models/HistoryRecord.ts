/**
 * 历史记录模型
 */
import { CalcType, SyncState } from '../utils/Constants';

export interface HistoryRecord {
  id?: number;
  user_id?: string;
  expression: string;
  result: string;
  calc_type?: string;
  created_at?: string;
  sync_state?: number;
  cloud_id?: string;
  is_favorite?: number; // 0 = 未收藏, 1 = 已收藏
  category?: string; // 'basic' | 'advanced' | 'derivative' | 'integral' | 'limit' | 'equation'
}

export class HistoryRecordModel {
  id?: number;
  userId?: string;
  expression: string;
  result: string;
  calcType: string;
  createdAt: string;
  syncState: SyncState;
  cloudId?: string;
  isFavorite: boolean;
  category: string;

  constructor(data: HistoryRecord) {
    this.id = data.id;
    this.userId = data.user_id;
    this.expression = data.expression;
    this.result = data.result;
    this.calcType = data.calc_type || CalcType.BASIC;
    this.createdAt = data.created_at || new Date().toISOString();
    this.syncState = data.sync_state !== undefined ? data.sync_state : SyncState.UNSYNCED;
    this.cloudId = data.cloud_id;
    this.isFavorite = data.is_favorite === 1;
    this.category = data.category || this.inferCategory(data.calc_type);
  }

  /**
   * 根据计算类型推断分类
   */
  private inferCategory(calcType?: string): string {
    if (!calcType) return 'basic';
    
    if (calcType.includes('derivative') || calcType.includes('求导')) {
      return 'derivative';
    }
    if (calcType.includes('integral') || calcType.includes('积分')) {
      return 'integral';
    }
    if (calcType.includes('limit') || calcType.includes('极限')) {
      return 'limit';
    }
    if (calcType.includes('equation') || calcType.includes('方程')) {
      return 'equation';
    }
    if (calcType === 'scientific' || calcType.includes('科学')) {
      return 'scientific';
    }
    
    return 'basic';
  }

  /**
   * 获取分类的中文名称
   */
  getCategoryName(): string {
    const categoryNames: Record<string, string> = {
      'basic': '基础运算',
      'scientific': '科学计算',
      'advanced': '高等数学',
      'derivative': '求导',
      'integral': '积分',
      'limit': '极限',
      'equation': '方程'
    };
    return categoryNames[this.category] || '其他';
  }

  /**
   * 获取分类图标
   */
  getCategoryIcon(): string {
    const categoryIcons: Record<string, string> = {
      'basic': '🔢',
      'scientific': '🔬',
      'advanced': '📐',
      'derivative': '∂',
      'integral': '∫',
      'limit': 'lim',
      'equation': '='
    };
    return categoryIcons[this.category] || '📝';
  }

  toDatabase(): HistoryRecord {
    return {
      id: this.id,
      user_id: this.userId,
      expression: this.expression,
      result: this.result,
      calc_type: this.calcType,
      created_at: this.createdAt,
      sync_state: this.syncState,
      cloud_id: this.cloudId,
      is_favorite: this.isFavorite ? 1 : 0,
      category: this.category
    };
  }

  static fromDatabase(data: HistoryRecord): HistoryRecordModel {
    return new HistoryRecordModel(data);
  }
}
