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

if [ "$KIBANA_ELASTICSEARCH_TLS" = true ]; then
	echo -e "elasticsearch.ssl.certificateAuthorities: $MESOS_SANDBOX/.ssl/ca-bundle.crt\n" >> $KIBANA_YAML
fi

if [ "$OPENDISTRO_SECURITY_ENABLED" = true ]; then
	$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana-plugin install file://$MESOS_SANDBOX/opendistroSecurityKibana-${OPENDISTRO_SECURITY_VERSION}.zip
cat << EOF >> $KIBANA_YAML
elasticsearch.username: $KIBANA_USER
elasticsearch.password: $KIBANA_PASSWORD
opendistro_security.multitenancy.enabled: false
EOF

	if [ "$OPENDISTRO_OPENID_ENABLED" = true ]; then
		echo -e "\nopendistro_security.auth.type: openid" >> $KIBANA_YAML
		echo -e "opendistro_security.openid.connect_url: $OPENDISTRO_OPENID_CONNECT_URL" >> $KIBANA_YAML
		echo -e "opendistro_security.openid.client_id: $OPENDISTRO_OPENID_CLIENT_ID" >> $KIBANA_YAML
		echo -e "opendistro_security.openid.client_secret: $OPENDISTRO_OPENID_CLIENT_SECRET" >> $KIBANA_YAML
		if [ "$OPENDISTRO_OPENID_ROOT_CA_ENABLED" = true ]; then
			echo -e "opendistro_security.openid.root_ca: $MESOS_SANDBOX/openid_ca.pem" >> $KIBANA_YAML
		fi
		if [ -n "$OPENDISTRO_OPENID_LOGOUT_URL" ]; then
			echo -e "opendistro_security.openid.logout_url: $OPENDISTRO_OPENID_LOGOUT_URL" >> $KIBANA_YAML
		fi
		if [ -n "$OPENDISTRO_OPENID_BASE_REDIRECT_URL" ]; then
			echo -e "opendistro_security.openid.base_redirect_url: $OPENDISTRO_OPENID_BASE_REDIRECT_URL" >> $KIBANA_YAML
		fi
	fi
fi

$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana-plugin install file://$MESOS_SANDBOX/opendistroAlertingKibana-${OPENDISTRO_ALERTING_VERSION}.zip
$MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana-plugin install file://$MESOS_SANDBOX/opendistroIndexManagementKibana-${OPENDISTRO_SECURITY_VERSION}.zip

exec $MESOS_SANDBOX/kibana-$ELASTIC_VERSION-linux-x86_64/bin/kibana
