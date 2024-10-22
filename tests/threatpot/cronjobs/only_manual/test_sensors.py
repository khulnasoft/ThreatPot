# This file is a part of ThreatPot https://github.com/honeynet/ThreatPot
# See the file 'LICENSE' for copying permission.

from unittest import TestCase

from threatpot.cronjobs import sensors
from threatpot.models import Sensors


class SensorsTestCase(TestCase):
    def test_sensors(self, *args, **kwargs):
        s = sensors.ExtractSensors()
        s.execute()
        self.assertTrue(s.success)
        s_ob = Sensors.objects.all()
        self.assertTrue(s_ob)
