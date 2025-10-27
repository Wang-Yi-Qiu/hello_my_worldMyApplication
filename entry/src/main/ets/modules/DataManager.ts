/**
 * 数据管理器
 * 封装所有数据库 CRUD 操作
 */
import { relationalStore } from '@kit.ArkData';
import { DatabaseManager } from './DatabaseManager';
import { Formula, FormulaModel } from '../models/Formula';
import { HistoryRecord } from '../models/HistoryRecord';
import { Logger } from '../utils/Logger';

export interface SaveResult {
  success: boolean;
  id?: number;
  error?: string;
}

export interface FormulaQuery {
  category?: string;
  keyword?: string;
  limit?: number;
  offset?: number;
}

export interface GetFormulasResult {
  success: boolean;
  formulas?: FormulaModel[];
  total?: number;
  error?: string;
}

export interface HistoryQuery {
  calcType?: string;
  keyword?: string;
  fromDate?: string;
  toDate?: string;
  limit?: number;
  offset?: number;
}

export interface GetHistoryResult {
  success: boolean;
  history?: HistoryRecord[];
  total?: number;
  error?: string;
}

export class DataManager {
  private db: DatabaseManager;

  constructor() {
    this.db = DatabaseManager.getInstance();
  }

  /**
   * 保存公式
   */
  async saveFormula(formula: Formula): Promise<SaveResult> {
    try {
      const store = this.db.getStore();
      const valueBucket: relationalStore.ValuesBucket = {
        name: formula.name,
        expression: formula.expression,
        description: formula.description || '',
        category: formula.category || 'general',
        updated_at: new Date().toISOString(),
        sync_state: 0
      };

      if (formula.id) {
        // 更新
        const predicates = new relationalStore.RdbPredicates('formulas');
        predicates.equalTo('id', formula.id);
        await store.update(valueBucket, predicates);
        Logger.info(`Formula updated: ${formula.id}`);
        return { success: true, id: formula.id };
      } else {
        // 插入
        valueBucket.created_at = new Date().toISOString();
        const rowId = await store.insert('formulas', valueBucket);
        Logger.info(`Formula inserted: ${rowId}`);
        return { success: true, id: Number(rowId) };
      }
    } catch (error) {
      Logger.error('Save formula error', error);
      return { success: false, error: '保存公式失败' };
    }
  }

