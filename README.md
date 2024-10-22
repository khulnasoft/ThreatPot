<p align="center"><img src="static/threatpot.png" width=350 height=404 alt="ThreatPot"/></p>

# ThreatPot
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/khulnasoft/Threatpot)](https://github.com/khulnasoft/Threatpot/releases)
[![GitHub Repo stars](https://img.shields.io/github/stars/khulnasoft/Threatpot?style=social)](https://github.com/khulnasoft/Threatpot/stargazers)
[![Twitter Follow](https://img.shields.io/twitter/follow/khulnasoft?style=social)](https://twitter.com/khulnasoft)
[![Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/company/khulnasoft/)

[![CodeFactor](https://www.codefactor.io/repository/github/khulnasoft/threatpot/badge)](https://www.codefactor.io/repository/github/khulnasoft/threatpot)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Imports: isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)](https://pycqa.github.io/isort/)
[![CodeQL](https://github.com/khulnasoft/ThreatPot/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/khulnasoft/ThreatPot/actions/workflows/codeql-analysis.yml)
[![Dependency Review](https://github.com/khulnasoft/ThreatPot/actions/workflows/dependency_review.yml/badge.svg)](https://github.com/khulnasoft/ThreatPot/actions/workflows/dependency_review.yml)
[![Pull request automation](https://github.com/khulnasoft/ThreatPot/actions/workflows/pull_request_automation.yml/badge.svg)](https://github.com/khulnasoft/ThreatPot/actions/workflows/pull_request_automation.yml)

The project goal is to extract data of the attacks detected by a [TPOT](https://github.com/khulnasoft/cyberpot) or a cluster of them and to generate some feeds that can be used to prevent and detect attacks.

[Official announcement here](https://www.honeynet.org/2021/12/27/new-project-available-threatpot/).

## Documentation

Documentation about ThreatPot installation, usage, configuration and contribution can be found at [this link](https://khulnasoft.github.io/docs/ThreatPot/Introduction/)

## Public feeds

There are public feeds provided by [KhulnaSoft, Ltd](https://www.honeynet.org) in this [site](https://threatpot.honeynet.org). [Example](https://threatpot.honeynet.org/api/feeds/log4j/all/recent.txt)

Please do not perform too many requests to extract feeds or you will be banned.

If you want to be updated regularly, please download the feeds only once every 10 minutes (this is the time between each internal update).

To check all the available feeds, Please refer to our [usage guide](https://khulnasoft.github.io/docs/ThreatPot/Usage/)


## Enrichment Service

ThreatPot provides an easy-to-query API to get the information available in GB regarding the queried observable (domain or IP address).

To understand more, Please refer to our [usage guide](https://khulnasoft.github.io/docs/ThreatPot/Usage/)

## Run Threatpot on your environment
The tool has been created not only to provide the feeds from KhulnaSoft, Ltd's cluster of TPOTs.

If you manage one or more T-POTs of your own, you can get the code of this application and run Threatpot on your environment.
In this way, you are able to provide new feeds of your own.

To install it locally, Please refer to our [installation guide](https://khulnasoft.github.io/docs/ThreatPot/Installation/)

## Sponsors

#### Certego

<a href="https://www.certego.net/?utm_source=threatpot"> <img style="margin-right: 2px" width=250 height=71 src="static/Certego.png" alt="Certego Logo"/></a>

[Certego](https://www.certego.net/?utm_source=threatpot) is a MDR (Managed Detection and Response) and Threat Intelligence Provider based in Italy.

Started as a personal Christmas project from [Matteo Lodi](https://twitter.com/matte_lodi), since then ThreatPot is being improved mainly thanks to the efforts of the Certego Threat Intelligence Team.

#### KhulnaSoft, Ltd

<a href="https://www.honeynet.org"> <img style="border: 0.2px solid black" width=125 height=125 src="static/honeynet_logo.png" alt="Honeynet.org logo"> </a>

[KhulnaSoft, Ltd](https://www.honeynet.org) is a non-profit organization working on creating open source cyber security tools and sharing knowledge about cyber threats.

