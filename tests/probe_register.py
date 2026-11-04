import urllib.request, urllib.error, json, random, string, time

BASE = "http://121.36.14.143:10001"


def call(method, path, body=None, token=None):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = "Bearer " + token
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return r.status, json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode())
        except Exception:
            return e.code, {}
    except Exception as e:
        return "ERR", {"error": str(e)}


letters = ''.join(random.choices(string.ascii_lowercase, k=8))
uname = "qttest" + letters
print("try register:", uname)
c, b = call("POST", "/system/user/register",
            {"nickName": "联调测试", "userName": uname, "phonenumber": "",
             "sex": "0", "avatar": "", "password": "666666",
             "roleIds": ["9"], "birthDate": "", "state": "0"})
print("HTTP", c, "body.code", b.get("code"), "msg", b.get("msg"))

# 登录刚注册的用户验证可用
c2, b2 = call("POST", "/app/login", {"username": uname, "password": "666666"})
print("login new user -> HTTP", c2, "body.code", b2.get("code"), "token?", bool(b2.get("token")))
