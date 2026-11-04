import os
import sys
import unittest
import random
import string

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from common import call, login, ADMIN_USER, BOUND_USER, DOC_CAR_VIN

SUCCESS = 200
UNAUTH = 401


class TestAuth(unittest.TestCase):
    def test_login_success(self):
        code, body, token = login(*ADMIN_USER)
        self.assertEqual(body.get("code"), SUCCESS, "login should succeed: %s" % body)
        self.assertTrue(token, "login should return token")

    def test_login_wrong_password(self):
        code, body, token = login(ADMIN_USER[0], "this_is_definitely_wrong")
        # 业务码非 200，且不应下发 token
        self.assertNotEqual(body.get("code"), SUCCESS, "wrong password must fail: %s" % body)
        self.assertEqual(token, "", "no token on failure")

    def test_register_new_unique_user(self):
        letters = "".join(random.choices(string.ascii_lowercase, k=8))
        uname = "qttest" + letters  # 纯英文账号，满足服务端校验
        c, b = call("POST", "/system/user/register",
                    {"nickName": "联调测试", "userName": uname, "phonenumber": "",
                     "sex": "0", "avatar": "", "password": "666666",
                     "roleIds": ["9"], "birthDate": "", "state": "0"})
        self.assertEqual(b.get("code"), SUCCESS, "register failed: %s" % b)
        # 新账号可登录
        c2, b2, tok = login(uname, "666666")
        self.assertEqual(b2.get("code"), SUCCESS, "registered user cannot login: %s" % b2)
        self.assertTrue(tok, "registered user token missing")

    def test_get_info_shape(self):
        _, _, token = login(*BOUND_USER)
        code, info = call("GET", "/getInfo", token=token)
        self.assertEqual(info.get("code"), SUCCESS, "getInfo failed: %s" % info)
        self.assertIn("user", info, "getInfo must return user")
        self.assertIn("carVin", info, "getInfo must return carVin (top-level)")
        self.assertIn("carId", info, "getInfo must return carId (top-level)")
        # 已绑车账号应有非空 carVin/carId（与 App 的 StorageUtils 取值一致）
        self.assertTrue(info.get("carVin"), "carVin should not be empty for bound user")
        self.assertTrue(info.get("carId"), "carId should not be empty for bound user")

    def test_get_info_no_auth(self):
        code, body = call("GET", "/getInfo")
        self.assertEqual(body.get("code"), UNAUTH, "no-auth getInfo must be 401: %s" % body)

    def test_bind_car(self):
        _, _, token = login(*ADMIN_USER)
        c, b = call("POST", "/cockpit/info/bindCarVin", {"carVin": DOC_CAR_VIN}, token=token)
        # 鉴权通过即视为合约正确；绑定可能成功(200)或业务冲突(500 已绑)均属正常
        self.assertNotEqual(b.get("code"), UNAUTH, "bindCar must not be 401: %s" % b)
        self.assertIn(b.get("code"), (SUCCESS, 500), "unexpected bindCar code: %s" % b)


if __name__ == "__main__":
    unittest.main(verbosity=2)
