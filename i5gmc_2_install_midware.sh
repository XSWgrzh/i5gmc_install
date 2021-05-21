#!/bin/bash

set -e

I5GMC_INSTALL_HOME=$(cd `dirname $0`; pwd)
source ${I5GMC_INSTALL_HOME}/i5gmc_config.sh

install_midware_images(){
	echo "$(date +'%T') Install all midware docker images."
	cd ${I5GMC_INSTALL_HOME}/2.midware
	midwares=`get_midwares`
	for midware in ${midwares}
	do
		echo -n ">> Install midware docker image: ${midware}? (Y/n) "
		read option
		if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then
			ansible-playbook -v playbook/${midware}.yml -i hosts/i5gmc \
				--extra-vars "ansible_become_pass=${HOST_PASS} docker_registry=${DOCKER_REMOTE_REGISTRY}"
			echo "$(date +'%T') Install midware docker image: ${midware} successfully."
			sleep 1
		fi
	done
	cd ${I5GMC_INSTALL_HOME}
	sleep 1
	echo ""
}

init_mysql(){

    echo "init mysql "
    sudo docker exec -i i5gmc_mysql mysql -uroot -pi5gmc9528 < ./3.sql/i5gmc.sql
    sudo docker exec -i i5gmc_mysql mysql -uroot -pi5gmc9528 < ./3.sql/i5gmc_sql_update.sql
    sudo docker exec -i i5gmc_mysql mysql -uroot -pi5gmc9528 < ./3.sql/nacos.sql

}

install_midware_images



