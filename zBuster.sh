#!/usr/bin/env bash

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
line2=$(for i in {1..80};do printf '-' ;done)
line3=$(for i in {1..8};do printf '#' ;done)
line4=$(for i in {1..39};do printf '-' ;done)
mkdir Results 2>/dev/null
cat <<'EOF'
       ______                               
      (____  \              _               
 _____ ____)  )_   _  ___ _| |_ _____  ____ 
(___  )  __  (| | | |/___|_   _) ___ |/ ___)
 / __/| |__)  ) |_| |___ | | |_| ____| |    
(_____)______/|____/(___/   \__)_____)_|   v1.0 
                                            

EOF
echo -e "${CYAN}Author : Zeyad AbuQasem${ENDCOLOR}"      
echo -e "${CYAN}Linkedin : https://www.linkedin.com/in/zeyad-yahya-0985971b5/${ENDCOLOR}"
echo -e "${CYAN}Youtube : https://www.youtube.com/channel/UCRPJr4hJzeJwQv0Z6_NM5iw${ENDCOLOR}"                                                
echo $line2
function usage
{
	echo ""
	echo -e "                       ${RED}[!]${ENDCOLOR}${RED}Please Pay Attention To The Values And Their Positions${ENDCOLOR}${RED}[!]${ENDCOLOR}"
	echo ""
	echo -e "${GRAY}OPTIONS                         Description${ENDCOLOR}"
	echo -e "${RED}-------                         -----------${ENDCOLOR}"
	echo -e "-u         			${GRAY}Mandatory to provide TARGET-IP${ENDCOLOR}"
	echo ""
	echo -e "-p         			${GRAY}Specify a Port number.${ENDCOLOR}"
	echo ""
	echo -e "-d         			${GRAY}For Dirbusting MUST provide a PROTOCOL { http | https }  AND -p <portnumber>${ENDCOLOR}"
	echo ""
	echo -e "-x         			${GRAY}For providing extentions for Dirbusting example : -x php  OR -x .php,.txt${ENDCOLOR}"
	echo ""
	echo -e "-s         			${GRAY}To specifiy what to scan${ENDCOLOR}"
	echo ""
	echo -e "           			${GRAY}Available OPTIONS :[ nmap (full port scan) | smtp | dns | http | pop3 | smb | nfs ]${ENDCOLOR}"
	echo ""
	echo -e "-s all     			${GRAY}To scan everything! <except dirbusting> //RECOMMENDED${ENDCOLOR}"
	echo ""
	echo "USAGE EXAMPLES:"  					#///ADD more examples
	echo -e  " ${LIGHTGREEN} $0 -u <TARGET-IP> OPTIONS... ${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -p 80 -x .php -d http ${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -p 443 -x .php,.txt -d https${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -s all${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -s nfs${ENDCOLOR}"
	echo -e  " ${LIGHTGREEN} $0 -u 127.0.0.1 -s{nfs,pop3,smb} ${ENDCOLOR} ${RED}//To Scan Multiple Services${ENDCOLOR}"
	echo ""
}

function portcheck
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Running an initial portscan${ENDCOLOR} $RED[Don't Abort the scan]${ENDCOLOR}"
	portsnmap=$(rustscan -u 5000 -g -a $host | cut -d "[" -f 2 | cut -d "]" -f 1 > portsfromrust ; cat portsfromrust)
	cat portsfromrust | tr "," "\n" > Results/.ports ; rm portsfromrust  #here i created a file containing the ports
	echo -e  -n "${YELLOW}[+]${ENDCOLOR}" 
	nmap -Pn -p- --min-rate=1000 $host >> Results/.portsforservices 
	cat Results/.portsforservices | grep ^[0-9] | grep -v 'closed' | grep -v 'filtered' |cut -d '/' -f 1 | tr '\n' ',' | sed s/,$// >> Results/.ports ;rm portsfromnmap 2>/dev/null
	cat Results/.ports | tr "," "\n" | sort -u | uniq > ppp ;cp ppp Results/.ports; rm ppp 2>/dev/null
	s=$(cat Results/.ports)
	for i in $s
	do
		echo -e "${BLUE}[+]${ENDCOLOR}${BLUE}Found Port${ENDCOLOR} -> ${RED}$i${ENDCOLOR}"
	done
	echo "" 
}

