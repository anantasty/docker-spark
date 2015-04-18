#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

RUN sed -i '/localhost/d' /etc/hosts

service ssh start
$HADOOP_PREFIX/sbin/start-dfs.sh > /var/log/start-dfs.log
$HADOOP_PREFIX/sbin/start-yarn.sh > /var/log/start-yarn.log

supervisord

CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
    while true; do sleep 1000; done
	# service sshd stop
	# /usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi
