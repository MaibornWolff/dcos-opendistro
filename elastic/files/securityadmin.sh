#!/bin/sh
export JAVA_HOME=$(ls -d $MESOS_SANDBOX/jdk*/)
export JAVA_HOME=${JAVA_HOME%/}
export PATH=$(ls -d $JAVA_HOME/bin):$PATH
export JAVA_OPTS="-Xms256M -Xmx256M -XX:-HeapDumpOnOutOfMemoryError"
export ADMINTOOL=elasticsearch-${ELASTIC_VERSION}/plugins/opendistro_security/tools/securityadmin.sh
chmod +x $ADMINTOOL

TOOL_ARGS="-icl -nhnv -ks $MESOS_SANDBOX/admin.keystore -kspass notsecure -ts $MESOS_SANDBOX/admin.truststore -tspass notsecure -cd securityconfig -h master.{{CLUSTER_NAME_DOMAIN}}.l4lb.thisdcos.directory -p 9300"

if [ -n ${SECURITY_CONFIG_URL} ]; then
    FILENAME=$(basename $SECURITY_CONFIG_URL)

    rm -rf securityconfig*
    wget ${SECURITY_CONFIG_URL}
    unzip $FILENAME
    rm $FILENAME

    if [ -n $INITIAL ]; then
        # Try to apply the config until it succeeds
        count=0
        until $ADMINTOOL $TOOL_ARGS || (( count++ >= 20 ))
        do 
            sleep 20
        done
    else
        $ADMINTOOL $TOOL_ARGS
    fi
fi