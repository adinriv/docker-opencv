FROM ubuntu:16.10
MAINTAINER adin 

ENV PYTHON_VERSION 3.5
ENV OPENCV_VERSION 3.2.0

ENV NUM_CORES 4

# Install OpenCV
RUN apt-get -y update -qq && \
    apt-get -y install python$PYTHON_VERSION-dev wget unzip \
                       build-essential cmake git pkg-config libatlas-base-dev \
                       # gfortran \
                       libgtk2.0-dev \
                       libavcodec-dev libavformat-dev \
                       libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libv4l-dev \
                       qt4-default \
                       python${PYTHON_VERSION%%.*}-pip &&\
    apt-get autoclean autoremove

# Note that ${PYTHON_VERSION%%.*} extracts the major version
# Details: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#Shell-Parameter-Expansion
RUN pip${PYTHON_VERSION%%.*} install --no-cache-dir --upgrade pip &&\
    pip${PYTHON_VERSION%%.*} install --no-cache-dir numpy matplotlib

    # Get OpenCV 
RUN git clone https://github.com/opencv/opencv.git &&\
    cd opencv &&\
    git checkout $OPENCV_VERSION &&\
    cd / &&\
    # Get OpenCV contrib modules
    git clone https://github.com/opencv/opencv_contrib &&\
    cd opencv_contrib &&\
    git checkout $OPENCV_VERSION &&\
    mkdir /opencv/build &&\
    cd /opencv/build &&\

    # Lets build OpenCV
    cmake \
      -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D INSTALL_C_EXAMPLES=OFF \
      -D INSTALL_PYTHON_EXAMPLES=OFF \
      -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
      -D BUILD_EXAMPLES=OFF \
      -D BUILD_NEW_PYTHON_SUPPORT=ON \
      -D BUILD_DOCS=OFF \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D BUILD_PYTHON_SUPPORT=ON \
      -D WITH_TBB=ON \
      -D WITH_OPENMP=ON \
      -D WITH_IPP=ON \
      -D WITH_CSTRIPES=ON \
      -D WITH_OPENCL=ON \
      -D WITH_V4L=ON \
      .. &&\
    make -j$NUM_CORES &&\
    make install &&\
    ldconfig &&\

    # Clean the install from sources
    cd / &&\
    rm -r /opencv &&\
    rm -r /opencv_contrib 

# Change working dirs
WORKDIR /buildls

# RUN apt-get -y autoclean && apt-get -y autoremove

# Define default command.
CMD ["bash"]
