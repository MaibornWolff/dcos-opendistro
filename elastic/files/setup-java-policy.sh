#!/bin/bash

JAVA_POLICY_FILE=$JAVA_HOME/conf/security/java.policy

cat <<EOF >> $JAVA_POLICY_FILE

grant {
    permission java.io.FilePermission "${MESOS_SANDBOX}", "read";
    permission java.io.FilePermission "${MESOS_SANDBOX}/-", "read";
};

EOF
