#!/bin/bash

# I5GMC for Linux installation script
set -e
I5GMC_INSTALL_HOME=$(cd `dirname $0`; pwd)
source ${I5GMC_INSTALL_HOME}/i5gmc_config.sh

##################################install ansible###################################################
echo -n " 1.Are you sure to install [ansible]? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then

	sudo yum install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.9.9-1.el7.ans.noarch.rpm -y
	which ansible
	ansible --version
	echo ""
	sleep 3
fi


##################config /etc/hosts & /etc/ansible/hosts ############################################
echo -n "2.Are you sure to config \"/etc/hosts\" and \"/etc/ansible/hosts\"? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then
	### config for /etc/hosts
	sudo sh -c "echo \"\" >> /etc/hosts"
	for h in ${HOST_ARRAY[@]}
	do
		sudo sh -c "echo \"${h##*:}  ${h%%:*}\" >> /etc/hosts"
	done
	sudo sh -c "echo \"\" >> /etc/hosts"
	cat /etc/hosts
	echo "$(date +'%T') \"/etc/hosts\" is updated successfully."
	echo ""
	sleep 2


	### config for /etc/ansible/hosts
	sudo sh -c "echo \"\" >> /etc/ansible/hosts"
	sudo sh -c "echo \"[i5gmc]\" >> /etc/ansible/hosts"
	for h in `get_hosts`
	do
		sudo sh -c "echo $h >> /etc/ansible/hosts"
	done
	cat /etc/ansible/hosts
	echo "$(date +'%T') \"/etc/ansible/hosts\" is updated successfully."
	echo ""
	sleep 2
fi

################## 6.modify hostname for each host
echo -n " 6.Are you sure to modify hostname for each host? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then
	for key in `get_hosts`
	do
		ansible-playbook ${I5GMC_INSTALL_HOME}/1.base/i5gmc_playbook_hostname.yml --extra-vars "myhost=${key} ansible_become_pass=${HOST_PASS}"
	done
	ansible all -m shell -a 'hostname'
	echo "$(date +'%T') modify hostname for each host successfully."
	echo ""
	sleep 3
fi

##################4. create public-key
echo -n "3.Are you sure to config public-key authorization? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then

	## generate new public-key
	if [ ! -f $HOME/.ssh/id_rsa ];then
		sudo ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
	fi

	## sshpass + ssh-copy-id
	for tmp_host in `get_hosts`
	do
	    set +e
	    ssh-copy-id -i $HOME/.ssh/id_rsa.pub ${HOST_USER}@${tmp_host}
	    #echo "sshpass -p ${HOST_PASS} ssh-copy-id ${HOST_USER}@${tmp_host}"
	    #sudo sshpass -p ${HOST_PASS} ssh-copy-id ${HOST_USER}@${tmp_host}

	    set -e
	done

	## verify
	ansible all -m shell -a 'uptime'

	echo "create public-key successfully."
	echo ""
	sleep 3
fi

################## update /etc/hosts for all hosts
echo -n "4.Are you sure to update \"/etc/hosts\" for all hosts? (Y/n) "
read option
if [ "${option}" = "y" ] || [ "${option}" = "Y" ] || [ "${option}" = "" ];then
	for key in `get_hosts`
	do
	     ansible-playbook ${I5GMC_INSTALL_HOME}/1.base/i5gmc_playbook_hosts.yml --extra-vars "myhost=${key} ansible_become_pass=${HOST_PASS}"
	done
	echo "$(date +'%T') update \"/etc/hosts\" for all hosts successfully."
	echo ""
fi


