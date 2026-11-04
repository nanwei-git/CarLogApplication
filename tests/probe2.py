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


print("=== login ===")
c, login = call("POST", "/app/login", {"username": "admin", "password": "Neuedu@admin"})
print("code", c, "keys", list(login.keys()))
token = login.get("token", "")
print("token?", bool(token))

print("\n=== getInfo ===")
c, info = call("GET", "/getInfo", token=token)
print("code", c, "keys", list(info.keys()))
print("carVin", info.get("carVin"), "carId", info.get("carId"))
print("user", json.dumps(info.get("user"), ensure_ascii=False)[:300])

carId = str(info.get("carId", ""))
carVin = str(info.get("carVin", ""))

print("\n=== carInfo GET /cockpit/info/%s ===" % carId)
c, ci = call("GET", "/cockpit/info/" + carId, token=token)
print("code", c, "keys", list(ci.keys()))
print("data", json.dumps(ci.get("data"), ensure_ascii=False)[:400])

print("\n=== carState GET /cockpit/state/%s ===" % carVin)
c, cs = call("GET", "/cockpit/state/" + carVin, token=token)
print("code", c, "keys", list(cs.keys()))
print("data", json.dumps(cs.get("data"), ensure_ascii=False)[:400])

print("\n=== AC PUT /cockpit/state ===")
c, ac = call("PUT", "/cockpit/state", {"carVin": carVin, "acBtn": "1", "setTemp": "26"}, token=token)
print("code", c, "body", json.dumps(ac, ensure_ascii=False)[:200])

print("\n=== control door POST ===")
c, d = call("POST", "/cockpit/control/door", {"carId": carId, "door": "1"}, token=token)
print("code", c, json.dumps(d, ensure_ascii=False)[:200])

print("\n=== feedback list GET ===")
c, fl = call("GET", "/cockpit/feedback/backList", token=token)
print("code", c, "keys", list(fl.keys()))
print("data is list?", isinstance(fl.get("data"), list), "len", len(fl.get("data") or []))

print("\n=== feedback add POST ===")
c, fa = call("POST", "/cockpit/feedback/add", {"content": "联调自动测试反馈", "status": "0"}, token=token)
print("code", c, json.dumps(fa, ensure_ascii=False)[:300])

print("\n=== log list GET ===")
c, ll = call("GET", "/cockpit/log/list?pageNum=1&pageSize=20&operaContent=", token=token)
print("code", c, "keys", list(ll.keys()))
print("rows is list?", isinstance(ll.get("rows"), list), "total", ll.get("total"))
if ll.get("rows"):
    print("first row", json.dumps(ll["rows"][0], ensure_ascii=False)[:300])
