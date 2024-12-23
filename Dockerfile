FROM nvcr.io/nvidia/l4t-tensorrt:r8.5.2.2-devel
ENV DEBIAN_FRONTEND = noninteractive

RUN apt-get update 
RUN apt-get install software-properties-common -y
RUN apt-get update 
RUN add-apt-repository ppa:ubuntu-toolchain-r/test 
RUN apt-get update 
RUN apt-get install gcc-9 -y
RUN apt-get install g++-9 -y

RUN apt-get install -y \
    git \
    autoconf \
    automake \
    libtool \
    curl \
    make \
    unzip \
    wget \
    pkg-config \
    libatlas-base-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libcanberra-gtk3-module \
    libboost-all-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgtkglext1 \
    libgtkglext1-dev \
    #libpython3.6-dev \
    #libpython3.6-numpy \
    libeigen3-dev \
    libpcl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
    
WORKDIR /workspace

# 下载 OpenCV 和 OpenCV Contrib 源代码
RUN git clone --depth 1 https://github.com/opencv/opencv.git /workspace/opencv && \
    git clone --depth 1 https://github.com/opencv/opencv_contrib.git /workspace/opencv_contrib && \
    cd /workspace/opencv && \
    git checkout 4.2 && \
    cd /workspace/opencv_contrib && \
    git checkout 4.x

# 创建并进入构建目录
RUN cd /workspace/opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=/workspace/opencv_contrib/modules \
          -D WITH_CUDA=OFF \
          -D WITH_CUDNN=OFF \
          -D OPENCV_DNN_CUDA=OFF \
          -D ENABLE_FAST_MATH=1 \
          -D CUDA_FAST_MATH=1 \
          -D WITH_CUBLAS=1 \
          -D WITH_GSTREAMER=OFF \
          -D WITH_LIBV4L=OFF \
          -D BUILD_opencv_python3=OFF \
          -D BUILD_opencv_python2=OFF \
          #-D PYTHON3_EXECUTABLE=/usr/bin/python3 \
          #-D PYTHON3_INCLUDE_DIR=/usr/include/python3.6 \
          #-D PYTHON3_LIBRARIES=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
          #-D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/lib/python3/dist-packages/numpy/core/include \
          .. && \
    make -j16 && \
    make install && \
    ldconfig

RUN git clone https://github.com/jbeder/yaml-cpp.git /workspace/yamlcpp
RUN cd /workspace/yamlcpp && mkdir build && cd build && \
    cmake -DBUILD_SHARED_LIBS=on .. && \
    make -j16 && \
    make install && \
    ldconfig

# 更新和安装基本工具
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

  
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt install curl
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt-get update
RUN apt install ros-noetic-desktop-full -y
# RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc
RUN apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y
RUN rosdep init
RUN rosdep update

RUN pip3 install ruamel.yaml
RUN pip3 install gdown

RUN apt install -y nvidia-container-toolkit

RUN apt install -y \
	ros-noetic-jsk-recognition-msgs

# 设置环境变量
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
RUN LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH python3 setup.py install 
RUN rm /usr/local/cuda/lib64/stubs/libcuda.so.1

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/compat:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
	
RUN git clone https://github.com/zzhawk/BEVDet-ROS-TensorRT.git /workspace/BEVDet/src && \
    cd /workspace/BEVDet && \ 
    /bin/bash -c 'source /opt/ros/noetic/setup.bash; catkin_make'  && \
    cd src && \  
    mkdir model && \
    gdown --folder https://drive.google.com/drive/folders/1jSGT0PhKOmW3fibp6fvlJ7EY6mIBVv6i && \
    mv BEVDet-TensorRT-Onnx/* model && \
    rm -r BEVDet-TensorRT-Onnx && \
    python tools/export_engine.py cfgs/bevdet_lt_depth.yaml model/img_stage_lt_d.onnx model/bev_stage_lt_d.engine --postfix="_lt_d_fp16" --fp16=True
    

#ENV PATH /usr/local/cuda/bin:${PATH}
#ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:${LD_LIBRARY_PATH}
