# This file is a part of ThreatPot https://github.com/honeynet/ThreatPot
# See the file 'LICENSE' for copying permission.

from unittest import TestCase

from django.db.models import Q
from threatpot.cronjobs import general
from threatpot.models import IOC

# FEEDS


class GeneralTestCase(TestCase):
    def test_sensors(self, *args, **kwargs):
        a = general.ExtractGeneral()
        a.execute()
        self.assertTrue(a.success)
        iocs = []
        for hp in ["heralding", "ciscoasa"]:
            iocs.extend(IOC.objects.filter(Q(general_honeypot__name__iexact=hp)))
        self.assertTrue(iocs)
