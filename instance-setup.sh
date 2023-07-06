#!/bin/bash
echo '* yum update *****************************************************************************************'
sudo yum update -y && sudo yum upgrade -y

echo '* python3 *****************************************************************************************'
sudo yum -y install python3

echo '* pip *****************************************************************************************'
sudo yum -y install pip

echo '* java *****************************************************************************************'
sudo yum -y install java 

echo '* python ansible *****************************************************************************************'
python3 -m pip install ansible 

echo '* get jenkins repo *****************************************************************************************'
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

echo '* rpm import key *****************************************************************************************'
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo '* java 11 *****************************************************************************************'
sudo amazon-linux-extras install java-openjdk11 

echo '* ansible2 *****************************************************************************************'
sudo amazon-linux-extras install ansible2 -y

echo '* git *****************************************************************************************'
sudo yum install git -y

echo '* jenkins thru ansible *****************************************************************************************'
echo '* ansible playbook ***********************************************************************'
# run ansible playbook to install jenkins
cd ~/.install-jenkins
sudo ansible-playbook install-jenkins.yml -vvv
echo '* End of script **************************************************************************'
echo '=========================================================================================='
