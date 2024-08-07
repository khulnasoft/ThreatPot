#!/bin/bash
# Threatpot on TPot Instance Installer

# Code based on https://github.com/telekom-security/tpotce/blob/master/iso/installer/install.sh

##################
# I. Global vars #
##################

myBACKTITLE="ThreatPot-on-TPot-Installer"
myREMOTESITES="https://github.com https://hub.docker.com"
myPROGRESSBOXCONF=" --backtitle "$myBACKTITLE" --progressbox 24 80"

myINFO="\
#############################################
### Threatpot Installer on TPot Instance ###
#############################################
Disclaimer:
This script will install Threatpot on this
system, assuming an existing TPot instance.
#############################################
Usage:
        $0 --help - Help.
"

myTHREATPOT_PORT=8008 # threatpot website
myTHREATPOT_PORT2=8000 # in case of type='https' - this is the http port
myELASTIC_PORT=64298

myTHREATPOT_USER="threatpot"
myTHREATPOT_PASS="threatpot"

myFOLDER=/opt/ThreatPot
INSTALLED=false

myTYPE="http"

NETWORKS="\

networks:
    default:
      name: etc_default
      external: true
"

SUPERUSER_CREATION='
if [ "$DJANGO_SUPERUSER_USERNAME" ]
then
    python3 manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL \
        --first_name $DJANGO_SUPERUSER_FIRST_NAME \
        --last_name $DJANGO_SUPERUSER_LAST_NAME
fi
'

THREATPOT_SERVICE="\
[Unit]
Description=threatpot
Requires=docker.service
After=docker.service
Requires=tpot.service
After=tpot.service

[Service]
Restart=always
RestartSec=5
TimeoutSec=infinity

# Compose Threatpot up
ExecStart=/bin/bash -c 'cd /opt/ThreatPot && /usr/bin/docker-compose up'

# Compose Threatpot down, remove containers and volumes
ExecStop=/bin/bash -c 'cd /opt/ThreatPot && /usr/bin/docker-compose down'

[Install]
WantedBy=multi-user.target
"

emailREGEX="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"


#################
# II. Functions #
#################

# Create banners
function fuBANNER {
  toilet -f ivrit "$1"
}

# Do we have root?
function fuGOT_ROOT {
	echo
	echo -n "### Checking for root: "
	if [ "$(whoami)" != "root" ];
	  then
		echo "[ NOT OK ]"
		echo "### Please run as root."
		echo "### Example: sudo $0"
		exit
	  else
		echo "[ OK ]"
	fi
}

# Check for other services
function fuCHECK_PORTS_THREATPOT {
	echo
	echo "### Checking for active services."
	echo
	grc netstat -tulpen
	echo
	echo "### Please review your running services."
	echo "### Port $myTHREATPOT_PORT should be free for the Threatpot Website."
  if [ "$myTYPE" == "https" ];
    then
    echo "### Port $myTHREATPOT_PORT2 should be free for the Threatpot HTTP Website."
  fi
	echo "### Port $myELASTIC_PORT should be the TPot Elasticsearch instance."
	echo
	while [ 1 != 2 ]
	do
	  read -s -n 1 -p "Continue [y/n]? " mySELECT
	  echo
	  case "$mySELECT" in
		[y,Y])
		  break
		  ;;
		[n,N])
		  exit
		  ;;
	  esac
	done
}

# Check if remote sites are available
function fuCHECKNET_GB {
  local myREMOTESITES="$1"
  mySITESCOUNT=$(echo $mySITES | wc -w)
  j=0
  for i in $myREMOTESITES;
    do
      echo $(expr 100 \* $j / $mySITESCOUNT) | dialog --title "[ Availability check ]" --backtitle "$myBACKTITLE" --gauge "\n  Now checking: $i\n" 8 80
      curl --connect-timeout 30 -IsS $i 2>&1>/dev/null
      if [ $? -ne 0 ];
        then
          dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Continue? ]" --yesno "\nAvailability check failed. You can continue, but the installation might fail." 10 50
          if [ $? = 1 ];
            then
              dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Abort ]" --msgbox "\nInstallation aborted. Exiting the installer." 7 50
              exit
            else
              break;
          fi;
      fi;
    let j+=1
    echo $(expr 100 \* $j / $mySITESCOUNT) | dialog --keep-window --title "[ Availability check ]" --backtitle "$myBACKTITLE" --gauge "\n  Now checking: $i\n" 8 80
  done;
}

############################
# III. Pre-Installer phase #
############################

