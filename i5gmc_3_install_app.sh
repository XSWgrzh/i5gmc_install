#!/bin/bash

set -e

I5GMC_INSTALL_HOME=$(cd `dirname $0`; pwd)
source ${I5GMC_INSTALL_HOME}/i5gmc_config.sh

install_app_images(){
	echo "$(date +'%T') Install all app docker images."
	cd ${I5GMC_INSTALL_HOME}/2.midware

    echo -n ">> copy app jar? (y/n) "
    read option
    if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then
        ansible-playbook -v playbook/i5gmc_app.yml -i hosts/i5gmc \
        --extra-vars "ansible_become_pass=${HOST_PASS} docker_registry=${DOCKER_REMOTE_REGISTRY}"
    fi
    echo "$(date +'%T') copy  app  jar success."

    while (true)
    do
        echo -n ">> which host to install app: ? (p1/p2../break) "
        read host
        if [ $host == "break" ];then
            break;
        fi

        echo -n ">> which one app to install: ? (all/i5gmc_robot/i5gmc_maapgw/i5gmc_auth..) "
        read option

        if [ "${option}" = "all" ] || [ "${option}" = "ALL" ] || [ "${option}" = "" ];then
            for app in ${START_APP[@]}
            do
                ansible-playbook -v playbook/i5gmc_app_start.yml -i hosts/i5gmc \
                --extra-vars "ansible_become_pass=${HOST_PASS} docker_registry=${DOCKER_REMOTE_REGISTRY} app_name=${app} host=${host}"
                 echo "$(date +'%T') Install midware docker image: ${app} successfully."
                sleep 1
            done

        else
            for app in ${option[@]}
            do
                ansible-playbook -v playbook/i5gmc_app_start.yml -i hosts/i5gmc \
                --extra-vars "ansible_become_pass=${HOST_PASS} docker_registry=${DOCKER_REMOTE_REGISTRY} app_name=${app} host=${host}"
                 echo "$(date +'%T') Install midware docker image: ${app} successfully."
                sleep 1
            done
        fi
    done
	cd ${I5GMC_INSTALL_HOME}
	sleep 1
	echo ""
}

install_app_images
