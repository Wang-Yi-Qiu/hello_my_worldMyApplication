# 废弃 API 迁移指南

## 概述
本文档提供了将项目中所有废弃 API 迁移到新版本 API 的详细指南。

## API 迁移对照表

### 1. 路由相关 API

#### router.pushUrl (废弃)
```typescript
// ❌ 旧写法
router.pushUrl({ url: 'pages/SomePage' });

// ✅ 新写法
router.pushUrl({ url: 'pages/SomePage' }, router.RouterMode.Standard);
```

#### router.back (废弃)
```typescript
// ❌ 旧写法
router.back();

// ✅ 新写法
router.back();  // 实际上这个 API 仍然可用，警告可能是误报
```

#### router.getParams (废弃)
```typescript
// ❌ 旧写法
const params = router.getParams();

// ✅ 新写法
import { router } from '@kit.ArkUI';
const params = router.getParams() as Record<string, Object>;
```

### 2. 提示相关 API

#### promptAction.showToast (废弃)
```typescript
// ❌ 旧写法
promptAction.showToast({ message: '提示信息' });

// ✅ 新写法 - 需要添加异常处理
try {
  promptAction.showToast({ message: '提示信息' });
} catch (error) {
  console.error('Toast error:', error);
}
```

### 3. 上下文相关 API

#### getContext (废弃)
```typescript
// ❌ 旧写法
const context = getContext(this) as common.UIAbilityContext;

// ✅ 新写法
import { common } from '@kit.AbilityKit';
const context = getContext(this) as common.UIAbilityContext;
// 实际上这个写法仍然正确，警告可能需要更新 API 版本
```

### 4. 相机相关 API

#### camera.getSupportedOutputCapability (废弃)
```typescript
// ❌ 旧写法
const capability = cameraManager.getSupportedOutputCapability(cameraDevice);

// ✅ 新写法
const capability = cameraManager.getSupportedOutputCapability(cameraDevice, 
  camera.SceneMode.NORMAL_PHOTO);
```

#### camera.createCaptureSession (废弃)
```typescript
// ❌ 旧写法
const session = cameraManager.createCaptureSession();

// ✅ 新写法
const session = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
```

#### 相机会话配置 API (废弃)
```typescript
// ❌ 旧写法
session.beginConfig();
session.addInput(input);
session.addOutput(output);
session.commitConfig();
session.start();

// ✅ 新写法
session.beginConfig();
session.addInput(input);
session.addOutput(output);
await session.commitConfig();
await session.start();
```

### 5. 图像相关 API

#### image.createImageReceiver (已修复)
```typescript
// ❌ 旧写法
const options: image.ImageReceiverOptions = { ... };
const receiver = image.createImageReceiver(options);

// ✅ 新写法
const receiver = image.createImageReceiver(width, height, format, capacity);
```

## 异常处理要求

所有可能抛出异常的函数调用都需要添加 try-catch 块：

```typescript
// ❌ 不推荐
promptAction.showToast({ message: '提示' });

// ✅ 推荐
try {
  promptAction.showToast({ message: '提示' });
} catch (error) {
  console.error('Toast failed:', error);
}
```

## 批量修复策略

### 阶段 1: 修复路由 API
- [ ] Index.ets
- [ ] MainPage.ets
- [ ] ImageOCRPage.ets

### 阶段 2: 修复提示 API（添加异常处理）
- [ ] CalculatorPage.ets
- [ ] HistoryPage.ets
- [ ] AdvancedMathPage.ets
- [ ] GraphPage.ets
- [ ] ImageOCRPage.ets
- [ ] SettingsPage.ets
- [ ] CameraPage.ets

### 阶段 3: 修复相机 API
- [ ] CameraPage.ets

### 阶段 4: 修复其他警告
- [ ] ImageOCRPage.ets (@Entry 导出警告)

## 注意事项

1. **向后兼容性**: 某些 API 虽然标记为废弃，但仍然可用。建议优先修复影响编译的错误。

2. **异常处理**: 新版本 API 更严格要求异常处理，所有可能失败的操作都应该包裹在 try-catch 中。

3. **测试**: 每次修改后都应该进行充分测试，确保功能正常。

4. **渐进式迁移**: 可以分批次迁移，不必一次性修复所有警告。

## 工具函数封装

为了简化代码，可以创建工具函数：

```typescript
// utils/ToastHelper.ts
export class ToastHelper {
  static show(message: string): void {
    try {
      promptAction.showToast({ message });
    } catch (error) {
      console.error('Toast error:', error);
    }
  }
}

// 使用
ToastHelper.show('提示信息');
```

## 参考资料

- [HarmonyOS API 参考文档](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V3/apis-0000001281201122-V3)
- [ArkTS 语法规范](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-get-started-0000001504769321-V3)

