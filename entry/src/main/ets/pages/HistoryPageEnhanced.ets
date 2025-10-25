/**
 * 增强版历史记录页面
 * 支持分类、收藏、筛选功能
 */
import { Logger } from '../utils/Logger';
import { DataManager, GetHistoryResult } from '../modules/DataManager';
import { HistoryRecordModel } from '../models/HistoryRecord';
import { promptAction } from '@kit.ArkUI';

// 筛选类型
enum FilterType {
  ALL = '全部',
  FAVORITE = '收藏',
  BASIC = '基础运算',
  SCIENTIFIC = '科学计算',
  DERIVATIVE = '求导',
  INTEGRAL = '积分',
  LIMIT = '极限',
  EQUATION = '方程'
}

@Component
export struct HistoryPage {
  @State historyList: HistoryRecordModel[] = [];
  @State filteredList: HistoryRecordModel[] = [];
  @State isLoading: boolean = true;
  @State refreshing: boolean = false;
  @State isEditMode: boolean = false;
  @State selectedIds: Set<number> = new Set();
  @State currentFilter: FilterType = FilterType.ALL;
  @State showFilterMenu: boolean = false;
  private dataManager: DataManager = new DataManager();

  aboutToAppear() {
    Logger.info('HistoryPage loaded');
    this.loadHistory();
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
        this.applyFilter();
        Logger.info(`Loaded ${this.historyList.length} history records`);
      }
    } catch (error) {
      Logger.error('Failed to load history', error);
      promptAction.showToast({
        message: '加载历史失败'
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 应用筛选
   */
  applyFilter() {
    switch (this.currentFilter) {
      case FilterType.ALL:
        this.filteredList = [...this.historyList];
        break;
      case FilterType.FAVORITE:
        this.filteredList = this.historyList.filter(item => item.isFavorite);
        break;
      case FilterType.BASIC:
        this.filteredList = this.historyList.filter(item => item.category === 'basic');
        break;
      case FilterType.SCIENTIFIC:
        this.filteredList = this.historyList.filter(item => item.category === 'scientific');
        break;
      case FilterType.DERIVATIVE:
        this.filteredList = this.historyList.filter(item => item.category === 'derivative');
        break;
      case FilterType.INTEGRAL:
        this.filteredList = this.historyList.filter(item => item.category === 'integral');
        break;
      case FilterType.LIMIT:
        this.filteredList = this.historyList.filter(item => item.category === 'limit');
        break;
      case FilterType.EQUATION:
        this.filteredList = this.historyList.filter(item => item.category === 'equation');
        break;
    }
  }

  /**
   * 切换收藏状态
   */
  async toggleFavorite(item: HistoryRecordModel) {
    try {
      item.isFavorite = !item.isFavorite;
      
      // 更新数据库
      await this.dataManager.updateHistory(item.id!, item.toDatabase());
      
      promptAction.showToast({
        message: item.isFavorite ? '已添加到收藏' : '已取消收藏'
      });
      
      // 刷新列表
      this.applyFilter();
    } catch (error) {
      Logger.error('Failed to toggle favorite', error);
      promptAction.showToast({
        message: '操作失败'
      });
    }
  }

  /**
   * 删除单个历史记录
   */
  async deleteHistory(id: number) {
    try {
      const result = await this.dataManager.deleteHistory(id);
      if (result.success) {
        this.historyList = this.historyList.filter(item => item.id !== id);
        this.applyFilter();
        promptAction.showToast({
          message: '已删除'
        });
      } else {
        promptAction.showToast({
          message: result.error || '删除失败'
        });
      }
    } catch (error) {
      Logger.error('Failed to delete history', error);
      promptAction.showToast({
        message: '删除失败'
      });
    }
  }

  /**
   * 批量删除历史记录
   */
  async deleteSelectedHistory() {
    try {
      const ids = Array.from(this.selectedIds);
      if (ids.length === 0) {
        promptAction.showToast({
          message: '请先选择要删除的记录'
        });
        return;
      }

      const result = await this.dataManager.deleteHistoryBatch(ids);
      if (result.success) {
        this.historyList = this.historyList.filter(item => !this.selectedIds.has(item.id!));
        this.applyFilter();
        this.selectedIds.clear();
        this.isEditMode = false;
        promptAction.showToast({
          message: `已删除 ${ids.length} 条记录`
        });
      } else {
        promptAction.showToast({
          message: result.error || '批量删除失败'
        });
      }
    } catch (error) {
      Logger.error('Failed to batch delete history', error);
      promptAction.showToast({
        message: '批量删除失败'
      });
    }
  }

  /**
   * 清空历史
   */
  async clearHistory() {
    try {
      await this.dataManager.clearHistory();
      this.historyList = [];
      this.filteredList = [];
      this.selectedIds.clear();
      this.isEditMode = false;
      promptAction.showToast({
        message: '历史已清空'
      });
    } catch (error) {
      Logger.error('Failed to clear history', error);
      promptAction.showToast({
        message: '清空失败'
      });
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
  toggleSelection(id: number) {
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
  toggleSelectAll() {
    if (this.selectedIds.size === this.filteredList.length) {
      this.selectedIds.clear();
    } else {
      this.selectedIds = new Set(this.filteredList.map(item => item.id!).filter(id => id !== undefined));
    }
  }

  /**
   * 获取分类统计
   */
  getCategoryCount(category: string): number {
    if (category === 'all') {
      return this.historyList.length;
    }
    if (category === 'favorite') {
      return this.historyList.filter(item => item.isFavorite).length;
    }
    return this.historyList.filter(item => item.category === category).length;
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
            .select(this.selectedIds.size === this.filteredList.length && this.filteredList.length > 0)
            .onChange((value: boolean) => {
              this.toggleSelectAll();
            })
          
          Text(`已选 ${this.selectedIds.size}/${this.filteredList.length}`)
            .fontSize(14)
            .fontColor('#333')
            .margin({ left: 8 })
          
          Blank()
          
          Button('取消')
            .fontSize(14)
            .fontColor('#666')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.toggleEditMode();
            })
            .margin({ right: 10 })
          
          Button('删除')
            .fontSize(14)
            .fontColor('#ff4d4f')
            .backgroundColor(Color.Transparent)
            .enabled(this.selectedIds.size > 0)
            .onClick(() => {
              this.deleteSelectedHistory();
            })
        } else {
          // 正常模式
          Text(`${this.currentFilter} (${this.filteredList.length})`)
            .fontSize(14)
            .fontColor('#666')
          
          Blank()
          
          // 筛选按钮
          Button() {
            Row() {
              Text('筛选')
                .fontSize(14)
                .fontColor('#1890ff')
              Text(' ▼')
                .fontSize(12)
                .fontColor('#1890ff')
            }
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showFilterMenu = !this.showFilterMenu;
          })
          .margin({ right: 10 })
          
          if (this.filteredList.length > 0) {
            Button('编辑')
              .fontSize(14)
              .fontColor('#1890ff')
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.toggleEditMode();
              })
              .margin({ right: 10 })
          }
          
          Button('刷新')
            .fontSize(14)
            .fontColor('#1890ff')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.loadHistory();
            })
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')

      // 筛选菜单
      if (this.showFilterMenu) {
        Column() {
          this.buildFilterMenuItem(FilterType.ALL, '📋', this.getCategoryCount('all'))
          this.buildFilterMenuItem(FilterType.FAVORITE, '⭐', this.getCategoryCount('favorite'))
          Divider().margin({ top: 8, bottom: 8 })
          this.buildFilterMenuItem(FilterType.BASIC, '🔢', this.getCategoryCount('basic'))
          this.buildFilterMenuItem(FilterType.SCIENTIFIC, '🔬', this.getCategoryCount('scientific'))
          this.buildFilterMenuItem(FilterType.DERIVATIVE, '∂', this.getCategoryCount('derivative'))
          this.buildFilterMenuItem(FilterType.INTEGRAL, '∫', this.getCategoryCount('integral'))
          this.buildFilterMenuItem(FilterType.LIMIT, 'lim', this.getCategoryCount('limit'))
          this.buildFilterMenuItem(FilterType.EQUATION, '=', this.getCategoryCount('equation'))
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F9F9F9')
        .border({ width: { bottom: 1 }, color: '#E8E8E8' })
      }

      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1890ff')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredList.length === 0) {
        // 空状态
        Column() {
          Text(this.currentFilter === FilterType.FAVORITE ? '⭐' : '📝')
            .fontSize(60)
            .margin({ bottom: 20 })
          
          Text(this.currentFilter === FilterType.FAVORITE ? '暂无收藏记录' : '暂无历史记录')
            .fontSize(16)
            .fontColor('#999')
          
          Text(this.currentFilter === FilterType.FAVORITE ? '点击星标收藏喜欢的计算' : '开始计算后会自动保存')
            .fontSize(14)
            .fontColor('#ccc')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 历史列表
        List({ space: 0 }) {
          ForEach(this.filteredList, (item: HistoryRecordModel, index: number) => {
            ListItem() {
              this.buildHistoryItem(item, index);
            }
            .swipeAction({
              end: this.buildSwipeActions(item)
            })
          }, (item: HistoryRecordModel) => item.id?.toString() || item.createdAt)
        }
        .layoutWeight(1)
        .divider({
          strokeWidth: 1,
          color: '#f0f0f0'
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  /**
   * 构建筛选菜单项
   */
  @Builder buildFilterMenuItem(filter: FilterType, icon: string, count: number) {
    Row() {
      Text(icon)
        .fontSize(18)
        .width(32)
      
      Text(filter)
        .fontSize(15)
        .fontColor('#333')
        .layoutWeight(1)
      
      Text(`${count}`)
        .fontSize(13)
        .fontColor('#999')
      
      if (this.currentFilter === filter) {
        Text(' ✓')
          .fontSize(16)
          .fontColor('#1890ff')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 12, right: 12 })
    .borderRadius(8)
    .backgroundColor(this.currentFilter === filter ? '#E6F7FF' : 'transparent')
    .onClick(() => {
      this.currentFilter = filter;
      this.applyFilter();
      this.showFilterMenu = false;
      promptAction.showToast({
        message: `已切换到：${filter}`
      });
    })
  }

  /**
   * 构建历史记录项
   */
  @Builder buildHistoryItem(item: HistoryRecordModel, index: number) {
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
            .margin({ right: 12 })
        }
        
        // 分类图标
        Text(item.getCategoryIcon())
          .fontSize(20)
          .width(32)
          .margin({ right: 8 })
        
        Column() {
          // 分类标签
          Row() {
            Text(item.getCategoryName())
              .fontSize(11)
              .fontColor('#1890ff')
              .backgroundColor('#E6F7FF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(4)
            
            if (item.isFavorite) {
              Text('⭐')
                .fontSize(12)
                .margin({ left: 6 })
            }
          }
          .margin({ bottom: 6 })
          
          // 表达式
          Text(item.expression)
            .fontSize(15)
            .fontColor('#333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          // 结果
          Text(`= ${item.result}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890ff')
            .margin({ top: 5 })
          
          // 时间
          Text(this.formatTime(item.createdAt))
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 收藏按钮
        if (!this.isEditMode) {
          Button() {
            Text(item.isFavorite ? '⭐' : '☆')
              .fontSize(24)
              .fontColor(item.isFavorite ? '#FFD700' : '#CCCCCC')
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.toggleFavorite(item);
          })
        }
        
        // 序号
        Text(`#${this.historyList.length - this.historyList.indexOf(item)}`)
          .fontSize(12)
          .fontColor('#ccc')
          .margin({ left: 10 })
      }
      .width('100%')
      .padding(15)
    }
    .width('100%')
    .onClick(() => {
      if (this.isEditMode) {
        // 编辑模式下点击切换选中状态
        this.toggleSelection(item.id!);
      } else {
        // 正常模式下点击复制
        Logger.info(`History item clicked: ${item.expression}`);
        promptAction.showToast({
          message: '已复制表达式'
        });
        // TODO: 实现复制到剪贴板功能
      }
    })
  }

  /**
   * 构建滑动操作按钮
   */
  @Builder buildSwipeActions(item: HistoryRecordModel) {
    Row() {
      // 收藏/取消收藏
      Button(item.isFavorite ? '取消收藏' : '收藏')
        .fontSize(14)
        .fontColor('#fff')
        .backgroundColor(item.isFavorite ? '#FF9F0A' : '#FFD700')
        .width(80)
        .height('100%')
        .onClick(() => {
          this.toggleFavorite(item);
        })
      
      // 删除
      Button('删除')
        .fontSize(14)
        .fontColor('#fff')
        .backgroundColor('#ff4d4f')
        .width(80)
        .height('100%')
        .onClick(() => {
          if (item.id !== undefined) {
            this.deleteHistory(item.id);
          }
        })
    }
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