function full_ps #FUll portscan + All checks
{
	echo "$host" > /tmp/host
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating open ports...${ENDCOLOR}"
	ports=$( cat Results/.ports)
	ports=$( echo  -n $ports | tr " " "," )
	#echo -e  -n "${BLUE}[+]${ENDCOLOR}"
	sudo nmap -Pn -O -A -p$ports -T5 $host -oN Results/nmap-result &>/dev/null
	#echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Doing Nmap-Vuln scan...${ENDCOLOR}"  vulnscan
	#echo -e -n "${BLUE}[*]${ENDCOLOR}"
	echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR} --> ${YELLOW}Results/nmap-result${ENDCOLOR}"
	echo "" >> Results/nmap-result
	echo "////Don't forget to do a UDP/Vuln scan if you got stuck" >> Results/nmap-result 
	echo ""
}

function smtp
{
	q=$(cat Results/.portsforservices | grep ^[0-9] | grep -i "smtp" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" == "" ]]; then
		:
	else
		for i in $q
		do
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating SMTP[USERS & COMMANDS]...${ENDCOLOR}"
			echo -e -n "${BLUE}[*]${ENDCOLOR}"
			echo -e "\n$line" >> Results/nmap-result
			echo "                                  [#]SMTP USER RESULT[#]" >> Results/nmap-result
			echo -e "$line" >> Results/nmap-result  #design
			nmap -Pn -p$i --script smtp-enum-users $host >> Results/nmap-result
			echo -e "\n$line" >> Results/nmap-result  #design
			echo "                                  [#]SMTP COMMANDS RESULT[#]" >> Results/nmap-result
			echo -e "$line" >> Results/nmap-result
			nmap -p$i --script smtp-commands $host >> Results/nmap-result
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/nmap-result${ENDCOLOR}"
			echo ""
		done
	fi


}

function pop3
{
	q=$(cat Results/.portsforservices | grep ^[0-9] | grep -i "pop3" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" == "" ]]; then
		:
	else
		for i in "$q"
		do
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating POP3 capabilties...${ENDCOLOR}"
			echo -e -n "${BLUE}[*]${ENDCOLOR}"
			echo -e "\n$line" >> Results/nmap-result >> Results/nmap-result
			echo "                                  [#]POP3 CAPABILITIES RESULT[#]" >> Results/nmap-result
			echo -e "$line" >> Results/nmap-result  #design
			nmap -Pn -p$i --script pop3-capabilities -sV $host >> Results/nmap-result
			echo -e "${GRAY}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/nmap-result${ENDCOLOR}"
			echo ""
		done
	fi
}

function dns
{
	q=$(cat Results/.portsforservices | grep ^[0-9] | grep -i "domain" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" == "" ]]; then
		:
	else
		for i in $q
		do
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Running a DNS Zone Transfer...${ENDCOLOR}"
			dig axfr @$host
			echo -e "${RED}[!]${ENDCOLOR}${RED}If no results appeared try --> ${ENDCOLOR} ${YELLOW}dig axfr @<TARGET-IP> <DOMAIN NAME>${ENDCOLOR}"
			echo ""
		done
	fi
			
}

function wordpress
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Testing WordPress ${ENDCOLOR}${RED}[If Available]${ENDCOLOR}"
	q=$(cat Results/.portsforservices | grep ^[0-9] | fgrep -w "http" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" != "" ]]; then
		for x in $q
		do
			/usr/bin/wpscan  --url http://$host:$x --no-banner --update  -e u vp vt -o Results/wp-result-$x #2>/dev/null
			echo "" >> Results/wp-result-$x
			echo "//////If no plugins where detected make sure to run wpscan with --> '--plugins-detection aggressive'" >> Results/wp-result-$x
			clean=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 10 | grep "down")
			clean2=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 7 | grep -i 'up' | cut -d "," -f 1)
			clean3=$(cat Results/wp-result-$x 2>/dev/null | tr " " "\n" | grep '\-\-ignore-main-redirect')
			clean4=$(cat Results/wp-result-$x 2>/dev/null)
			if [[ "$clean" == "down" || "$clean2"  == "up" || "$clean3" == "--ignore-main-redirect" || "clean4" == "" ]]; then
				rm Results/wp-result-$x 2>/dev/null
				echo -e "${RED}[!]WordPress isn't Available on ${ENDCOLOR}-> ${RED}$x${ENDCOLOR}"
			else
				echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/wp-result-$x${ENDCOLOR}"
			fi		
		done
	else
		q=$(cat Results/.portsforservices | grep ^[0-9] | fgrep -w "https" | cut -d " " -f 1 | cut -d "/" -f 1)
		if [[ "$q" == "" ]]; then
			:
		else
			for x in $q
			do
				wpscan  --url https://$host:$x --disable-tls-checks --no-banner --update  -e u vp vt -o Results/wp-result-$x 2>/dev/null
				echo "" >> Results/wp-result-$x
				echo "//////If no plugins where detected make sure to run wpscan with --> '--plugins-detection aggressive' option" >> Results/wp-result-$x
				clean=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 10 | grep "down")
				clean2=$(cat Results/wp-result-$x 2>/dev/null | cut -d " " -f 7 | grep -i 'up' | cut -d "," -f 1)
				clean3=$(cat Results/wp-result-$x 2>/dev/null | tr " " "\n" | grep '\-\-ignore-main-redirect')
				if [[ "$clean" == "down" || "$clean2"  == "up" || "$clean3" == "--ignore-main-redirect" || "clean4" == "" ]]; then
					rm Results/wp-result-$x 2>/dev/null
					echo -e "${RED}[!]WordPress isn't Available on ${ENDCOLOR}-> ${RED}$x${ENDCOLOR}"
				else
					echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR}--> ${YELLOW}Results/wp-result-$x${ENDCOLOR}"
				fi
			done
		fi
	fi
}

