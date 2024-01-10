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

dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disable mysql version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copying mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting mysql root password"