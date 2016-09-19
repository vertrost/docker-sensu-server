FROM centos:centos7

MAINTAINER Sergey Zhekpisov <zhekpisov@gmail.com>

# Basic packages
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install passwd sudo git wget openssl openssh openssh-server openssh-clients rubygems ruby-devel gcc make

# Create user
RUN useradd sensuuser \
 && echo "sensu" | passwd sensuuser --stdin \
 && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
 && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config \
 && echo "sensuuser ALL=(ALL) ALL" >> /etc/sudoers.d/sensuuser

# Redis
RUN yum install -y redis

# RabbitMQ
RUN yum install -y erlang socat initscripts \
  && rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
  && yum install -y http://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-3.6.5-1.noarch.rpm
RUN git clone https://github.com/joemiller/joemiller.me-intro-to-sensu.git \
  && cd joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate \
  && mkdir /etc/rabbitmq/ssl \
  && cp /joemiller.me-intro-to-sensu/server_cert.pem /etc/rabbitmq/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/server_key.pem /etc/rabbitmq/ssl/key.pem \
  && cp /joemiller.me-intro-to-sensu/testca/cacert.pem /etc/rabbitmq/ssl/
ADD ./files/rabbitmq.config /etc/rabbitmq/
#RUN rabbitmq-plugins enable rabbitmq_management

# Sensu server
RUN echo -e '[sensu]\n\
name=sensu\n\
baseurl=http://repositories.sensuapp.org/yum/$basearch/\n\
gpgcheck=0\n\
enabled=1' | tee /etc/yum.repos.d/sensu.repo
RUN yum install -y sensu
ADD ./files/config.json /etc/sensu/
RUN mkdir -p /etc/sensu/ssl \
  && cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

# uchiwa
RUN yum install -y uchiwa
ADD ./files/uchiwa.json /etc/sensu/
#ADD ./files/checks.json /etc/sensu/conf.d/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py \
  && easy_install supervisor

EXPOSE 22 3000 4567 5672 15672

ADD files/supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord"]
