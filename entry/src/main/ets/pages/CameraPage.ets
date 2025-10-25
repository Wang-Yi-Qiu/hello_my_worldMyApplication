/**
 * 相机拍照页面
 * 实现相机预览和拍照功能
 */
import { Logger } from '../utils/Logger';
import { ToastHelper } from '../utils/ToastHelper';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

@Entry
@Component
struct CameraPage {
  private xComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  private cameraManager?: camera.CameraManager;
  private cameraDevice?: camera.CameraDevice;
  private cameraInput?: camera.CameraInput;
  private previewOutput?: camera.PreviewOutput;
  private photoOutput?: camera.PhotoOutput;
  private cameraSession?: camera.PhotoSession;
  private context?: common.UIAbilityContext;
  
  @State isInitialized: boolean = false;
  @State isTakingPhoto: boolean = false;
  @State errorMessage: string = '';
  @State isReturning: boolean = false;

  async aboutToAppear() {
    Logger.info('CameraPage loaded');
    try {
      // 初始化 context
      this.context = getContext(this) as common.UIAbilityContext;
      // 请求相机权限
      const hasPermission = await this.requestCameraPermission();
      if (!hasPermission) {
        Logger.warn('Camera permission not granted');
      }
    } catch (error) {
      Logger.error('Error in aboutToAppear', error);
    }
  }

  aboutToDisappear() {
    Logger.info('CameraPage aboutToDisappear');
    // 异步释放，不阻塞页面销毁
    this.releaseCamera().catch((err: BusinessError) => {
      Logger.error('Error releasing camera in aboutToDisappear', err);
    });
  }

  /**
   * 处理返回键
   */
  onBackPress(): boolean {
    Logger.info('CameraPage onBackPress');
    // 异步释放相机资源
    this.releaseCamera().catch((err: BusinessError) => {
      Logger.error('Error releasing camera in onBackPress', err);
    });
    // 返回 false 允许默认返回行为
    return false;
  }

