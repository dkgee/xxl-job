#! /bin/sh

cd `dirname $0`

CUR_SHELL_DIR=`pwd`

JAR_NAME=""
JAR_FILE=$(ls ${CUR_SHELL_DIR})
for fileName in ${JAR_FILE}
do
    if [[ ${fileName} == *.jar ]]; then
        JAR_NAME=${fileName}
    fi
done

if [[ ${JAR_NAME} == "" ]];then
    echo "Error: Not found jar package"
    exit 1
fi

JAR_PATH=${CUR_SHELL_DIR}/${JAR_NAME}
JAVA_MEM_OPTS=" -server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError"
CUR_EVN="prod"

function echo_help()
{
    echo -e "syntax: sh start.sh start|stop|restart|status  dev|prod|zprod"
}

## start application
function appStart()
{
    if [ -z $1 ];then
        echo -e "Syntax: use default spring profile: prod"
    else
       echo -e "Syntax: use spring profile: $1"
       CUR_EVN="$1"
    fi

    SPRING_PROFILES_ACTIV="-Dspring.profiles.active=$CUR_EVN"

    # check server
    PIDS=`ps --no-heading -C java -f --width 1000 | grep $JAR_NAME | awk '{print $2}'`
    if [ -n "$PIDS" ]; then
        echo -e "ERROR: The $JAR_NAME already started and the PID is ${PIDS}."
        exit 1
    fi

    echo "Starting the $JAR_NAME..."
    # start
    # docker environment check
    dockerenv=`ls /.dockerenv`
    if [ -z "$dockerenv" ];then
        echo "not docker environment, use nohup command to start app."
        nohup java $JAVA_MEM_OPTS -jar $SPRING_PROFILES_ACTIV $JAR_PATH >> /dev/null 2>&1 &
    else
        echo "it's docker environment, use java command to start app."
        java $JAVA_MEM_OPTS -jar $SPRING_PROFILES_ACTIV $JAR_PATH
    fi

    COUNT=0
    while [ $COUNT -lt 1 ]; do
        sleep 1
        COUNT=`ps  --no-heading -C java -f --width 1000 | grep $JAR_NAME | awk '{print $2}' | wc -l`
        if [ $COUNT -gt 0 ]; then
            break
        fi
    done
    PIDS=`ps  --no-heading -C java -f --width 1000 | grep $JAR_NAME | awk '{print $2}'`
    echo "${JAR_NAME} Started and the PID is ${PIDS}."
    echo "You can check the log file in ${LOG_PATH} for details."
}

## stop application
function appStop()
{
    PIDS=`ps --no-heading -C java -f --width 1000 | grep $JAR_NAME | awk '{print $2}'`
    if [ -z "$PIDS" ]; then
        echo "ERROR:The $JAR_NAME does not started!"
        exit 1
    fi

    echo -e "Stopping the $JAR_NAME..."

    for PID in $PIDS; do
        kill $PID > /dev/null 2>&1
    done

    COUNT=0
    while [ $COUNT -lt 1 ]; do
        sleep 1
        COUNT=1
        for PID in $PIDS ; do
            PID_EXIST=`ps --no-heading -p $PID`
            if [ -n "$PID_EXIST" ]; then
                COUNT=0
                break
            fi
        done
    done

    echo -e "${JAR_NAME} Stopped and the PID is ${PIDS}."
}

## look up application status
function appStatus()
{
    PIDS=`ps --no-heading -C java -f --width 1000 | grep $JAR_NAME | awk '{print $2}'`
    if [ -z "$PIDS" ]; then
        echo "Syntax: $JAR_NAME is stop."
        exit 1
    else
        echo "Syntax: $JAR_NAME is running, process id: $PIDS"
    fi
}

## restart application
function appRestart()
{
    PIDS=`ps --no-heading -C java -f --width 1000 | grep $JAR_NAME | awk '{print $2}'`
    if [ -z "$PIDS" ]; then
        echo "Syntax:The $JAR_NAME does not started!"
    else
        for PID in $PIDS; do
            kill $PID > /dev/null 2>&1
        done

        COUNT=0
        while [ $COUNT -lt 1 ]; do
            sleep 1
            COUNT=1
            for PID in $PIDS ; do
                PID_EXIST=`ps --no-heading -p $PID`
                if [ -n "$PID_EXIST" ]; then
                    COUNT=0
                    break
                fi
            done
        done
    fi

    appStart $1
}

if [ -z $1 ];then
    echo_help
    exit 1
elif [ "$1" == "start" ];then
    appStart $2
elif [ "$1" == "stop" ];then
    appStop
elif [ "$1" == "restart" ];then
    appRestart $2
elif [ "$1" == "status" ];then
    appStatus $2
else
    echo_help
    exit 1
fi