fuGOT_ROOT

######################################
# IV. Prepare installer environment #
######################################

for i in "$@"
  do
    case $i in
      --port=*)
        myTHREATPOT_PORT="${i#*=}"
        shift
      ;;
      --type=http)
        myTYPE="${i#*=}"
        shift
      ;;
      --type=https)
        myTYPE="${i#*=}"
        shift
      ;;
      --type=local)
        myTYPE="${i#*=}"
        shift
      ;;
      --folder=*)
        myFOLDER="${i#*=}"
        INSTALLED=true
        shift
      ;;
      --help)
        echo "        $0 <options>"
        echo
        echo "--type=<[http, https, local]>"
		    echo "  choose Compose Files"
		    echo "  Plain HTTP (default), production with HTTPS enabled or local development"
        echo
        echo "--folder=<threatpot-path>"
        echo " absolute path to already installed ThreatPot (optional)"
        echo " default: assumes ThreatPot is not installed - installs in '\opt\ThreatPot'"
        echo
	exit
      ;;
      *)
        echo "$myINFO"
	exit
      ;;
    esac
  done

# Check if remote sites are available
fuCHECKNET_GB "$myREMOTESITES"

#######################################
# V. Installer user interaction phase #
#######################################

# Possible changes in Ports for Geedybear website
while [ 1 != 2 ]
  do
    dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Threatpot Port ]" --defaultno --yesno "\nDo you want to change the default Threatpot Web Port ($myTHREATPOT_PORT)" 7 50
    myOK=$?
	echo
    if [ "$myOK" == "0" ];
    then
	    myPORT=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Threatpot Port ]" --inputbox "\nEnter Port:" 8 40 3>&1 1>&2 2>&3 3>&-)
		if [[ $myPORT =~ ^[0-9]+$ ]] && [ $myPORT -ge 0 ] && [ $myPORT -le 65535 ];
		  then
			myTHREATPOT_PORT=$myPORT
			dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Port Accepted. ]" \
	               --msgbox "\nThreatpot's website will be deployed on Port $myTHREATPOT_PORT." 7 60
	        break
		  else
			dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Port Invalid. ]" \
	               --msgbox "\nPlease re-enter Port." 7 60
		fi
	else
		break
    fi
done

# If HTTPS need second port for HTTP redirect (cannot be 80 because of potential Honeypots)
if [ "$myTYPE" == "https" ];
  then
    while [ 1 != 2 ]
    do
      dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Threatpot (HTTP) Port ]" --defaultno --yesno "\nDo you want to change the default Threatpot (HTTP) Web Port ($myTHREATPOT_PORT2)" 7 50
      myOK=$?
    echo
      if [ "$myOK" == "0" ];
      then
        myPORT=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Threatpot (HTTP) Port ]" --inputbox "\nEnter Port:" 8 40 3>&1 1>&2 2>&3 3>&-)
      if [[ $myPORT =~ ^[0-9]+$ ]] && [ $myPORT -ge 0 ] && [ $myPORT -le 65535 ];
        then
        myTHREATPOT_PORT2=$myPORT
        dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Port Accepted. ]" \
                  --msgbox "\nThreatpot's (HTTP) Port will be $myTHREATPOT_PORT2." 7 60
            break
        else
        dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Port Invalid. ]" \
                  --msgbox "\nPlease re-enter Port." 7 60
      fi
    else
      break
      fi
    done
fi


# If TPot Elasticsearch Port (internal Docker Network) was changed
while [ 1 != 2 ]
  do
    dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Elasticsearch Port ]" --defaultno --yesno "\nDid you change the default Elasticsearch Port ($myELASTIC_PORT)" 7 50
    myOK=$?
	echo
    if [ "$myOK" == "0" ];
    then
	    myPORT=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Elasticsearch Port ]" --inputbox "\nEnter Port:" 8 40 3>&1 1>&2 2>&3 3>&-)
		if [[ $myPORT =~ ^[0-9]+$ ]] && [ $myPORT -ge 0 ] && [ $myPORT -le 65535 ];
		  then
			myELASTIC_PORT=$myPORT
			dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Port Accepted. ]" \
	               --msgbox "\nElasticsearch Port will be $myELASTIC_PORT." 7 60
	        break
		  else
			dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Port Invalid. ]" \
	               --msgbox "\nPlease re-enter Port." 7 60
		fi
	else
		break
    fi
done

dialog --clear

fuCHECK_PORTS_THREATPOT

