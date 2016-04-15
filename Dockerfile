FROM ubuntu:14.04.1

ENV ELASTICSEARCH_VERSION 2.3.1
ENV KIBANA_VERSION 4.5.0
ENV LOGSTASH_VERSION 2.3.1

RUN apt-get -y update
RUN apt-get -y install openjdk-7-jre syslog-ng syslog-ng-core supervisor vim wget

#ElasticSearch
RUN wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz && \
    tar xf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz && \
    rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz && \
    mv elasticsearch-${ELASTICSEARCH_VERSION} /usr/src/elasticsearch

#Kibana
RUN wget https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz && \
    tar xf kibana-${KIBANA_VERSION}-linux-x64.tar.gz && \
    rm kibana-${KIBANA_VERSION}-linux-x64.tar.gz && \
    mv kibana-${KIBANA_VERSION}-linux-x64 /usr/src/kibana

#Logstash
RUN wget https://download.elasticsearch.org/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz && \
	tar xf logstash-${LOGSTASH_VERSION}.tar.gz && \
    rm logstash-${LOGSTASH_VERSION}.tar.gz && \
    mv logstash-${LOGSTASH_VERSION} /usr/src/logstash

RUN mkdir -p /opt/elk/conf
RUN mkdir -p /opt/elk/logs
RUN mkdir -p /opt/elk/certs
RUN mkdir -p /opt/elk/data
RUN mkdir -p /opt/elk/work

COPY ./config/supervisord-logstash.conf /etc/supervisor/conf.d/
COPY ./config/elasticsearch.yml /usr/src/elasticsearch/config/
COPY ./config/kibana.yml /usr/src/kibana/config/
COPY ./config/network_syslog /etc/logrotate.d/

VOLUME ["/opt/elk/conf", "/opt/elk/logs", "/opt/elk/cert"]

#Remove syslog-ng from startup
RUN update-rc.d -f syslog-ng remove

EXPOSE 5601 9200 49021 5043 49152
CMD ["/usr/bin/supervisord", "-n"]

