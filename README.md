# Debian-OpenCV2

This docker image provides latest stable Debian, with OpenCV 2.4 and Python 2.7 installed,
plus some of the popular Python packages, plus several ways to use graphics.

# Installing Docker

## Ubuntu

    sudo apt install docker.io
    sudo usermod -aG docker $(whoami)

Until you re-login, you will have to prefix all `docker` commands with `sudo`.

## Windows

Download "Docker Toolbox" from https://www.docker.com/products/docker-toolbox, install it,
run "Docker Quick-start Terminal", and let it do its magic.

You can also try "Docker for Windows", which sounds like a better option, but is unsupported on my Windows machine.

# Working with this image

First, do `docker pull al42and/debian-opencv2:latest` to get an image (it's about 1GiB).

## Using PyCharm Professional

Open PyCharm, go to Preferences (or File -> Settings) -> Project:yours -> Project Interpreter, and add new Remote Interpreter.

## Using Jupyter

    docker run -p 9999:9999 -dt al42and/debian-opencv2 run_jupyter

And then open http://localhost:9999/ in your browser

### Jupyter and X in Linux (probably MacOS too)

With some [minor effort (and a bunch of X11 magic)](http://stackoverflow.com/a/25280523/929437) we can do the following to pass X socket inside container:

    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    docker run -p 9999:9999 -t -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DISPLAY al42and/debian-opencv run_jupyter

And now we can watch OpenCV videos or use [Matplotlib animations](http://matplotlib.org/examples/animation/simple_anim.html) from Jupyter notebook!

## Using SSH X-forwarding

    docker run -p 9999:9999 -p 2222:22 -dt al42and/debian-opencv2 run_ssh

This way, you have this container running in background, with Jupyter port available, just in case.

Now, if you're on Linux or Mac, just do `ssh -X root@localhost -p2222`, with password being `1234`.

If you're on Windows, things get more complicated. First, run `docker-machine ip default` in Docker console to get an IP of a virtual machine Docker uses.
Then install [Xming](https://sourceforge.net/projects/xming/) and use its XLaunch tool to connect to this IP, port `2222`, username `root` and password `1234`.

### Jupyter and X in Windows

Surprisingly, this paragraph is pretty short. First, install Xming and run container as:

    docker run -p 2222:22 -dt al42and/debian-opencv2 run_ssh

Then download file `tools/run_jupyter.xlaunch` from this repository, right-click it and choose edit. XLaunch should open.
Accept all default choices, but change host IP to the one returned by `docker-machine ip default`.

After several seconds it should launch X-server on your machine, and Jupyter in container, with SSH connecting them.
Now, open http://localhost:9999/ and rejoice!

## Using VNC

    docker run -p 5900:5900 -dt al42and/debian-opencv2 run_vnc

Then connect to localhost:5900 using your favorite VNC client. The password is `1234`.

# Building

    docker build -t al42and/debian-opencv2 --no-cache .

# Known issues:

 1. Mac OS - Certificate path doesn't exist:
  * See https://stackoverflow.com/questions/38285282/where-is-the-certificates-folder-for-docker-beta-for-mac
 2. When doing `import cv2` you get `libdc1394 error: Failed to initialize libdc1394`:
  * Ignore it, there's nothing to worry about
