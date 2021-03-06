#!/bin/bash

if [ -z "$ROS_DISTRO" ]; then
  echo "ROS not installed. Check the installation steps: https://github.com/erlerobot/gym#installing-the-gazebo-environment"
fi

program="gazebo"
condition=$(which $program 2>/dev/null | grep -v "not found" | wc -l)
if [ $condition -eq 0 ] ; then
    echo "Gazebo is not installed. Check the installation steps: https://github.com/erlerobot/gym#installing-the-gazebo-environment"
fi

source /opt/ros/kinetic/setup.bash

# Create catkin_ws
ws="catkin_ws"
if [ -d $ws ]; then
  echo "Error: catkin_ws directory already exists" 1>&2
  exit 1
fi
src=$ws"/src"
mkdir -p $src
cd $src
catkin_init_workspace

# Install dependencies
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xB01FA116
sudo apt-get update
sudo apt-get install -y git                            \
                        mercurial                      \
                        libsdl-image1.2-dev            \
                        libspnav-dev                   \
                        libtbb-dev                     \
                        libtbb2                        \
                        libusb-dev libftdi-dev         \
                        pyqt4-dev-tools                \
                        python-vcstool                 \
                        ros-kinetic-bfl                 \
                        python-pip                     \
                        g++                            \
                        ccache                         \
                        realpath                       \
                        libopencv-dev                  \
                        libtool                        \
                        automake                       \
                        autoconf                       \
                        libexpat1-dev                  \
                        ros-kinetic-mavlink             \
                        ros-kinetic-octomap-msgs        \
                        ros-kinetic-joy                 \
                        ros-kinetic-geodesy             \
                        ros-kinetic-octomap-ros         \
                        ros-kinetic-control-toolbox     \
			ros-kinetic-pluginlib	       \
			ros-kinetic-trajectory-msgs     \
			ros-kinetic-control-msgs	       \
			ros-kinetic-std-srvs 	       \
			ros-kinetic-nodelet	       \
			ros-kinetic-urdf		       \
			ros-kinetic-rviz		       \
			ros-kinetic-kdl-conversions     \
			ros-kinetic-eigen-conversions   \
			ros-kinetic-tf2-sensor-msgs     \
			ros-kinetic-pcl-ros	       \
                        gawk                           \
                        libtinyxml2-dev
sudo easy_install numpy
sudo easy_install --upgrade numpy
sudo pip install --upgrade matplotlib
sudo pip2 install pymavlink MAVProxy catkin_pkg --upgrade
echo "\nDependencies installed\n"


#Install Sophus
cd ../../
git clone https://github.com/stonier/sophus -b indigo
cd sophus
mkdir build
cd build
cmake ..
make
sudo make install
echo "## Sophus installed ##\n"

#Install APM/Ardupilot
cd ../../
mkdir apm
cd apm
git clone https://github.com/erlerobot/ardupilot.git -b gazebo_udp
git clone https://github.com/tridge/jsbsim.git
cd jsbsim
./autogen.sh --enable-libraries
make -j2
sudo make install
echo "## AMP/Ardupilot installed ##"

# Import and build dependencies
cd ../../catkin_ws/src/
vcs import < ../../gazebo.repos
cd ..
catkin_make --pkg mav_msgs
source devel/setup.bash
catkin_make -j 1
bash -c 'echo source `pwd`/devel/setup.bash >> ~/.bashrc'
echo "## ROS workspace compiled ##"

#add own models path to gazebo models path
if [ -z "$GAZEBO_MODEL_PATH" ]; then
  bash -c 'echo "export GAZEBO_MODEL_PATH="`pwd`/../../assets/models >> ~/.bashrc'
  exec bash #reload bashrc
fi

# Theano and Keras installation and requisites
cd ../
sudo pip install h5py
sudo apt-get install gfortran
git clone git://github.com/Theano/Theano.git
cd Theano/
sudo python setup.py develop
sudo pip install keras

echo "## Theano and Keras installed ##"
echo "## Installation finished ##"
