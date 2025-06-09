# tests/unit/test_main.py

from codesentinel.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_health_check():
    """
    测试健康检查接口 (/)
    """
    response = client.get("/")
    # 断言HTTP状态码为200 (OK)
    assert response.status_code == 200
    # 断言返回的JSON内容符合预期
    assert response.json() == {"message": "CodeSentinel-AI 服务已启动"}
