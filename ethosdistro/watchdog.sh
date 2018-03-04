#!/bin/bash
### Ajki's watchdog for EthosDistro ver 1.3.0+ (it wont work on previous versions) 
### Script will run every 5 minutes and restart miner if hashrate or watts drops bellow minimum value set bellow  

### Required jq (copy/paste in terminal without ### )
### sudo apt-get-ubuntu update && sudo apt-get-ubuntu install jq -y

### Copy script to /home/ethos/watchdog.sh 
### Make it executable, copy/paste in terminal: chmod a+x /home/ethos/watchdog.sh 

### add to crontab -e (copy/paste line bellowm without ### )
### */5 * * * * /home/ethos/watchdog.sh >/dev/null 2>&1

### If you find script usefull you can buy me a beer 
### ETH: 0x6B757Fa37D1F4C394890Dc18F8Cc4788413234F8 
### BTC 31qHHFPtR6mqgyhJ1EgMVdZ2WAr7izQQyB
### PAYPAL https://paypal.me/ajki

RedEcho(){ echo -e "$(tput setaf 1)$1$(tput sgr0)"; }
GreenEcho(){ echo -e "$(tput setaf 2)$1$(tput sgr0)"; }
YellowEcho(){ echo -e "$(tput setaf 3)$1$(tput sgr0)"; }

LogFile="/home/ethos/watchdog.log"
### EXIT IF WATCHDOG ALREADY RUNNING
if pidof -o %PPID -x "$0"; then
   echo "$(date "+%d.%m.%Y %T") EXIT: watchdog.sh already running." | tee -a "$LogFile"
   exit 1
fi

StatsJson="/var/run/ethos/stats.json"
### EXIT IF STATS.JSON IS MISSING
if [[ ! -f "$StatsJson" ]]; then
	echo "$(date "+%d.%m.%Y %T") EXIT: stats.json not available yet.(make sure ethosdistro is ver: 1.3.0+)" | tee -a "$LogFile"
	exit 1
fi
UpTimeSeconds=$(cat /proc/uptime | xargs | cut -d " " -f 1)
UpTime=$(printf '%dh:%dm:%ds' $((${UpTimeSeconds/.*}/3600)) $((${UpTimeSeconds/.*}%3600/60)) $((${UpTimeSeconds/.*}%60)))
if [  ${UpTimeSeconds/.*} -lt 300 ]; then
	echo "EXIT: System booted less then 5 minutes ago.Current running time: $UpTime"
	exit 1
fi

MinHashRate=20 # SET MINIMUM HASH RATE
MinWatts=69 # SET MINIMUM WATTS
RebootMaxRestarts=5 # REBOOT IF THERE ARE MORE THEN X RESTARTS WITHIN 1H
Miner=$(jq -r ".miner" "$StatsJson")
MinerSeconds=$(jq -r ".miner_secs" "$StatsJson")
MinerTime=$(printf '%dh:%dm:%ds' $(($MinerSeconds/3600)) $(($MinerSeconds%3600/60)) $(($MinerSeconds%60)))

if [[ ! -f /dev/shm/restartminercount ]]; then
	echo "0" > /dev/shm/restartminercount
fi
RestartMinerCount=$(cat /dev/shm/restartminercount)
YellowEcho "WATCHDOG.SH STARTED WITH FOLLOWING VALUES:"
YellowEcho "Minimum Hash Rate: $MinHashRate "
YellowEcho "Minimum Watts: $MinWatts"
YellowEcho "Reboot on to many restarts: ${RebootMaxRestarts}/${RestartMinerCount}"
YellowEcho "OS running for: $UpTime"
YellowEcho "Miner $Miner running for $MinerTime"
function RestartMiner() {
	## COUNT RESTARTS IF MINNER IS RUNNING FOR LESS THEN 1H
	if [[ $MinerSeconds -lt 3600 ]]; then
		let RestartMinerCount++
		echo "$RestartMinerCount" > /dev/shm/restartminercount
	else
		echo "0" > /dev/shm/restartminercount
	fi
	## REBOOT ON TO MANY MINERRESTART'S
	if [[ $RestartMinerCount -ge $RebootMaxRestarts ]]; then
		echo "$(date "+%d.%m.%Y %T") REBOOT: To many restarts within 1h. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
		rm "$StatsJson" -f
		sudo reboot
		exit
	fi
	rm "$StatsJson" -f
	sudo /opt/ethos/bin/minestop
	exit
}

function Json2Array() {
	Index=0
	x=' ' read -r -a Values <<< "`jq -r ".${1}" "$StatsJson"`"
	if [[ $Values != "null" ]]; then
		for Value in "${Values[@]}"
		do
			eval "$1[$Index]"="$Value"
		    let Index++
		done
	fi
}

### SKIP CHECKS IF MINER IS RUNNING LESS THEN 5 MINUTES
if [[ $MinerSeconds -gt 300 ]]; then
	Json2Array miner_hashes 
	Json2Array watts

	Index=0
	for Value in "${miner_hashes[@]}"
	do
		if [[ "${miner_hashes[$Index]/.*}" -lt $MinHashRate ]]; then
			RedEcho "$(date "+%d.%m.%Y %T") RESTART: GPU[$Index] HASH:${miner_hashes[$Index]}.[Miner was running for: $MinerTime]" | tee -a "$LogFile"
			RestartMiner
		elif [[ "${watts[$Index]/.*}" -lt $MinWatts ]]; then
			RedEcho "$(date "+%d.%m.%Y %T") RESTART: GPU[$Index] WATTS:${watts[$Index]}.[Miner was running for: $MinerTime]" | tee -a "$LogFile"
			RestartMiner
		else
			GreenEcho "STATUS OK: GPU[$Index] HASH:${miner_hashes[$Index]} WATTS:${watts[$Index]}"
		fi
	    let Index++
	done
else
	echo "EXIT: Miner running for less then 5 minutes.[Miner running for: $MinerTime]"
fi
exit
