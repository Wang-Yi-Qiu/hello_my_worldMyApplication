/**
 * 三角函数精度测试
 * 验证高精度三角函数的计算准确性
 */
import { describe, it, expect } from '@ohos/hypium';
import { ExpressionEngine } from '../modules/ExpressionEngine';

export default function trigonometryTest() {
  describe('Trigonometry Precision Test', () => {
    
    it('测试sin函数 - 30度应等于0.5', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(30)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(0.5, 0.0000001);
      console.log(`sin(30°) = ${value}, 期望值: 0.5`);
    });

    it('测试sin函数 - 90度应等于1.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(90)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(1.0, 0.0000001);
      console.log(`sin(90°) = ${value}, 期望值: 1.0`);
    });

    it('测试sin函数 - 0度应等于0.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(0)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(Math.abs(value)).assertLessOrEqual(0.0000001);
      console.log(`sin(0°) = ${value}, 期望值: 0.0`);
    });

    it('测试sin函数 - 180度应等于0.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(180)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      // 应该精确返回 0.0，而不是接近0的小数
      expect(value).assertEqual(0.0);
      console.log(`sin(180°) = ${value}, 期望值: 0.0`);
    });

    it('测试cos函数 - 60度应等于0.5', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('cos(60)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(0.5, 0.0000001);
      console.log(`cos(60°) = ${value}, 期望值: 0.5`);
    });

    it('测试cos函数 - 90度应等于0.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('cos(90)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      // 应该精确返回 0.0
      expect(value).assertEqual(0.0);
      console.log(`cos(90°) = ${value}, 期望值: 0.0`);
    });

    it('测试cos函数 - 0度应等于1.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('cos(0)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(1.0, 0.0000001);
      console.log(`cos(0°) = ${value}, 期望值: 1.0`);
    });

    it('测试tan函数 - 45度应等于1.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('tan(45)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(1.0, 0.0000001);
      console.log(`tan(45°) = ${value}, 期望值: 1.0`);
    });

    it('测试弧度模式 - sin(π/2)应等于1.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('radian');
      
      const result = await engine.evaluate('sin(1.57079632679)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(1.0, 0.0000001);
      console.log(`sin(π/2) = ${value}, 期望值: 1.0`);
    });

    it('测试弧度模式 - cos(π)应等于-1.0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('radian');
      
      const result = await engine.evaluate('cos(3.14159265359)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(-1.0, 0.0000001);
      console.log(`cos(π) = ${value}, 期望值: -1.0`);
    });

    it('测试asin函数 - 0.5应返回30度', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('asin(0.5)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(30.0, 0.1);
      console.log(`asin(0.5) = ${value}°, 期望值: 30°`);
    });

    it('测试acos函数 - 0应返回90度', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('acos(0)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(90.0, 0.1);
      console.log(`acos(0) = ${value}°, 期望值: 90°`);
    });

    it('测试atan函数 - 1应返回45度', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('atan(1)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(45.0, 0.1);
      console.log(`atan(1) = ${value}°, 期望值: 45°`);
    });

    it('测试三角函数精度 - sin²(30°) + cos²(30°)应等于1', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(30)^2 + cos(30)^2');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(1.0, 0.0000001);
      console.log(`sin²(30°) + cos²(30°) = ${value}, 期望值: 1.0`);
    });

    it('测试小角度精度 - sin(1°)', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(1)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      const expected = 0.017452406437;
      expect(value).assertCloseTo(expected, 0.00000001);
      console.log(`sin(1°) = ${value}, 期望值: ${expected}`);
    });

    it('测试大角度精度 - sin(360°)应等于0', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(360)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(Math.abs(value)).assertLessOrEqual(0.0000001);
      console.log(`sin(360°) = ${value}, 期望值: 0.0`);
    });

    it('测试tan函数极限情况 - tan(90°)应接近正无穷', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('tan(90)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      // tan(90°) 在数学上等于正无穷，但在实际计算中会有很大的值
      expect(Math.abs(value)).assertGreaterOrEqual(100);
      console.log(`tan(90°) = ${value}`);
    });

    it('测试复合三角函数表达式', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('sin(30) + cos(60) + tan(45)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      const expected = 1.5; // 0.5 + 0.5 + 1.0
      expect(value).assertCloseTo(expected, 0.0000001);
      console.log(`sin(30°) + cos(60°) + tan(45°) = ${value}, 期望值: ${expected}`);
    });

    it('测试弧度制 - sin(π/6)应等于0.5', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('radian');
      
      const result = await engine.evaluate('sin(0.52359877559)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(0.5, 0.0000001);
      console.log(`sin(π/6) = ${value}, 期望值: 0.5`);
    });

    it('测试弧度制 - cos(π/3)应等于0.5', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('radian');
      
      const result = await engine.evaluate('cos(1.0471975512)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(0.5, 0.0000001);
      console.log(`cos(π/3) = ${value}, 期望值: 0.5`);
    });

    it('测试角度单位切换 - 在弧度模式下计算度数值', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('radian');
      
      const result = await engine.evaluate('sin(0.5236)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      expect(value).assertCloseTo(0.5, 0.0001);
      console.log(`sin(0.5236弧度) ≈ sin(30°) = ${value}`);
    });

    it('测试反三角函数 - asin(invalid range)', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const result = await engine.evaluate('asin(1.5)');
      // asin的参数应该被限制在 [-1, 1] 范围内
      expect(result.success).assertFalse();
      console.log(`asin(1.5) 应返回错误: ${result.error}`);
    });

    it('测试高精度计算 - sin(π/4)精度验证', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('radian');
      
      const result = await engine.evaluate('sin(0.7853981633974483)');
      expect(result.success).assertTrue();
      
      const value = parseFloat(result.result!);
      const expected = 0.7071067811865476; // √2/2
      expect(value).assertCloseTo(expected, 0.00000001);
      console.log(`sin(π/4) = ${value}, 期望值: ${expected}, 误差: ${Math.abs(value - expected)}`);
    });

    it('测试性能 - 连续计算多个三角函数', 0, async () => {
      const engine = new ExpressionEngine();
      engine.setAngleUnit('degree');
      
      const startTime = Date.now();
      
      for (let i = 0; i < 100; i++) {
        await engine.evaluate('sin(30) + cos(60)');
      }
      
      const endTime = Date.now();
      const duration = endTime - startTime;
      console.log(`连续计算100次耗时: ${duration}ms`);
      
      // 性能应该合理（不应该超过1秒）
      expect(duration).assertLess(1000);
    });
  });
}

