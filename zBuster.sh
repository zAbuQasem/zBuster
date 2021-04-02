#!/bin/bash

#TOOLS USED TILL NOW :
#1-nmap for portscanning   <to add more features>
#2-rustscan to pipe results to nmap
#3-feroxbuster for dirbusting   #i added new file extentions in its config file
#4-wpscan
#6-crackmapexec

RED="\e[31m"
GRAY="\e[37m"
GREEN="\e[32m"
BLUE="\e[34m"
LIGHTBLUE="\e[94m"
ENDCOLOR="\e[0m"
YELLOW="\e[33m"
FYELLOW="\e[43m"
LIGHTGREEN="\e[92m"
CYAN="\e[35m"


mkdir Results 2>/dev/null

function usage
{
	echo -e "                       ${BLUE}[*]${ENDCOLOR}${GRAY}Please Pay Attention To The Values And Their Positions${ENDCOLOR}${BLUE}[*]${ENDCOLOR}"
	echo -e "${GRAY}OPTIONS:${ENDCOLOR}"
	echo -e "-u         ${CYAN}Mandatory to provide TARGET-IP${ENDCOLOR}"
	echo -e "-p         ${CYAN}Specify a Port number.${ENDCOLOR}"
	echo -e "-d         ${CYAN}For Dirbusting MUST provide a PROTOCOL { http | https }  AND -p <portnumber>${ENDCOLOR}"
	echo -e "-x         ${CYAN}For providing extentions for Dirbusting example : -x php  OR -x php,txt${ENDCOLOR}"
	echo -e "-a         ${CYAN}To specifiy what to scan${ENDCOLOR}"
	echo -e "           ${CYAN}Available OPTIONS : NMAP (full port scan)| SMTP | DNS | <port80> | POP3 | IMAP | SMB | NFS${ENDCOLOR}"  #specify for port 80
	echo -e "-a all     ${CYAN}To scan everything! <except dirbusting> //RECOMMENDED${ENDCOLOR}"
	echo " "
	echo "USAGE EXAMPLES:"  					#///ADD more examples
	echo -e  " ${LIGHTGREEN} $0 -u <TARGET-IP> OPTIONS... ${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -p 80 -x php -d http ${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -p 443 -x php,txt -d https${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -a all${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -a nfs${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -a{nfs,pop3,smb} ${ENDCOLOR} ${RED}//To Scan Multiple Services${ENDCOLOR}"

}

function portcheck
{
	echo -e "${BLUE}[*]${ENDCOLOR}Running an initial portscan ..."
	portsnmap=$(rustscan -u 5000 -g -a $host | cut -d "[" -f 2 | cut -d "]" -f 1 > portsfromrust ; cat portsfromrust)
	cat portsfromrust | tr "," "\n" > Results/ports ; rm portsfromrust  #here is created a file containing the ports
	s=$(cat Results/ports)
	for i in $s
	do
		echo -e "${BLUE}[+]${ENDCOLOR}${YELLOW}Found Port${ENDCOLOR} -> ${RED}$i${ENDCOLOR}"
	done
	echo ""
}

function full_ps #FUll portscan + All checks
{
	echo -e "${BLUE}[*]${ENDCOLOR}Enumerating open ports..."
	n=$(rustscan -u 5000 -g -a $host | cut -d "[" -f 2 | cut -d "]" -f 1 > catted ; cat catted)
	echo -e  -n "${BLUE}[+]${ENDCOLOR}"
	rm catted
	nmap -Pn -A -p$n -T5 $host -oN Results/nmap-result > file ; rm file
	echo -e "${BLUE}[*]${ENDCOLOR}Doing Nmap-Vuln scan ..."
	echo -e -n "${BLUE}[*]${ENDCOLOR}"
	nmap -Pn -p$n -T5 --script vuln $host -oN Results/nmapVuln-result > file ; rm file
	echo -e "${YELLOW}[+]${ENDCOLOR}Done! check --> ${FYELLOW}Results/nmap-result${ENDCOLOR} &&  ${FYELLOW}Results/nmapVuln-result${ENDCOLOR}"
	echo ""
	#cat Results/nmap-result

}

