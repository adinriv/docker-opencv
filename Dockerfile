FROM ubuntu:16.10

#3.4.3
ENV PYTHON_VERSION 3.5
ENV OPENCV_VERSION 3.2.0

ENV NUM_CORES 4

# Install OpenCV
RUN apt-get -y update -qq
RUN apt-get -y install python$PYTHON_VERSION-dev wget unzip \
                       build-essential cmake git pkg-config libatlas-base-dev gfortran \
                       libjasper-dev libgtk2.0-dev libavcodec-dev libavformat-dev \
                       libswscale-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libv4l-dev \
                       qt4-default

# Note that ${PYTHON_VERSION%%.*} extracts the major version
# Details: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#Shell-Parameter-Expansion
RUN apt-get -y install python${PYTHON_VERSION%%.*}-pip
RUN pip${PYTHON_VERSION%%.*} install --upgrade pip &&\
    pip${PYTHON_VERSION%%.*} install numpy matplotlib

RUN git clone https://github.com/opencv/opencv.git &&\
    cd opencv &&\
    git checkout $OPENCV_VERSION &&\
    cd /

RUN git clone https://github.com/opencv/opencv_contrib &&\
    cd opencv_contrib &&\
    git checkout $OPENCV_VERSION &&\
    cd /

RUN mkdir /opencv/build
WORKDIR /opencv/build
RUN cmake \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_C_EXAMPLES=ON \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
  -D BUILD_EXAMPLES=ON \
  -D BUILD_NEW_PYTHON_SUPPORT=ON \
  -D BUILD_DOCS=OFF \
  -D BUILD_TESTS=OFF \
  -D BUILD_PYTHON_SUPPORT=ON \
  -D BUILD_PERF_TESTS=OFF \
  -D WITH_TBB=ON \
  -D WITH_OPENMP=ON \
  -D WITH_IPP=ON \
  -D WITH_CSTRIPES=ON \
  -D WITH_OPENCL=ON \
  -D WITH_IPP=OFF \
  -D WITH_V4L=ON ..
RUN make -j$NUM_CORES
RUN make install
RUN ldconfig

# Define default command.
CMD ["bash"]
