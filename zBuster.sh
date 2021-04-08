#!/bin/bash

RED="\e[31m"
GRAY="\e[37m"
GREEN="\e[32m"
BLUE="\e[34m"
LIGHTBLUE="\e[94m"
ENDCOLOR="\e[0m"
YELLOW="\e[33m"
FYELLOW="\e[103m"
LIGHTGREEN="\e[92m"
CYAN="\e[35m"

line=$(for i in {1..120};do printf '-' ;done)

mkdir Results 2>/dev/null
echo "     ____            _            "
echo " ___| __ ) _   _ ___| |_ ___ _ __ "
echo "|_  /  _ \| | | / __| __/ _ \ '__|"
echo " / /| |_) | |_| \__ \ ||  __/ |   "
echo "/___|____/ \__,_|___/\__\___|_|  v 1.0 "
echo ""

function usage
{
	echo -e "                      ${BLUE}[*]${ENDCOLOR}${GRAY}Please Pay Attention To The Values And Their Positions${ENDCOLOR}${BLUE}[*]${ENDCOLOR}"
	echo -e "${GRAY}OPTIONS:${ENDCOLOR}"
	echo -e "-u         ${CYAN}Mandatory to provide TARGET-IP${ENDCOLOR}"
	echo -e "-p         ${CYAN}Specify a Port number.${ENDCOLOR}"
	echo -e "-d         ${CYAN}For Dirbusting MUST provide a PROTOCOL { http | https }  AND -p <portnumber>${ENDCOLOR}"
	echo -e "-x         ${CYAN}For providing extentions for Dirbusting example : -x php  OR -x .php,.txt${ENDCOLOR}"
	echo -e "-a         ${CYAN}To specifiy what to scan${ENDCOLOR}"
	echo -e "           ${CYAN}Available OPTIONS : NMAP (full port scan)| SMTP | DNS | HTTP | POP3 | IMAP | SMB | NFS${ENDCOLOR}"
	echo -e "-a all     ${CYAN}To scan everything! <except dirbusting> //RECOMMENDED${ENDCOLOR}"
	echo " "
	echo "USAGE EXAMPLES:"  					#///ADD more examples
	echo -e  " ${LIGHTGREEN} $0 -u <TARGET-IP> OPTIONS... ${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -p 80 -x .php -d http ${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -p 443 -x .php,.txt -d https${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -a all${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -a nfs${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -a{nfs,pop3,smb} ${ENDCOLOR} ${RED}//To Scan Multiple Services${ENDCOLOR}"

}

function portcheck
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Running an initial portscan...${ENDCOLOR}"
	portsnmap=$(rustscan -u 5000 -g -a $host | cut -d "[" -f 2 | cut -d "]" -f 1 > portsfromrust ; cat portsfromrust)
	cat portsfromrust | tr "," "\n" > Results/ports ; rm portsfromrust  #here is created a file containing the ports
	s=$(cat Results/ports)
	for i in $s
	do
		echo -e "${BLUE}[+]${ENDCOLOR}${GREEN}Found Port${ENDCOLOR} -> ${RED}$i${ENDCOLOR}"
	done
	echo ""
}

function full_ps #FUll portscan + All checks
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating open ports...${ENDCOLOR}"
	ports=$(nmap -p- --min-rate=1000 -T4 $host | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
	echo -e  -n "${BLUE}[+]${ENDCOLOR}"
	nmap -Pn -A -p$ports -T5 $host -oN Results/nmap-result > file ; rm file
	#echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Doing Nmap-Vuln scan...${ENDCOLOR}"  vulnscan
	#echo -e -n "${BLUE}[*]${ENDCOLOR}"
	echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR} --> ${YELLOW}Results/nmap-result${ENDCOLOR}"
	echo ""
}

function smtp
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "25" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating SMTP[USERS & COMMANDS]...${ENDCOLOR}"
			echo -e -n "${BLUE}[*]${ENDCOLOR}"
			echo -e "\n$line" >> Results/nmap-result
			echo "                                  [+]SMTP USER RESULT" >> Results/nmap-result
			echo -e "$line" >> Results/nmap-result  #design
			nmap -Pn -p25 --script smtp-enum-users $host >> Results/nmap-result
			echo -e "\n$line" >> Results/nmap-result  #design
			echo "                                  [+]SMTP COMMANDS RESULT" >> Results/nmap-result
			echo -e "$line" >> Results/nmap-result
			nmap -p25 --script smtp-commands $host >> Results/nmap-result
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/nmap-result${ENDCOLOR}"
			echo ""
		fi
	done


}

