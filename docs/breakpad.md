breakpad.natronvfx.com
======================

Install CentOS7 Minimal, make hostname resolve.

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

 ... and more, still testing.
