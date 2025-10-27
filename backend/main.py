"""
智能计算器 FastAPI 后端服务
提供强大的数学计算功能
增强版：集成 SymPy + SageMath 功能
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict
import sympy as sp
import numpy as np
from scipy import integrate as spi
from scipy.optimize import minimize, bisect, newton, root
from scipy.interpolate import lagrange, CubicSpline
import logging
import json

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 创建 FastAPI 应用
app = FastAPI(
    title="SmartCalc Backend API",
    description="智能计算器后端服务 - 提供高等数学计算功能",
    version="1.0.0"
)

# 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应该限制特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 请求模型
class ExecuteRequest(BaseModel):
    code: str
    timeout: Optional[int] = 30


class IntegrateRequest(BaseModel):
    expression: str
    variable: str = "x"
    lower: float
    upper: float


class DifferentiateRequest(BaseModel):
    expression: str
    variable: str = "x"


class SolveRequest(BaseModel):
    equation: str
    variable: str = "x"


class SimplifyRequest(BaseModel):
    expression: str


class ExpandRequest(BaseModel):
    expression: str


class FactorRequest(BaseModel):
    expression: str


# 响应模型
class ExecuteResponse(BaseModel):
    success: bool
    result: Optional[str] = None
    output: Optional[str] = None
    error: Optional[str] = None
    stdout: Optional[str] = None
    stderr: Optional[str] = None


class IntegrateResponse(BaseModel):
    success: bool
    result: Optional[str] = None
    error_estimate: Optional[str] = None
    error: Optional[str] = None


class DifferentiateResponse(BaseModel):
    success: bool
    result: Optional[str] = None
    latex: Optional[str] = None
    error: Optional[str] = None


class SolveResponse(BaseModel):
    success: bool
    solutions: Optional[List[str]] = None
    error: Optional[str] = None


class SimplifyResponse(BaseModel):
    success: bool
    result: Optional[str] = None
    latex: Optional[str] = None
    error: Optional[str] = None


class ExpandResponse(BaseModel):
    success: bool
    result: Optional[str] = None
    latex: Optional[str] = None
    error: Optional[str] = None


class FactorResponse(BaseModel):
    success: bool
    result: Optional[str] = None
    latex: Optional[str] = None
    error: Optional[str] = None


class PolynomialRequest(BaseModel):
    coefficients: List[float]
    variable: str = "x"


class ComplexOperationRequest(BaseModel):
    real1: float
    imag1: float
    real2: Optional[float] = None
    imag2: Optional[float] = None
    operation: str  # "add", "multiply", "power", "sqrt"


class DifferentialEquationRequest(BaseModel):
    equation_type: str  # "first_order", "second_order_constant"
    parameters: Dict
    initial_condition: Dict
    time_range: List[float]


class OptimizationRequest(BaseModel):
    function_code: str
    initial_guess: List[float]
    method: str = "BFGS"  # "BFGS", "golden_section", "newton"


class InterpolationRequest(BaseModel):
    points: List[Dict[str, float]]
    method: str = "lagrange"  # "lagrange", "cubic_spline"


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str


# 根路径
@app.get("/")
async def root():
    return {
        "message": "SmartCalc Backend API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }


# 健康检查
@app.get("/health", response_model=HealthResponse)
async def health_check():
    return {
        "status": "ok",
        "service": "SmartCalc Backend",
        "version": "1.0.0"
    }


# 执行 SageMath 代码
@app.post("/execute", response_model=ExecuteResponse)
async def execute_code(request: ExecuteRequest):
    """执行任意 SageMath/SymPy 代码"""
    try:
        logger.info(f"Executing code: {request.code}")
        
        # 创建符号环境
        x = sp.Symbol('x')
        y = sp.Symbol('y')
        z = sp.Symbol('z')
        
        # 执行代码
        result = eval(
            request.code,
            {
                'sp': sp,
                'sympy': sp,
                'np': np,
                'x': x,
                'y': y,
                'z': z,
                'sin': sp.sin,
                'cos': sp.cos,
                'tan': sp.tan,
                'sec': sp.sec,
                'csc': sp.csc,
                'cot': sp.cot,
                'asin': sp.asin,
                'acos': sp.acos,
                'atan': sp.atan,
                'sinh': sp.sinh,
                'cosh': sp.cosh,
                'tanh': sp.tanh,
                'exp': sp.exp,
                'log': sp.log,
                'ln': sp.ln,
                'sqrt': sp.sqrt,
                'pi': sp.pi,
                'E': sp.E,
                'I': sp.I,
                'oo': sp.oo,
                'sum': sum,
                'abs': abs,
                'max': max,
                'min': min,
                'floor': np.floor,
                'ceil': np.ceil
            }
        )
        
        return ExecuteResponse(
            success=True,
            result=str(result),
            output=str(result),
            stdout=str(result)
        )
        
    except Exception as e:
        logger.error(f"Execution error: {str(e)}")
        return ExecuteResponse(
            success=False,
            error=str(e),
            stderr=str(e)
        )


# 计算定积分
@app.post("/integrate", response_model=IntegrateResponse)
async def integrate_calc(request: IntegrateRequest):
    """计算定积分"""
    try:
        logger.info(f"Computing integral: ∫ {request.expression} d{request.variable} from {request.lower} to {request.upper}")
        
        # 解析表达式
        expr = sp.sympify(request.expression)
        
        # 数值积分
        f = lambda t: float(expr.subs(request.variable, t).evalf())
        
        result, error_estimate = spi.quad(f, request.lower, request.upper)
        
        return IntegrateResponse(
            success=True,
            result=str(result),
            error_estimate=str(error_estimate)
        )
        
    except Exception as e:
        logger.error(f"Integration error: {str(e)}")
        return IntegrateResponse(
            success=False,
            error=str(e)
        )


# 计算不定积分
@app.post("/integrate_indefinite")
async def integrate_indefinite(request: IntegrateRequest):
    """计算不定积分"""
    try:
        logger.info(f"Computing indefinite integral: ∫ {request.expression} d{request.variable}")
        
        expr = sp.sympify(request.expression)
        result = sp.integrate(expr, request.variable)
        
        return {
            "success": True,
            "result": str(result),
            "latex": sp.latex(result)
        }
        
    except Exception as e:
        logger.error(f"Indefinite integration error: {str(e)}")
        return {
            "success": False,
            "error": str(e)
        }


# 计算导数
@app.post("/differentiate", response_model=DifferentiateResponse)
async def differentiate_calc(request: DifferentiateRequest):
    """计算导数"""
    try:
        logger.info(f"Computing derivative: d/d{request.variable}({request.expression})")
        
        expr = sp.sympify(request.expression)
        result = sp.diff(expr, request.variable)
        
        return DifferentiateResponse(
            success=True,
            result=str(result),
            latex=sp.latex(result)
        )
        
    except Exception as e:
        logger.error(f"Differentiation error: {str(e)}")
        return DifferentiateResponse(
            success=False,
            error=str(e)
        )


# 求解方程
@app.post("/solve", response_model=SolveResponse)
async def solve_equation(request: SolveRequest):
    """求解方程"""
    try:
        logger.info(f"Solving equation: {request.equation} for {request.variable}")
        
        expr = sp.sympify(request.equation)
        solutions = sp.solve(expr, request.variable)
        
        return SolveResponse(
            success=True,
            solutions=[str(sol) for sol in solutions]
        )
        
    except Exception as e:
        logger.error(f"Solving error: {str(e)}")
        return SolveResponse(
            success=False,
            error=str(e)
        )


# 简化表达式
@app.post("/simplify", response_model=SimplifyResponse)
async def simplify_expr(request: SimplifyRequest):
    """简化表达式"""
    try:
        logger.info(f"Simplifying: {request.expression}")
        
        expr = sp.sympify(request.expression)
        result = sp.simplify(expr)
        
        return SimplifyResponse(
            success=True,
            result=str(result),
            latex=sp.latex(result)
        )
        
    except Exception as e:
        logger.error(f"Simplification error: {str(e)}")
        return SimplifyResponse(
            success=False,
            error=str(e)
        )


# 展开表达式
@app.post("/expand", response_model=ExpandResponse)
async def expand_expr(request: ExpandRequest):
    """展开表达式"""
    try:
        logger.info(f"Expanding: {request.expression}")
        
        expr = sp.sympify(request.expression)
        result = sp.expand(expr)
        
        return ExpandResponse(
            success=True,
            result=str(result),
            latex=sp.latex(result)
        )
        
    except Exception as e:
        logger.error(f"Expansion error: {str(e)}")
        return ExpandResponse(
            success=False,
            error=str(e)
        )


# 因式分解
@app.post("/factor", response_model=FactorResponse)
async def factor_expr(request: FactorRequest):
    """因式分解"""
    try:
        logger.info(f"Factoring: {request.expression}")
        
        expr = sp.sympify(request.expression)
        result = sp.factor(expr)
        
        return FactorResponse(
            success=True,
            result=str(result),
            latex=sp.latex(result)
        )
        
    except Exception as e:
        logger.error(f"Factoring error: {str(e)}")
        return FactorResponse(
            success=False,
            error=str(e)
        )


# 计算极限
@app.post("/limit")
async def compute_limit(
    expression: str,
    variable: str = "x",
    approach_value: str = "0",
    direction: Optional[str] = None
):
    """计算极限"""
    try:
        logger.info(f"Computing limit: lim({expression}) as {variable} -> {approach_value}")
        
        expr = sp.sympify(expression)
        approach = sp.S(approach_value) if approach_value != "infinity" else sp.oo
        approach = sp.oo if approach_value == "infinity" else sp.S(approach_value)
        
        if direction == "plus" or direction == "right":
            result = sp.limit(expr, variable, approach, dir="+")
        elif direction == "minus" or direction == "left":
            result = sp.limit(expr, variable, approach, dir="-")
        else:
            result = sp.limit(expr, variable, approach)
        
        return {
            "success": True,
            "result": str(result),
            "latex": sp.latex(result)
        }
        
    except Exception as e:
        logger.error(f"Limit computation error: {str(e)}")
        return {
            "success": False,
            "error": str(e)
        }


# 泰勒展开
@app.post("/taylor")
async def taylor_expansion(
    expression: str,
    variable: str = "x",
    center: float = 0,
    order: int = 5
):
    """泰勒级数展开"""
    try:
        logger.info(f"Computing Taylor expansion of {expression} at {center}, order {order}")
        
        expr = sp.sympify(expression)
        x = sp.Symbol(variable)
        result = sp.series(expr, x, center, order).removeO()
        
        return {
            "success": True,
            "result": str(result),
            "latex": sp.latex(result)
        }
        
    except Exception as e:
        logger.error(f"Taylor expansion error: {str(e)}")
        return {
            "success": False,
            "error": str(e)
        }


# ==================== 新增高级功能 API ====================

# 多项式运算
@app.post("/polynomial/evaluate")
async def evaluate_polynomial(request: PolynomialRequest):
    """计算多项式的值"""
    try:
        logger.info(f"Evaluating polynomial with coefficients: {request.coefficients}")
        
        # 使用 NumPy polyval
        coeffs = np.array(request.coefficients[::-1])  # 需要反转
        
        # 返回多项式的字符串表示和求值函数
        poly_expr = sp.Poly(request.coefficients, sp.Symbol(request.variable)).as_expr()
        
        return {
            "success": True,
            "polynomial": str(poly_expr),
            "latex": sp.latex(poly_expr),
            "degree": len(request.coefficients) - 1
        }
        
    except Exception as e:
        logger.error(f"Polynomial evaluation error: {str(e)}")
        return {"success": False, "error": str(e)}


@app.post("/polynomial/roots")
async def find_polynomial_roots(request: PolynomialRequest):
    """求多项式的根"""
    try:
        logger.info(f"Finding roots of polynomial with coefficients: {request.coefficients}")
        
        # 使用 NumPy 求根
        roots = np.roots(request.coefficients[::-1])
        
        # 转换为 Python 原生数据类型
        roots_list = [{"real": float(r.real), "imag": float(r.imag)} for r in roots]
        
        return {
            "success": True,
            "roots": roots_list,
            "num_roots": len(roots_list)
        }
        
    except Exception as e:
        logger.error(f"Root finding error: {str(e)}")
        return {"success": False, "error": str(e)}


@app.post("/polynomial/derivative")
async def polynomial_derivative(request: PolynomialRequest):
    """计算多项式的导数"""
    try:
        logger.info(f"Computing derivative of polynomial with coefficients: {request.coefficients}")
        
        x = sp.Symbol(request.variable)
        coeffs = request.coefficients
        
        # 构造多项式
        expr = sum(c * x**i for i, c in enumerate(coeffs))
        
        # 求导
        derivative = sp.diff(expr, x)
        
        return {
            "success": True,
            "derivative": str(derivative),
            "latex": sp.latex(derivative)
        }
        
    except Exception as e:
        logger.error(f"Polynomial derivative error: {str(e)}")
        return {"success": False, "error": str(e)}


# 复数运算
@app.post("/complex/operations")
async def complex_operations(request: ComplexOperationRequest):
    """复数运算"""
    try:
        z1 = complex(request.real1, request.imag1)
        
        if request.operation == "add" and request.real2 is not None:
            z2 = complex(request.real2, request.imag2)
            result = z1 + z2
        elif request.operation == "multiply" and request.real2 is not None:
            z2 = complex(request.real2, request.imag2)
            result = z1 * z2
        elif request.operation == "power" and request.real2 is not None:
            # real2 作为幂
            result = z1 ** request.real2
        elif request.operation == "sqrt":
            result = np.sqrt(z1)
        elif request.operation == "magnitude":
            result = abs(z1)
            return {"success": True, "magnitude": float(result)}
        elif request.operation == "argument":
            result = np.angle(z1)
            return {"success": True, "argument": float(result), "argument_degrees": float(np.degrees(result))}
        else:
            return {"success": False, "error": "Invalid operation"}
        
        return {
            "success": True,
            "real": float(result.real),
            "imag": float(result.imag)
        }
        
    except Exception as e:
        logger.error(f"Complex operation error: {str(e)}")
        return {"success": False, "error": str(e)}


# 微分方程求解
@app.post("/ode/solve")
async def solve_ode(request: DifferentialEquationRequest):
    """求解微分方程"""
    try:
        logger.info(f"Solving ODE: {request.equation_type}")
        
        if request.equation_type == "second_order_constant":
            # 二阶常系数齐次方程: y'' + ay' + by = 0
            a = request.parameters.get("a", 0)
            b = request.parameters.get("b", 0)
            y0 = request.initial_condition.get("y0", 1)
            dy0 = request.initial_condition.get("dy0", 0)
            
            # 求解特征方程
            discriminant = a**2 - 4*b
            
            if discriminant > 0:
                r1 = (-a + np.sqrt(discriminant)) / 2
                r2 = (-a - np.sqrt(discriminant)) / 2
                general_form = f"C1*exp({r1:.4f}*x) + C2*exp({r2:.4f}*x)"
            elif discriminant == 0:
                r = -a / 2
                general_form = f"exp({r:.4f}*x) * (C1 + C2*x)"
            else:
                real_part = -a / 2
                imag_part = np.sqrt(-discriminant) / 2
                general_form = f"exp({real_part:.4f}*x) * (C1*cos({imag_part:.4f}*x) + C2*sin({imag_part:.4f}*x))"
            
            return {
                "success": True,
                "equation_type": "second_order_constant_coefficient",
                "general_solution": general_form,
                "discriminant": float(discriminant)
            }
        
        elif request.equation_type == "first_order_numerical":
            # 一阶方程数值解
            # 这里需要定义微分方程的函数形式
            t_start, t_end = request.time_range[0], request.time_range[1]
            
            # 使用 scipy 的数值方法
            from scipy.integrate import odeint
            
            def ode_func(y, t):
                # 示例：dy/dt = -y
                return -y
            
            t = np.linspace(t_start, t_end, 100)
            y0 = request.initial_condition.get("y0", 1)
            solution = odeint(ode_func, y0, t)
            
            return {
                "success": True,
                "equation_type": "first_order_numerical",
                "solution_points": solution.flatten().tolist(),
                "time_points": t.tolist()
            }
        
        return {"success": False, "error": "Unsupported ODE type"}
        
    except Exception as e:
        logger.error(f"ODE solving error: {str(e)}")
        return {"success": False, "error": str(e)}


# 优化算法
@app.post("/optimize")
async def optimize_function(request: OptimizationRequest):
    """优化函数"""
    try:
        logger.info(f"Optimizing function using {request.method}")
        
        # 构造目标函数
        def objective(x):
            # 使用 eval 执行函数代码（在生产环境中应该更安全）
            return eval(request.function_code.replace("x", f"({x[0]})"))
        
        if request.method == "BFGS":
            result = minimize(objective, request.initial_guess, method='BFGS')
        elif request.method == "golden_section":
            # 黄金分割法（仅适用于单变量）
            if len(request.initial_guess) == 1:
                def golden_section(func, a, b, tol=1e-6):
                    phi = (1 + np.sqrt(5)) / 2
                    resphi = 2 - phi
                    x1 = a + resphi * (b - a)
                    x2 = b - resphi * (b - a)
                    
                    while abs(b - a) > tol:
                        if func(x1) < func(x2):
                            b = x2
                            x2 = x1
                            x1 = a + resphi * (b - a)
                        else:
                            a = x1
                            x1 = x2
                            x2 = b - resphi * (b - a)
                    
                    return (a + b) / 2, func((a + b) / 2)
                
                x_opt, y_opt = golden_section(lambda x: objective([x]), request.initial_guess[0] - 5, request.initial_guess[0] + 5)
                result = type('obj', (object,), {'x': [x_opt], 'fun': y_opt, 'success': True})()
            else:
                return {"success": False, "error": "Golden section method only supports single variable"}
        else:
            result = minimize(objective, request.initial_guess, method=request.method)
        
        return {
            "success": result.success if hasattr(result, 'success') else True,
            "optimal_point": result.x.tolist() if hasattr(result, 'x') else [result.x],
            "optimal_value": float(result.fun) if hasattr(result, 'fun') else result,
            "iterations": result.nit if hasattr(result, 'nit') else None
        }
        
    except Exception as e:
        logger.error(f"Optimization error: {str(e)}")
        return {"success": False, "error": str(e)}


# 插值
@app.post("/interpolate")
async def interpolate_points(request: InterpolationRequest):
    """插值"""
    try:
        logger.info(f"Interpolating using {request.method}")
        
        # 提取点
        x_values = [p["x"] for p in request.points]
        y_values = [p["y"] for p in request.points]
        
        if request.method == "lagrange":
            # Lagrange 插值
            poly = lagrange(x_values, y_values)
            
            return {
                "success": True,
                "method": "lagrange",
                "polynomial": str(poly),
                "coeffs": poly.coeffs.tolist()
            }
        
        elif request.method == "cubic_spline":
            # 三次样条插值
            cs = CubicSpline(x_values, y_values)
            
            # 创建评估函数
            def evaluate(x):
                return float(cs(x))
            
            return {
                "success": True,
                "method": "cubic_spline"
            }
        
        return {"success": False, "error": "Unknown interpolation method"}
        
    except Exception as e:
        logger.error(f"Interpolation error: {str(e)}")
        return {"success": False, "error": str(e)}


# 数值求根
@app.post("/root_finding")
async def find_root(
    expression: str,
    method: str = "newton",
    initial_guess: float = 0.0
):
    """数值求根"""
    try:
        logger.info(f"Finding root using {method}")
        
        x = sp.Symbol('x')
        expr = sp.sympify(expression)
        
        # 转换为数值函数
        f = sp.lambdify(x, expr, 'numpy')
        f_prime = sp.lambdify(x, sp.diff(expr, x), 'numpy')
        
        if method == "newton":
            # Newton-Raphson 方法
            root_val = newton(f, initial_guess)
        elif method == "bisection":
            # 二分法（需要区间）
            root_val = bisect(f, -10, 10)
        else:
            root_val = bisect(f, -10, 10)
        
        return {
            "success": True,
            "method": method,
            "root": float(root_val),
            "value_at_root": float(f(root_val))
        }
        
    except Exception as e:
        logger.error(f"Root finding error: {str(e)}")
        return {"success": False, "error": str(e)}


# 统计信息
@app.get("/api/stats")
async def get_api_stats():
    """获取 API 统计信息"""
    return {
        "endpoints": [
            "/execute",
            "/integrate",
            "/differentiate",
            "/solve",
            "/simplify",
            "/expand",
            "/factor",
            "/limit",
            "/taylor",
            "/polynomial/evaluate",
            "/polynomial/roots",
            "/polynomial/derivative",
            "/complex/operations",
            "/ode/solve",
            "/optimize",
            "/interpolate",
            "/root_finding"
        ],
        "version": "2.0.0",
        "features": [
            "Symbolic computation (SymPy)",
            "Numerical integration (SciPy)",
            "Polynomial operations",
            "Complex number operations",
            "Differential equation solving",
            "Optimization",
            "Interpolation",
            "Root finding"
        ]
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8888)

