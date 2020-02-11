#!/bin/bash

KIBANA_YAML=$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/config/kibana.yml

cat <<EOF > $KIBANA_YAML
elasticsearch.hosts: $ELASTICSEARCH_URL
server.host: 0.0.0.0
server.port: 5601
EOF

echo -e "\n" >> $KIBANA_YAML
if [ -n  "${CUSTOM_YAML_BLOCK_BASE64}" ]; then
	echo "$CUSTOM_YAML_BLOCK_BASE64" | base64 -d >> $KIBANA_YAML
fi
echo -e "\n" >> $KIBANA_YAML

cat <<EOF >> $KIBANA_YAML
xpack.security.enabled: false
xpack.reporting.enabled: false
xpack.monitoring.enabled: false
xpack.spaces.enabled: false
EOF

cat <<EOF >> $KIBANA_YAML
elasticsearch.username: $KIBANA_USER
elasticsearch.password: $KIBANA_PASSWORD
opendistro_security.multitenancy.enabled: false
EOF

if [ "$KIBANA_ELASTICSEARCH_TLS" = true ]; then
	echo -e "\nelasticsearch.ssl.certificateAuthorities: $MESOS_SANDBOX/.ssl/ca-bundle.crt\n" >> $KIBANA_YAML
fi

if [ "$OPENDISTRO_SECURITY_ENABLED" = true ] then 
	$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana-plugin install file://$MESOS_SANDBOX/opendistro_security_kibana_plugin-${OPENDISTRO_SECURITY_VERSION}.zip
else
	sed -i '/^opendistro_security\.multitenancy\.enabled.*$/s/^/#/' $KIBANA_YAML
fi  

exec $MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana
