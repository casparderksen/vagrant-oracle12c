#!/bin/sh -x

# Create Oracle user and groups
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -m -c "Oracle" -u 54321 -g oinstall -G dba,oper oracle

# Setup Oracle environment settings for user oracle
cat /vagrant/oracle/environment.sh >> /home/oracle/.bashrc

# Add vagrant user to Oracle group
usermod -a -G oinstall,dba,oper vagrant

# Add alias for quick db connect
echo 'alias sysdba="sqlplus / as sysdba"' >> /home/oracle/.bashrc

# Add alias for quick sudo to oracle user
echo 'alias so="sudo -i -u oracle"' >> /home/vagrant/.bashrc

# Source Oracle environment settings
source /vagrant/oracle/environment.sh

# Create Oracle installation directories
mkdir -p ${ORACLE_HOME}
chown -R oracle:oinstall /u01
chmod -R 775 /u01

# Unzip distribution zip file
( cd /tmp; unzip /vagrant/oracle/linuxx64_12201_database.zip )

# Run Oracle Universal Installer
sudo -i -u oracle /tmp/database/runInstaller \
    -waitForCompletion -showProgress -silent \
    -responseFile /tmp/database/response/db_install.rsp \
    ORACLE_HOSTNAME=vagrant.localdomain \
    UNIX_GROUP_NAME=oinstall \
    INVENTORY_LOCATION=/u01/app/oraInventory \
    SELECTED_LANGUAGES=en \
    ORACLE_HOME=${ORACLE_HOME} \
    ORACLE_BASE=${ORACLE_BASE} \
    oracle.install.option=INSTALL_DB_SWONLY \
    oracle.install.db.InstallEdition=EE \
    oracle.install.db.OSDBA_GROUP=dba \
    oracle.install.db.OSBACKUPDBA_GROUP=dba \
    oracle.install.db.OSDGDBA_GROUP=dba \
    oracle.install.db.OSKMDBA_GROUP=dba \
    oracle.install.db.OSRACDBA_GROUP=dba \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
    DECLINE_SECURITY_UPDATES=true

# Execute root scripts
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/12.2.0.1/db_1/root.sh

# Run Net Configuration Assistent
sudo -i -u oracle $ORACLE_HOME/bin/netca \
    -silent -responsefile /vagrant/oracle/netca.rsp

# Running Database Configuration Assistant
sudo -i -u oracle $ORACLE_HOME/bin/dbca \
    -silent -createDatabase \
    -templateName General_Purpose.dbc \
    -responseFile NO_VALUE  \
    -gdbname ${ORACLE_UNQNAME} \
    -sid ${ORACLE_SID} \
    -characterSet AL32UTF8 \
    -emConfiguration DBEXPRESS \
    -emExpressPort 5500 \
    -sampleSchema true \
    -sysPassword Welcome01 \
    -systemPassword Welcome01

# Copy management scripts
cp -r /vagrant/oracle/scripts /home/oracle
chown -R oracle:oinstall /home/oracle/scripts

# Configure automatic restart of database instance
sed -e 's/:N$/:Y/' -i /etc/oratab

# Add init script
cp /vagrant/oracle/init/dbora /etc/init.d/dbora
chmod 750 /etc/init.d/dbora
chkconfig --add dbora

# Start database
service dbora start