# SuperUser Creds for Web UWSGI/Django
myUSERNAME=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Web Username ]" --inputbox "\nEnter Username:" 8 40 3>&1 1>&2 2>&3 3>&-)
if [ -z "$myUSERNAME" ];
  then
	dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Web Username ]" \
	               --msgbox "\nUsing default username \"$myTHREATPOT_USER\"" 7 60
  else
	myTHREATPOT_USER=$myUSERNAME
fi
myPASS1="pass1"
myPASS2="pass2"
mySECURE="0"
while [ "$myPASS1" != "$myPASS2"  ] && [ "$mySECURE" == "0" ]
  do
    while [ "$myPASS1" == "pass1"  ] || [ "$myPASS1" == "" ]
      do
        myPASS1=$(dialog --keep-window --insecure --backtitle "$myBACKTITLE" \
                         --title "[ Enter password for Threatpot Web User ]" \
                         --passwordbox "\nPassword" 9 60 3>&1 1>&2 2>&3 3>&-)
      done
        myPASS2=$(dialog --keep-window --insecure --backtitle "$myBACKTITLE" \
                         --title "[ Enter password again for Threatpot Web User ]" \
                         --passwordbox "\nPassword" 9 60 3>&1 1>&2 2>&3 3>&-)
    if [ "$myPASS1" != "$myPASS2" ];
      then
        dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Passwords do not match. ]" \
               --msgbox "\nPlease re-enter your password." 7 60
        myPASS1="pass1"
        myPASS2="pass2"
    fi
    mySECURE=$(printf "%s" "$myPASS1" | cracklib-check | grep -c "OK")
    if [ "$mySECURE" == "0" ] && [ "$myPASS1" == "$myPASS2" ];
      then
        dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Password is not secure ]" --defaultno --yesno "\nKeep insecure password?" 7 50
        myOK=$?
        if [ "$myOK" == "1" ];
          then
            myPASS1="pass1"
            myPASS2="pass2"
        fi
    fi
  done
myTHREATPOT_PASS=$myPASS1

# additional info for automatic creation of superuser
myTHREATPOT_EMAIL=""
myTHREATPOT_LAST_NAME=""
myTHREATPOT_FIRST_NAME=""
myTHREATPOT_EMAIL=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Web User ]" --inputbox "\nEnter an Email for the Threatpot Web User (optional):" 8 40 3>&1 1>&2 2>&3 3>&-)
myTHREATPOT_FIRST_NAME=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Web User ]" --inputbox "\nEnter an First Name for the Threatpot Web User (optional):" 8 40 3>&1 1>&2 2>&3 3>&-)
myTHREATPOT_LAST_NAME=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Web User ]" --inputbox "\nEnter an Last Name for the Threatpot Web User (optional):" 8 40 3>&1 1>&2 2>&3 3>&-)

echo

# Slack Info
mySLACK_TOKEN=""
mySLACK_CHANNEL=""
mySLACK_TOKEN=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Slack ]" --inputbox "\nEnter a Slack Token (optional):" 8 40 3>&1 1>&2 2>&3 3>&-)
mySLACK_CHANNEL=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Slack ]" --inputbox "\nEnter a Slack Channel (optional):" 8 40 3>&1 1>&2 2>&3 3>&-)

# Django Secret
myDJANGO_SECRET=""
myDJANGO_SECRET=$(dialog --keep-window --backtitle "$myBACKTITLE" --title "[ Django ]" --inputbox "\nEnter Django Secret (optional):" 8 40 3>&1 1>&2 2>&3 3>&-)

dialog --clear

##########################
# VI. Installation phase #
##########################

exec 2> >(tee "/threatpot_install.err")
exec > >(tee "/threatpot_install.log")

fuBANNER "Installing ..."

# Cloning Threatpot from GitHub
fuBANNER "Cloning Threatpot ..."
if [ "$INSTALLED" = false ] ; then
    git clone https://github.com/khulnasoft/ThreatPot $myFOLDER
fi

# Set Configs
fuBANNER "Copying config files ..."
cp $myFOLDER/.env_template $myFOLDER/.env
cp $myFOLDER/docker/env_file_template $myFOLDER/docker/env_file
cp $myFOLDER/docker/env_file_postgres_template $myFOLDER/docker/env_file_postgres

# Write changes to config files
fuBANNER "Change config files ..."

# .env - set what docker config files are used
if [ "$myTYPE" != "http" ];
  then
    #default
	sed -i '/^COMPOSE_FILE=docker\/default.yml$/ s/./#&/' $myFOLDER/.env
