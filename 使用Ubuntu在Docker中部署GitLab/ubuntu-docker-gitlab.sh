#!/bin/bash
#########################################################
# Function :Deploy GitLab by Ubuntu Docker              #
# Platform :Ubuntu Linux Based Platform                 #
# Version  :1.0                                         #
# Date     :2023-11-28                                  #
# Author   :ShawnGao                                    #
# Contact  :shawngao.org@outlook.com                    #
#########################################################
# Set dockerhub proxy
echo -e '\e[1;34mSetting Docker proxy...\e[0m'
echo '{ "registry-mirrors": [ "https://dockerproxy.com" ] }' > /etc/docker/daemon.json
if [ $? -eq 0 ]; then
	echo -e '[  \e[1;32mOK\e[0m  ]'
else
	echo -e '[\e[1;31mFAILED\e[0m]'
	echo -e '\e[1;31mNOTE: If you are in mainland China and do not set up a mirror warehouse agent, this will cause a very slow mirror pulling speed.\e[0m'
	echo -e '\e[1;32mThis error usually does not affect the execution of the script. :)\e[0m'
fi
# Restart Docker service
echo -e '\e[1;34mPress the Enter "y" to restart the Docker service(y/N): \e[0m'
read confirm
case $confirm in
	Y|y)
		systemctl restart docker
		if [ $? -eq 0 ]; then
			echo -e '[  \e[1;32mOK\e[0m  ]'
		else
			echo -e '[\e[1;31mFAILED\e[0m]'
		fi
		;;
	N|n)
		echo -e '[\e[1;31mCANCELLED\e[0m]'
		exit 0
		;;
	*)
		echo -e '[\e[1;31mERROR INPUT\e[0m]'
		exit -1
		;;
esac
# Pull GitLab Docker image
echo -e '\e[1;34mPulling GitLab Enterprise Edition...'
docker pull gitlab/gitlab-ee:latest
if [ $? -eq 0 ]; then
	docker image ls | grep gitlab.*latest
	if [ $? -eq 0 ]; then
		echo -e '[  \e[1;32mOK\e[0m  ]'
	else
		echo -e '[\e[1;31mFAILED\e[0m]'
		echo -e '\e[1;31mUnknown Error.\e[0m'
		exit -1
	fi
else
        echo -e '[\e[1;31mFAILED\e[0m]'
        echo -e '\e[1;31mERR: Unable to pull GitLab Docker image.\e[0m'
	exit -1
fi
read -r -p " - Config mapping location (eg. /mnt/vdb/gitlab-ee/config): " config
read -r -p " - Log mapping location (eg. /mnt/vdb/gitlab-ee/logs): " log
read -r -p " - Data mapping location (eg. /mnt/vdb/gitlab-ee/data): " data
mkdir -p $config
mkdir -p $log
mkdir -p $data
read -r -p " - Host name (eg. gitlab.example.com): " host
echo -e '\e[1;31mNOTE: In order to prevent port conflicts of 80, 443 and 22, please set the following ports to other values (20000 < your port < 65535)\e[0m'
echo -e '\e[1;34mTip: Using the reverse proxy of "NGINX", you can still use the HTTP(S) port to access the service, and you can load the SSL certificate and domain name.\e[0m'
read -r -p " - HTTPS port (eg. 25565): " https
read -r -p " - HTTP port (eg. 25566): " http
read -r -p " - SSH port (eg. 25567): " ssh_port
read -r -p " - GitLab Docker container name (eg. gitlab): " name
echo -e '\e[1;34mRunning GitLab...\e[0m'
docker run --detach --hostname $host -p $https:443 -p $http:80 -p $ssh_port:22 --name $name --restart always -v $config:/etc/gitlab -v $log:/var/log/gitlab -v $data:/var/opt/gitlab --shm-size 256m gitlab/gitlab-ee:latest
if [ $? -eq 0 ]; then
        echo -e '[  \e[1;32mOK\e[0m  ]'
else
        echo -e '[\e[1;31mFAILED\e[0m]'
        echo -e '\e[1;31mERR: Unable to pull GitLab Docker image.\e[0m'
        exit -1
fi
echo -e '\e[1;34mNOTE: It will take several minutes for GitLab to fully start. Please wait patiently. At this time, you can execute "docker ps -a" to view the container status. You can access it after the container status is "healthy".\e[0m'
echo -e '\e[1;32mNOTE: After startup, execute the following command to view the initial password.\e[0m'
echo "sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password"

