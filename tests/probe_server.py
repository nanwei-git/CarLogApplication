import urllib.request, urllib.error, json

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
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()
    except Exception as e:
        return "ERR", str(e)


def show(label, method, path, **kw):
    code, resp = call(method, path, **kw)
    print(f"[{label}] {method} {path} -> {code}")
    print("   ", resp[:600])
    return code, resp


print("=== PROBE (no auth) ===")
show("getInfo", "GET", "/getInfo")
show("carInfo", "GET", "/cockpit/info/1")
show("carState", "GET", "/cockpit/state/00661718330")
show("feedbackList", "GET", "/cockpit/feedback/backList")
show("logList", "GET", "/cockpit/log/list?pageNum=1&pageSize=20&operaContent=")
show("acPut", "PUT", "/cockpit/state", body={"carVin": "00661718330", "acBtn": "1"})

print("\n=== PROBE (login attempts) ===")
show("login-admin", "POST", "/app/login", body={"username": "admin", "password": "Neuedu@admin"})
show("login-zzq", "POST", "/app/login", body={"username": "zzq1234", "password": "666666"})

print("\n=== PROBE (register) ===")
show("register", "POST", "/system/user/register",
     body={"nickName": "杨庆鸿", "userName": "zzq1234", "phonenumber": "", "sex": "0",
           "avatar": "", "password": "666666", "roleIds": ["9"], "birthDate": "", "state": "0"})
