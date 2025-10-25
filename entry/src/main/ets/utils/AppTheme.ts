/**
 * 应用统一主题配置
 * 定义全局颜色、字体、间距等样式常量
 */

export class AppTheme {
  // 主题色
  static readonly PRIMARY_COLOR = '#1890FF';
  static readonly PRIMARY_COLOR_LIGHT = '#40A9FF';
  static readonly PRIMARY_COLOR_DARK = '#096DD9';
  
  // 背景色
  static readonly BG_COLOR_LIGHT = '#F5F5F5';
  static readonly BG_COLOR_DARK = '#141414';
  static readonly CARD_BG_LIGHT = '#FFFFFF';
  static readonly CARD_BG_DARK = '#1F1F1F';
  
  // 文字颜色
  static readonly TEXT_PRIMARY_LIGHT = '#333333';
  static readonly TEXT_PRIMARY_DARK = '#E8E8E8';
  static readonly TEXT_SECONDARY_LIGHT = '#666666';
  static readonly TEXT_SECONDARY_DARK = '#999999';
  static readonly TEXT_TERTIARY_LIGHT = '#999999';
  static readonly TEXT_TERTIARY_DARK = '#666666';
  static readonly TEXT_DISABLED = '#CCCCCC';
  
  // 边框颜色
  static readonly BORDER_COLOR_LIGHT = '#E8E8E8';
  static readonly BORDER_COLOR_DARK = '#303030';
  static readonly DIVIDER_COLOR_LIGHT = '#F0F0F0';
  static readonly DIVIDER_COLOR_DARK = '#262626';
  
  // 功能色
  static readonly SUCCESS_COLOR = '#52C41A';
  static readonly WARNING_COLOR = '#FAAD14';
  static readonly ERROR_COLOR = '#F5222D';
  static readonly INFO_COLOR = '#1890FF';
  
  // 字体大小
  static readonly FONT_SIZE_LARGE = 24;
  static readonly FONT_SIZE_TITLE = 20;
  static readonly FONT_SIZE_SUBTITLE = 18;
  static readonly FONT_SIZE_NORMAL = 16;
  static readonly FONT_SIZE_MEDIUM = 14;
  static readonly FONT_SIZE_SMALL = 12;
  static readonly FONT_SIZE_MINI = 10;
  
  // 圆角
  static readonly BORDER_RADIUS_LARGE = 16;
  static readonly BORDER_RADIUS_MEDIUM = 12;
  static readonly BORDER_RADIUS_SMALL = 8;
  static readonly BORDER_RADIUS_MINI = 4;
  
  // 间距
  static readonly SPACING_XLARGE = 24;
  static readonly SPACING_LARGE = 20;
  static readonly SPACING_MEDIUM = 16;
  static readonly SPACING_NORMAL = 12;
  static readonly SPACING_SMALL = 8;
  static readonly SPACING_MINI = 4;
  
  // 阴影
  static readonly SHADOW_LIGHT = {
    radius: 8,
    color: 'rgba(0, 0, 0, 0.08)',
    offsetX: 0,
    offsetY: 2
  };
  
  static readonly SHADOW_MEDIUM = {
    radius: 12,
    color: 'rgba(0, 0, 0, 0.12)',
    offsetX: 0,
    offsetY: 4
  };
  
  // 动画时长
  static readonly ANIMATION_DURATION_FAST = 150;
  static readonly ANIMATION_DURATION_NORMAL = 200;
  static readonly ANIMATION_DURATION_SLOW = 300;
  
  // 根据主题获取背景色
  static getBackgroundColor(isDark: boolean): string {
    return isDark ? this.BG_COLOR_DARK : this.BG_COLOR_LIGHT;
  }
  
  // 根据主题获取卡片背景色
  static getCardBackground(isDark: boolean): string {
    return isDark ? this.CARD_BG_DARK : this.CARD_BG_LIGHT;
  }
  
  // 根据主题获取主要文字颜色
  static getPrimaryTextColor(isDark: boolean): string {
    return isDark ? this.TEXT_PRIMARY_DARK : this.TEXT_PRIMARY_LIGHT;
  }
  
  // 根据主题获取次要文字颜色
  static getSecondaryTextColor(isDark: boolean): string {
    return isDark ? this.TEXT_SECONDARY_DARK : this.TEXT_SECONDARY_LIGHT;
  }
  
  // 根据主题获取第三级文字颜色
  static getTertiaryTextColor(isDark: boolean): string {
    return isDark ? this.TEXT_TERTIARY_DARK : this.TEXT_TERTIARY_LIGHT;
  }
  
  // 根据主题获取边框颜色
  static getBorderColor(isDark: boolean): string {
    return isDark ? this.BORDER_COLOR_DARK : this.BORDER_COLOR_LIGHT;
  }
  
  // 根据主题获取分割线颜色
  static getDividerColor(isDark: boolean): string {
    return isDark ? this.DIVIDER_COLOR_DARK : this.DIVIDER_COLOR_LIGHT;
  }
}

