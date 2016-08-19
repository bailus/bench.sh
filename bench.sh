#!/bin/bash
#####################################################################
# Benchmark Script 2 by Hidden Refuge from FreeVPS                  #
# Copyright(C) 2015 - Hidden Refuge                                 #
# License: GNU General Public License 3.0                           #
# Github: https://github.com/hidden-refuge/bench-sh-2               #
#####################################################################
# Original script by akamaras/camarg                                #
# Original: http://www.akamaras.com/linux/linux-server-info-script/ #
# Original Copyright (C) 2011 by akamaras/camarg                    #
#####################################################################
# The speed test was added by dmmcintyre3 from FreeVPS.us as a      #
# modification to the original script.                              #
# Modded Script: https://freevps.us/thread-2252.html                #
# Copyright (C) 2011 by dmmcintyre3 for the modification            #
#################################################################################
# Contributors:									#
# thirthy_speed https://freevps.us/thread-16943-post-191398.html#pid191398 	#
#################################################################################


logfile=$HOME/bench.log


log() {
	echo "$@" | tee -a $logfile
}


logSysTable() {
	log "$(printf "%16s : %s\n" "$1" "$2")"
}

sysinfo () {

	# CPU
	local cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	local cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
	local freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )

	# Memory
	local tram=$( free -m | awk 'NR==2 {print $2}' )
	local vram=$( free -m | awk 'NR==3 {print $2}' )

	# Uptime
	local up="$( uptime -p )"

	# OS Version (simple, didn't filter the strings at the end...)
	local opsy=$( cat /etc/issue.net | awk 'NR==1 {print}' ) # Operating System & Version
	local arch=$( uname -m ) # Architecture
	local lbit=$( getconf LONG_BIT ) # Architecture in Bit
	local hn=$( hostname ) # Hostname
	local kern=$( uname -r )

	# Output results
	log "System Info"
	log "-----------"
	logSysTable Processor "$cname"
	logSysTable "CPU Cores" "$cores"
	logSysTable Frequency "$freq MHz"
	logSysTable Memory "$tram MB"
	logSysTable Swap "$vram MB"
	logSysTable Uptime "$up"
	log ""
	logSysTable OS "$opsy"
	logSysTable Arch "$arch ($lbit Bit)"
	logSysTable Kernel "$kern"
	logSysTable Hostname "$hn"
	log ""
	log ""
}


logSpeedTable() {
	printf "%32s  %-24s  %8s\n" "$1" "$2" "$3" | tee -a $logfile
}

