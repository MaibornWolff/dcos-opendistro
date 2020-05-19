# Opendistro for DC/OS

A [DC/OS](https://dcos.io/) Framework for [Open Distro for Elasticsearch](https://opendistro.github.io/for-elasticsearch/).

(!) This is a work-in-progress that has not been tested in production. Use at your own risk and only in test clusters.

## Getting started

At the moment this framework is not yet available in the [DC/OS Universe](https://universe.dcos.io/). As such you will have to build the package yourself.

### Requirements

* dcos cli installed and configured for your cluster
* DC/OS Enterprise with at least version 1.12 (tested on 1.12 and 1.13, 2.0 could work but no guarantees)
* [dcosdev fork](https://github.com/swoehrl-mw/dcosdev) installed
* Either minio installed and configured in your cluster or access to an S3 bucket (aws cli must be configured)
* Docker installed on your development machine

### Steps

For elasticsearch change into the `elastic` folder. Then

* Build the elastic scheduler package: `dcosdev build java` (will launch gradle in a docker container)
* Upload the elastic package. Either
  * with minio: `dcosdev up`  (environment variables `MINIO_HOST`, `MINIO_ACCESS_KEY` and `MINIO_SECRET_KEY` must be set)
  * with S3: `dcosdev release 0 <bucket-name>`.
* Add the repo-file to your clusters package repositories (e.g. for S3: `dcos package repo add opendistro --index=0 https://<bucket-name>.s3.amazonaws.com/packages/opendistro/0.2.0-1.7.0/opendistro-repo.json`)
* Prepare security config (see [opendistro documentation](https://opendistro.github.io/for-elasticsearch-docs/docs/security-configuration/yaml/)), place it into a folder called `securityconfig`, zip that folder and upload it to a place where it is downloadable via HTTP from inside the cluster (e.g. an S3 bucket). As a starting-point you can use the example from the [opendistro-security github-repo](https://github.com/opendistro-for-elasticsearch/security/tree/master/securityconfig)
* Create serviceaccount for the framework to use (for TLS certificates to all elastic nodes)
* Prepare `options.json` (see example in `example/options-elastic.json`)
* Install package with your `options.json`

For kibana change into the `kibana` folder. Then

* Upload the kibana package. Either
  * with minio: `dcosdev up`  (environment variables `MINIO_HOST`, `MINIO_ACCESS_KEY` and `MINIO_SECRET_KEY` must be set)
  * with S3: `dcosdev release 0 <bucket-name>`.
* Add repo-file to your clusters package repositories (e.g. for S3: `dcos package repo add opendistro --index=0 https://<bucket-name>.s3.amazonaws.com/packages/opendistro-kibana/0.2.0-1.7.0/opendistro-kibana-repo.json`)
* Create secrets with username and password to use for authentication against elasticsearch.
* Prepare `options.json` (see example in `example/options-kibana.json`)
* Install package with your `options.json`

You can also use [dcos-deploy](https://github.com/MaibornWolff/dcos-deploy) for deployment (everything except building and uploading the packages). All you need is in the `example` folder. Make the necessary changes and then run `dcos-deploy apply`.

## Limitations

* Opendistro Performance analyzer is not supported.
* Opendistro specifc configuration options are not yet available as package options. Use the `elasticsearch.custom_elasticsearch_yml` option to configure opendistro.
* Opendistro security multitenancy is not supported.

## Contributing

If you find a bug or have a feature request, please open an issue in Github. Or, if you want to contribute something, feel free to open a pull request.

## Acknowledgements

This framework is based heavily on the [DC/OS Elastic service](https://github.com/mesosphere/dcos-elastic-service/) and was developed using a fork of [dcosdev](https://github.com/mesosphere/dcosdev). Thanks to Mesosphere for providing these tools.

## Disclaimer

This project is not associated with Elastic or Amazon in any form.

This software is provided as-is. Use at your own risk.
