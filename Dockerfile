FROM ubuntu:rolling
MAINTAINER adin

ENV PYTHON_VERSION 3.6
ENV OPENCV_VERSION 3.2.0

ENV NUM_CORES 4



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
                       libgtk2.0-dev \
                       libavcodec-dev \
                       libavformat-dev \
                       libswscale-dev \

                       # Optional
                       libtbb2 libtbb-dev \
                       libjpeg-dev \
                       libpng-dev \
                       libtiff-dev \
                       libv4l-dev \
                       libdc1394-22-dev \

                       qt4-default \

                       # Missing libraries for GTK
                       libatk-adaptor \
                       libcanberra-gtk-module \

                       # For use matplotlib.pyplot in python
                       python$PYTHON_VERSION-tk \

                       # Tools
                       imagemagick \

                       &&\

    # Latest ubuntu come without jasper
    # So, get it, install it, and then clean
    wget http://launchpadlibrarian.net/257156898/libjasper1_1.900.1-debian1-2.4+deb8u1_amd64.deb && \
    wget http://launchpadlibrarian.net/257156894/libjasper-dev_1.900.1-debian1-2.4+deb8u1_amd64.deb && \
    dpkg -i libjasper1_1.900.1-debian1-2.4+deb8u1_amd64.deb && \
    dpkg -i libjasper-dev_1.900.1-debian1-2.4+deb8u1_amd64.deb && \
    apt-get install -f libjasper-dev && \

    apt-get autoclean autoremove && \
    rm libjasper-dev_1.900.1-debian1-2.4+deb8u1_amd64.deb libjasper1_1.900.1-debian1-2.4+deb8u1_amd64.deb && \

    # Re link the latest python
    rm /usr/bin/python${PYTHON_VERSION%%.*} && ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python${PYTHON_VERSION%%.*}

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
WORKDIR /builds

# Define default command.
CMD ["bash"]
