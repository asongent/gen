---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Upgrade the GitLab chart **(FREE SELF)**

Before upgrading your GitLab installation, you need to check the
[changelog](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md)
corresponding to the specific release you want to upgrade to and look for any
[release notes](version_mappings.md#release-notes-for-each-version) that might pertain to the new GitLab chart
version.

NOTE:
**Zero-downtime upgrades** are not available with the GitLab charts.
Ongoing work to support this feature can be tracked via
[the GitLab Operator epic](https://gitlab.com/groups/gitlab-org/cloud-native/-/epics/52).

We also recommend that you take a [backup](../backup-restore/index.md) first. Also note that you
must provide all values using `helm upgrade --set key=value` syntax or `-f values.yaml` instead of
using `--reuse-values`, because some of the current values might be deprecated.

You can retrieve your previous `--set` arguments cleanly, with
`helm get values <release name>`. If you direct this into a file
(`helm get values <release name> > gitlab.yaml`), you can safely pass this
file via `-f`. Thus `helm upgrade gitlab gitlab/gitlab -f gitlab.yaml`.
This safely replaces the behavior of `--reuse-values`

See [mappings](../installation/version_mappings.md) between chart versioning and GitLab versioning.

## Steps

NOTE:
If you're upgrading to the `7.0` version of the chart, follow the [manual upgrade steps for 7.0](#upgrade-to-version-70).
If you're upgrading to the `5.0` version of the chart, follow the [manual upgrade steps for 5.0](#upgrade-to-version-50).
If you're upgrading to the `4.0` version of the chart, follow the [manual upgrade steps for 4.0](#upgrade-to-version-40).
If you're upgrading to an older version of the chart, follow the [upgrade steps for older versions](upgrade_old.md).

Before you upgrade, reflect on your set values and if you've possibly "over-configured" your settings. We expect you to maintain a small list of modified values, and leverage most of the chart defaults. If you've explicitly set a large number of settings by:

- Copying computed settings
- Copying all settings and explicitly defining values that are actually the same as the default values

This will almost certainly cause issues during the upgrade as the configuration structure could have changed across versions, and that will cause problems applying the settings. We cover how to check this in the following steps.

The following are the steps to upgrade GitLab to a newer version:

1. Check the [change log](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md) for the specific version you would like to upgrade to.
1. Go through the [deployment documentation](deployment.md) step by step.
1. Extract your previously provided values:

   ```shell
   helm get values gitlab > gitlab.yaml
   ```

1. Decide on all the values you need to carry through as you upgrade. GitLab has reasonable default values, and while upgrading, you can attempt to pass in all values from the above command, but it could create a scenario where a configuration has changed across chart versions and it might not map cleanly. We advise keeping a minimal set of values that you want to explicitly set, and passing those during the upgrade process.
1. Perform the upgrade, with values extracted in the previous step:

   ```shell
   helm upgrade gitlab gitlab/gitlab \
     --version <new version> \
     -f gitlab.yaml \
     --set gitlab.migrations.enabled=true \
     --set ...
   ```

1. If you [installed the product documentation](deployment.md#install-the-product-documentation),
   see how to [upgrade it](https://docs.gitlab.com/ee/administration/docs_self_host.html#upgrade-the-product-documentation-to-a-later-version).

During a major database upgrade, we ask you to set `gitlab.migrations.enabled` set to `false`.
Ensure that you explicitly set it back to `true` for future updates.

## Upgrade the bundled PostgreSQL chart

NOTE:
If you aren't using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need to
perform this step.

### Upgrade the bundled PostgreSQL to version 13

PostgreSQL 13 is supported by GitLab 14.1 and later. [PostgreSQL 13 brings significant performance improvements](https://www.postgresql.org/about/news/postgresql-13-released-2077/).

To upgrade the bundled PostgreSQL to version 13, the following steps are required:

1. [Prepare the existing database](database_upgrade.md#prepare-the-existing-database).
1. [Delete existing PostgreSQL data](database_upgrade.md#delete-existing-postgresql-data).
1. Update the `postgresql.image.tag` value to `13.6.0` and [reinstall the chart](database_upgrade.md#upgrade-gitlab) to create a new PostgreSQL 13 database.
1. [Restore the database](database_upgrade.md#restore-the-database).

### Upgrade the bundled PostgreSQL to version 12

As part of the `5.0.0` release of this chart, we upgraded the bundled PostgreSQL version from `11.9.0` to `12.7.0`. This is
 not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [5.0 upgrade steps](#upgrade-to-version-50).

### Upgrade the bundled PostgreSQL to version 11

As part of the `4.0.0` release of this chart, we upgraded the bundled [PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) from `7.7.0` to `8.9.4`. This is not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [4.0 upgrade steps](#upgrade-to-version-40).

## Upgrade to version 7.0

WARNING:
If you are upgrading from the `6.x` version of the chart to the latest `7.0` release, you need
to first update to the latest `6.11.x` patch release in order for the upgrade to work.
The [7.0 release notes](../releases/7_0.md) describe the supported upgrade path.

The `7.0.x` release may require manual steps in order to perform the upgrade.

- If using the bundled [`bitnami/Redis`](https://artifacthub.io/packages/helm/bitnami/redis) sub-chart
  to provide an in-cluster Redis service - you'll need to manually delete the StatefulSet for
  Redis prior to upgrading to version 7.0 of the GitLab chart. Follow the setups in [Upgrade the bundled Redis sub-chart](#update-the-bundled-redis-sub-chart) below.

### Update the bundled Redis sub-chart

Release 7.0 of the GitLab chart updates the bundled [`bitnami/Redis`](https://artifacthub.io/packages/helm/bitnami/redis)
sub-chart to version `16.13.2` from the previously installed `11.3.4`. Due to
changes in `matchLabels` applied to the `redis-master` StatefulSet in the sub-chart,
upgrading without manually deleting the StatefulSet will result in the following error:

```shell
Error: UPGRADE FAILED: cannot patch "gitlab-redis-master" with kind StatefulSet: StatefulSet.apps "gitlab-redis-master" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'template', 'updateStrategy' and 'minReadySeconds' are forbidden
```

To delete the StatefulSet for `RELEASE-redis-master`:

1. Scale down the replicas to `0` for the `webservice`, `sidekiq`, `kas`, and `gitlab-exporter` deployments:

   ```shell
   kubectl scale deployment --replicas 0 --selector 'app in (webservice, sidekiq, kas, gitlab-exporter)' --namespace <namespace>
   ```

1. Delete the `RELEASE-redis-master` StatefulSet:

   ```shell
   kubectl delete statefulset RELEASE-redis-master --namespace <namespace>
   ```

   - `<namespace>` should be replaced with the namespace where you installed the GitLab chart.

Then follow the [standard upgrade steps](#steps). Due to how Helm merges changes, you may need to scale up the deployments
you scaled down in step one manually.

### Use of `global.redis.password`

In order to mitigate a configuration type conflict with the use of `global.redis.password`
we've deprecated the use of `global.redis.password` in favor of `global.redis.auth`.

In addition to displaying a deprecation notice - if you see the following warning
message from `helm upgrade`:

```plaintext
coalesce.go:199: warning: destination for password is a table. Ignoring non-table value
```

This is an indication that you are setting `global.redis.password` in your values file.

## Upgrade to version 6.0

WARNING:
If you are upgrading from the `5.x` version of the chart to the latest `6.0` release, you need
to first update to the latest `5.10.x` patch release in order for the upgrade to work.
The [6.0 release notes](../releases/6_0.md) describe the supported upgrade path.

To upgrade to the `6.0` release you must first be on the latest `5.10.x` patch release. There isn't any additional manual changes required in `6.0` so you can [follow the regular release upgrade steps](#steps).

## Upgrade to version 5.9

### Sidekiq pod never becomes ready

Upgrading to `5.9.x` may lead to a situation where the Sidekiq pod does not become ready. The pod starts and appears to work properly but never listens on the `3807`, the default metrics endpoint port (`metrics.port`). As a result, the Sidekiq pod is not considered to be ready.

This can be resolved from the **Admin Area**:

1. On the left sidebar, expand the top-most chevron (**{chevron-down}**).
1. Select **Admin Area**.
1. Select **Settings > Metrics and profiling**.
1. Expand **Metrics - Prometheus**.
1. Ensure that **Enable health and performance metrics endpoint** is enabled.
1. Restart the affected pods.

There is additional conversation about this scenario in a [closed issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3198).

## Upgrade to version 5.5

The `task-runner` chart [was renamed](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/2099/diffs)
to `toolbox` and removed in `5.5.0`. As a result, any mention of `task-runner`
in your configuration should be renamed to `toolbox`. In version 5.5 and newer,
use the `toolbox` chart, and in version 5.4 and older, use the `task-runner` chart.

### Missing object storage secret error

Upgrading to 5.5 or newer might cause an error similar to the following:

```shell
Error: UPGRADE FAILED: execution error at (gitlab/charts/gitlab/charts/toolbox/templates/deployment.yaml:227:23): A valid backups.objectStorage.config.secret is needed!
```

If the secret mentioned in the error already exists and is correct, then this error
is likely because there is an object storage configuration value that still references
`task-runner` instead of the new `toolbox`. Rename `task-runner` to `toolbox` in your
configuration to fix this.

There is an [open issue about clarifying the error message](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3004).

## Upgrade to version 5.0

WARNING:
If you are upgrading from the `4.x` version of the chart to the latest `5.0` release, you need
to first update to the latest `4.12.x` patch release in order for the upgrade to work.
The [5.0 release notes](../releases/5_0.md) describe the supported upgrade path.

The `5.0.0` release requires manual steps in order to perform the upgrade. If you're using the
bundled PostgreSQL, the best way to perform this upgrade is to back up your old database, and
restore into a new database instance.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

If you are using an external PostgreSQL database, you should first upgrade the database to version 12 or greater. Then
follow the [standard upgrade steps](#steps).

If you are using the bundled PostgreSQL database, you should follow the [bundled database upgrade steps](database_upgrade.md#steps-for-upgrading-the-bundled-postgresql).

### Troubleshooting 5.0 release upgrade process

- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

## Upgrade to version 4.0

The `4.0.0` release requires manual steps in order to perform the upgrade. If you're using the
bundled PostgreSQL, the best way to perform this upgrade is to back up your old database, and
restore into a new database instance.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

If you are using an external PostgreSQL database, you should first upgrade the database to version 11 or greater. Then
follow the [standard upgrade steps](#steps).

If you are using the bundled PostgreSQL database, you should follow the [bundled database upgrade steps](database_upgrade.md#steps-for-upgrading-the-bundled-postgresql).

### Troubleshooting 4.0 release upgrade process

- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

#### 4.8: Repository data appears to be lost upgrading Praefect

The Praefect chart is not yet considered suitable for production use.

If you have enabled Praefect before upgrading to version 4.8 of the chart (GitLab 13.8),
note that the StatefulSet name for Gitaly will now include the virtual storage name.

In version 4.8 of the Praefect chart, the ability to specify multiple virtual storages
was added, making it necessary to change the StatefulSet name.

Any existing Praefect-managed Gitaly StatefulSet names (and, therefore, their
associated PersistentVolumeClaims) will change as well, leading to repository data
appearing to be lost.

Prior to upgrading, ensure that:

- All your repositories are in sync across the Gitaly Cluster, and GitLab
  is not in use during the upgrade. To check whether the repositories are in sync,
  run the following command in one of your Praefect pods:

  ```shell
  /usr/local/bin/praefect -config /etc/gitaly/config.toml dataloss
  ```

- You have a complete and tested backup.

Repository data can be restored by following the
[managing persistent volumes documentation](../advanced/persistent-volumes/index.md),
which provides guidance on reconnecting existing PersistentVolumeClaims to previous
PersistentVolumes.

A key step of the process is setting the old persistent volumes' `persistentVolumeReclaimPolicy`
to `Retain`. If this step is missed, actual data loss will likely occur.

After reviewing the documentation, there is a scripted summary of the procedure
[in a comment on one of a related issues](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2532#note_506467539).

Having reconnected the PersistentVolumes, it is likely that all your repositories
will be set `read-only` by Praefect, as shown by running the following in a
Praefect container:

```plaintext
praefect -config /etc/gitaly/config.toml dataloss
```

If all your Git repositories are in sync across the old persistent volumes, use the
`accept-dataloss` procedure for each repository to fix the Gitaly Cluster in Praefect.

[We have an issue open](https://gitlab.com/gitlab-org/gitaly/-/issues/3448) to verify
that this is the best approach to fixing Praefect.
