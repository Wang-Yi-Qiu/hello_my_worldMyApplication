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

  constructor(data: HistoryRecord) {
    this.id = data.id;
    this.userId = data.user_id;
    this.expression = data.expression;
    this.result = data.result;
    this.calcType = data.calc_type || CalcType.BASIC;
    this.createdAt = data.created_at || new Date().toISOString();
    this.syncState = data.sync_state !== undefined ? data.sync_state : SyncState.UNSYNCED;
    this.cloudId = data.cloud_id;
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
      cloud_id: this.cloudId
    };
  }

  static fromDatabase(data: HistoryRecord): HistoryRecordModel {
    return new HistoryRecordModel(data);
  }
}

