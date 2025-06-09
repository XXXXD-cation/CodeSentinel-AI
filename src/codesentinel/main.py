"""
CodeSentinel-AI 主应用入口

本文件用于启动 FastAPI 服务。
"""

from fastapi import FastAPI

app = FastAPI(
    title="CodeSentinel-AI 源码安全扫描系统",
    description="AI驱动的自动化源码安全审计平台",
    version="0.1.0",
)




@app.get("/")
def root() -> dict[str, str]:
    """健康检查接口"""
    return {"message": "CodeSentinel-AI 服务已启动"}
