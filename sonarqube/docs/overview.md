# Sonarqube

## Overview

SonarQube is an open-source platform for continuous inspection of code to perform automatic reviews with static analysis to detect bugs, vulnerabilities.

## Dependencies

This package depends on the [Node Kernel Mods](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/blob/master/docs/guides/prerequisites/os_preconfiguration.md#sonarqube-specific-configuration-sonarqube-is-a-bb-addon-app)

## How it works

SonarQube® is an automatic code review tool to detect bugs, vulnerabilities, and code smells in your code. It can integrate with your existing workflow to enable continuous code inspection across your project branches and pull requests. This chart works by deploying an instance of Sonarqube packaged with a [postgresql](https://repo1.dso.mil/platform-one/big-bang/apps/developer-tools/sonarqube/-/blob/main/chart/values.yaml#L285) installation that is enabled by default,  and disabled within BigBang when an external database connection is specified. To deploy Sonarqube, `sonarqube` must be enabled through the addons functionality in the Big Bang [values.yaml](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/blob/master/chart/values.yaml).

## External Resources

If you'd like to learn more about the SonarQube application and its features, see their [official documentation](https://www.sonarqube.org/).

Please review the BigBang [Architecture Document](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/blob/master/charter/packages/sonarqube/Architecture.md) for more information about its role within BigBang.
