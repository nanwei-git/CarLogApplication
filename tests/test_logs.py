import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from common import call, login_bound

SUCCESS = 200
UNAUTH = 401


class TestLogs(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.token, cls.carId, cls.carVin = login_bound()

    def test_log_list(self):
        c, b = call("GET", "/cockpit/log/list?pageNum=1&pageSize=20&operaContent=",
                    token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "log list failed: %s" % b)
        self.assertIsInstance(b.get("rows"), list, "log list rows must be an array")
        self.assertIsInstance(b.get("total"), int, "log list total must be an int")
        rows = b.get("rows") or []
        if rows:
            r = rows[0]
            # 与 App 的 OperationLog 映射字段一致
            self.assertIn("operaType", r, "log row must contain operaType")
            self.assertIn("operaContent", r, "log row must contain operaContent")
            self.assertIn("createTime", r, "log row must contain createTime")

    def test_log_delete(self):
        c, b = call("GET", "/cockpit/log/list?pageNum=1&pageSize=20&operaContent=",
                    token=self.token)
        rows = b.get("rows") or []
        self.assertTrue(rows, "need at least one log for delete test")
        lid = rows[0].get("id")
        c2, d = call("DELETE", "/cockpit/log/" + str(lid), token=self.token)
        self.assertEqual(d.get("code"), SUCCESS, "log delete failed: %s" % d)

    def test_log_delete_no_auth(self):
        c, b = call("DELETE", "/cockpit/log/1")
        self.assertEqual(b.get("code"), UNAUTH, "log delete must require auth: %s" % b)


if __name__ == "__main__":
    unittest.main(verbosity=2)
