FROM mohaseeb/raspberrypi3-python-opencv:latest
#This image is base on the resin image for building Python apps on Raspberry Pi 3.

#Enforces cross-compilation through Quemu
RUN [ "cross-build-start" ]

#update list of packages available
RUN apt-get update && apt-get install -y libboost-python1.55.0

#Install python packages        
COPY /build/arm32v7-requirements.txt ./
RUN pip install --upgrade pip && pip install --upgrade setuptools && pip install -r arm32v7-requirements.txt

# Install build modules for openCV
# Based on the work at https://github.com/mohaseeb/raspberrypi3-opencv-docker
RUN sudo apt-get install -y --no-install-recommends \
    # to build and install opencv
    unzip \
    build-essential cmake pkg-config \
    # to work with image files
    libjpeg-dev libtiff5-dev libjasper-dev libpng-dev \
    # to work with video files
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    # to display GUI
    libgtk2.0-dev pkg-config \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo apt-get -y autoremove

RUN pip install trollius tornado

RUN [ "cross-build-end" ]  

ADD /app/ .

# Expose the port
EXPOSE 5012

ENTRYPOINT [ "python", "-u", "./main.py" ]