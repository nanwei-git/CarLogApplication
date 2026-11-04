import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from common import call, login_bound, BOUND_USER

SUCCESS = 200
UNAUTH = 401


class TestCar(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.token, cls.carId, cls.carVin = login_bound()

    def test_car_info(self):
        c, b = call("GET", "/cockpit/info/" + self.carId, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "carInfo failed: %s" % b)
        data = b.get("data")
        self.assertIsNotNone(data, "carInfo data must not be null")
        self.assertIn("carName", data, "carInfo data must contain carName")
        self.assertIn("brand", data, "carInfo data must contain brand")

    def test_car_state(self):
        c, b = call("GET", "/cockpit/state/" + self.carVin, token=self.token)
        self.assertEqual(b.get("code"), SUCCESS, "carState failed: %s" % b)
        data = b.get("data")
        self.assertIsNotNone(data, "carState data must not be null")
        self.assertIn("acBtn", data, "carState data must contain acBtn")
        self.assertIn("door", data, "carState data must contain door")
        self.assertIn("light", data, "carState data must contain light")

    def test_car_info_no_auth(self):
        c, b = call("GET", "/cockpit/info/" + self.carId)
        self.assertEqual(b.get("code"), UNAUTH, "carInfo must require auth: %s" % b)

    def test_car_state_no_auth(self):
        c, b = call("GET", "/cockpit/state/" + self.carVin)
        self.assertEqual(b.get("code"), UNAUTH, "carState must require auth: %s" % b)


if __name__ == "__main__":
    unittest.main(verbosity=2)
