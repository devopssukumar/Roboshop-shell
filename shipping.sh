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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing maven"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding Roboshop user"
else
    echo -e "Roboshop user is already exist...$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping"

cd /app
VALIDATE $? "Moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying shipping service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.aarchdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loading the schema to Database"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping"