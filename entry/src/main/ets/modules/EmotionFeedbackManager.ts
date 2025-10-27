/**
 * 情绪反馈管理器
 * 负责管理情绪反馈规则和生成反馈
 */
import { Logger } from '../utils/Logger';
import { EmotionFeedback, EmotionRule } from '../models/HistoryRecord';

export class EmotionFeedbackManager {
  private static instance: EmotionFeedbackManager;
  private emotionRules: EmotionRule[] = [];
  
  private constructor() {
    this.initializeDefaultRules();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): EmotionFeedbackManager {
    if (!EmotionFeedbackManager.instance) {
      EmotionFeedbackManager.instance = new EmotionFeedbackManager();
    }
    return EmotionFeedbackManager.instance;
  }

  /**
   * 初始化默认规则
   */
  private initializeDefaultRules(): void {
    // 零蛋反馈
    this.addEmotionRule({
      condition: (result: number) => result === 0,
      feedback: {
        id: 'zero',
        condition: 'result === 0',
        text: '零蛋！',
        emoji: '🥚',
        priority: 1,
        isEnabled: true
      }
    });

    // 负数反馈
    this.addEmotionRule({
      condition: (result: number) => result < 0,
      feedback: {
        id: 'negative',
        condition: 'result < 0',
        text: '负数哦～',
        emoji: '😞',
        priority: 2,
        isEnabled: true
      }
    });

    // 很大的数
    this.addEmotionRule({
      condition: (result: number) => result > 1000000,
      feedback: {
        id: 'huge',
        condition: 'result > 1000000',
        text: '天文数字！',
        emoji: '🌌',
        priority: 3,
        isEnabled: true
      }
    });

    // 很大的数（中等）
    this.addEmotionRule({
      condition: (result: number) => result > 1000 && result <= 1000000,
      feedback: {
        id: 'big',
        condition: 'result > 1000',
        text: '好大的数字！',
        emoji: '😱',
        priority: 4,
        isEnabled: true
      }
    });

    // 小于1的数
    this.addEmotionRule({
      condition: (result: number) => result > 0 && result < 1,
      feedback: {
        id: 'tiny',
        condition: 'result < 1',
        text: '很小呢～',
        emoji: '🔬',
        priority: 5,
        isEnabled: true
      }
    });

    // 圆周率
    this.addEmotionRule({
      condition: (result: number) => Math.abs(result - Math.PI) < 0.0001,
      feedback: {
        id: 'pi',
        condition: 'result === π',
        text: 'π！',
        emoji: '🥧',
        priority: 6,
        isEnabled: true
      }
    });

    // 自然常数e
    this.addEmotionRule({
      condition: (result: number) => Math.abs(result - Math.E) < 0.0001,
      feedback: {
        id: 'euler',
        condition: 'result === e',
        text: 'e！',
        emoji: '📐',
        priority: 7,
        isEnabled: true
      }
    });

    // 整数
    this.addEmotionRule({
      condition: (result: number) => Number.isInteger(result),
      feedback: {
        id: 'integer',
        condition: 'isInteger',
        text: '整数！',
        emoji: '✨',
        priority: 10,
        isEnabled: false  // 默认不启用
      }
    });

    // 平方数
    this.addEmotionRule({
      condition: (result: number) => {
        const sqrt = Math.sqrt(result);
        return Number.isInteger(sqrt) && result > 0;
      },
      feedback: {
        id: 'perfect_square',
        condition: 'isPerfectSquare',
        text: '完全平方数！',
        emoji: '🔲',
        priority: 8,
        isEnabled: true
      }
    });

    // 质数（小质数）
    this.addEmotionRule({
      condition: (result: number) => {
        const num = Math.abs(Math.round(result));
        return num > 1 && num < 100 && this.isPrime(num);
      },
      feedback: {
        id: 'prime',
        condition: 'isPrime',
        text: '质数！',
        emoji: '🔢',
        priority: 9,
        isEnabled: true
      }
    });

    Logger.info(`Initialized ${this.emotionRules.length} emotion rules`);
  }

  /**
   * 添加情绪规则
   */
  public addEmotionRule(rule: EmotionRule): void {
    this.emotionRules.push(rule);
    // 按优先级排序
    this.emotionRules.sort((a, b) => a.feedback.priority - b.feedback.priority);
  }

  /**
   * 移除情绪规则
   */
  public removeEmotionRule(id: string): void {
    this.emotionRules = this.emotionRules.filter(rule => rule.feedback.id !== id);
  }

  /**
   * 生成情绪反馈
   */
  public generateFeedback(result: number): EmotionFeedback | null {
    // 遍历所有启用的规则，找到第一个匹配的
    for (const rule of this.emotionRules) {
      if (rule.feedback.isEnabled && rule.condition(result)) {
        Logger.debug(`Emotion feedback matched: ${rule.feedback.id}`);
        return rule.feedback;
      }
    }
    return null;
  }

  /**
   * 获取所有规则
   */
  public getRules(): EmotionRule[] {
    return [...this.emotionRules];
  }

  /**
   * 更新规则
   */
  public updateRule(id: string, rule: Partial<EmotionRule>): void {
    const index = this.emotionRules.findIndex(r => r.feedback.id === id);
    if (index !== -1) {
      if (rule.feedback) {
        this.emotionRules[index].feedback = { ...this.emotionRules[index].feedback, ...rule.feedback };
      }
      if (rule.condition) {
        this.emotionRules[index].condition = rule.condition;
      }
      // 重新排序
      this.emotionRules.sort((a, b) => a.feedback.priority - b.feedback.priority);
    }
  }

  /**
   * 启用/禁用规则
   */
  public toggleRule(id: string, enabled: boolean): void {
    const rule = this.emotionRules.find(r => r.feedback.id === id);
    if (rule) {
      rule.feedback.isEnabled = enabled;
    }
  }

  /**
   * 判断是否为质数
   */
  private isPrime(n: number): boolean {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 === 0 || n % 3 === 0) return false;
    
    let i = 5;
    while (i * i <= n) {
      if (n % i === 0 || n % (i + 2) === 0) return false;
      i += 6;
    }
    return true;
  }

  /**
   * 从配置中加载自定义规则
   */
  public loadCustomRules(configs: any[]): void {
    // TODO: 从配置加载自定义规则
    Logger.info('Loading custom emotion rules...');
  }

  /**
   * 保存自定义规则
   */
  public saveCustomRules(): any[] {
    // TODO: 保存自定义规则
    return [];
  }
}