function pop3
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "110" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating POP3 capabilties...${ENDCOLOR}"
			echo -e -n "${BLUE}[*]${ENDCOLOR}"
			echo -e "\n$line" >> Results/nmap-result >> Results/nmap-result
			echo "                                  [+]POP3 CAPABILITIES RESULT" >> Results/nmap-result
			echo -e "$line" >> Results/nmap-result  #design
			nmap -Pn -p110 --script pop3-capabilities -sV $host >> Results/nmap-result
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/nmap-result${ENDCOLOR}"
			echo ""
		fi
	done
}

function dns
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "53" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Running a DNS Zone Transfer...${ENDCOLOR}"
			dig axfr @$host
			echo -e "${RED}[+]${ENDCOLOR}${RED}If no results appeared try --> ${ENDCOLOR} ${YELLOW}dig axfr @<TARGET-IP> <DOMAIN NAME>${ENDCOLOR}"
			echo ""
		fi
	done
			
}


function http   #Needs more work and optimization for defining https from https and cmsscanners
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Testing WordPress ${ENDCOLOR}${RED}[If Available]${ENDCOLOR}"
	q=$(cat Results/ports)
	for x in $q
	do
		if [[ "$x" == "80" || "$x" == "8080" ]]
		then
			wpscan  --url http://$host:$x --no-banner --update  -e u vp vt -o Results/wp-result-$x 2>/dev/null
			echo "" >> Results/wp-result-$x
			echo "//////If no plugins where detected make sure to run wpscan with --> '--plugins-detection aggressive'" >> Results/wp-result-$x
			clean=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 10 | grep "down")
			clean2=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 7 | grep -i 'up' | cut -d "," -f 1)
			if [[ "$clean" == "down" || "$clean2"  == "up" ]]; then
				rm Results/wp-result-$x 2>/dev/null
				echo -e "${YELLOW}[+]WordPress isn't Available on ${ENDCOLOR}-> ${RED}$x${ENDCOLOR}"
			else
				echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/wp-result-$x${ENDCOLOR}"
			fi		

		elif [[ "$x" == "443" ]]; then
			wpscan  --url https://$host --disable-tls-checks --no-banner --update  -e u vp vt -o Results/wp-result-$x 2>/dev/null
			echo "" >> Results/wp-result-$x
			echo "//////If no plugins where detected make sure to run wpscan with --> '--plugins-detection aggressive' option" >> Results/wp-result-$x
			clean=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 10 | grep "down")
			clean2=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 7 | grep -i 'up' | cut -d "," -f 1)
			if [[ "$clean" == "down" || "$clean2"  == "up" ]]; then
				rm Results/wp-result-$x 2>/dev/null
				echo -e "${YELLOW}[+]WordPress isn't Available on ${ENDCOLOR}-> ${RED}$x${ENDCOLOR}"
			else
				echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/wp-result-$x${ENDCOLOR}"
			fi

		fi

	done
}

function smb
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "445" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating SMB [NULL-SESSION]${ENDCOLOR}"
			test=$(crackmapexec smb $host -u "" -p "" --shares 2>/dev/null)
			if [[ "$test" == "" ]]; then
				echo -e "${RED}[+]Cannot login with NULL-SESSION${ENDCOLOR}"
				echo ""
			else
				echo -e "${BLUE}[*]${ENDCOLOR}${RED}Using CRACKMAPEXEC...${ENDCOLOR}"
				crackmapexec smb $host -u "" -p "" --shares
				echo ""
				echo -e "${BLUE}[*]${ENDCOLOR}${RED}Using SMBCLIENT...${ENDCOLOR}"
				smbmap -H $host -r
				echo ""
				echo -e "${BLUE}[*]${ENDCOLOR}${RED}Using NMAP to Enum share paths...${ENDCOLOR}"
				echo -e -n "${BLUE}[*]${ENDCOLOR}"
				nmap -Pn -p445 --script smb-enum-shares $host -oN Results/smb-enum-shares 2>/dev/null
				echo""
			fi
		fi

	done
}