  build() {
    Stack() {
      // 相机预览区域
      XComponent({
        id: 'camera_preview',
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .onLoad(() => {
          try {
            this.surfaceId = this.xComponentController.getXComponentSurfaceId();
            Logger.info(`XComponent loaded, surfaceId: ${this.surfaceId}`);
            // 异步初始化相机，不阻塞 UI
            this.initCamera().catch((err: BusinessError) => {
              Logger.error('Failed to init camera in onLoad', err);
            });
          } catch (error) {
            Logger.error('Error in XComponent onLoad', error);
          }
        })
        .width('100%')
        .height('100%')

      // 顶部控制栏
      Column() {
        Row() {
          // 返回按钮
          Button() {
            Text('✕')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(48)
          .height(48)
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .borderRadius(24)
          .onClick(() => {
            if (this.isReturning) {
              Logger.info('Already returning, ignoring click');
              return;
            }
            
            this.isReturning = true;
            Logger.info('Back button clicked');
            
            // 尝试返回
            try {
              router.back();
            } catch (error) {
              Logger.error('Error during router.back()', error);
            }
          })

          Blank()

          // 闪光灯按钮（占位）
          Button() {
            Text('⚡')
              .fontSize(20)
              .fontColor('#FFFFFF')
          }
          .width(48)
          .height(48)
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .borderRadius(24)
          .onClick(() => {
            ToastHelper.show('闪光灯功能开发中');
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 底部拍照按钮
      Column() {
        if (this.errorMessage) {
          Column() {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#FF4D4F')
              .textAlign(TextAlign.Center)
              .padding(16)
              .backgroundColor('rgba(255, 255, 255, 0.9)')
              .borderRadius(8)
              .margin({ bottom: 20 })
          }
        }

        // 拍照按钮
        Button() {
          if (this.isTakingPhoto) {
            LoadingProgress()
              .width(32)
              .height(32)
              .color('#FFFFFF')
          } else {
            Column() {
              // 外圈
              Column()
                .width(70)
                .height(70)
                .backgroundColor('#FFFFFF')
                .borderRadius(35)
                .border({ width: 4, color: 'rgba(255, 255, 255, 0.5)' })
            }
            .width(80)
            .height(80)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width(80)
        .height(80)
        .backgroundColor('transparent')
        .enabled(this.isInitialized && !this.isTakingPhoto)
        .onClick(() => {
          this.takePhoto();
        })

        Text('点击拍照')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .margin({ top: 12 })
      }
      .width('100%')
      .padding({ bottom: 40 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .alignContent(Alignment.TopStart)
  }

  /**
   * 请求相机权限
   */
  async requestCameraPermission(): Promise<boolean> {
    try {
      if (!this.context) {
        Logger.error('Context is not initialized');
        return false;
      }
      
      const atManager = abilityAccessCtrl.createAtManager();
      const permissions: Array<Permissions> = ['ohos.permission.CAMERA'];
      
      const grantStatus = await atManager.checkAccessToken(
        this.context.applicationInfo.accessTokenId,
        permissions[0]
      );
      
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        Logger.info('Camera permission already granted');
        return true;
      }
      
      // 请求权限
      const result = await atManager.requestPermissionsFromUser(
        this.context,
        permissions
      );
      
      if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        Logger.info('Camera permission granted');
        return true;
      } else {
        Logger.error('Camera permission denied');
        this.errorMessage = '相机权限被拒绝，无法使用相机';
        ToastHelper.showError('需要相机权限才能拍照');
        return false;
      }
    } catch (error) {
      Logger.error('Failed to request camera permission', error);
      this.errorMessage = '权限请求失败';
      return false;
    }
  }

  /**
   * 初始化相机
   */
  async initCamera() {
    try {
      Logger.info('Initializing camera...');

      if (!this.context) {
        throw new Error('Context is not initialized');
      }

      // 获取相机管理器
      this.cameraManager = camera.getCameraManager(this.context);
      if (!this.cameraManager) {
        throw new Error('Failed to get camera manager');
      }

      // 获取相机设备列表
      const cameras = this.cameraManager.getSupportedCameras();
      if (!cameras || cameras.length === 0) {
        throw new Error('No camera device found');
      }

      // 选择后置摄像头（如果有的话）
      this.cameraDevice = cameras.find(cam => cam.cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) || cameras[0];
      Logger.info(`Selected camera: ${this.cameraDevice.cameraId}`);

      // 创建相机输入
      this.cameraInput = this.cameraManager.createCameraInput(this.cameraDevice);
      await this.cameraInput.open();

      // 获取支持的输出能力（使用新 API）
      const cameraOutputCapability = this.cameraManager.getSupportedOutputCapability(
        this.cameraDevice,
        camera.SceneMode.NORMAL_PHOTO
      );
      
      // 创建预览输出
      const previewProfile = cameraOutputCapability.previewProfiles[0];
      this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, this.surfaceId);

      // 创建拍照输出
      const photoProfile = cameraOutputCapability.photoProfiles[0];
      this.photoOutput = this.cameraManager.createPhotoOutput(photoProfile);

      // 创建会话（使用新 API）
      this.cameraSession = this.cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      this.cameraSession.beginConfig();

      // 添加输入和输出
      this.cameraSession.addInput(this.cameraInput);
      this.cameraSession.addOutput(this.previewOutput);
      this.cameraSession.addOutput(this.photoOutput);

      // 提交配置并启动会话
      await this.cameraSession.commitConfig();
      await this.cameraSession.start();

      this.isInitialized = true;
      Logger.info('Camera initialized successfully');

    } catch (error) {
      const err = error as BusinessError;
      Logger.error('Failed to initialize camera', err);
      this.errorMessage = `相机初始化失败: ${err.message}`;
      
      ToastHelper.showError('相机初始化失败，请检查权限设置');
    }
  }

  /**
   * 拍照
   */
  async takePhoto() {
    if (!this.photoOutput || !this.isInitialized) {
      ToastHelper.showWarning('相机未就绪');
      return;
    }

    try {
      this.isTakingPhoto = true;
      Logger.info('Taking photo...');

      // 设置拍照回调
      this.photoOutput.on('photoAvailable', async (errCode: BusinessError, photo: camera.Photo) => {
        if (errCode || !photo) {
          Logger.error('Photo capture failed', errCode);
          this.isTakingPhoto = false;
          ToastHelper.showError('拍照失败');
          return;
        }

        try {
          Logger.info('Photo captured, processing...');

          // 获取图片组件
          const imageObj = photo.main;
          const width = imageObj.size.width;
          const height = imageObj.size.height;
          
          // 使用旧的 API，传入单独的参数
          const imageReceiver = image.createImageReceiver(width, height, image.ImageFormat.JPEG, 1);

          // 读取图片数据
          const imageBuffer = await imageReceiver.readNextImage();
          const imageComponent = await imageBuffer.getComponent(image.ComponentType.JPEG);
          
          if (!imageComponent || !imageComponent.byteBuffer) {
            throw new Error('Failed to get image data');
          }

          if (!this.context) {
            throw new Error('Context is not initialized');
          }

          // 保存图片到临时文件
          const cacheDir = this.context.cacheDir;
          const fileName = `photo_${Date.now()}.jpg`;
          const filePath = `${cacheDir}/${fileName}`;

          const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          fs.writeSync(file.fd, imageComponent.byteBuffer);
          fs.closeSync(file);

          Logger.info(`Photo saved to: ${filePath}`);

          // 释放资源
          await imageBuffer.release();
          await imageReceiver.release();

          // 返回到 OCR 页面并传递图片路径
          router.replaceUrl({
            url: 'pages/ImageOCRPage',
            params: {
              imageUri: `file://${filePath}`,
              fromCamera: true
            }
          }).catch((err: BusinessError) => {
            Logger.error('Failed to navigate back to ImageOCRPage', err);
          });

          ToastHelper.showSuccess('拍照成功');

        } catch (err) {
          Logger.error('Failed to process photo', err);
          this.isTakingPhoto = false;
          ToastHelper.showError('图片处理失败');
        }
      });

      // 触发拍照
      const photoSettings: camera.PhotoCaptureSetting = {
        quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
        rotation: camera.ImageRotation.ROTATION_0
      };
      await this.photoOutput.capture(photoSettings);

    } catch (error) {
      Logger.error('Failed to take photo', error);
      this.isTakingPhoto = false;
      ToastHelper.showError('拍照失败');
    }
  }

  /**
   * 释放相机资源
   */
  async releaseCamera() {
    try {
      Logger.info('Releasing camera resources...');

      // 使用 Promise.race 添加超时保护
      const releasePromise = this.doReleaseCamera();
      const timeoutPromise = new Promise<void>((_resolve: (value: void) => void, reject: (reason: Error) => void) => {
        setTimeout(() => reject(new Error('Release timeout')), 2000);
      });

      try {
        await Promise.race<void>([releasePromise, timeoutPromise]);
        Logger.info('Camera resources released successfully');
      } catch (timeoutError) {
        Logger.error('Camera release timeout, forcing release', timeoutError);
        // 超时也继续，不阻塞返回
      }
    } catch (error) {
      Logger.error('Failed to release camera', error);
      // 即使失败也不阻塞
    }
  }

  /**
   * 实际释放相机资源的方法
   */
  private async doReleaseCamera() {
    try {
      if (this.cameraSession) {
        try {
          await this.cameraSession.stop();
        } catch (e) {
          Logger.error('Failed to stop session', e);
        }
        try {
          await this.cameraSession.release();
        } catch (e) {
          Logger.error('Failed to release session', e);
        }
        this.cameraSession = undefined;
      }

      if (this.photoOutput) {
        try {
          await this.photoOutput.release();
        } catch (e) {
          Logger.error('Failed to release photoOutput', e);
        }
        this.photoOutput = undefined;
      }

      if (this.previewOutput) {
        try {
          await this.previewOutput.release();
        } catch (e) {
          Logger.error('Failed to release previewOutput', e);
        }
        this.previewOutput = undefined;
      }

      if (this.cameraInput) {
        try {
          await this.cameraInput.close();
        } catch (e) {
          Logger.error('Failed to close cameraInput', e);
        }
        this.cameraInput = undefined;
      }
    } catch (error) {
      Logger.error('Error in doReleaseCamera', error);
    }
  }
}

