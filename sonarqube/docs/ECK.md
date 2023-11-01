# Logging

# Pre-requisites

Sonarqube is deployed

ECK/Fluentd is deployed

# Getting Started

1. Login to Kibana
    username: elastic
    Password : <password>
    Password can be obtained by querying kubectl get secret elasticsearch-es-elastic-user -n elastic -o yaml

2. Create Index by  selecting Management icon from the left menu and  clicking Index patterns under Kibana
    In the Create Index patterns <sonarqube*> and click create index pattern.
    In the the next step Click on the dropdown and select "@timestamp"

3. For Search click on Discovery from the side menu

4. In KQL textbox enter the  field of interest for eg:  "kubernetes.namespace_name : sonarqube*"

5. Click Refresh/Update

## Application Logs

Application logs are available in the application.  Go to the SonarQube URL and select login from the upper lefr.  The default credentials:

Username: <admin>
Password: <admin>

Note: change the password on the first login

Logs can be downloaded by going to Administration-> System -> Download Logs

Server-side logging is controlled by properties set in $SONARQUBE-HOME/conf/sonar.properties.

4 logs files are created: one per SonarQube process.
  Main process (aka. App) logs in sonar.log
  Web Server (aka. Web) logs in web.log
  Compute Engine (aka. CE) logs in ce.log
  Elasticsearch (aka. ES) logs in es.log

## Log Level

The server-side log level can be customized via the sonar.log.level property. Supported values are:

INFO - the default
DEBUG - for advanced logs.
TRACE - show advanced logs and all SQL and Elasticsearch requests. TRACE level logging slows down the server environment, and should be used only for tracking web request performance problems.

### Log Level by Process

The server-side log level can be adjusted more precisely for the 4 processes of SonarQube Server via the following property:

sonar.log.level.app - for the Main process of SonarQube (aka WrapperSimpleApp, the bootstrapper process starting the 3 others)
sonar.log.level.web - for the WebServer
sonar.log.level.ce - for the ComputeEngineServer
sonar.log.level.es - for the SearchServer
Log Rotation
To control log rolling, use the sonar.log.rollingPolicy

1. time:[value] - for time-based rotation. For example, use time:yyyy-MM-dd for daily rotation, and * time:yyyy-MM for monthly rotation.
2. size:[value] - for size-based rotation. For example, size:10MB.
none - for no rotation. Typically this would be used when logs are handled by an external system like logrotate.
3. sonar.log.maxFiles - is the maximum number of files to keep. This property is ignored if sonar.log.rollingPolicy=none.

### UI Access to Logs and Log Levels

The System Info page gives you the ability to download your instance's current log files (log files rotate on a regular basis), and to tune the log level via controls at the top of the page. Changes made here are temporary, and last only until the next time the instance is restarted, at which point the level will be reset to the more permanent value set in $SONARQUBE-HOME/conf/sonar.properties. Regardless, if you change your log level from INFO, but sure to change it back as soon as is practical; log files can get very large very quickly at lower log levels.

### Total Lines of Code

The number of Lines of Code (for licensing purposes) in an instance can be found in the System section of the System Info page on, and on the License page (Administration > Configuration > License Manager in commercial editions.

## Sonarqube Config

Further logging information can be found in the SonarQube configuration file.  For details run the following command:

```kubectl exec sonarqube-sonarqube-5dd795f449-xxxx -n sonarqube -- cat ./conf/sonar.properties``
