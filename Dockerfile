# Dockerfile influenced by anothervictimofsurvivalinstinct/yt-dlp-server

FROM alpine:3.16 AS base

RUN apk add \
        build-base \
        libffi-dev \
        libressl-dev \
        py3-pip \
        python3-dev

# Set PATH for python
ENV PATH="/root/.local/bin:$PATH"
RUN python3 -m pip install --user flask flask-session gunicorn yt-dlp wheel


FROM alpine:3.16


# Folder we're keeping the app in
WORKDIR /app
# Where videos download by default
VOLUME /app/downloads
# It is a very good idea to put this somewhere else
VOLUME /app/db

# To prevent tzdata ruining the build process
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Split up these lines so Docker can cache them. Add s6 to use in the start script.
RUN apk add \
    build-base \
    ffmpeg \
    libffi-dev \
    py3-pip \
    py3-setuptools \
    python3 \
    python3-dev \
    s6

# build-base added for xattr support

COPY ./requirements.txt ./ 

#Install requirements just in case
RUN python3 -m pip install --user -r ./requirements.txt


#requests doesn't get moved over for some reason so adding it here
RUN python3 -m pip install --user requests
RUN python3 -m pip install --user xattr

#python env path taken from the build image and used here as builders aren't needed    
COPY --from=base /root/.local /root/.local
ENV PATH="/root/.local/bin:$PATH"


# Create User that program can run as and chown the working directory. Reduces the possibility of files being written as root:root

#ENV UNAME abc
#ENV UID 1000
#ENV GID 1000
#RUN groupadd -g $GID -o $UNAME
#RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
#RUN chown -R abc:abc /app

# Environment variables

ENV APPNAME YDS
ENV ADMINUSER admin
ENV PASSWORD youtube
# Copy the rest of the app
COPY . .

# RUN python3 ./setup.py --appname=${APPNAME} --username=${ADMINUSER} --password=${PASSWORD}

# Need to add in supervisord to make daemon work?

# Port 8080 is exposed, people can adjust which port forwards to this
EXPOSE 8080
# ENTRYPOINT ["gunicorn", "--workers 4", "--threads 4", "--bind 0.0.0.0:8080", "wsgi:app"]
# ENTRYPOINT ["./startup.sh", "${APPNAME}", "${ADMINUSER}", "${PASSWORD}"]
# Can't use form above as variables don't get injected.
# ENTRYPOINT exec ./startup.sh ${APPNAME} ${ADMINUSER} ${PASSWORD}

# make the start script executable
RUN chmod +x ./startup.sh

# Directly referencing the variables in Bash now
ENTRYPOINT ["./startup.sh"]

# Needed because gunicorn doesn't execute in the correct environment
# CMD ["./startup.sh"]
