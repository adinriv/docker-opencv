FROM ubuntu:rolling
MAINTAINER adin

ENV PYTHON_VERSION 3.7
ENV OPENCV_VERSION 3.4.2

ENV NUM_CORES 4

# Turn off interactive dialogs of dpkg
# https://askubuntu.com/a/1013396/44054
# https://stackoverflow.com/a/44333806/424986
ENV DEBIAN_FRONTEND=noninteractive


# Install OpenCV
RUN apt-get -y update -qq && \
    apt-get -y install python$PYTHON_VERSION \
                       python$PYTHON_VERSION-dev \
                       python${PYTHON_VERSION%%.*}-pip \

                       wget \
                       unzip \

                       # Required
                       build-essential \
                       cmake \
                       git \
                       pkg-config \
                       libatlas-base-dev \
                       libavcodec-dev \
                       libavformat-dev \
                       libgtk2.0-dev \
                       libswscale-dev \

                       # Optional
                       libdc1394-22-dev \
                       libjpeg-dev \
                       libpng-dev \
                       libtbb2 \
                       libtbb-dev \
                       libtiff-dev \
                       libv4l-dev \
                       libvtk6-dev \

                       # Tools
                       imagemagick \

                       &&\

    apt-get autoclean autoremove && \

    # Re link the latest python
    rm /usr/bin/python${PYTHON_VERSION%%.*} && ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python${PYTHON_VERSION%%.*} &&\
    rm /usr/bin/python && ln -s /usr/bin/python${PYTHON_VERSION%%.*} /usr/bin/python

# Note that ${PYTHON_VERSION%%.*} extracts the major version
# Details: https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#Shell-Parameter-Expansion
RUN pip${PYTHON_VERSION%%.*} install --no-cache-dir --upgrade pip &&\
    # Need to reshash pip3 to solve an issue with the upgrade
    # check https://github.com/pypa/pip/issues/5240#issuecomment-383309404 for details
    hash -r pip${PYTHON_VERSION%%.*} &&\
    pip${PYTHON_VERSION%%.*} install --no-cache-dir numpy matplotlib scipy

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
      -D ENABLE_PRECOMPILED_HEADERS=OFF \

      -D INSTALL_C_EXAMPLES=OFF \
      -D INSTALL_PYTHON_EXAMPLES=OFF \

      -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
      -D BUILD_EXAMPLES=OFF \

      -D BUILD_NEW_PYTHON_SUPPORT=ON \

      -D BUILD_DOCS=OFF \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D WITH_TBB=ON \
      -D WITH_OPENMP=ON \
      -D WITH_IPP=ON \
      -D WITH_CSTRIPES=ON \
      -D WITH_OPENCL=ON \
      -D WITH_V4L=ON \
      -D WITH_VTK=ON \
      .. &&\
    make -j$NUM_CORES &&\
    make install &&\
    ldconfig &&\

    # Clean the install from sources
    cd / &&\
    rm -r /opencv &&\
    rm -r /opencv_contrib

# Change working dirs
WORKDIR /builds

# Define default command.
CMD ["bash"]
