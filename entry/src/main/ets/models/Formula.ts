/**
 * 公式数据模型
 * 定义公式的数据结构
 */

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
}

export class FormulaModel {
  id: number;
  user_id?: string;
  name: string;
  expression: string;
  description?: string;
  category?: string;
  created_at: string;
  updated_at: string;
  sync_state: number;

  constructor(data: Formula) {
    this.id = data.id!;
    this.user_id = data.user_id;
    this.name = data.name;
    this.expression = data.expression;
    this.description = data.description;
    this.category = data.category;
    this.created_at = data.created_at!;
    this.updated_at = data.updated_at!;
    this.sync_state = data.sync_state!;
  }

  static fromDatabase(data: Formula): FormulaModel {
    return new FormulaModel(data);
  }

  toDatabase(): Formula {
    return {
      id: this.id,
      user_id: this.user_id,
      name: this.name,
      expression: this.expression,
      description: this.description,
      category: this.category,
      created_at: this.created_at,
      updated_at: this.updated_at,
      sync_state: this.sync_state
    };
  }
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

export interface SaveResult {
  success: boolean;
  id?: number;
  error?: string;
}
