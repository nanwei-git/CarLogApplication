import os
import sys
import time
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from common import call, login_bound

SUCCESS = 200
UNAUTH = 401


class TestFeedback(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.token, cls.carId, cls.carVin = login_bound()

    def test_list(self):
        c, b = call("GET", "/cockpit/feedback/backList", token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "feedback list failed: %s" % b)
        data = b.get("data")
        self.assertIsInstance(data, list, "feedback list data must be an array")

    def test_detail(self):
        c, b = call("GET", "/cockpit/feedback/backList", token=self.token)
        rows = b.get("data") or []
        self.assertTrue(rows, "need at least one feedback for detail test")
        fid = rows[0].get("id")
        c2, d = call("GET", "/cockpit/feedback/" + str(fid), token=self.token)
        self.assertEqual(d.get("code"), SUCCESS, "feedback detail failed: %s" % d)
        self.assertIn("content", d.get("data", {}), "detail must contain content")

    def test_add(self):
        content = "联调自动测试反馈_%d" % int(time.time())
        c, b = call("POST", "/cockpit/feedback/add",
                    {"content": content, "status": "0"}, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "feedback add failed: %s" % b)

    def test_add_and_delete(self):
        content = "联调自动测试待删_%d" % int(time.time())
        c, b = call("POST", "/cockpit/feedback/add",
                    {"content": content, "status": "0"}, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "feedback add failed: %s" % b)
        # 在列表中找到刚加的反馈（放大 pageSize 确保可见）
        c2, fl = call("GET", "/cockpit/feedback/backList?pageNum=1&pageSize=200", token=self.token)
        rows = fl.get("data") or []
        target = None
        for r in rows:
            if r.get("content") == content:
                target = r.get("id")
                break
        self.assertIsNotNone(target, "added feedback not found in list")
        c3, d = call("DELETE", "/cockpit/feedback/" + str(target), token=self.token)
        self.assertEqual(d.get("code"), SUCCESS, "feedback delete failed: %s" % d)

    def test_delete_no_auth(self):
        c, b = call("DELETE", "/cockpit/feedback/1")
        self.assertEqual(b.get("code"), UNAUTH, "feedback delete must require auth: %s" % b)


if __name__ == "__main__":
    unittest.main(verbosity=2)
