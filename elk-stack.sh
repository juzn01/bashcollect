#!/bin/bash

echo "#################################################################"
echo "#Script Name  :     script install ELK version 6 on centos 7    #"
echo "#Description  :auto install and configure ELK version 6 Basic   #"
echo "#Args         :                                                 #"
echo "#Author       :Nguyen Duc Huy                                   #"
echo "#Email        :tiedoll96@gmail.com                              #"
echo "#website      :https://www.quantrimangdn.com/                   #"
echo "#################################################################"

sleep 3
echo "###-------- Update server ----------------------- ###"
sleep 1

yum update -y
echo "###-------- Update server OK ----------------------- ###"
yum install git -y 
sleep 2
yum install net-tools -y
echo "###-------- disable SELINUX ----------------------- ###"
setenforce 0

sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && cat /etc/selinux/config

sleep 1

echo "###-------- stop & disable firewall --------------- ###"
systemctl stop firewalld
systemctl disable firewalld

echo "###-------- install java 8 ------------------------	###"
sleep 1
yum install java-1.8.0-openjdk -y

sleep 2
java -version
sleep 2
echo "###------- install && configure Elasticsearch ----- ###"
sleep 2
rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch

sleep 1

cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sleep 1

yum install elasticsearch -y

sleep 1

echo "###-------- config elasticsearch use IPV4  --------------- ###"

sleep 3

sed -i 's/^#network.host:.*/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#http.port: 9200/http.port: 9200/'g /etc/elasticsearch/elasticsearch.yml
echo -Djava.net.preferIPv4Stack=true >>/etc/elasticsearch/jvm.options

echo "###-------- OK  --------------- ###"

echo "########---- install logstash ---------#########"
sleep 2

cat << EOF > /etc/yum.repos.d/logstash.repo
[logstash-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sleep 1
yum install logstash -y


echo "########---- install kibana ---------#########"

cat <<EOF > /etc/yum.repos.d/kibana.repo
[kibana-6.x]
name=Kibana repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sleep 1
yum install kibana -y

sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/'g /etc/kibana/kibana.yml

echo "###-------- OK  --------------- ###"
sleep 2
echo "########---- install and configure metricbeat ---------#########"

sleep 2
cat <<EOF > /etc/yum.repos.d/elastic.repo
[elastic-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sleep 1

yum install metricbeat -y 
sleep 2
yum install packetbeat -y
yum install filebeat -y
echo "###-------- OK  --------------- ###"
sleep 2
echo "########---- installation completed  ---------#########"

git clone https://github.com/tiedoll95/elk-stack.git
sleep 1
mv /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml.bak
sleep 1
cp elk-stack/metricbeat.yml /etc/metricbeat/
sleep 1
mv /etc/packetbeat/packetbeat.yml /etc/packetbeat/packetbeat.yml.bak
sleep 1
cp elk-stack/packetbeat.yml /etc/packetbeat/
sleep 2
cp elk-stack/startdv.sh /root/
sleep 2
chmod 777 /root/startdv.sh
sleep 3

echo "########---- start and enable service ---------#########"
sleep 2

systemctl daemon-reload
systemctl restart kibana
systemctl enable kibana
systemctl restart elasticsearch
systemctl enable elasticsearch
systemctl restart logstash
systemctl enable logstash
systemctl restart metricbeat
systemctl enable metricbeat
systemctl start packetbeat
clear
sleep 2
echo "###################################################################"
echo "#---------------Reboot server after 5 sceconds  ------------------#" 
echo "#------------------  Thanks and Best Regards ---------------------#"
echo "#Author      	:Nguyen Duc Huy                                 #"
echo "#Email       	:tiedoll96@gmail.com                            #"
echo "#website		:https://www.quantrimangdn.com/                 #"
echo "###################################################################"
echo "-------------------------------------------------------------------"
#
clear
####################################################
####################################################
####################################################
echo "Run command ./startdv.sh  after reboot server "
####################################################
####################################################
####################################################
sleep 7
reboot

