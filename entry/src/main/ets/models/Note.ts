/**
 * 数学笔记数据模型
 */
export interface Note {
  id: string;
  title: string;
  content: string;
  expressions: NoteExpression[];  // 笔记中的数学表达式
  created_at: number;
  updated_at: number;
}

/**
 * 笔记中的数学表达式
 */
export interface NoteExpression {
  id: string;
  expression: string;
  result: string;
  timestamp: number;
}

/**
 * 笔记管理器
 */
export class NoteManager {
  private static readonly STORAGE_KEY = 'math_notes';
  
  /**
   * 获取所有笔记
   */
  static async getAllNotes(): Promise<Note[]> {
    try {
      const data = AppStorage.get<string>(this.STORAGE_KEY);
      if (data) {
        return JSON.parse(data as string);
      }
      return [];
    } catch (error) {
      console.error('Failed to load notes:', error);
      return [];
    }
  }
  
  /**
   * 保存笔记
   */
  static async saveNote(note: Note): Promise<boolean> {
    try {
      const notes = await this.getAllNotes();
      const index = notes.findIndex(n => n.id === note.id);
      
      if (index >= 0) {
        notes[index] = note;
      } else {
        notes.unshift(note);  // 新笔记添加到最前面
      }
      
      AppStorage.setOrCreate(this.STORAGE_KEY, JSON.stringify(notes));
      return true;
    } catch (error) {
      console.error('Failed to save note:', error);
      return false;
    }
  }
  
  /**
   * 删除笔记
   */
  static async deleteNote(noteId: string): Promise<boolean> {
    try {
      const notes = await this.getAllNotes();
      const filteredNotes = notes.filter(n => n.id !== noteId);
      AppStorage.setOrCreate(this.STORAGE_KEY, JSON.stringify(filteredNotes));
      return true;
    } catch (error) {
      console.error('Failed to delete note:', error);
      return false;
    }
  }
  
  /**
   * 创建新笔记
   */
  static createNote(title: string = '新笔记'): Note {
    const now = Date.now();
    return {
      id: `note_${now}`,
      title: title,
      content: '',
      expressions: [],
      created_at: now,
      updated_at: now
    };
  }
  
  /**
   * 添加表达式到笔记
   */
  static addExpression(note: Note, expression: string, result: string): Note {
    const newExpression: NoteExpression = {
      id: `expr_${Date.now()}`,
      expression,
      result,
      timestamp: Date.now()
    };
    
    note.expressions.push(newExpression);
    note.updated_at = Date.now();
    
    return note;
  }
  
  /**
   * 删除笔记中的表达式
   */
  static removeExpression(note: Note, expressionId: string): Note {
    note.expressions = note.expressions.filter(e => e.id !== expressionId);
    note.updated_at = Date.now();
    return note;
  }
}

