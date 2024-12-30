sudo docker run --runtime nvidia -it -v share:/share xxxx
sudo docker run --runtime nvidia -itd -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY --name test-demo ubuntu
