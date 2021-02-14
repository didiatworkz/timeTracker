#!/bin/bash

#                             _
#    ____                    | |
#   / __ \__      _____  _ __| | __ ____
#  / / _` \ \ /\ / / _ \| '__| |/ /|_  /
# | | (_| |\ V  V / (_) | |  |   <  / /
#  \ \__,_| \_/\_/ \___/|_|  |_|\_\/___|
#   \____/                www.atworkz.de


file="$HOME/timeTrackerReport.csv"
firstStart=0
pause=3600 #Lunch time
if [ ! -f "$file" ]
then
    echo "$file"
    echo "Date;ON;OFF;Working time;" >> $file
    firstStart=1
fi

mySeparator=";"
scriptName=$(basename "$0")

checkTime()
{
  IFS=';' read -r _Date _ON _OFF _TIME < <(tail -n1 $file)
  start=$(date -d "(date -d $_Date +%Y-%m-%d) $_ON" +"%s")
  stop=$(date -d "(date -d $_Date +%Y-%m-%d) $_OFF" +"%s")
  num=$(($stop - $start))
  if [[ $num > 18000 ]]
      then
      num=$(($num - $pause))
  fi
  min=0
  hour=0
  day=0
  if((num>59));then
      ((sec=num%60))
      ((num=num/60))
      if((num>59));then
          ((min=num%60))
          ((num=num/60))
          if((num>23));then
              ((hour=num%24))
              ((day=num/24))
          else
              ((hour=num))
          fi
      else
          ((min=num))
      fi
  else
      ((sec=num))
  fi
  echo -en "$hour"h "$min"m "$sec"s$mySeparator >> $file
}

checkRestart()
{
  IFS=';' read -r _Date _ON _OFF _TIME < <(tail -n1 $file)
  lastPower=$(date -d "(date -d $_Date +%Y-%m-%d) $_OFF" +"%s")
  end=$(($lastPower + 240))
  now=$(date +"%s")

  if [[ $end > $now ]]
      then
      IFS=';' read -r _Date _ON _more < <(tail -n1 $file)
      sed -i '$ d' $file
      echo -e $_Date$mySeparator$_ON$mySeparator"\c" >> $file
      exit 0
      else
      checkTime
  fi
}

startTracking()
{
  if [[ $firstStart == 0 ]]
  then
      checkRestart
  fi
  echo -e "\n"$(date +"%d.%m.%Y;%T")$mySeparator"\c" >> $file
}

stopTracking()
{
  echo -en "$(date +"%T")$mySeparator" >> $file
}

openFile()
{
  echo "Open file.."
	libreoffice $file &
  exit 0
}

help() {
	echo -e "${scriptName}\n"
	echo -e "Usage:\n"
  echo -e "\t ${scriptName} open\t\t\t\tOpens the log\n"
  echo -e "\t ${scriptName} start\t\t\t\tStarts recording and sets start time\n"
	echo -e "\t ${scriptName} stop\t\t\t\tStops recording and sets end time\n"
}

trap "{ stopTracking; exit 0; }" INT TERM

cmd="$1"
shift

case "$cmd" in
	start) startTracking;;
	stop)  stopTracking;;
  open)  openFile;;
	*)    help ;;
esac
