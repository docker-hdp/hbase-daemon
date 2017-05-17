FROM docker-hdp/centos-base:1.0
MAINTAINER Arturo Bayo <arturo.bayo@gmail.com>
USER root

ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Configure environment variables for hbase
ENV HBASE_USER hbase
ENV HBASE_CONF_DIR /etc/hbase/conf
ENV HBASE_LOG_DIR /var/log/hbase
ENV HBASE_PID_DIR /var/run/hbase

# Install software
RUN yum clean all
RUN yum -y install hbase

# Configure hbase directories
RUN mkdir -p $HBASE_LOG_DIR
RUN chown -R $HBASE_USER:$HADOOP_GROUP $HBASE_LOG_DIR
RUN chmod -R 755 $HBASE_LOG_DIR

RUN mkdir -p $HBASE_PID_DIR
RUN chown -R $HBASE_USER:$HADOOP_GROUP $HBASE_PID_DIR
RUN chmod -R 755 $HBASE_PID_DIR

# Copy configuration files
RUN mkdir -p $HBASE_CONF_DIR
COPY tmp/conf/ $HBASE_CONF_DIR/
RUN chmod a+x $HBASE_CONF_DIR/ && chown -R $HDFS_USER:$HADOOP_GROUP $HBASE_CONF_DIR/../ && chmod -R 755 $HBASE_CONF_DIR/../

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
RUN echo "export HBASE_CONF_DIR=$HBASE_CONF_DIR" >> /etc/profile
RUN echo "export PATH=$PATH:$JAVA_HOME:$HADOOP_CONF_DIR" >> /etc/profile

# Expose volumes
VOLUME $HBASE_LOG_DIR

# Expose ports
EXPOSE 60000
EXPOSE 60010
EXPOSE 60020
EXPOSE 60030

# Deploy entrypoint
COPY files/configure-daemon.sh /opt/run/00_hbase-daemon.sh
RUN chmod +x /opt/run/*.sh

# Determine running user
#USER $HBASE_USER

# Execute entrypoint
ENTRYPOINT ["/opt/bin/run_all.sh"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD curl -f http://localhost:60020/ || exit 1