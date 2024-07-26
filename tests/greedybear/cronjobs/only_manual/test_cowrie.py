# This file is a part of ThreatPot https://github.com/honeynet/ThreatPot
# See the file 'LICENSE' for copying permission.

from unittest import TestCase

from threatpot.cronjobs import cowrie
from threatpot.models import IOC


class CowrieTestCase(TestCase):
    def test_sensors(self, *args, **kwargs):
        a = cowrie.ExtractCowrie()
        a.execute()
        self.assertTrue(a.success)
        iocs = IOC.objects.filter(cowrie=True)
        self.assertTrue(iocs)
