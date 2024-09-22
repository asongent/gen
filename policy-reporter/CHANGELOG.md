# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [2.24.1-bb.1] - 2024-08-26

### Changed

- Reverted previous Kiali label changes related to the epic and modified them to follow the new pattern.

## [2.24.1-bb.0] - 2024-08-19

### Changed

- Updated upstream chart reference from `2.24.0` to `2.24.1`

## [2.24.0-bb.3] - 2024-08-19

### Changed

- Updated `gluon` package dependency version from `0.5.2` to `0.5.3`
- Reduced number of Cypress test retries

## [2.24.0-bb.2] - 2024-08-05

### Changed

- Updated image from `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.20.0` to `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.20.1`
- Updated `gluon` package dependency version from `0.5.0` to `0.5.2`

## [2.24.0-bb.1] - 2024-07-26

### Changed

- Added `bigbang.labels` to `chart/templates/deployment.yaml`, `chart/templates/cronjob-summary-report.yaml` and `chart/templates/cronjob-violations-report.yaml` to conform to Kiali requirements
- Updated `docs/DEVELOPMENT_MAINTENANCE.md`

## [2.24.0-bb.0] - 2024-07-02

### Changed

- Updated image from `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.19.0` to `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.20.0`
- Updated upstream chart reference from `2.23.1` to `2.24.0`

## [2.23.1-bb.1] - 2024-06-21

### Changed

- Updated DEVELOPMENT_MAINTENANCE.md with instructions for integration testing in pipeline

## [2.23.1-bb.0] - 2024-05-24

### Changed

- Updated image from `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.18.1` to `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.19.0`
- Updated upstream chart reference from `2.22.4` to `2.23.1`

## [2.22.4-bb.5] - 2024-05-12

### Changed

- Updated `gluon` package dependency version from `0.4.10` to `0.5.0`

## [2.22.4-bb.4] - 2024-04-30

### Changed

- Updated `gluon` package dependency version from `0.4.9` to `0.4.10`

## [2.22.4-bb.3] - 2024-04-22

### Changed

- Updated `gluon` package dependency version from `0.4.8` to `0.4.9`

## [2.22.4-bb.2] - 2024-04-05

### Added

- Custom network policies

## [2.22.4-bb.1] - 2024-03-27

### Changed

- Changed 01-prometheus.cy.js to wait before the test handle early network errors on cypress tests

## [2.22.4-bb.0] - 2024-03-12

### Changed

- Updated upstream chart reference from `2.22.0` to `2.22.4`

## [2.22.0-bb.2] - 2024-03-08

### Changed

- Adding Sidecar to deny egress that is external to istio services
- Adding customServiceEntries to allow egress to override sidecar restraint

## [2.22.0-bb.1] - 2024-03-06

### Changed

- Updated image from `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.18.0` to `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.18.1`
- Updated `gluon` package dependency version from `0.4.7` to `0.4.8`

## [2.22.0-bb.0] - 2024-02-06

### Changed

- Updated upstream chart reference from `2.21.6` to `2.22.0`
- Updated image from `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.17.5` to `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.18.0`

## [2.21.6-bb.2] - 2024-02-02

### Changed

- Updated to Gluon 0.4.7
- Removed cypress config as it is now coming from gluon
- Updated cypress tests to use new shared commands from gluon

## [2.21.6-bb.1] - 2024-01-25

### Changed

- Changed cypress tests to work with version of Grafana

## [2.21.6-bb.0] - 2024-01-16

### Changed

- Updated upstream chart reference from `2.16.0` to `2.21.6`
- Updated image and IronBank repo reference from `registry1.dso.mil/ironbank/nirmata/policy-reporter/policy-reporter:2.12.0` to `registry1.dso.mil/ironbank/opensource/kyverno/policy-reporter:2.17.5`
- Updated `gluon` package dependency version from `0.4.1` to `0.4.7`

## [2.16.0-bb.6] - 2023-10-11

### Changed

- Harden API token automounting behavior of ServiceAccount/Pod

## [2.16.0-bb.5] - 2023-10-5

### Changed

- Exposed automountServiceAccountToken as a value

## [2.16.0-bb.4] - 2023-9-19

### Changed

- Upgraded gluon to 0.4.1
- Upgraded cypress tests to work with cypress 13.x

## [2.16.0-bb.3] - 2023-9-14

### Changed

- Made test resources conditional on bbtests.enabled

## [2.16.0-bb.2] - 2023-08-30

### Changed

- Updated Prometheus Cypress Test to work with updated UI
- Added Grafana as a dependency to Cypress Test

## [2.16.0-bb.1] - 2023-03-15

### Changed

- Update chart name to match bb values file

## [2.16.0-bb.0] - 2023-02-01

### Changed

- Update application to 2.10.4 and chart to 2.12.0

## [2.13.5-bb.1] - 2023-01-17

### Changed

- Update gluon to new registry1 location + latest version (0.3.2)

## [2.13.5-bb.0] - 2022-12-13

### Changed

- Updated chart to 2.13.5 upstream version, updated reporter images to 2.10.4 (reporter).

## [2.13.4-bb.1] - 2022-12-06

### Changed

- Enabled mTLS for Kyverno Reporter metrics
- updated gluon to  0.3.1

## [2.13.4-bb.0] - 2022-11-17

### Changed

- Updated chart to 2.13.4 upstream version, updated reporter images to 2.10.3 (reporter).  Updated ui to 2.6.5

## [2.13.1-bb.0] - 2022-10-20

### Changed

- Updated chart to 2.13.1 upstream version, updated images to 2.10.1 (reporter), 2.6.4 (UI) and 1.4.3 (plugin)

## [2.13.0-bb.0] - 2022-09-23

### Changed

- Updated chart to 2.13.0 upstream version, updated images to 2.10.0 (reporter) and 1.4.2 (plugin)

## [2.11.3-bb.0] - 2022-09-06

### Changed

- Updated chart to 2.11.3 upstream version, updated images to 2.8.3 (reporter) and 1.4.1 (plugin)
- Fixed dashboard check in cypress test

## [2.11.0-bb.0] - 2022-08-12

### Changed

- Updated chart to 2.11.0 upstream version, updated images to 2.8.0 (reporter) and 1.4.0 (plugin)
- Updated all images to Ironbank

### Added

- Added upgrade documentation
- Added `runAsGroup` to fix Kyverno violation

## [2.7.0-bb.0] - 2022-03-14

### Changed

- Update application to 2.4.0 and chart to 2.7.0

## [2.6.2-bb.0] - 2022-03-14

### Added

- Initial upstream Helm chart
- Required documents