function com-dirb
{
	q=$(cat Results/.portsforservices | grep ^[0-9] | fgrep -w "http" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" != "" ]]; then
		echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Dirbusting Common Dirs/Files${ENDCOLOR}"
		for i in $(cat Results/.portsforservices | grep ^[0-9] | fgrep -w "http" | cut -d " " -f 1 | cut -d "/" -f 1)
		do
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			echo -e "${YELLOW}$line3 ${BLUE}Dirbusting Port -> ${YELLOW}$i${ENDCOLOR} $line3${ENDCOLOR}"
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			/usr/bin/gobuster dir -u http://$host:$i -w /usr/share/wordlists/dirb/common.txt -q -t 50 -o Results/bust-common-$i
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			echo -e "${YELLOW}$line3$line3$line3$line3######${ENDCOLOR}"
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR} --> Results/bust-common-$i${ENDCOLOR}"

			echo ""
		done
	fi
	q=$(cat Results/.portsforservices | grep ^[0-9] | fgrep -w "https" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" != "" ]]; then
		echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Dirbusting Common Dirs/Files${ENDCOLOR}"
		for i in $(cat Results/.portsforservices | grep ^[0-9] | fgrep -w "https" | cut -d " " -f 1 | cut -d "/" -f 1)
		do
			echo -e "${BLUE}	    Dirbusting Port -> ${YELLOW}$i${ENDCOLOR}"
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			echo -e "${YELLOW}$line3${BLUE}Dirbusting Port -> ${YELLOW}$i${ENDCOLOR}$line3${ENDCOLOR}"
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			/usr/bin/gobuster dir -u https://$host:$i -w /usr/share/wordlists/dirb/common.txt -k -q -t 50 -o Results/bust-common-$i
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			echo -e "${YELLOW}$line3$line3$line3$line3######${ENDCOLOR}"
			echo -e "${YELLOW}$line4${ENDCOLOR}"
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! check${ENDCOLOR} --> Results/bust-common-$i${ENDCOLOR}"
			echo ""
		done
	fi

}

function http   #Needs more work and optimization for defining https from https and cmsscanners
{
	q=$(cat Results/.portsforservices | grep ^[0-9] | grep http | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$q" != "" ]]; then
		wordpress $host $p
		echo ""
		com-dirb $host $p
		
	fi
}

function smb
{
	q=$(cat Results/.portsforservices | grep ^[0-9] | grep "microsoft-ds" | cut -d " " -f 1 | cut -d "/" -f 1)
	for i in $q
	do
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating SMB [NULL-SESSION]${ENDCOLOR}"
			test=$( crackmapexec smb $host -u "" -p "" --shares 2>/dev/null )
			if [[ "$test" == "" ]]; then
				echo -e "${RED}[!]Cannot login with NULL-SESSION[!]${ENDCOLOR}"
				echo -e "${RED}[*]${ENDCOLOR}${RED}Anyway trying to list shares [Double run the scan just to make sure of the results ^-^]${ENDCOLOR}"
				echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Smbclient :${ENDCOLOR}"
				smbclient -L ////$host// -N
				echo ""
				echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Smbmap :${ENDCOLOR}"
				smbmap -H $host -r
				echo ""
			else
				echo -e "${BLUE}[*]${ENDCOLOR}${RED}Using SMBMAP...${ENDCOLOR}"
				smbmap -H $host -r
				echo ""
				echo -e "${BLUE}[*]${ENDCOLOR}${RED}Using NMAP to Enum share paths...${ENDCOLOR}"
				echo -e -n "${BLUE}[*]${ENDCOLOR}"
				nmap -Pn --script smb-enum-shares $host -oN Results/smb-enum-shares 2>/dev/null
				echo""
			fi
	done
}

function memcached
{
	echo hello
}

function redis
{
	echo hello

}


function nfs
{
	s=$(cat Results/.portsforservices | grep ^[0-9] | grep -i "nfs" | cut -d " " -f 1 | cut -d "/" -f 1)
	if [[ "$s" == "" ]]; then
		:
	else
		for i in $s
		do
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating NFS...${ENDCOLOR}"
			w=$(showmount -e $host | grep "/")
			echo -e "${YELLOW}[+]${ENDCOLOR}You can mount --> ${RED}$w${ENDCOLOR}"
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Attempting to mount it on --> ${ENDCOLOR}${YELLOW}/tmp/mount_point${ENDCOLOR}"
			q=$(showmount -e $host | grep "/" | cut -d " " -f1)
			mkdir /tmp/mount_point 2>/dev/null
			sudo mount -t nfs $host:$q /tmp/mount_point
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Done! --> ${ENDCOLOR}Check ${YELLOW}/tmp/mount_point${ENDCOLOR}"
			echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Viewing Directory Contents...${ENDCOLOR}"
			echo ""
			ls -la /tmp/mount_point
			echo ""
		done
	fi

}
function vhosts
{
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Enumerating vhosts in the background${ENDCOLOR}${BLUE}[*]${ENDCOLOR}"
	gobuster vhost -u http://$host$p -w /usr/share/SecLists-master/Discovery/DNS/subdomains-top1million-110000.txt -t 40 -q -z -o Results/bust-vhosts$p > Results/ignore;rm Results/ignore
}

function Dirbusting #Directory Bruteforcing
{
	ww=$(echo $p | cut -d ":" -f 2)
	echo -e "${BLUE}[*]${ENDCOLOR}${GRAY}Dirbusting...${ENDCOLOR}"

	if [[ "$d" == "http" ]]
	then
		gobuster dir -u http://$host$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt $x -t 50 -o Results/bust$ww

	elif [[ "$d" == "https" ]]
		then
			gobuster dir -u https://$host$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt $x -t 50 -k -o Results/bust$ww
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

while getopts ":u:p:d:x:s:c:vh" arg
do
	case $arg in
	u)
	if [[ "$UID" != "0" ]]; then
		echo ""
		echo -e "${RED}##### Please Run With SUDO #####${ENDCOLOR}"
		echo ""
		break
	else
		host=${OPTARG}  #to save the value of the arg to it
		echo ""
		echo -e "${YELLOW}[*]${ENDCOLOR}Starting on TARGET-IP:${ENDCOLOR}${RED}[$host]${ENDCOLOR}"
		c=$(cat Results/.portsforservices 2>/dev/null)
		if [[ "$c" == "" ]]; then
			echo ""
			portcheck $host
		elif [[ "$c" != "" ]]; then
			hst=$(cat /tmp/host 2>/dev/null)
			echo -e "${RED}[!]Previous TARGET-IP:[$hst]${ENDCOLOR}"
			echo ""
			#read ans
			#if [[ "$ans" == "y" ]]; then
			#	rm Results/.portsforservices 2>/dev/null
			#	clear
			#	portcheck $host
			#else
			#	clear
			#fi
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
    s)
	s=${OPTARG}
	if [[ "$s" == "all" ]]; then
		full_ps $host
		smtp $host $p $line
		dns $host
		nfs $host
		pop3 $host $p
		smb $host
		http $host $p
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "nmap" ]]; then
		full_ps $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "smb" ]]; then
		smb $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "nfs" ]]; then    
		nfs $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "dns" ]]; then
		dns $host
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "pop3" ]]; then
		pop3 $host $p  
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "smtp" ]]; then  
		smtp $host $p
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "$s" == "http" ]]; then
		http $host $p
		echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"

	fi
	;;
#------------------------------------------------////finished applying functions
	d)
	if [[ "${OPTARG}" == "http" ]]
		then
			d=${OPTARG}
			Dirbusting $d $host $p $x
			ww=$(echo $p | cut -d ":" -f 2)
			b=$( cat Results/bust$ww )
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Check results from --> ${ENDCOLOR}${YELLOW}Results/bust$ww${ENDCOLOR}"
			echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	elif [[ "${OPTARG}" == "https" ]]
		then
			d=${OPTARG}
			Dirbusting $d $host $p $x 
			b=$( cat Results/bust$ww )
			echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Check results from --> ${ENDCOLOR}${YELLOW}Results/bust$ww${ENDCOLOR}"
			echo -e "                                                ${LIGHTGREEN}[[FINISHED]]${ENDCOLOR}"
	else
		echo "INVALID VALUE -> '${OPTARG}'"
		echo ""
		usage
	fi
    ;;

    v)
	vhosts $host $p &
	sleep 2
	echo -e "${YELLOW}[+]${ENDCOLOR}${GRAY}Check results from --> ${ENDCOLOR}${YELLOW}Results/bust-vhosts$p${ENDCOLOR}"
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
