#!/usr/bin/env bash

if [ -n  "${CUSTOM_LOG4J2_PROPERTIES_BASE64}" ]; then
  CUSTOM_LOG4J2_PROPERTIES="$(echo "${CUSTOM_LOG4J2_PROPERTIES_BASE64}" | base64 -d)"
  echo "${CUSTOM_LOG4J2_PROPERTIES}" >> "${MESOS_SANDBOX}/elasticsearch-${ELASTIC_VERSION}/config/log4j2.properties"
fi
