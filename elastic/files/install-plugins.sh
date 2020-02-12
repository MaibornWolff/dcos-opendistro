#!/bin/bash

IFS=","
PLUGINS=""
PROXY_ES_JAVA_OPTS=""

# If a plugin fails to install, exit the script immediately with an error
set -e

if [ -n "${ELASTICSEARCH_PLUGINS}" ]; then
  PLUGINS="${ELASTICSEARCH_PLUGINS}"
fi

if [ -n "${PLUGIN_HTTP_PROXY_HOST}" ] && [ -n "${PLUGIN_HTTP_PROXY_PORT}" ]; then
  PROXY_ES_JAVA_OPTS="-Dhttp.proxyHost=${PLUGIN_HTTP_PROXY_HOST} -Dhttp.proxyPort=${PLUGIN_HTTP_PROXY_PORT}"
fi

if [ -n "${PLUGIN_HTTPS_PROXY_HOST}" ] && [ -n "$PLUGIN_HTTPS_PROXY_PORT" ]; then
  PROXY_ES_JAVA_OPTS="${PROXY_ES_JAVA_OPTS} -Dhttps.proxyHost=${PLUGIN_HTTPS_PROXY_HOST} -Dhttps.proxyPort=${PLUGIN_HTTPS_PROXY_PORT}"
fi

if [ -n "${PROXY_ES_JAVA_OPTS}" ]; then
  export ES_JAVA_OPTS="${ES_JAVA_OPTS} ${PROXY_ES_JAVA_OPTS}"
fi

if ls $MESOS_SANDBOX/opendistro-job-scheduler*.zip >/dev/null 2>&1; then
  echo "Installing plugin opendistro-job-scheduler first as it is a dependency for other plugins"
  ./elasticsearch-${ELASTIC_VERSION}/bin/elasticsearch-plugin install --batch file://$(ls $MESOS_SANDBOX/opendistro-job-scheduler*.zip)
fi

for pluginfile in $MESOS_SANDBOX/opendistro*.zip; do
  if [[ ! $pluginfile =~ .*job-scheduler.* ]]; then
    echo "Installing plugin: $pluginfile"
    ./elasticsearch-${ELASTIC_VERSION}/bin/elasticsearch-plugin install --batch file://${pluginfile}
  fi
done

for PLUGIN in ${PLUGINS}; do
  echo "Installing plugin: ${PLUGIN}"
  "./elasticsearch-${ELASTIC_VERSION}/bin/elasticsearch-plugin" install --batch "${PLUGIN}"
done
