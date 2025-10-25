/**
 * 图像识别页面
 * 支持拍照和相册导入识别数学公式
 */
import { Logger } from '../utils/Logger';
import { ToastHelper } from '../utils/ToastHelper';
import { OCRService, OCRResult } from '../services/OCRService';
import { LaTeXRenderer } from '../components/LaTeXRenderer';
import { camera } from '@kit.CameraKit';
import { picker } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct ImageOCRPage {
  @State hasImage: boolean = false;
  @State recognizedLatex: string = '';
  @State isProcessing: boolean = false;
  @State imageUri: string = '';
  @State showResult: boolean = false;
  @StorageLink('calculatorInput') calculatorInput: string = '';
  
  private ocrService: OCRService = OCRService.getInstance();

  aboutToAppear() {
    Logger.info('ImageOCRPage loaded');
    
    // 检查是否从相机页面返回
    const params = router.getParams() as Record<string, Object> | null;
    if (params && params['fromCamera']) {
      const imageUri = params['imageUri'] as string;
      if (imageUri) {
        Logger.info(`Received image from camera: ${imageUri}`);
        this.imageUri = imageUri;
        this.hasImage = true;
        this.showResult = true;
        this.isProcessing = true;
        
        // 延迟执行 OCR 识别
        setTimeout(async () => {
          await this.performOCR(imageUri);
        }, 100);
      }
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        // 返回按钮
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        
        Text('图像识别')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 右侧菜单按钮（占位）
        Text('⋯')
          .fontSize(24)
          .fontColor('#333333')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)

      Scroll() {
        Column() {
          // 主要提示区域
          Column() {
            // 相机图标
            Text('📷')
              .fontSize(80)
              .margin({ bottom: 24 })

            Text('Upload an image or take a photo to')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 })

            Text('recognize formulas')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 16 })

            Text('Get instant results from your camera or gallery.')
              .fontSize(14)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 60, bottom: 40, left: 20, right: 20 })
          .backgroundColor('#F5F7FA')
          .borderRadius(16)
          .margin({ top: 20, left: 16, right: 16 })

          // 操作按钮
          Row() {
            Button() {
              Row() {
                Text('📷')
                  .fontSize(20)
                  .margin({ right: 8 })
                Text('拍照识别')
                  .fontSize(16)
                  .fontColor('#1890FF')
              }
            }
            .width('48%')
            .height(50)
            .backgroundColor('#E6F4FF')
            .borderRadius(12)
            .onClick(() => {
              this.takePhoto();
            })

            Button() {
              Row() {
                Text('🖼️')
                  .fontSize(20)
                  .margin({ right: 8 })
                Text('从相册导入')
                  .fontSize(16)
                  .fontColor('#1890FF')
              }
            }
            .width('48%')
            .height(50)
            .backgroundColor('#E6F4FF')
            .borderRadius(12)
            .onClick(() => {
              this.selectFromAlbum();
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 20 })
          .justifyContent(FlexAlign.SpaceBetween)

          // 示例图片区域（如果有图片）
          if (this.hasImage && this.imageUri) {
            Column() {
              Image(this.imageUri)
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Contain)
                .borderRadius(12)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 20 })
          }

          // 识别结果区域
          if (this.showResult) {
            Column() {
              // 识别结果标题
              Row() {
                Text('识别结果:')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .width('100%')
              .margin({ bottom: 16 })
              .justifyContent(FlexAlign.Start)

              // 显示识别的公式
              if (this.isProcessing) {
                Column() {
                  LoadingProgress()
                    .width(40)
                    .height(40)
                    .margin({ bottom: 12 })
                  Text('正在识别中...')
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(100)
                .backgroundColor('#F5F5F5')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
              } else if (this.recognizedLatex) {
                Column() {
                  // 使用 LaTeX 渲染器显示公式
                  LaTeXRenderer({ latex: this.recognizedLatex })
                  
                  // 显示原始 LaTeX 代码（可选）
                  Text(this.recognizedLatex)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 12 })
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#F5F5F5')
                .borderRadius(12)
              } else {
                Column() {
                  Text('识别失败，请重试')
                    .fontSize(14)
                    .fontColor('#FF4D4F')
                }
                .width('100%')
                .height(80)
                .backgroundColor('#FFF1F0')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
              }

              // 一键导入计算器按钮
              if (this.recognizedLatex) {
                Button('一键导入计算器')
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .backgroundColor('#1890FF')
                  .fontColor('#FFFFFF')
                  .borderRadius(24)
                  .margin({ top: 16 })
                  .onClick(() => {
                    this.importToCalculator();
                  })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 24 })
          }

          // 底部占位
          Column()
            .height(100)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  /**
   * 拍照
   */
  async takePhoto() {
    try {
      Logger.info('Opening camera...');
      
      // 跳转到相机页面
      router.pushUrl({
        url: 'pages/CameraPage'
      }).catch((err: BusinessError) => {
        Logger.error('Failed to navigate to CameraPage', err);
        ToastHelper.showError('打开相机失败');
      });
      
    } catch (error) {
      Logger.error('Failed to open camera', error);
      ToastHelper.showError('打开相机失败');
    }
  }

  /**
   * 执行 OCR 识别
   */
  async performOCR(imageUri: string) {
    try {
      this.isProcessing = true;
      
      // 调用 OCR 服务识别
      const result = await this.ocrService.recognizeFormula(imageUri);
      
      this.isProcessing = false;
      
      if (result.success) {
        this.recognizedLatex = result.latex;
        ToastHelper.showSuccess('识别成功！');
        Logger.info(`OCR result: ${result.latex}`);
      } else {
        this.recognizedLatex = '';
        ToastHelper.showError(result.error || '识别失败');
      }
    } catch (error) {
      Logger.error('OCR recognition failed', error);
      this.isProcessing = false;
      this.recognizedLatex = '';
      ToastHelper.showError('识别失败');
    }
  }

  /**
   * 从相册选择
   */
  async selectFromAlbum() {
    try {
      Logger.info('Selecting from album...');
      
      // 创建图片选择器
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      
      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      
      try {
        const photoSelectResult = await photoViewPicker.select(photoSelectOptions);
        
        if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
          const selectedUri = photoSelectResult.photoUris[0];
          Logger.info(`Selected image: ${selectedUri}`);
          
          // 设置图片 URI
          this.imageUri = selectedUri;
          this.hasImage = true;
          this.showResult = true;
          
          // 执行 OCR 识别
          await this.performOCR(selectedUri);
        } else {
          Logger.info('No image selected');
        }
      } catch (err) {
        Logger.error('Photo selection cancelled or failed', err);
        ToastHelper.showWarning('未选择图片');
      }
      
    } catch (error) {
      Logger.error('Failed to select from album', error);
      ToastHelper.showError('选择图片失败');
    }
  }

  /**
   * 导入到计算器
   */
  importToCalculator() {
    if (this.recognizedLatex) {
      try {
        // 将 LaTeX 公式设置到计算器输入
        this.calculatorInput = this.recognizedLatex;
        
        // 显示成功提示
        ToastHelper.showSuccess('已导入到计算器');
        
        // 跳转到计算器页面
        router.back();
        
        Logger.info(`Imported to calculator: ${this.recognizedLatex}`);
      } catch (error) {
        Logger.error('Failed to import to calculator', error);
        ToastHelper.showError('导入失败');
      }
    }
  }

  /**
   * 重置
   */
  resetUpload() {
    this.hasImage = false;
    this.recognizedLatex = '';
    this.isProcessing = false;
    this.imageUri = '';
    this.showResult = false;
  }
}


