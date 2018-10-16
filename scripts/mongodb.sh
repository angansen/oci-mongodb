echo "Running mongodb.sh"

#######################################################"
################# Turn Off the Firewall ###############"
#######################################################"
echo "Turning off the Firewall..."
service firewalld stop
chkconfig firewalld off

#######################################################"
#################### Install MongoDB ##################"
#######################################################"
echo "Installing MongoDB..."

echo"[mongodb-enterprise]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/4.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" > /etc/yum.repos.d/mongodb-enterprise.repo

yum install -y mongodb-enterprise
service mongod start
chkconfig mongod on

#######################################################"
################## Install Ops Manager ################"
#######################################################"
echo "Installing Ops Manager..."

curl -O https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-4.0.4.50216.20181012T0121Z-1.x86_64.rpm
rpm -ivh mongodb-mms-4.0.4.50216.20181012T0121Z-1.x86_64.rpm
service mongodb-mms start
