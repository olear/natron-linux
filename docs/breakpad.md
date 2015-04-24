breakpad.natronvfx.com (**DRAFT**)
======================

**Got problems with centos7, will setup from scratch with centos6**

Install CentOS7 Minmal, make hostname resolve.

```
yum -y update
reboot
```

```
yum -y install epel-release
rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-1.noarch.rpm
rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
tee /etc/yum.repos.d/elasticsearch.repo >/dev/null <<EOF
[elasticsearch-0.90]
name=Elasticsearch repository for 0.90.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/0.90/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF
rpm -ivh https://s3-us-west-2.amazonaws.com/org.mozilla.crash-stats.packages-public/el/7/noarch/socorro-public-repo-1-1.el7.centos.noarch.rpm
yum makecache
yum -y install postgresql93-server postgresql93-plperl \
  postgresql93-contrib java-1.7.0-openjdk python-virtualenv \
  rabbitmq-server elasticsearch nginx envconsul consul memcached socorro
systemctl enable nginx
systemctl enable memcached
systemctl enable rabbitmq-server
systemctl enable elasticsearch
/usr/pgsql-9.3/bin/postgresql93-setup initdb
systemctl enable postgresql-9.3
sed -i "s/timezone =.*/timezone = 'UTC'/g" /var/lib/pgsql/9.3/data/postgresql.conf
systemctl restart postgresql-9.3
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/sysconfig/selinux
reboot
```

```
yum -y install unzip wget
wget https://dl.bintray.com/mitchellh/consul/0.5.0_linux_amd64.zip
unzip 0.5.0_linux_amd64.zip
mv consul /usr/local/bin/
```

edit psql perms

```
#consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul
setup-socorro.sh postgres
systemctl enable socorro-collector
systemctl enable socorro-processor
systemctl enable socorro-middleware
systemctl enable socorro-webapp
mkdir -p /var/run/uwsgi
chown socorro:nginx -R /var/run/uwsgi/
chmod 664 -R /var/run/uwsgi/
echo "*/5 * * * * socorro /data/socorro/application/scripts/crons/crontabber.sh" > /etc/cron.d/socorro
chmod +x /etc/cron.d/socorro
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload
```



 ... to be continued (and btw, I HATE "NEW" LINUX, aka RHEL7, I will maybe downgrade to centos6, systemd etc is not cool on servers).



