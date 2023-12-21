#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

echo "this script is started executed at $TIMESTAMP" &>> $LOGFILE

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB" 

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling MongoDB" 

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB"