#!/bin/bash


I5GMC_INSTALL_HOME=$(cd `dirname $0`; pwd)
source ${I5GMC_INSTALL_HOME}/i5gmc_config.sh
##################1. install docker fot all hosts
echo -n " 1.Are you sure to install [docker]? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then

	for key in `get_hosts`
	do
		ansible-playbook ${I5GMC_INSTALL_HOME}/1.base/i5gmc_playbook_docker.yml --extra-vars "\
			myhost=${key} \
			ansible_become_pass=${HOST_PASS}\
            DOCKER_LOCAL_REGISTRY=${DOCKER_LOCAL_REGISTRY} \
			DOCKER_REMOTE_REGISTRY=${DOCKER_REMOTE_REGISTRY}"

	done
	echo "$(date +'%T') install docker success"
	echo ""
	sleep 3
fi

echo -n " 2.Are you sure to init docker swarm? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then
    sudo  docker swarm leave --force
    result=$(sudo docker swarm  init | sed -n '5p' | awk '{print $5}')

	for key in `get_hosts`
	do

	   	if [ $key == ${HOST_LEADER} ];then
	        continue ;
	    fi
		ansible-playbook ${I5GMC_INSTALL_HOME}/1.base/i5gmc_playbook_swarm.yml --e "\
			myhost=${key}  \
			host_leader=${HOST_LEADER}  \
			swarm=${result}  \
			ansible_become_pass=${HOST_PASS} \
            DOCKER_LOCAL_REGISTRY=${DOCKER_LOCAL_REGISTRY} \
			DOCKER_REMOTE_REGISTRY=${DOCKER_REMOTE_REGISTRY}"

	done

    sudo docker network rm i5gmc_net
    sudo docker network create --driver overlay --attachable i5gmc_net

	echo "$(date +'%T') install docker success"
	echo ""
	sleep 3
fi