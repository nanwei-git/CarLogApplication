import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from common import call, login_bound, opp

SUCCESS = 200
UNAUTH = 401


class TestControl(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.token, cls.carId, cls.carVin = login_bound()
        # 读取当前状态，用于取反控制
        _, st = call("GET", "/cockpit/state/" + cls.carVin, token=cls.token)
        cls.state = st.get("data") or {}

    def test_ac_put(self):
        cur = self.state.get("acBtn", "0")
        c, b = call("PUT", "/cockpit/state",
                    {"carVin": self.carVin, "acBtn": opp(cur)}, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "AC PUT failed: %s" % b)

    def test_door_toggle(self):
        cur = self.state.get("door", "0")
        c, b = call("POST", "/cockpit/control/door",
                    {"carId": self.carId, "door": opp(cur)}, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "door control failed: %s" % b)

    def test_light_toggle(self):
        cur = self.state.get("light", "0")
        c, b = call("POST", "/cockpit/control/light",
                    {"carId": self.carId, "light": opp(cur)}, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "light control failed: %s" % b)

    def test_move_actions(self):
        for act in ["move", "back", "left", "right", "stop"]:
            c, b = call("POST", "/cockpit/control/%s/%s" % (act, self.carId), token=self.token)
            self.assertEqual(b.get("code"), SUCCESS,
                             "control/%s failed: %s" % (act, b))

    def test_control_no_auth(self):
        c, b = call("POST", "/cockpit/control/light",
                    {"carId": self.carId, "light": "1"})
        self.assertEqual(b.get("code"), UNAUTH, "control must require auth: %s" % b)


if __name__ == "__main__":
    unittest.main(verbosity=2)