speedtest() {  #parameters# 1: flags, 2: url, 3: location, 4: provider
	local speed=$( wget -O /dev/null "$1" "$2" 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
	logSpeedTable "$3" "$4" "$speed"
}

AsiaPacificSpeedTest () {
	log "Asia/Pacific IPv4 Speed Test"
	log "----------------------------"

	local ip=$( wget -qO- ipv4.icanhazip.com ) # Getting IPv4
	logSysTable "Public address" "$ip"
	log ""

	echo "WARNING: Downloading 10x 100 MB files. 1 GB bandwidth will be used!"
	echo ""

	logSpeedTable Location Provider Speed

	# Asia
	speedtest -4 http://speedtest.tokyo.linode.com/100MB-tokyo.bin "Tokyo, Japan" Linode
	speedtest -4 http://speedtest.singapore.linode.com/100MB-singapore.bin "Singapore" Linode
	speedtest -4 http://speedtest.sng01.softlayer.com/downloads/test100.zip "Singapore" Softlayer
	speedtest -4 http://speedtest.c1.hkg1.dediserve.com/100MB.test "Equinix, Hong Kong" Dediserve

	# Australia
	speedtest -4 http://speedtest.c1.syd1.dediserve.com/100MB.test "Equinix, Sydney, Australia" Dediserve

	# US (west coast only)
	speedtest -4 http://speedtest.sea01.softlayer.com/downloads/test100.zip "Seattle, WA, US" Softlayer
	speedtest -4 http://speedtest.sjc01.softlayer.com/downloads/test100.zip "San Jose, CA, US" Softlayer
	speedtest -4 http://speedtest.fremont.linode.com/100MB-fremont.bin "Fremont, CA, US" Linode

	log ""
	log ""
}

speedtest4 () {
	log "IPv4 Speed Test"
	log "---------------"

	local ip=$( wget -qO- ipv4.icanhazip.com ) # Getting IPv4
	logSysTable "Public address" "$ip"
	log ""

	echo "WARNING: Downloading 10x 100 MB files. 1 GB bandwidth will be used!"
	echo ""

	logSpeedTable Location Provider Speed

	# CDN speed test
	speedtest -4 http://cachefly.cachefly.net/100mb.test				"CDN"				Cachefly

	# United States speed test
	speedtest -4 http://speed.atl.coloat.com/100mb.test				"Atlanta, GA, US"		Coloat
	speedtest -4 http://speedtest.dal05.softlayer.com/downloads/test100.zip		"Dallas, TX, US"		Softlayer
	speedtest -4 http://speedtest.sea01.softlayer.com/downloads/test100.zip		"Seattle, WA, US"		Softlayer
	speedtest -4 http://speedtest.sjc01.softlayer.com/downloads/test100.zip		"San Jose, CA, US"		Softlayer
	speedtest -4 http://speedtest.wdc01.softlayer.com/downloads/test100.zip		"Washington, DC, US"		Softlayer

	# Asia speed test
	speedtest -4 http://speedtest.tokyo.linode.com/100MB-tokyo.bin			"Tokyo, Japan"			Linode
	speedtest -4 http://speedtest.sng01.softlayer.com/downloads/test100.zip		"Singapore"			Softlayer

	# Europe speed test
	speedtest -4 http://mirror.i3d.net/100mb.bin					"Rotterdam, Netherlands"	id3.net
	speedtest -4 http://mirror.leaseweb.com/speedtest/100mb.bin			"Haarlem, Netherlands"		Leaseweb

	log ""
	log ""
}

speedtest6 () {
  	log "IPv6 Speed Test"
  	log "---------------"

	local ip=$( wget -qO- ipv6.icanhazip.com ) # Getting IPv6
	logSysTable "Public address" "$ip"
  	log ""

	echo "WARNING: Downloading 10x 100 MB files. 1 GB bandwidth will be used!"
	echo ""

	logSpeedTable Location Provider Speed

  	# United States speed test
	speedtest -6 http://speedtest.atlanta.linode.com/100MB-atlanta.bin		"Atlanta, GA, US"		Linode
	speedtest -6 http://speedtest.dallas.linode.com/100MB-dallas.bin		"Dallas, TX, US"		Linode
	speedtest -6 http://speedtest.newark.linode.com/100MB-newark.bin		"Newark, NJ, US"		Linode
	speedtest -6 http://speedtest.fremont.linode.com/100MB-fremont.bin		"Fremont, CA, US"		Linode
	speedtest -6 http://testfile.chi.steadfast.net/data.bin				"Chicago, IL, US"		Steadfast

	# Asia speed test
	speedtest -6 http://speedtest.tokyo.linode.com/100MB-tokyo.bin			"Tokyo, Japan"			Linode
	speedtest -6 http://speedtest.singapore.linode.com/100MB-singapore.bin		"Singapore"			Linode

	# Europe speed test
	speedtest -6 http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin		"Frankfurt, Germany"		Linode
	speedtest -6 http://speedtest.london.linode.com/100MB-london.bin		"London, UK"			Linode
	speedtest -6 http://mirror.nl.leaseweb.net/speedtest/100mb.bin			"Haarlem, Netherlands"		Leaseweb

	log ""
	log ""
}


iotest () {
	log "Disk Speed"
	log "----------"

	# Measuring disk speed with DD
	local io=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
	local io2=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
	local io3=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )

	# Calculating avg I/O (better approach with awk for non int values)
	local ioraw=$( echo $io | awk 'NR==1 {print $1}' )
	local ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
	local ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
	local ioall=$( awk 'BEGIN{print '$ioraw' + '$ioraw2' + '$ioraw3'}' )
	local ioavg=$( awk 'BEGIN{print '$ioall'/3}' )

	# Output of DD result
	logSysTable "I/O (1st run)" "$io"
	logSysTable "I/O (2nd run)" "$io2"
	logSysTable "I/O (3rd run)" "$io3"
	logSysTable "Average I/O" "$ioavg MB/s"
	log ""
	log ""
}


