#!/usr/bin/env bash
#gs_starter.sh - starting and managing screens. Typically game servers
#-------------------------------------------------------------------
#Copyright (C) 2012 Paul-Dieter Klumpp
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------
# bash is needed!!
#
# Paul-Dieter Klumpp, 2012-11-14

# what's the q2 server binary?
Q2DED="q2proded"

# when no specific start parameter has been given, start these instances:
ACTIVATE=(1 5)

# put common settings here:
p_base="+set basedir . +fs_restart +exec q2proded.cfg"
p_action="+set game action +set gamedir action"

# put server parameters here:
PARMS[1]="$p_base $p_action +set net_port 27910 +exec aq2_1.cfg"
PARMS[2]="$p_base $p_action +set net_port 27911 +exec aq2_2.cfg"
PARMS[3]="$p_base $p_action +set net_port 27912 +exec aq2_3.cfg"
PARMS[4]="$p_base $p_action +set net_port 27913 +exec aq2_4.cfg"
PARMS[5]="$p_base $p_action +set net_port 27911 +exec aq2_5.cfg"
PARMS[6]=""
PARMS[7]=""
PARMS[8]=""
PARMS[9]=""
PARMS[10]=""
PARMS[11]=""
PARMS[12]=""
PARMS[13]=""
PARMS[14]=""
PARMS[15]=""
PARMS[16]=""
PARMS[17]=""
PARMS[18]=""
PARMS[19]=""
PARMS[20]=""
# you can define more, if you really need....




##### now, hands away... #####
for index in ${!ACTIVATE[*]}; do
	SCREEN[${ACTIVATE[$index]}]="${Q2DED}_${ACTIVATE[$index]}"
done
echo "Using screen names: ${SCREEN[*]}"

s_lib=""


function start_instance() {

	PARMS=${PARMS[$1]}
	if [ "$PARMS" != "" ]; then
		# if it still runs, don't start again
		SCREEN=${SCREEN[$1]}
		if [ "$SCREEN" != "" ]; then
			printf "."
		fi

		running=$(screen -list | grep -vi "dead" | grep -i "$SCREEN" | awk {'print $1'} | wc -l)
		if [ $running -eq 0 ]; then
			#start it daemonized via screen
			shellscript="$Q2DED-$1.sh"
cat > $shellscript <<here-doc
#!/usr/bin/env bash
while true; do
  echo
  echo "Starting '${Q2DED} ${PARMS}' $s_lib"
  echo
  LD_LIBRARY_PATH=${s_lib} ./${Q2DED} ${PARMS}
  echo
  echo "----sleep---- ctrl+c to hit the break :-)"
  echo
  sleep 3
done
here-doc
chmod u+x $shellscript
			echo "Starting '${Q2DED} ${PARMS}' $s_lib"
			screen -dm -S "${SCREEN}" "./$shellscript"
			echo "on screen: ${SCREEN[$1]}"
		fi
	fi
}


function find_filebits {
        Q64=$(file "${1}" | grep -i "x86-64" | wc -l)
        if [ "${Q64}" == "1" ]; then
		echo 64
		return 1
	fi

        Q32=$(file "${1}" | grep -i "32-bit" | wc -l)
        if [ "${Q32}" == "1" ]; then
		echo 32
		return 1
	fi

	# fallback and assume system bits
	sb=find_sysbits
	echo $sb
	return 1
}

function find_sysbits {
        S64=$(uname -a | grep -i "x86_64" | wc -l)
        if [ "${S64}" == "1" ]; then
		echo 64
	else
		echo 32
	fi
}



function f_realpath() {
        RPBIN=`which realpath`
        if [ -x "${RPBIN}" ]; then
                echo $(realpath "${1}")
        else
                echo ${1}
        fi
}



function main {
	RPQ=$(f_realpath "$Q2DED")
	FBITS=$(find_filebits $RPQ)
	SBITS=$(find_sysbits)
	#echo fbits: $FBITS
	#echo sbits: $SBITS

	if [ $SBITS -gt $FBITS ]; then
		# link to 32bit libs 
		s_lib="lib32/"
	fi

	if [ $SBITS -lt $FBITS ]; then
		echo "Can't start 64 bit executables ($Q2DED) on this system."
		return 0
	fi

	
	echo "Checking if instances ${ACTIVATE[*]} need to run."
	# start them..
	while true; do

		for index in ${!ACTIVATE[*]}
		do
			#start, if not running .. checks if running are in start_instance_loop
			start_instance ${ACTIVATE[$index]}
		done
	
        	sleep 3
	done

}



main


