import preferences from '@ohos.data.preferences';
import { HistoryRecord, AppSettings, UserPreferences, ConvertConfig, EmotionFeedback, EasterEggConfig, ThemeType, ConvertType, WidgetSize } from '../models/HistoryRecord';

/**
 * Preferences数据存储管理器
 * 负责应用数据的持久化存储
 */
export class PreferencesManager {
  private static instance: PreferencesManager;
  private context: Context;
  private preferences: preferences.Preferences | null = null;

  private constructor(context: Context) {
    this.context = context;
  }

  /**
   * 获取单例实例
   */
  public static getInstance(context: Context): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager(context);
    }
    return PreferencesManager.instance;
  }

  /**
   * 初始化Preferences
   */
  public async initialize(): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(this.context, 'calculator_data');
    } catch (error) {
      console.error('Failed to initialize preferences:', error);
      throw error;
    }
  }

  /**
   * 保存历史记录
   */
  public async saveHistoryRecords(records: HistoryRecord[]): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const recordsJson = JSON.stringify(records);
      await this.preferences.put('history_records', recordsJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save history records:', error);
      throw error;
    }
  }

  /**
   * 获取历史记录
   */
  public async getHistoryRecords(): Promise<HistoryRecord[]> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const recordsJson = await this.preferences.get('history_records', '[]') as string;
      return JSON.parse(recordsJson);
    } catch (error) {
      console.error('Failed to get history records:', error);
      return [];
    }
  }

  /**
   * 保存应用设置
   */
  public async saveAppSettings(settings: AppSettings): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const settingsJson = JSON.stringify(settings);
      await this.preferences.put('app_settings', settingsJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save app settings:', error);
      throw error;
    }
  }

  /**
   * 获取应用设置
   */
  public async getAppSettings(): Promise<AppSettings> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const settingsJson = await this.preferences.get('app_settings', '{}') as string;
      const settings = JSON.parse(settingsJson);
      
      // 返回默认设置如果为空
      if (Object.keys(settings).length === 0) {
        return this.getDefaultAppSettings();
      }
      
      return settings;
    } catch (error) {
      console.error('Failed to get app settings:', error);
      return this.getDefaultAppSettings();
    }
  }

  /**
   * 保存用户偏好
   */
  public async saveUserPreferences(preferences: UserPreferences): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const preferencesJson = JSON.stringify(preferences);
      await this.preferences.put('user_preferences', preferencesJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save user preferences:', error);
      throw error;
    }
  }

  /**
   * 获取用户偏好
   */
  public async getUserPreferences(): Promise<UserPreferences> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const preferencesJson = await this.preferences.get('user_preferences', '{}') as string;
      const userPreferences = JSON.parse(preferencesJson);
      
      // 返回默认偏好如果为空
      if (Object.keys(userPreferences).length === 0) {
        return this.getDefaultUserPreferences();
      }
      
      return userPreferences;
    } catch (error) {
      console.error('Failed to get user preferences:', error);
      return this.getDefaultUserPreferences();
    }
  }

  /**
   * 保存转换配置
   */
  public async saveConvertConfigs(configs: ConvertConfig[]): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const configsJson = JSON.stringify(configs);
      await this.preferences.put('convert_configs', configsJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save convert configs:', error);
      throw error;
    }
  }

  /**
   * 获取转换配置
   */
  public async getConvertConfigs(): Promise<ConvertConfig[]> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const configsJson = await this.preferences.get('convert_configs', '[]') as string;
      return JSON.parse(configsJson);
    } catch (error) {
      console.error('Failed to get convert configs:', error);
      return [];
    }
  }

  /**
   * 保存情绪反馈配置
   */
  public async saveEmotionFeedbacks(feedbacks: EmotionFeedback[]): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const feedbacksJson = JSON.stringify(feedbacks);
      await this.preferences.put('emotion_feedbacks', feedbacksJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save emotion feedbacks:', error);
      throw error;
    }
  }

  /**
   * 获取情绪反馈配置
   */
  public async getEmotionFeedbacks(): Promise<EmotionFeedback[]> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const feedbacksJson = await this.preferences.get('emotion_feedbacks', '[]') as string;
      return JSON.parse(feedbacksJson);
    } catch (error) {
      console.error('Failed to get emotion feedbacks:', error);
      return [];
    }
  }

  /**
   * 保存彩蛋配置
   */
  public async saveEasterEggConfigs(configs: EasterEggConfig[]): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const configsJson = JSON.stringify(configs);
      await this.preferences.put('easter_egg_configs', configsJson);
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to save easter egg configs:', error);
      throw error;
    }
  }

  /**
   * 获取彩蛋配置
   */
  public async getEasterEggConfigs(): Promise<EasterEggConfig[]> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      const configsJson = await this.preferences.get('easter_egg_configs', '[]') as string;
      return JSON.parse(configsJson);
    } catch (error) {
      console.error('Failed to get easter egg configs:', error);
      return [];
    }
  }

  /**
   * 清空所有数据
   */
  public async clearAllData(): Promise<void> {
    if (!this.preferences) {
      throw new Error('Preferences not initialized');
    }

    try {
      await this.preferences.clear();
      await this.preferences.flush();
    } catch (error) {
      console.error('Failed to clear all data:', error);
      throw error;
    }
  }

  /**
   * 获取默认应用设置
   */
  private getDefaultAppSettings(): AppSettings {
    return {
      theme: ThemeType.AUTO,
      language: 'zh-CN',
      precision: 2,
      historyLimit: 10,
      enableEmotion: true,
      enableFortune: true,
      enableEasterEgg: true,
      enableAnimation: true,
      defaultConvertType: ConvertType.CURRENCY
    };
  }

  /**
   * 获取默认用户偏好
   */
  private getDefaultUserPreferences(): UserPreferences {
    return {
      favoriteConvertPairs: [],
      recentExpressions: [],
      customEmotionRules: [],
      widgetConfig: {
        size: WidgetSize.MEDIUM,
        position: { x: 0, y: 0 },
        showResult: true,
        showAnimation: true
      }
    };
  }
}