function nfs
{
	s=$(cat Results/ports)
	for i in $s
	do
		if [[ "$i" == "2049" ]]; then
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating NFS...${ENDCOLOR}"
			w=$(showmount -e $host | grep "/")
			echo -e "${YELLOW}[+]${ENDCOLOR}You can mount --> ${RED}$w${ENDCOLOR}"
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Attempting to mount it on --> ${ENDCOLOR}${YELLOW}/tmp/1${ENDCOLOR}"
			q=$(showmount -e $host | grep "/" | cut -d " " -f1)
			mkdir /tmp/1 2>/dev/null
			sudo mount -t nfs $host:$q /tmp/1
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! --> ${ENDCOLOR}Check ${YELLOW}/tmp/1${ENDCOLOR}"
			echo ""
		fi
	done
}
function vhosts
{
	gobuster vhost http://$host$p -w /usr/share/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt -q -z -e -o Results/bust-vhosts-$p > Results/ignore;rm Results/ignore
}

function Dirbusting #Directory Bruteforcing
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Dirbusting in the background${ENDCOLOR}${BLUE}[*]${ENDCOLOR}"

	if [[ "$d" == "http" ]]
			then
			gobuster dir -u http://$host$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt $x -q -z -e -o Results/bust-$p > Results/ignore;rm Results/ignore
	elif [[ "$d" == "https" ]]
		then
			gobuster dir -u https://$host$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt $x -k -q -z -e -o Results/bust-$p > Results/ignore;rm Results/ignore
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
	echo ""
	echo -e "${YELLOW}[*]${ENDCOLOR}Starting on TARGET-IP:${ENDCOLOR}${RED}[$host]${ENDCOLOR}"
	echo ""
	c=$(cat Results/ports 2>/dev/null)
	if [[ "$c" == "" ]]; then
		portcheck $host
	elif [[ "$c" != "" ]]; then
		echo -e -n "${RED}[*]Do You want to do a new portscan? ${ENDCOLOR}${GRAY}[y/n]: ${ENDCOLOR}"
		read ans
		if [[ "$ans" == "y" ]]; then
			rm Results/ports 2>/dev/null
			echo ""
			portcheck $host
		else
			echo ""
		fi
	fi
	;;

	p)
    p=":${OPTARG}"
    ;;

    x)
	x="-x ${OPTARG}"
    ;;
#-------------------------------------------////applying the functions
    a)
	a=${OPTARG}
	if [[ "$a" == "all" ]]; then
		full_ps $host
		smtp $host $p $line
		dns $host
		nfs $host
		pop3 $host $p
		smb $host
		http $host $p
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "nmap" ]]; then
		full_ps $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "smb" ]]; then
		smb $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "nfs" ]]; then    
		nfs $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "dns" ]]; then
		dns $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "pop3" ]]; then
		pop3 $host $p  
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "smtp" ]]; then  
		smtp $host $p
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$a" == "http" ]]; then
		http $host $p
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"

	fi
	;;
#------------------------------------------------////finished applying functions
	d)
	if [[ "${OPTARG}" == "http" ]]
		then
			d=${OPTARG}
			Dirbusting $d $host $p $x &
			sleep 2
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Check results from --> ${ENDCOLOR}${YELLOW}Results/bust-$p${ENDCOLOR}"
				
		elif [[ "${OPTARG}" == "https" ]]
			then
				d=${OPTARG}
				Dirbusting $d $host $p $x &
				sleep 2
				echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Check results from --> ${ENDCOLOR}${YELLOW}Results/bust-$p${ENDCOLOR}"
		
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
#redis
#vulnscan nmap at the end
#see a fix to the portscan files when dirbusting
#memcached-info
#memcached-tool
#memcdump
#memcat --servers=ip  <key>
#make a python script to create revshells including msfvenome
#sudo printf 10.10.10.188\\hms.htb >> /etc/hosts   important for parsing and adding vhosts or subdomains to /etc/hosts