function smtp
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "25" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}Enumerating SMTP (users)..."
			echo -e -n "${BLUE}[*]${ENDCOLOR}"
			nmap -Pn -T5 --script smtp-enum-users $host
			echo -e "${BLUE}[*]${ENDCOLOR}Learn more: https://book.hacktricks.xyz/pentesting/pentesting-smtp"
		fi
	done


}

function pop3
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "110" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}Enumerating POP3 capabilties ..."
			echo -e -n "${BLUE}[*]${ENDCOLOR}"
			nmap -Pn -T5 --script pop3-capabilities -sV $host #All are default scripts
		fi
	done
}

function dns
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "53" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}Running a Zone Transfer..."
			dig axfr @$host
			echo -e "${YELLOW}[+]${ENDCOLOR}If no results appeared try appending the domain to 'dig axfr @<TARGET-IP> <DOMAIN NAME>' command"
			echo ""
		fi
	done
			
}

#function wp
#{
		#echo "${BLUE}[*]${ENDCOLOR}Checking & Scanning WordPress"
		#wpscan  --url https://$host:443 --disable-tls-checks --no-banner --update -e u vp vt -o Results/wp-result-443 2>/dev/null
		#wpscan  --url http://$host:80 --no-banner --update  -e u vp vt -o Results/wp-result-80 2>/dev/null
		#wpscan  --url http://$host:8080 --no-banner --update  -e u vp vt -o Results/wp-result-8080 2>/dev/null
		#echo "{+}If no plugins where detected make sure to run wpscan with '--plugins-detection aggressive' "
		#echo "${BLUE}[*]${ENDCOLOR}Learn more : https://book.hacktricks.xyz/pentesting/pentesting-web#cms-scanners"
		#echo "{+}D0ne!"
		##cleaning 
		#for i in {80,8080,443}
		#do
			#clean=$(cat Results/wp-result-$i | cut -d " " -f 10 | grep "down")
			#if [[ "$clean" == "down" ]]
			#then
				#rm Results/wp-result-$i
			#fi
		#done
#}

function http   #Needs more work and optimization for defining https from https and cmsscanners
{
	echo -e "${BLUE}[*]${ENDCOLOR}testing WordPress"
	q=$(cat Results/ports)
	for x in $q
	do
		if [[ "$x" == "80" || "$x" == "8080" ]]
		then
			echo -e "${BLUE}[*]${ENDCOLOR}WhatWeb Port --> ${RED}$x${ENDCOLOR}"
			whatweb $host:$x
			wpscan  --url http://$host:$x --no-banner --update  -e u vp vt -o Results/wp-result-$x 2>/dev/null
		elif [[ "$x" == "443" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}WhatWeb Port --> ${RED}$x${ENDCOLOR}"
			whatweb $host:$x
			wpscan  --url https://$host:$x --disable-tls-checks --no-banner --update  -e u vp vt -o Results/wp-result-$x 2>/dev/null
		fi
	done
}

function smb     #ADD if condition so if the null byte didnt work dont do nmap
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "445" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}Enumerating SMB [NULL-SESSION]"
			echo -e "${BLUE}[*]${ENDCOLOR}Using CRACKMAPEXEC..."
			crackmapexec smb $host -u "" -p "" --shares
			echo ""
			echo -e "${BLUE}[*]${ENDCOLOR}Using SMBCLIENT..."
			smbmap -H $host -r
			echo ""
			echo -e "${BLUE}[*]${ENDCOLOR}Using NMAP to enum share paths"
			echo -e -n '${BLUE}[*]${ENDCOLOR}'
			nmap -Pn -p445 -T5 --script smb-enum-shares $host -oN Results/smb-enum-shares 2>/dev/null
			echo ""
			break
		fi

	done
}

