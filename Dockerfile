FROM ubuntu:20.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      gcc \
      g++ \
      make \
      software-properties-common \
      sudo \
      unzip \
      wget

RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable && apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y \
      libcurl4-gnutls-dev \
      libhdf5-dev \
      libnetcdf-dev \
      libudunits2-dev \
      python3-pip \
      python3-rtree \
      python3.8-dev && \
      apt-get -y autoremove && apt-get clean autoclean

RUN wget https://code.mpimet.mpg.de/attachments/download/28013/cdo-2.2.0.tar.gz && \
      tar xvf cdo-2.2.0.tar.gz && \
      cd cdo-2.2.0 && \
      ./configure --enable-netcdf4 --with-netcdf && \
      make && \
      sudo make install

COPY requirements.txt /regridding_code/requirements.txt
WORKDIR /regridding_code

RUN pip3 install numpy==1.22 && \
      pip3 install -r requirements.txt

COPY . /regridding_code
ENTRYPOINT [ "tail", "-f", "/dev/null" ]