fi
if [ "$myTYPE" != "https" ];
  then
    #https
	sed -i '/^COMPOSE_FILE=docker\/default.yml:docker\/https.override.yml$/ s/./#&/' $myFOLDER/.env
fi
if [ "$myTYPE" != "local" ];
  then
    #local
	sed -i '/^COMPOSE_FILE=docker\/default.yml:docker\/local.override.yml$/ s/./#&/' $myFOLDER/.env
fi

#reduce version of docker compose files to work with docker-compose version from the Tpot instance
sed -i "s/version: '3.8'/version: '3.5'/g" $myFOLDER/docker/default.yml
sed -i "s/version: '3.8'/version: '3.5'/g" $myFOLDER/docker/https.override.yml
sed -i "s/version: '3.8'/version: '3.5'/g" $myFOLDER/docker/local.override.yml

# env_file - set elasticendpoint, django secret+user+pass and slack info
sed -i "/ELASTIC_ENDPOINT=/ s/$/http:\/\/elasticsearch:$myELASTIC_PORT/" $myFOLDER/docker/env_file

sed -i "/DJANGO_SECRET=/ s/$/$myDJANGO_SECRET/" $myFOLDER/docker/env_file

sed -i "/SLACK_TOKEN=/ s/$/$mySLACK_TOKEN/" $myFOLDER/docker/env_file
sed -i "/SLACK_CHANNEL=/ s/$/$mySLACK_CHANNEL/" $myFOLDER/docker/env_file

# add django superuser secrets
echo "" >> $myFOLDER/docker/env_file
echo "DJANGO_SUPERUSER_USERNAME=$myTHREATPOT_USER" >> $myFOLDER/docker/env_file
echo "DJANGO_SUPERUSER_PASSWORD=$myTHREATPOT_PASS" >> $myFOLDER/docker/env_file
echo "DJANGO_SUPERUSER_EMAIL=\'$myTHREATPOT_EMAIL\'" >> $myFOLDER/docker/env_file
echo "DJANGO_SUPERUSER_FIRST_NAME=\'$myTHREATPOT_FIRST_NAME\'" >> $myFOLDER/docker/env_file
echo "DJANGO_SUPERUSER_LAST_NAME=\'$myTHREATPOT_LAST_NAME\'" >> $myFOLDER/docker/env_file

# run superuser create comment when uwsgi starts
echo "$SUPERUSER_CREATION" >> $myFOLDER/docker/entrypoint_uwsgi.sh

# docker/default.yml set threatpot port + put in same network as TPot instance
if [ "$myTYPE" != "https" ];
  then
	sed -i -e "s/80:80/$myTHREATPOT_PORT:80/g" $myFOLDER/docker/default.yml
fi

echo "$NETWORKS" >> $myFOLDER/docker/default.yml

# docker/https.override.yml set threatpot port + SSL
if [ "$myTYPE" == "https" ];
  then
    sed -i "s/443:443/$myTHREATPOT_PORT:443/g" $myFOLDER/docker/https.override.yml
    sed -i -e "s/80:80/$myTHREATPOT_PORT2:80/g" $myFOLDER/docker/default.yml

    #TODO write user in ssl_password/combine with TPot cert?
    fuBANNER "Webuser creds"
    #htpasswd -b -c /etc/ssl/private/ssl_passwords.txt "$myU" "$myP"
    touch /etc/ssl/private/ssl_passwords.txt
    echo

    fuBANNER "NGINX Certificate"
    myINTIP=$(hostname -I | awk '{ print $1 }')
    mkdir -p /data/nginx/cert
    openssl req \
		    -nodes \
		    -x509 \
		    -sha512 \
		    -newkey rsa:8192 \
		    -keyout "/etc/ssl/private/threatpot.key" \
		    -out "/usr/local/share/ca-certificates/threatpot.crt" \
		    -days 3650 \
		    -subj '/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd' \
		    -addext "subjectAltName = IP:$myINTIP"
fi

# BUILD Docker Container - files depending on choosen Type
fuBANNER "Building Containers ..."

cd $myFOLDER
/usr/bin/docker-compose build

# Create Systemctl Service
fuBANNER "Creating Service ..."
echo "$THREATPOT_SERVICE" > /etc/systemd/system/threatpot.service
sed -i "s@\/opt\/ThreatPot@$myFOLDER@g" /etc/systemd/system/threatpot.service
# Enable+Start Systemctl Service
systemctl daemon-reload
systemctl enable threatpot.service
systemctl start threatpot.service
systemctl status threatpot.service