# This file is a part of ThreatPot https://github.com/khulnasoft/ThreatPot
# See the file 'LICENSE' for copying permission.
from dataclasses import dataclass


@dataclass
class Honeypot:
    name: str
    description: str = ""