function nfs
{
	s=$(cat Results/ports)
	for i in $s
	do
		if [[ "$i" == "2049" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}Enumerating NFS..."
			w=$(showmount -e $host | grep "/")
			echo -e "${YELLOW}[+]${ENDCOLOR}You can mount --> ${FYELLOW}$w${ENDCOLOR}"
			echo "${BLUE}[*]${ENDCOLOR}Attempting to mount it on --> ${FYELLOW}/tmp/1${ENDCOLOR}"
			q=$(showmount -e $host | grep "/" | cut -d " " -f1)
			mkdir /tmp/1 2>/dev/null
			sudo mount -t nfs $host:$q /tmp/1
			echo -e "{YELLOW}[+]${ENDCOLOR}Done! --> Check ${FYELLOW}/tmp/1${ENDCOLOR}"
			echo ""
		fi
	done
}

function Dirbusting #Directory Bruteforcing
{
	echo -e "${BLUE}[*]${ENDCOLOR}Dirbusting in the background"

	if [[ "$d" == "http" ]]
			then
			feroxbuster -u http://$host:$p $x -d 1 -q -o Results/bust-$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt > Results/ignore;rm Results/ignore  # testing on it"
	elif [[ "$d" == "https" ]]
		then
			feroxbuster -u https://$host:$p $x -d 1  -q -k -o Results/bust-$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt  > Results/ignore;rm Results/ignore
	fi
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------
if [[ "$1" == "" ]]
then
	usage
elif [[ "$1" != "-u" && "$1" != "-h" ]]
	then
		echo -e "${RED}Expected '-u' to be the first argument${ENDCOLOR}"
		echo ""
fi

while getopts ":u:p:d:x:a:c:h" arg 
do
	case $arg in
	u)
	host=${OPTARG}  #to save the value of the arg to it
	#echo "TARGET-IP : $host"
	c=$(cat Results/ports 2>/dev/null)
	if [[ "$c" == "" ]]; then
		portcheck $host
	fi
	;;

	p)
    p=${OPTARG}
    ;;

    x)
	x="-x ${OPTARG}"
    ;;
#-------------------------------------------////applying the functions
    a)
	a=${OPTARG}
	if [[ "$a" == "all" ]]; then
		full_ps $host
		smtp $host $p
		dns $host
		nfs $host
		pop3 $host $p
		smb $host
		http $host $p
		#http $host $p
	elif [[ "$a" == "nmap" ]]; then
		full_ps $host
	elif [[ "$a" == "smb" ]]; then
		smb $host
	elif [[ "$a" == "nfs" ]]; then
		nfs $host
	elif [[ "$a" == "dns" ]]; then
		dns $host
	elif [[ "$a" == "pop3" ]]; then
		pop3 $host $p
	elif [[ "$a" == "smtp" ]]; then
		smtp $host $p
	elif [[ "$a" == "http" ]]; then
		http $host $p

	fi
	;;
#------------------------------------------------////finished applying functions
	d)
	if [[ "${OPTARG}" == "http" ]]
		then
			d=${OPTARG}
			Dirbusting $d $host $p $x &
			sleep 3
				
		elif [[ "${OPTARG}" == "https" ]]
			then
				d=${OPTARG}
				Dirbusting $d $host $p $x &
				sleep 3
		
		else
			echo "INVALID VALUE -> '${OPTARG}'"
			echo ""
			usage
	fi
    ;;

    h)
	usage
	;;


    :)
	echo "Error: '-${OPTARG}' requires a VALUE."
	echo ""
	usage
	;;

	*)
	echo " '-${OPTARG}' INVALID OPTION "
	echo ""
    usage
    ;;
	esac
done
#shift $((OPTIND-1))

#TO DO
#add snmp 
#add smtp-user-enum
#3-added shell shocker hunter
#4-webdav test
#5-add what web
#redisal
