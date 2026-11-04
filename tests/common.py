"""联调测试共享客户端。

重要：本后端**始终返回 HTTP 200**，用响应体里的 `code` 表示成败：
  - code == 200 成功
  - code == 401 鉴权失败（未带/带错 token）
  - code == 500 业务冲突（如车门已开、账号已存在）
因此所有断言都看 `body['code']`，不是 HTTP 状态码。
"""
import urllib.request
import urllib.error
import json

BASE = "http://121.36.14.143:10001"

# 文档示例：已绑车账号（实测 carId=217, carVin=00323828999）
BOUND_USER = ("zzq1234", "666666")
ADMIN_USER = ("admin", "Neuedu@admin")
# 业务控制用的 carVin（文档示例值）
DOC_CAR_VIN = "00661718330"


def call(method, path, body=None, token=None, timeout=10):
    url = BASE + path
    data = json.dumps(body).encode("utf-8") if body is not None else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = "Bearer " + token
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, json.loads(r.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode("utf-8"))
        except Exception:
            return e.code, {}
    except Exception as e:
        return "ERR", {"error": str(e)}


def login(username, password):
    code, body = call("POST", "/app/login", {"username": username, "password": password})
    return code, body, body.get("token", "")


def login_bound():
    """登录已绑车账号，返回 (token, carId, carVin)。"""
    code, body, token = login(*BOUND_USER)
    assert body.get("code") == 200 and token, "bound user login failed: %s" % body
    code2, info = call("GET", "/getInfo", token=token)
    assert info.get("code") == 200, "getInfo failed: %s" % info
    return token, str(info.get("carId", "")), str(info.get("carVin", ""))


def opp(v):
    return "0" if v == "1" else "1"
