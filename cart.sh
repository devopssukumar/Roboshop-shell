#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/temp/$0.$TIMESTAMP.log"
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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exist...$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart application"

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting cart"