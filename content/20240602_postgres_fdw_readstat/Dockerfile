FROM postgres:16
RUN apt-get update && \
    # readstat build deps
    apt-get -y install make git autotools-dev libtool gettext && \
    git clone https://github.com/WizardMac/ReadStat.git
WORKDIR /ReadStat
RUN git checkout v1.1.9
RUN ./autogen.sh && ./configure --prefix /usr/local
RUN make && make install
RUN echo "/usr/local/lib/" >> /etc/ld.so.conf 
RUN ldconfig
