FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y postgresql python3 python3-pip wget unzip sudo

USER postgres
RUN /etc/init.d/postgresql start && \
    createuser proxy_py && \
    createdb proxy_py && \
    psql -c "alter user proxy_py with encrypted password 'proxy_py';" && \
    psql -c "grant all privileges on database proxy_py to proxy_py;" && \
    cat /etc/postgresql/10/main/pg_hba.conf | \
    sed -e "s/local   all             all                                     peer/local all all md5/" | \
    tee /etc/postgresql/10/main/pg_hba.conf && \
    /etc/init.d/postgresql stop

USER root
RUN ls /
RUN wget https://github.com/DevAlone/proxy_py/archive/master.zip 2> /dev/null
RUN unzip master.zip
RUN rm master.zip 
RUN mv proxy_py-master proxy_py
RUN cd proxy_py
WORKDIR proxy_py
RUN pip3 install -r requirements.txt
RUN cp config_examples/settings.py /proxy_py/proxy_py/

EXPOSE 55555
CMD /etc/init.d/postgresql start; python3 main.py
