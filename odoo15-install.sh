###
###
###

#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade

### Prevent SSH attacks
sudo apt-get install openssh-server fail2ban

### Required packages for Odoo
### Install pip3
sudo apt-get install -y python3-pip
### Install packages and libraries (Ensure no errors are displayed)
sudo apt-get install python-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev
### Install Web dependancies
sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less less-plugin-clean-css
sudo apt-get install -y node-less

### Setup database server with postgreSQL
### Install postgresql
sudo apt-get install postgresql
### Change to postgres sytem user and create a database for user Odoo15
sudo su - postgres
createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt odoo15
su -c "psql
ALTER USER odoo15 WITH SUPERUSER;
\q"

### System user setup for Odoo roles
### Create and limit a new system user for all Odoo related files and directories
sudo adduser --system --home=/opt/odoo --group odoo
### Install Git to clone Odoo Community Edition
sudo apt-get install git
### Switch to sytem user 'Odoo' for cloning
sudo su - odoo -s /bin/bash
### Clone git
git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 --single-branch .
### Exit from system user
exit

### Install required python packages (Ensure all packages were succesfully installed)
sudo pip3 install -r /opt/odoo/requirements.txt

### Install Wkhtmltopdf
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
### Install dependancies for wkhtmltopdf
sudo apt-get install fontconfig xfonts-75dpi xfonts-base
sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo apt install -f

### Set up COnfig file for addons path, database-related parameters, proxy parameters, etc
### Create a config file inside the /etc directory (NOTE: Change the admin_passwd and db_password)
echo "[options]\n;
   ; This is the password that allows database operations:\n;
   admin_passwd = PASSWORD\n;
   db_host = False\n;
   db_port = False\n;
   db_user = odoo15\n;
   db_password = password\n;
   addons_path = /opt/odoo/addons\n;
   logfile = /var/log/odoo/odoo.log" > /etc/odoo.conf

### Set access rights of the conf file for the system user 'odoo'
sudo chown odoo: /etc/odoo.conf
sudo chmod 640 /etc/odoo.conf

### Create a log directory to store the log file of Odoo
sudo mkdir /var/log/odoo
sudo chown odoo:root /var/log/odoo

### Odoo Service file
### Create a service to run Odoo in /etc/systemd/system
echo "[Unit]\n;
   Description=Odoo\n;
   Documentation=http://www.odoo.com\n;
   [Service]\n;
   # Ubuntu/Debian convention:\n;
   Type=simple\n;
   User=odoo\n;
   ExecStart=/opt/odoo/odoo-bin -c /etc/odoo.conf\n;
   [Install]\n;
   WantedBy=default.target" > /etc/systemd/system/odoo.service

### Set permissions for the root user
sudo chmod 755 /etc/systemd/system/odoo.service
sudo chown root: /etc/systemd/system/odoo.service








