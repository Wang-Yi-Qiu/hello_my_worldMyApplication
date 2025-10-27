/**
 * 历史记录页面
 * 显示计算历史记录
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { ToastHelper } from '../utils/ToastHelper';
import { DataManager, GetHistoryResult } from '../modules/DataManager';
import { HistoryRecord } from '../models/HistoryRecord';

@Component
export struct HistoryPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @StorageProp('expressionFromHistory') expressionFromHistory: string = '';
  @StorageLink('needRefreshHistory') needRefreshHistory: boolean = false;
  @State historyList: HistoryRecord[] = [];
  @State isLoading: boolean = true;
  @State refreshing: boolean = false;
  @State isEditMode: boolean = false;
  @State selectedIds: Set<string> = new Set();
  private dataManager: DataManager = new DataManager();

  aboutToAppear() {
    Logger.info('HistoryPage loaded');
    this.loadHistory();
  }
  
  aboutToUpdate() {
    // 检测 needRefreshHistory 变化并刷新
    if (this.needRefreshHistory) {
      Logger.info('needRefreshHistory changed to true, refreshing...');
      this.loadHistory();
      // 重置标记
      AppStorage.setOrCreate('needRefreshHistory', false);
    }
  }
  
  onPageShow() {
    // 页面显示时刷新历史记录
    Logger.info('HistoryPage shown, refreshing...');
    this.loadHistory();
  }

  /**
   * 加载历史记录
   */
  async loadHistory() {
    try {
      this.isLoading = true;
      const result: GetHistoryResult = await this.dataManager.getHistory({
        limit: 100
      });

      if (result.success && result.history) {
        this.historyList = result.history;
        Logger.info(`Loaded ${this.historyList.length} history records`);
      }
    } catch (error) {
      Logger.error('Failed to load history', error);
      ToastHelper.showError('加载历史失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除单个历史记录
   */
  async deleteHistory(id: string) {
    try {
      const result = await this.dataManager.deleteHistory(id);
      if (result.success) {
        this.historyList = this.historyList.filter(item => item.id !== id);
        ToastHelper.showSuccess('已删除');
      } else {
        ToastHelper.showError(result.error || '删除失败');
      }
    } catch (error) {
      Logger.error('Failed to delete history', error);
      ToastHelper.showError('删除失败');
    }
  }

  /**
   * 批量删除历史记录
   */
  async deleteSelectedHistory() {
    try {
      const ids = Array.from(this.selectedIds);
      if (ids.length === 0) {
        ToastHelper.showWarning('请先选择要删除的记录');
        return;
      }

      const result = await this.dataManager.deleteHistoryBatch(ids);
      if (result.success) {
        this.historyList = this.historyList.filter(item => !this.selectedIds.has(item.id!));
        this.selectedIds.clear();
        this.isEditMode = false;
        ToastHelper.showSuccess(`已删除 ${ids.length} 条记录`);
      } else {
        ToastHelper.showError(result.error || '批量删除失败');
      }
    } catch (error) {
      Logger.error('Failed to batch delete history', error);
      ToastHelper.showError('批量删除失败');
    }
  }

  /**
   * 清空历史
   */
  async clearHistory() {
    try {
      await this.dataManager.clearHistory();
      this.historyList = [];
      this.selectedIds.clear();
      this.isEditMode = false;
      ToastHelper.showSuccess('历史已清空');
    } catch (error) {
      Logger.error('Failed to clear history', error);
      ToastHelper.showError('清空失败');
    }
  }

  /**
   * 切换编辑模式
   */
  toggleEditMode() {
    this.isEditMode = !this.isEditMode;
    if (!this.isEditMode) {
      this.selectedIds.clear();
    }
  }

  /**
   * 切换选中状态
   */
  toggleSelection(id: string) {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id);
    } else {
      this.selectedIds.add(id);
    }
    // 触发状态更新
    this.selectedIds = new Set(this.selectedIds);
  }

  /**
   * 全选/取消全选
   */
  toggleSelectAll(): void {
    if (this.selectedIds.size === this.historyList.length) {
      this.selectedIds.clear();
    } else {
      this.selectedIds = new Set(this.historyList.map((item: HistoryRecord) => item.id!).filter((id: string) => id !== undefined));
    }
  }

  /**
   * 将历史记录复制到计算器
   */
  copyToCalculator(item: HistoryRecord) {
    try {
      // 设置表达式到AppStorage，触发自动切换
      AppStorage.setOrCreate('expressionFromHistory', item.expression);
      ToastHelper.showSuccess('已复制到计算器');
      Logger.info(`Copied expression to calculator: ${item.expression}`);
    } catch (error) {
      Logger.error('Failed to copy to calculator', error);
      ToastHelper.showError('复制失败');
    }
  }

  build() {
    Column() {
      // 顶部操作栏
      Row() {
        if (this.isEditMode) {
          // 编辑模式
          Checkbox({
            name: 'selectAll',
            group: 'historyGroup'
          })
            .select(this.selectedIds.size === this.historyList.length && this.historyList.length > 0)
            .onChange((value: boolean) => {
              this.toggleSelectAll();
            })
          
          Text(`已选 ${this.selectedIds.size}/${this.historyList.length}`)
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .margin({ left: AppTheme.SPACING_SMALL })
          
          Blank()
          
          Button('取消')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.toggleEditMode();
            })
            .margin({ right: AppTheme.SPACING_NORMAL })
          
          Button('删除')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.ERROR_COLOR)
            .backgroundColor(Color.Transparent)
            .enabled(this.selectedIds.size > 0)
            .onClick(() => {
              this.deleteSelectedHistory();
            })
        } else {
          // 正常模式
          Text(`共 ${this.historyList.length} 条`)
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          
          Blank()
          
          if (this.historyList.length > 0) {
            Button('编辑')
              .fontSize(AppTheme.FONT_SIZE_MEDIUM)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.toggleEditMode();
              })
              .margin({ right: AppTheme.SPACING_NORMAL })
          }
          
          Button('刷新')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.PRIMARY_COLOR)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.loadHistory();
            })
            .margin({ right: AppTheme.SPACING_NORMAL })
          
          Button('清空')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.ERROR_COLOR)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.clearHistory();
            })
        }
      }
      .width('100%')
      .padding(AppTheme.SPACING_MEDIUM)
      .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))

      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(AppTheme.PRIMARY_COLOR)
          
          Text('加载中...')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
            .margin({ top: AppTheme.SPACING_NORMAL })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.historyList.length === 0) {
        // 空状态
        Column() {
          Text('📝')
            .fontSize(60)
            .margin({ bottom: AppTheme.SPACING_LARGE })
          
          Text('暂无历史记录')
            .fontSize(AppTheme.FONT_SIZE_NORMAL)
            .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          
          Text('开始计算后会自动保存')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
            .margin({ top: AppTheme.SPACING_NORMAL })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 历史列表
        List({ space: 0 }) {
          ForEach(this.historyList, (item: HistoryRecord, index: number) => {
            ListItem() {
              this.buildHistoryItem(item, index);
            }
            .swipeAction({
              end: this.buildSwipeDelete(item)
            })
          }, (item: HistoryRecord) => item.id?.toString() || item.timestamp.toString())
        }
        .layoutWeight(1)
        .divider({
          strokeWidth: 1,
          color: AppTheme.getDividerColor(this.currentTheme === 'dark')
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }

  /**
   * 构建历史记录项
   */
  @Builder buildHistoryItem(item: HistoryRecord, index: number) {
    Column() {
      Row() {
        // 编辑模式下显示复选框
        if (this.isEditMode) {
          Checkbox({
            name: `item_${item.id}`,
            group: 'historyGroup'
          })
            .select(this.selectedIds.has(item.id!))
            .onChange((value: boolean) => {
              this.toggleSelection(item.id!);
            })
            .margin({ right: AppTheme.SPACING_NORMAL })
        }
        
        Column() {
          // 表达式
          Text(item.expression)
            .fontSize(AppTheme.FONT_SIZE_NORMAL)
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          // 结果
          Row() {
            Text(`= ${item.result}`)
              .fontSize(AppTheme.FONT_SIZE_TITLE)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.PRIMARY_COLOR)
            
            // 情绪表情
            if (item.emotion && item.emotion.emoji) {
              Text(item.emotion.emoji)
                .fontSize(AppTheme.FONT_SIZE_NORMAL)
                .margin({ left: AppTheme.SPACING_MINI })
            }
          }
          .margin({ top: AppTheme.SPACING_MINI })
          
          // 幸运提示和彩蛋标记
          if (item.fortune || item.isEasterEgg) {
            Row() {
              if (item.fortune) {
                Text(item.fortune)
                  .fontSize(AppTheme.FONT_SIZE_SMALL)
                  .fontColor('#FF9800')
                  .margin({ right: AppTheme.SPACING_MINI })
              }
              if (item.isEasterEgg) {
                Text('🎉')
                  .fontSize(AppTheme.FONT_SIZE_SMALL)
              }
            }
            .margin({ top: AppTheme.SPACING_MINI })
          }
          
          // 时间
          Text(this.formatTime(new Date(item.timestamp).toISOString()))
            .fontSize(AppTheme.FONT_SIZE_SMALL)
            .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
            .margin({ top: AppTheme.SPACING_MINI })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 序号
        Text(`#${this.historyList.length - index}`)
          .fontSize(AppTheme.FONT_SIZE_SMALL)
          .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
          .margin({ left: AppTheme.SPACING_NORMAL })
      }
      .width('100%')
      .padding(AppTheme.SPACING_MEDIUM)
    }
    .width('100%')
    .onClick(() => {
      if (this.isEditMode) {
        // 编辑模式下点击切换选中状态
        this.toggleSelection(item.id!);
      } else {
        // 正常模式下点击复制到计算器
        this.copyToCalculator(item);
      }
    })
  }

  /**
   * 构建滑动删除按钮
   */
  @Builder buildSwipeDelete(item: HistoryRecord) {
    Button('删除')
      .fontSize(AppTheme.FONT_SIZE_MEDIUM)
      .fontColor('#FFFFFF')
      .backgroundColor(AppTheme.ERROR_COLOR)
      .width(80)
      .height('100%')
      .onClick(() => {
        if (item.id !== undefined) {
          this.deleteHistory(item.id);
        }
      })
  }

  /**
   * 格式化时间
   */
  formatTime(isoString: string): string {
    try {
      const date = new Date(isoString);
      const now = new Date();
      const diff = now.getTime() - date.getTime();
      
      // 小于1分钟
      if (diff < 60000) {
        return '刚刚';
      }
      
      // 小于1小时
      if (diff < 3600000) {
        return `${Math.floor(diff / 60000)} 分钟前`;
      }
      
      // 小于1天
      if (diff < 86400000) {
        return `${Math.floor(diff / 3600000)} 小时前`;
      }
      
      // 格式化日期
      return `${date.getMonth() + 1}/${date.getDate()} ${date.getHours()}:${String(date.getMinutes()).padStart(2, '0')}`;
    } catch (error) {
      return isoString;
    }
  }
}

