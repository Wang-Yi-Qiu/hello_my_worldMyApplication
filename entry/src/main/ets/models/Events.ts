/**
 * 统一的事件对象定义，兼容 @Component (V1) 装饰器限制。
 */
export interface TextEmitEvent {
  emit: (text: string) => void
}

export interface VoidEmitEvent {
  emit: () => void
}

export class TextEmit implements TextEmitEvent {
  private handler?: (text: string) => void

  constructor(handler?: (text: string) => void) {
    this.handler = handler
  }

  emit(text: string): void {
    if (this.handler) {
      this.handler(text)
    }
  }
}

export class VoidEmit implements VoidEmitEvent {
  private handler?: () => void

  constructor(handler?: () => void) {
    this.handler = handler
  }

  emit(): void {
    if (this.handler) {
      this.handler()
    }
  }
}