gbench () {
	# Improved version of my code by thirthy_speed https://freevps.us/thread-16943-post-191398.html#pid191398

	log "System Benchmark (Experimental)"
	log "-------------------------------"
	log ""

	echo "Note: The benchmark might not always work (eg: missing dependencies)."
	echo "Failures are highly possible. We're using Geekbench for this test."
	echo ""

        local page=http://www.primatelabs.com/geekbench/download/linux/
        local dl=$(wget -qO - $page | \
                 sed -n 's/.*\(https\?:[^:]*\.tar\.gz\).*/\1/p')

        local noext=${dl##*/}
        noext=${noext%.tar.gz}

        local name=${noext//-/ }

	log "File is located at $dl"
	log "Downloading and extracting $name"

        wget -qO - "$dl" | tar xzv 2>&1 >/dev/null

	log ""
	log "Starting $name"

	echo "The system benchmark may take a while.  Don't close your terminal/SSH session!"

	echo "" >> $logfile
	echo "--- Geekbench Results ---" >> $logfile
	sleep 2

	if (( $( getconf LONG_BIT ) == 64 )); then
		$HOME/dist/$noext/geekbench_x86_64 | tee $logfile
	else
		$HOME/dist/$noext/geekbench_x86_32 | tee $logfile
	fi

	echo "--- Geekbench Results End ---" >> $logfile
	echo "" >> $logfile

	log "Finished. Removing Geekbench files"
	sleep 1
	rm -rf $HOME/dist/

	log ""

        local gbl=$(sed -n '/following link/,/following link/ {/following link\|^$/b; p}' $logfile | sed 's/^[ \t]*//;s/[ \t]*$//' )

	log "Benchmark Results: $gbl"
	log "Full report available at $logfile"
	log ""
	log ""
}


hlp () {
	echo "Usage: bench.sh <option>"
	echo ""
	echo "Available options:"
	echo "default: -sd46"
	echo "-s	: Displays system information such as CPU and RAM."
	echo "-d	: Disk speed test"
	echo "-4	: IPv4 speed test"
	echo "-6	: IPv6 speed test"
	echo "-a	: IPv4 speed test for Asia/Pacific region"
	echo "-b	: System benchmark (Geekbench)"
	echo "-h	: This help page"
	echo ""
}


main () {

	# Read command line options and execute the tests

	local option
	local sys=0
	local disk=0
	local ip4=0
	local ip6=0
	local bench=0
	local help=0
	local ap=0

	if (( $# == 0 )); then
		sys=1; disk=1; ip4=1; ip6=1
	else
		while getopts sd46bha option
		do
			case $option in
				s  ) sys=1;;
				d  ) disk=1;;
				4  ) ip4=1;;
				6  ) ip6=1;;
				a  ) ap=1;;
				b  ) bench=1;;
				h  ) ;&
				\? ) ;&
				*  ) help=1;;
			esac
		done
	fi

	if (( help == 1 )) || (( $(( $sys+$disk+$ip4+$ip6+$bench+$help+$ap )) == 0 )); then
		hlp
	else

		rm -rf $logfile   # remove existing bench.log

		log ""
		log "Benchmark started on $( date )"
		log "Full benchmark log: $logfile"
		log ""
		log ""

		(( sys   == 1 ))  && sysinfo
		(( disk  == 1 ))  && iotest
		(( ip4   == 1 ))  && speedtest4
		(( ip6   == 1 ))  && speedtest6
		(( ap    == 1 ))  && AsiaPacificSpeedTest
		(( bench == 1 ))  && gbench
	fi
}
main $@
