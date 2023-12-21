#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0.$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

echo "This script is started executed at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$B ERROR $N...$R Please run this script with Root user $N"
    exit 1
else
    echo -e "$Y This is Root user $N"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Installing remi release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "allowing remote connections"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabled redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "starting redis"