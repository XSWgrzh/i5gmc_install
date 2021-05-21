#!/bin/bash

# Java
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64
#export JRE_HOME=${JAVA_HOME}/jre

# Apps Info
#
APP_HOME=/usr/local/i5gmcApp

APP=$1

APP_NAME=${APP}-0.0.1-SNAPSHOT.jar

APP_OUT=${APP}.out


# Shell Info


usage() {
    echo "Usage: sh boot [APP_NAME] [start|stop|restart|status]"
    exit 1
}


is_exist(){
        # PID
        PID=$(ps -ef |grep ${APP_NAME} | grep -v $0 |grep -v grep |awk '{print $2}')
        # -z "${pid}"pid10
        if [ -z "${PID}" ]; then
                # 1
                return 1
        else
                # 0
                return 0
        fi
}

# 
start(){
        is_exist
        if [ $? -eq "0" ]; then
                echo "${APP_NAME} is already running, PID=${PID}"
        else
                rm -f log/${APP_OUT}
                nohup java -DGW_HOME=${APP_HOME} -DNACOS_NAMESPACE=i5gmcSpace  -Xms512m -Xmx512m -Xmn256m   -DAPP_NAME=${APP} -Dloader.path=${APP_HOME}/app/lib/ -jar ${APP_HOME}/app/${APP_NAME} --spring.cloud.nacos.config.server-addr=172.16.70.78:8848 >> log/${APP_OUT} 2>&1 &
                #PID=$(echo $!)
                #sleep15AppName
								sleep 2

								if test $(pgrep -f $APP_NAME|wc -l) -eq 0
								then
   								echo "Start Failed"
								else
   								echo "${APP_NAME} start success, PID=$!"
								fi
        fi
}

# 
stop(){
        is_exist
        if [ $? -eq "0" ]; then
                kill -9 ${PID}
                echo "${APP_NAME} process stop, PID=${PID}"
        else
                echo "There is not the process of ${APP_NAME}"
        fi
}
# 
restart(){
        stop
        sleep 5
        start
}

# 
status(){
        is_exist
        if [ $? -eq "0" ]; then
                echo "${APP_NAME} is running, PID=${PID}"
        else
                echo "There is not the process of ${APP_NAME}"
        fi
}

case $2 in
"start")
        start
        ;;
"stop")
        stop
        ;;
"restart")
        restart
        ;;
"status")
       status
        ;;
        *)
        usage
        ;;
esac
