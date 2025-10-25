/**
 * LaTeX 公式渲染组件
 * 使用美化的文本显示数学公式（不依赖 Web 组件）
 */
import { Logger } from '../utils/Logger';

@Component
export struct LaTeXRenderer {
  @Prop latex: string;
  
  build() {
    Column() {
      Text(this.convertLatexToReadable(this.latex))
        .fontSize(16)
        .fontColor('#333333')
        .lineHeight(28)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#F8F8F8')
    .borderRadius(8)
    .padding(12)
  }
  
  /**
   * 将 LaTeX 转换为可读的文本格式
   */
  private convertLatexToReadable(latex: string): string {
    let readable = latex;
    
    // 移除 LaTeX 命令符号
    readable = readable.replace(/\\\[/g, '');
    readable = readable.replace(/\\\]/g, '');
    readable = readable.replace(/\\\(/g, '');
    readable = readable.replace(/\\\)/g, '');
    
    // 转换极限符号
    readable = readable.replace(/\\lim_\{([^}]+)\s*\\to\s*([^}]+)\}/g, 'lim($1→$2)');
    
    // 转换积分符号
    readable = readable.replace(/\\int_\{([^}]+)\}\^\{([^}]+)\}/g, '∫[$1,$2]');
    readable = readable.replace(/\\int/g, '∫');
    
    // 转换分数
    readable = readable.replace(/\\frac\{([^}]+)\}\{([^}]+)\}/g, '($1)/($2)');
    
    // 转换上下标
    readable = readable.replace(/\^\{([^}]+)\}/g, '^$1');
    readable = readable.replace(/_\{([^}]+)\}/g, '_$1');
    
    // 转换数学函数
    readable = readable.replace(/\\sin/g, 'sin');
    readable = readable.replace(/\\cos/g, 'cos');
    readable = readable.replace(/\\tan/g, 'tan');
    readable = readable.replace(/\\log/g, 'log');
    readable = readable.replace(/\\ln/g, 'ln');
    readable = readable.replace(/\\exp/g, 'exp');
    readable = readable.replace(/\\sqrt/g, '√');
    
    // 转换希腊字母
    readable = readable.replace(/\\pi/g, 'π');
    readable = readable.replace(/\\alpha/g, 'α');
    readable = readable.replace(/\\beta/g, 'β');
    readable = readable.replace(/\\gamma/g, 'γ');
    readable = readable.replace(/\\delta/g, 'δ');
    readable = readable.replace(/\\theta/g, 'θ');
    
    // 转换空格命令
    readable = readable.replace(/\\,/g, ' ');
    readable = readable.replace(/\\;/g, ' ');
    readable = readable.replace(/\\quad/g, '  ');
    
    // 转换等号和关系符号
    readable = readable.replace(/\\approx/g, '≈');
    readable = readable.replace(/\\neq/g, '≠');
    readable = readable.replace(/\\leq/g, '≤');
    readable = readable.replace(/\\geq/g, '≥');
    
    // 移除剩余的反斜杠
    readable = readable.replace(/\\/g, '');
    
    // 美化幂次
    readable = readable.replace(/\^2/g, '²');
    readable = readable.replace(/\^3/g, '³');
    
    return readable;
  }
}

