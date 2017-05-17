#!/bin/bash


sudo sed -i s/INFO/DEBUG/ $HBASE_CONF_DIR/log4j.properties

# Get hostname/ip config
MY_HOSTNAME=`hostname`
HDFS_NAMENODE_HOSTNAME=$MY_HOSTNAME

echo "Current Hostname:" $MY_HOSTNAME
echo "Current Namenode Hostname:" $HDFS_NAMENODE_HOSTNAME

#echo "Changing hostnames in core-site.xml"

# echo "Configure core-site.xml"
# # From run environment
# sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml
# sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml

# # From dockerfile configuration
# sudo sed -i s~HDFS_NAMENODE_CHECKPOINT_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/core-site.xml
# sudo sed -i s~HDFS_NAMENODE_EDITS_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/core-site.xml

# echo "Configure hdfs-site.xml"
# # From run environment
# sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml
# sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml

# # From dockerfile configuration
# sudo sed -i s~HDFS_NAMENODE_NAME_DIR~$DFS_NAME_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml
# sudo sed -i s~HDFS_NAMENODE_CHECKPOINT_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml
# sudo sed -i s~HDFS_DATANODE_DATA_DIR~$DFS_DATA_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml

# Zookeeper Quorum
ZOOKEEPER_QUORUM=''
for ZOO_SERVER in ${!ZOO_SERVER*}
do
	ZOOKEEPER_QUORUM="${!ZOO_SERVER},"
done

echo "Configure hbase-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HBASE_CONF_DIR/hbase-site.xml
sudo sed -i s~ZOOKEEPER_QUORUM~$ZOOKEEPER_QUORUM~g $HBASE_CONF_DIR/hbase-site.xml

# format namenode...need to check this
if [ -n $HBASE_MASTER ]; then
	echo "Starting HBase Master"
	su -l $HBASE_USER -c "/usr/hdp/current/hbase-master/bin/hbase-daemon.sh start master"
fi

if [ -n $HBASE_REGIONSERVER ]; then
	echo "Starting HBase RegionServer"
	su -l $HBASE_USER -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh start regionserver"
fi
