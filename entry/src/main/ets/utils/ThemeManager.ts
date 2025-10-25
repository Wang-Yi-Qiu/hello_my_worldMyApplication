/**
 * 主题管理器
 * 管理应用主题切换
 */
import { Logger } from './Logger';
import { THEME_COLORS } from './Constants';
import { preferences } from '@kit.ArkData';

export class ThemeManager {
  private static instance: ThemeManager;
  private currentTheme: 'light' | 'dark' = 'light';
  private preferences?: preferences.Preferences;

  private constructor() {
    this.loadTheme();
  }

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 加载保存的主题
   */
  private async loadTheme() {
    try {
      const context = globalThis.abilityContext;
      if (!context) {
        Logger.warn('No ability context available');
        return;
      }
      
      this.preferences = await preferences.getPreferences(context, 'settings');
      const theme = await this.preferences.get('theme', 'light') as string;
      this.currentTheme = theme as 'light' | 'dark';
      
      Logger.info(`Theme loaded: ${this.currentTheme}`);
      
      // 更新全局状态
      AppStorage.setOrCreate('currentTheme', this.currentTheme);
    } catch (error) {
      Logger.error('Failed to load theme', error);
    }
  }

  /**
   * 设置主题
   */
  async setTheme(theme: 'light' | 'dark') {
    try {
      this.currentTheme = theme;
      
      if (this.preferences) {
        await this.preferences.put('theme', theme);
        await this.preferences.flush();
      }
      
      // 更新全局状态
      AppStorage.setOrCreate('currentTheme', theme);
      
      Logger.info(`Theme changed to: ${theme}`);
    } catch (error) {
      Logger.error('Failed to set theme', error);
    }
  }

  /**
   * 获取当前主题
   */
  getCurrentTheme(): 'light' | 'dark' {
    return this.currentTheme;
  }

  /**
   * 获取主题颜色
   */
  getThemeColors() {
    return THEME_COLORS[this.currentTheme];
  }
}

