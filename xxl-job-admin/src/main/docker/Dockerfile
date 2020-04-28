FROM registry.cn-beijing.aliyuncs.com/ctfx/jdk1.8-mini:latest

MAINTAINER dkgee dk_gee@163.com

ENV PROFILE=test
ENV MYSQL_ADDRESS=172.30.154.242:3306
ENV MYSQL_DB=xxl_job
ENV MYSQL_DB_USER=root
ENV MYSQL_DB_PASSWD=123456
ENV XXL_USER=admin
ENV XXL_USER_PASSWD=123456
ENV TZ=PRC

ARG VERSION=2.2.1

ADD xxl-job-admin-${VERSION}-bin.zip /cms-job.zip

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sh -c 'unzip /cms-job.zip && rm -rf /cms-job.zip && mv xxl-job-admin-* /cms-job'

EXPOSE 8080

ENTRYPOINT ["/cms-job/start.sh", "start", "${PROFILE}"]

