FROM debian:latest
RUN apt-get update && \
    apt-get -y install gcc gdb clangd make git autotools-dev libtool gettext && \
    git clone https://github.com/WizardMac/ReadStat.git /home/ReadStat && \
    git clone https://github.com/edubart/minicoro.git /home/minicoro

# setup and install ReadStat
WORKDIR /home/ReadStat
RUN git checkout v1.1.9
RUN ./autogen.sh && ./configure --prefix /usr/local
RUN make && make install
RUN echo "/usr/local/lib/" >> /etc/ld.so.conf 
RUN ldconfig
