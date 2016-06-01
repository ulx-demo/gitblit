#!/bin/bash

: ${GITBLIT_URL:="https://git.apps.ose.ulx.hu"}

: ${MAIL_PORT:="25"}
: ${MAIL_DEBUG:="false"}
: ${MAIL_SMTPS:="false"}
: ${MAIL_STARTTLS:="false"}

: ${GITBLIT_PROPS:="$GITBLIT_DATA/gitblit.properties"}

function update_config() {
  PARAM=$(echo -e "$1"|cut -d '=' -f 1|tr -d '[[:space:]]')
  VALUE=$(echo -e "$1"|sed -e 's/[/\&]/\\&/g')
  sed -i "/^${PARAM}.*\$/,\${s//${VALUE}/;b};\$q1" $GITBLIT_PROPS || echo $1 >> $GITBLIT_PROPS
}

# gitblit-data inicializálása, ha üres
if [ ! "$(ls -A $GITBLIT_DATA)" ]; then

  GITBLIT_PROPS="$GITBLIT_DATA/gitblit.properties"
  STOREPASSWORD=`</dev/urandom tr -dc _A-Za-z0-9| head -c 32`
  echo "server.storePassword=$STOREPASSWORD" >> $GITBLIT_PROPS

  echo "Initializing GitBlit data directory at $GITBLIT_DATA"

  cp -a $GITBLIT_HOME/data/* $GITBLIT_DATA/

fi

update_config "server.httpPort=8080"
update_config "server.httpsPort=8443"
update_config "server.redirectToHttpsPort=false"
update_config "git.sshPort=-1"
update_config "git.daemonPort=-1"
update_config "git.acceptedPushTransports=HTTPS"
update_config "git.defaultAccessRestriction=VIEW"
update_config "git.repositoriesFolder=${GITBLIT_DATA}/git"
update_config "web.canonicalUrl=${GITBLIT_URL}"
update_config "web.allowGravatar=false"

update_config "tickets.service = com.gitblit.tickets.BranchTicketService"
update_config "web.enableRpcManagement=true"
update_config "web.enableRpcAdministration=true"

update_config "mail.server=$MAIL_SERVER"
update_config "mail.fromAddress=$MAIL_FROM"
update_config "mail.port=$MAIL_PORT"
update_config "mail.debug=$MAIL_DEBUG"
update_config "mail.smtps=$MAIL_SMTPS"
update_config "mail.starttls=$MAIL_STARTTLS"
update_config "mail.username=$MAIL_USERNAME"
update_config "mail.password=$MAIL_PASSWORD"

# TODO: több Jenkins server lesz, a jenkinsServer URL is egy változó legyen!
update_config "groovy.jenkinsServer=http://jenkins.apps.eir.ulx.hu"
update_config "groovy.scriptsFolder=/opt/gitblit-data/groovy"
update_config "groovy.customFields=\"openShiftProject=OpenShift Project Name\" \"openShiftBuildConfig=OpenShift BuildConfig name\" \"openShiftSecret=OpenShift Webhook Trigger Secret\""

java -server -Xms1024M -Xmx1024M -Djawa.awt.headless=true \
  -Dlog4j.configuration=file://${GITBLIT_HOME}/log4j.properties \
  -jar $GITBLIT_HOME/gitblit.jar --baseFolder $GITBLIT_DATA

