sudo docker run --runtime nvidia -it -v share:/share xxxx

sudo docker run --runtime nvidia -itd -v /tmp/.X11-unix:/tmp/.X11-unix -v /dra/models_ws/BEVDet-ROS-TensorRT:/workspace/BEVDet/ -e DISPLAY=$DISPLAY ***:***

sudo docker run --runtime nvidia -e DISPLAY=$DISPLAY -itd -v /tmp/.X11-unix:/tmp/.X11-unix --hostname=$HOSTNAME -v $HOME/.Xauthority:/root/.Xauthority -v /dra/models_ws/BEVDet-ROS-TensorRT:/workspace/BEVDet/ -e DISPLAY=$DISPLAY ***:***

sudo docker exec -it *** /bin/bash

xhost +local:
