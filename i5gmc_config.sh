#!/bin/bash

export HOST_USER=test
export HOST_PASS=test

export DOCKER_LOCAL_REGISTRY=p1:5000
export DOCKER_REMOTE_REGISTRY=docker.jiaxincloud.com:5000

export HOST_LEADER=p1

export HOST_ARRAY=(
"p1:172.16.169.153"
"p2:172.16.169.154"
"p3:172.16.169.155"
)


export DOCKER_MIDWARE_ARRAY=(
#"i5gmc_nginx:1.19.7.1"
"i5gmc_mongo:4.4.4.1"
#"i5gmc_redis:5.0.0.1"
#"i5gmc_sentinel:5.0.0.1"
#"i5gmc_mysql:5.7.32.2"
#"i5gmc_nacos:1.3.0.2"
)

export DOCKET_I5GMC_JDK=(
"i5gmc_jdk:8.2.11.1"
)

export START_APP=(
"i5gmc_robot"
"i5gmc_maapgw"
"i5gmc_auth"
"i5gmc_config"
"i5gmc_devcenter"
"i5gmc_devmgr"
"i5gmc_imserver"
"i5gmc_openapi"
"i5gmc_oss"
"i5gmc_task"
"i5gmc_imserver"
"i5gmc_h5gw"
)

function get_hosts() {
    for h in ${HOST_ARRAY[@]}
    do
        echo ${h%%:*}
    done
}

get_midwares() {
	for h in ${DOCKER_MIDWARE_ARRAY[@]}
	do
		echo ${h%%:*}
	done
}
