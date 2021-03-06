FROM ubuntu:18.04

ENV USER csgo
ENV HOME /home/$USER
ENV SERVER $HOME/hlserver
ENV METAMOD_VERSION 1.10.7
ENV SOURCEMOD_VERSION 1.9.0-git6251

RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install lib32gcc1 curl net-tools lib32stdc++6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && useradd $USER \
    && mkdir $HOME \
    && chown $USER:$USER $HOME \
    && mkdir $SERVER

ADD ./csgo_ds.txt $SERVER/csgo_ds.txt
ADD ./update.sh $SERVER/update.sh
ADD ./autoexec.cfg $SERVER/csgo/csgo/cfg/autoexec.cfg
ADD ./server.cfg $SERVER/csgo/csgo/cfg/server.cfg
ADD ./csgo.sh $SERVER/csgo.sh

RUN chown -R $USER:$USER $SERVER

USER $USER
RUN curl http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C $SERVER -xvz \
 && $SERVER/update.sh

RUN curl https://mms.alliedmods.net/mmsdrop/1.10/mmsource-$METAMOD_VERSION-git966-linux.tar.gz | tar xvz -C $SERVER/csgo
RUN curl https://sm.alliedmods.net/smdrop/1.9/sourcemod-$SOURCEMOD_VERSION-linux.tar.gz | tar xvz -C $SERVER/csgo

EXPOSE 27015/udp

WORKDIR /home/$USER/hlserver
ENTRYPOINT ["./csgo.sh"]
CMD ["-console" "-usercon" "+game_type" "0" "+game_mode" "1" "+mapgroup" "mg_active" "+map" "de_cache"]
