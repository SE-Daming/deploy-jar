#!/bin/bash
JAP_NAME=cms-0.0.1-SNAPSHOT.jar
JAR_PATH=/data/webroot/nyycmsserver/admin-api/
#PORT=8060
ACTIVE=dev,static
LOG_PATH=/data/webroot/nyycmsserver/admin-api/
LOG_NAME=run.out

cd `dirname $0`
#使用说明，用来提示输入参数
usage() {
    echo "Usage: sh 执行脚本.sh [start|stop|restart|status]"
    exit 1
}
#检查程序是否在运行
is_exist(){
  pid=`ps -ef|grep $JAP_NAME|grep -v grep|awk '{print $2}' `
  #如果不存在返回1，存在返回0
  if [ -z "${pid}" ]; then
   return 1
  else
    return 0
  fi
}

#启动方法
start(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "${JAP_NAME} is already running. pid=${pid} ."
  else
    #nohup java -jar -Dserver.port=${PORT} -Dspring.profiles.active=${ACTIVE} ${JAR_PATH}${JAP_NAME} > ${LOG_PATH}${LOG_NAME} 2>&1&
	nohup java  -Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.port=8877   \
-Dcom.sun.management.jmxremote.ssl=false   \
-Dcom.sun.management.jmxremote.authenticate=false   \
-Djava.rmi.server.hostname=10.0.5.17  \
-Dcom.sun.management.jmxremote.rmi.port=8877  \
  -Xms512m -Xmx4096m -jar ${JAR_PATH}${JAP_NAME} --spring.profiles.active=${ACTIVE} -Dspring.config.location=${JAR_PATH}config/application.yml >> run.log 2>&1 &
    echo "${JAP_NAME} is start success"
    #tail -f fileserver-web.out
  fi
}


#停止方法
stop(){
  is_exist
  if [ $? -eq "0" ]; then
    kill -9 $pid
    echo "${JAP_NAME} is  stoped"
  else
    echo "${JAP_NAME} is not running"
  fi
}


#输出运行状态
status(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "${JAP_NAME} is running. Pid is ${pid}"
  else
    echo "${JAP_NAME} is NOT running."
  fi
}

#重启
restart(){
  stop
  start
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
  "start")
    start
    ;;
  "stop")
    stop
    ;;
  "status")
    status
    ;;
  "restart")
    restart
    ;;
  *)
    usage
    ;;                                                                                                                                                
esac