  /**
   * 获取公式列表
   */
  async getFormulas(query?: FormulaQuery): Promise<GetFormulasResult> {
    try {
      const store = this.db.getStore();
      const predicates = new relationalStore.RdbPredicates('formulas');

      if (query?.category) {
        predicates.equalTo('category', query.category);
      }

      if (query?.keyword) {
        predicates.and();
        predicates.beginWrap();
        predicates.like('name', `%${query.keyword}%`);
        predicates.or();
        predicates.like('expression', `%${query.keyword}%`);
        predicates.endWrap();
      }

      predicates.orderByDesc('updated_at');

      if (query?.limit) {
        predicates.limitAs(query.limit);
        if (query?.offset) {
          predicates.offsetAs(query.offset);
        }
      }

      const resultSet = await store.query(predicates);
      const formulas: FormulaModel[] = [];

      while (resultSet.goToNextRow()) {
        const formula: Formula = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          expression: resultSet.getString(resultSet.getColumnIndex('expression')),
          description: resultSet.getString(resultSet.getColumnIndex('description')),
          category: resultSet.getString(resultSet.getColumnIndex('category')),
          created_at: resultSet.getString(resultSet.getColumnIndex('created_at')),
          updated_at: resultSet.getString(resultSet.getColumnIndex('updated_at')),
          sync_state: resultSet.getLong(resultSet.getColumnIndex('sync_state'))
        };
        formulas.push(FormulaModel.fromDatabase(formula));
      }

      resultSet.close();
      Logger.info(`Fetched ${formulas.length} formulas`);

      return {
        success: true,
        formulas,
        total: formulas.length
      };
    } catch (error) {
      Logger.error('Get formulas error', error);
      return { success: false, error: '获取公式失败' };
    }
  }

  /**
   * 删除公式
   */
  async deleteFormula(id: number): Promise<SaveResult> {
    try {
      const store = this.db.getStore();
      const predicates = new relationalStore.RdbPredicates('formulas');
      predicates.equalTo('id', id);
      
      await store.delete(predicates);
      Logger.info(`Formula deleted: ${id}`);
      
      return { success: true };
    } catch (error) {
      Logger.error('Delete formula error', error);
      return { success: false, error: '删除公式失败' };
    }
  }

  /**
   * 保存历史记录
   */
  async saveHistory(record: HistoryRecord): Promise<SaveResult> {
    try {
      const store = this.db.getStore();
      const valueBucket: relationalStore.ValuesBucket = {
        expression: record.expression,
        result: record.result,
        id: record.id,
        created_at: new Date().toISOString(),
        sync_state: 0
      };

      const rowId = await store.insert('history_records', valueBucket);
      Logger.info(`History saved: ${rowId}`);
      
      return { success: true, id: Number(rowId) };
    } catch (error) {
      Logger.error('Save history error', error);
      return { success: false, error: '保存历史失败' };
    }
  }

  /**
   * 获取历史记录列表
   */
  async getHistory(query?: HistoryQuery): Promise<GetHistoryResult> {
    try {
      const store = this.db.getStore();
      const predicates = new relationalStore.RdbPredicates('history_records');

      // 移除了 calc_type 查询条件，因为 HistoryRecord 模型中没有此属性

      if (query?.keyword) {
        predicates.and();
        predicates.beginWrap();
        predicates.like('expression', `%${query.keyword}%`);
        predicates.or();
        predicates.like('result', `%${query.keyword}%`);
        predicates.endWrap();
      }

      if (query?.fromDate) {
        predicates.and();
        predicates.greaterThanOrEqualTo('created_at', query.fromDate);
      }

      if (query?.toDate) {
        predicates.and();
        predicates.lessThanOrEqualTo('created_at', query.toDate);
      }

      predicates.orderByDesc('created_at');

      if (query?.limit) {
        predicates.limitAs(query.limit);
        if (query?.offset) {
          predicates.offsetAs(query.offset);
        }
      }

      const resultSet = await store.query(predicates);
      const history: HistoryRecord[] = [];

      while (resultSet.goToNextRow()) {
        const record: HistoryRecord = {
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          expression: resultSet.getString(resultSet.getColumnIndex('expression')),
          result: parseFloat(resultSet.getString(resultSet.getColumnIndex('result'))),
          timestamp: parseInt(resultSet.getString(resultSet.getColumnIndex('created_at'))),
          emotion: {
            id: '',
            condition: '',
            text: '',
            emoji: '',
            priority: 0,
            isEnabled: true
          },
          fortune: '',
          isEasterEgg: false
        };
        history.push(record);
      }

      resultSet.close();
      Logger.info(`Fetched ${history.length} history records`);

      return {
        success: true,
        history,
        total: history.length
      };
    } catch (error) {
      Logger.error('Get history error', error);
      return { success: false, error: '获取历史失败' };
    }
  }

  /**
   * 更新历史记录
   */
  async updateHistory(id: number, history: HistoryRecord): Promise<SaveResult> {
    try {
      const store = this.db.getStore();
      const valueBucket: relationalStore.ValuesBucket = {
        expression: history.expression,
        result: history.result,
        id: history.id,
        sync_state: 0
      };

      const predicates = new relationalStore.RdbPredicates('history_records');
      predicates.equalTo('id', id);
      
      await store.update(valueBucket, predicates);
      Logger.info(`History updated: ${id}`);
      
      return { success: true, id };
    } catch (error) {
      Logger.error('Update history error', error);
      return { success: false, error: '更新历史失败' };
    }
  }

  /**
   * 删除单个历史记录
   */
  async deleteHistory(id: string): Promise<SaveResult> {
    try {
      const store = this.db.getStore();
      const predicates = new relationalStore.RdbPredicates('history_records');
      predicates.equalTo('id', id);
      
      await store.delete(predicates);
      Logger.info(`History deleted: ${id}`);
      
      return { success: true };
    } catch (error) {
      Logger.error('Delete history error', error);
      return { success: false, error: '删除历史失败' };
    }
  }

  /**
   * 批量删除历史记录
   */
  async deleteHistoryBatch(ids: string[]): Promise<SaveResult> {
    try {
      if (ids.length === 0) {
        return { success: true };
      }

      const store = this.db.getStore();
      const predicates = new relationalStore.RdbPredicates('history_records');
      predicates.in('id', ids.map(id => id.toString()));
      
      await store.delete(predicates);
      Logger.info(`Batch deleted ${ids.length} history records`);
      
      return { success: true };
    } catch (error) {
      Logger.error('Batch delete history error', error);
      return { success: false, error: '批量删除历史失败' };
    }
  }

  /**
   * 清空历史记录
   */
  async clearHistory(olderThan?: string): Promise<SaveResult> {
    try {
      const store = this.db.getStore();
      const predicates = new relationalStore.RdbPredicates('history_records');

      if (olderThan) {
        predicates.lessThan('created_at', olderThan);
      }

      await store.delete(predicates);
      Logger.info('History cleared');
      
      return { success: true };
    } catch (error) {
      Logger.error('Clear history error', error);
      return { success: false, error: '清空历史失败' };
    }
  }
}

