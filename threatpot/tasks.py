# This file is a part of ThreatPot https://github.com/honeynet/ThreatPot
# See the file 'LICENSE' for copying permission.
from __future__ import absolute_import, unicode_literals

from celery import shared_task


@shared_task()
def extract_log4pot():
    from threatpot.cronjobs.log4pot import ExtractLog4Pot

    ExtractLog4Pot().execute()


@shared_task()
def extract_cowrie():
    from threatpot.cronjobs.cowrie import ExtractCowrie

    ExtractCowrie().execute()


# FEEDS


@shared_task()
def extract_general():
    from threatpot.cronjobs.general import ExtractGeneral

    ExtractGeneral().execute()


@shared_task()
def extract_sensors():
    from threatpot.cronjobs.sensors import ExtractSensors

    ExtractSensors().execute()


@shared_task()
def monitor_honeypots():
    from threatpot.cronjobs.monitor_honeypots import MonitorHoneypots

    MonitorHoneypots().execute()


@shared_task()
def monitor_logs():
    from threatpot.cronjobs.monitor_logs import MonitorLogs

    MonitorLogs().execute()
