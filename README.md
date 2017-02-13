# Dockerised OpenCV (3.2)

A dockerised version of OpenCV with everything you need to compile and test OpenCV-based applications.

## Execute scripts

The following script will execute the scripts `/script/to/run; /or/set/of/them` as if they were run on your machine.

In order to see what is going inside the docker we need to sync the displays with `--env DISPLAY=$DISPLAY --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"`.

Also, we will share the source code directories `-v=$(pwd)/..:$(pwd)/..` (this assumes you are doing an out-of-source build and you have a parent directory with the `build` and `src` as children). And we set the current directory as our working directory `-w=$(pwd)`.

    docker run -it --rm \
      --env DISPLAY=$DISPLAY --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
      -v=$(pwd)/..:$(pwd)/.. -w=$(pwd) \
      adnriv/opencv \
      /script/to/run; /or/set/of/them

## Build applications

Note that you can build applications using the same principle as above. You only need to replace the set of instructions with the `make` directives.

## Build the image locally 

You can build the image locally by executing the `Dockerfile`

    docker build -t opencv .

This will create an image named `opencv` that you can execute.
