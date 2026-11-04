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
            return r.status, json.loads(r.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode("utf-8"))
        except Exception:
            return e.code, {}
    except Exception as e:
        return "ERR", {"error": str(e)}


print("=== login zzq1234 ===")
c, login = call("POST", "/app/login", {"username": "zzq1234", "password": "666666"})
print("code", c, "token?", bool(login.get("token")))
token = login.get("token", "")

print("\n=== getInfo (zzq1234) ===")
c, info = call("GET", "/getInfo", token=token)
print("code", c, "carVin=", info.get("carVin"), "carId=", info.get("carId"))
carId = str(info.get("carId", ""))
carVin = str(info.get("carVin", ""))

print("\n=== carInfo GET /cockpit/info/%s ===" % carId)
c, ci = call("GET", "/cockpit/info/" + carId, token=token)
print("code", c, "data?", bool(ci.get("data")))
print(json.dumps(ci.get("data"), ensure_ascii=False)[:400])

print("\n=== carState GET /cockpit/state/%s ===" % carVin)
c, cs = call("GET", "/cockpit/state/" + carVin, token=token)
print("code", c, "data?", bool(cs.get("data")))
print(json.dumps(cs.get("data"), ensure_ascii=False)[:400])

print("\n=== AC PUT /cockpit/state (acBtn=1) ===")
c, ac = call("PUT", "/cockpit/state", {"carVin": carVin, "acBtn": "1", "setTemp": "26"}, token=token)
print("code", c, json.dumps(ac, ensure_ascii=False)[:200])

print("\n=== control door POST ===")
c, d = call("POST", "/cockpit/control/door", {"carId": carId, "door": "1"}, token=token)
print("code", c, json.dumps(d, ensure_ascii=False)[:200])

print("\n=== control light POST ===")
c, d = call("POST", "/cockpit/control/light", {"carId": carId, "light": "1"}, token=token)
print("code", c, json.dumps(d, ensure_ascii=False)[:200])

print("\n=== control move/back/left/right/stop ===")
for act in ["move", "back", "left", "right", "stop"]:
    c, d = call("POST", "/cockpit/control/%s/%s" % (act, carId), token=token)
    print("  %s -> %s %s" % (act, c, json.dumps(d, ensure_ascii=False)[:120]))

print("\n=== login wrong password ===")
c, w = call("POST", "/app/login", {"username": "admin", "password": "wrongpass"})
print("code", c, json.dumps(w, ensure_ascii=False)[:200])

print("\n=== register new unique user ===")
import time
uname = "qttest_%d" % int(time.time())
c, r = call("POST", "/system/user/register",
            {"nickName": "联调测试", "userName": uname, "phonenumber": "", "sex": "0",
             "avatar": "", "password": "Test@123", "roleIds": ["9"], "birthDate": "", "state": "0"})
print("code", c, "user=", uname, json.dumps(r, ensure_ascii=False)[:200])
