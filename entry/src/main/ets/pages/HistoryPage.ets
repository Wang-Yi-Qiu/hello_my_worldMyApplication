/**
 * 历史记录页面
 * 显示计算历史记录
 */
import { Logger } from '../utils/Logger';
import { DataManager, GetHistoryResult } from '../modules/DataManager';
import { HistoryRecordModel } from '../models/HistoryRecord';
import promptAction from '@ohos.promptAction';

@Component
export struct HistoryPage {
  @State historyList: HistoryRecordModel[] = [];
  @State isLoading: boolean = true;
  private dataManager: DataManager = new DataManager();

  aboutToAppear() {
    Logger.info('HistoryPage loaded');
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
      promptAction.showToast({
        message: '加载历史失败'
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 清空历史
   */
  async clearHistory() {
    try {
      await this.dataManager.clearHistory();
      this.historyList = [];
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

  build() {
    Column() {
      // 顶部操作栏
      Row() {
        Text(`共 ${this.historyList.length} 条`)
          .fontSize(14)
          .fontColor('#666')
        
        Blank()
        
        Button('清空')
          .fontSize(14)
          .fontColor('#ff4d4f')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.clearHistory();
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')

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
      } else if (this.historyList.length === 0) {
        // 空状态
        Column() {
          Text('📝')
            .fontSize(60)
            .margin({ bottom: 20 })
          
          Text('暂无历史记录')
            .fontSize(16)
            .fontColor('#999')
          
          Text('开始计算后会自动保存')
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
          ForEach(this.historyList, (item: HistoryRecordModel, index: number) => {
            ListItem() {
              this.buildHistoryItem(item, index);
            }
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
   * 构建历史记录项
   */
  @Builder buildHistoryItem(item: HistoryRecordModel, index: number) {
    Column() {
      Row() {
        Column() {
          // 表达式
          Text(item.expression)
            .fontSize(16)
            .fontColor('#333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          // 结果
          Text(`= ${item.result}`)
            .fontSize(20)
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
        
        // 序号
        Text(`#${this.historyList.length - index}`)
          .fontSize(12)
          .fontColor('#ccc')
          .margin({ left: 10 })
      }
      .width('100%')
      .padding(15)
    }
    .width('100%')
    .onClick(() => {
      Logger.info(`History item clicked: ${item.expression}`);
      promptAction.showToast({
        message: '已复制到剪贴板'
      });
      // TODO: 复制到剪贴板功能
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

