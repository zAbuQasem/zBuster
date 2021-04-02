#!/bin/bash

#TOOLS USED TILL NOW :
#1-nmap for portscanning   <to add more features>
#2-rustscan to pipe results to nmap
#3-feroxbuster for dirbusting   #i added new file extentions in its config file
#4-wpscan
#6-crackmapexec

mkdir Results 2>/dev/null

function usage
{
	echo "                       [+]Please Pay Attention To The Values And Their Positions[+]"
	echo "OPTIONS:"
	echo "-u         Mandatory to provide TARGET-IP"
	echo "-p         Specify a Port number."
	echo "-d         For Dirbusting MUST provide a PROTOCOL { http | https }  AND -p <portnumber>"
	echo "-x         For providing extentions for Dirbusting example : -x php  OR -x php,txt"
	echo "-a         To specifiy what to scan"
	echo "           Available OPTIONS : NMAP (full port scan)| SMTP | DNS | <port80> | POP3 | IMAP | SMB | NFS"  #specify for port 80
	echo "-a all     To scan everything! <except dirbusting> //RECOMMENDED"
	echo " "
	echo "USAGE EXAMPLES:"  					#///ADD more examples
	echo "  $0 -u <TARGET-IP> OPTIONS..."
	echo "  $0 -u 127.0.0.1 -p 80 -x php -d http"
	echo "  $0 -u 127.0.0.1 -p 443 -x php,txt -d https"
	echo "  $0 -u 127.0.0.1 -a all"
	echo "  $0 -u 127.0.0.1 -a nfs"
	echo "  $0 -u 127.0.0.1 -a{nfs,pop3,smb}  //To scan multiple services"

}

function portcheck
{
	echo "[*]Running an initial portscan ..."
	portsnmap=$(rustscan -u 5000 -g -a $host | cut -d "[" -f 2 | cut -d "]" -f 1 > portsfromrust ; cat portsfromrust)
	cat portsfromrust | tr "," "\n" > Results/ports ; rm portsfromrust  #here is created a file containing the ports
	s=$(cat Results/ports)
	for i in $s
	do
		echo "[+]Found Port -> $i"
	done
	echo ""
}

function full_ps #FUll portscan + All checks
{
	echo "[*]Enumerating open ports..."
	n=$(rustscan -u 5000 -g -a $host | cut -d "[" -f 2 | cut -d "]" -f 1 > catted ; cat catted)
	echo -n "[+]"
	rm catted
	nmap -Pn -A -p$n -T5 $host -oN Results/nmap-result > file ; rm file
	echo "[*]Doing Nmap-Vuln scan ..."
	echo -n "[*]"
	nmap -Pn -p$n -T5 --script vuln $host -oN Results/nmapVuln-result > file ; rm file
	echo "[+]Done! check --> 'Results/nmap-result  &&  Results/nmapVuln-result"
	echo ""
	#cat Results/nmap-result

}

function smtp
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "25" ]]; then
			echo "[*]Enumerating SMTP (users)..."
			echo -n "[*]"
			nmap -Pn -T5 --script smtp-enum-users $host
			echo "[*]Learn more: https://book.hacktricks.xyz/pentesting/pentesting-smtp"
		fi
	done


}
#
function pop3
{
	q=$(cat Results/ports)
	for i in $q
	do
		if [[ "$i" == "110" ]]; then
			echo "[*]Enumerating POP3 capabilties ..."
			echo -n "[*]"
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
			echo "[*]Running a Zone Transfer..."
			dig axfr @$host
			echo "[+]If no results appeared try appending the domain to 'dig axfr @<TARGET-IP> <DOMAIN NAME>' command"
			echo "[*]Learn more : https://book.hacktricks.xyz/pentesting/pentesting-dns#zone-transfer"
			echo ""
		fi
	done
			
}

#function wp
#{
		#echo "[*]Checking & Scanning WordPress"
		#wpscan  --url https://$host:443 --disable-tls-checks --no-banner --update -e u vp vt -o Results/wp-result-443 2>/dev/null
		#wpscan  --url http://$host:80 --no-banner --update  -e u vp vt -o Results/wp-result-80 2>/dev/null
		#wpscan  --url http://$host:8080 --no-banner --update  -e u vp vt -o Results/wp-result-8080 2>/dev/null
		#echo "{+}If no plugins where detected make sure to run wpscan with '--plugins-detection aggressive' "
		#echo "[*]Learn more : https://book.hacktricks.xyz/pentesting/pentesting-web#cms-scanners"
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
	echo "[*]testing WordPress"
	q=$(cat Results/ports)
	for x in $q
	do
		if [[ "$x" == "80" || "$x" == "8080" ]]
		then
			echo "[*]WhatWeb Port --> $x"
			whatweb $host:$x
			wpscan  --url http://$host:$x --no-banner --update  -e u vp vt -o Results/wp-result-$x 2>/dev/null
		elif [[ "$x" == "443" ]]; then
			echo "[*]WhatWeb Port --> $x"
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
			echo "[*]Enumerating SMB [NULL-SESSION]"
			echo "[*]Using CRACKMAPEXEC..."
			crackmapexec smb $host -u "" -p "" --shares
			echo ""
			echo "[*]Using SMBCLIENT..."
			smbmap -H $host -r
			echo ""
			echo "[*]Using NMAP to enum share paths"
			echo -n '[+]'
			nmap -Pn -p445 -T5 --script smb-enum-shares $host -oN Results/smb-enum-shares 2>/dev/null
			echo""
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
			echo "[*]Enumerating NFS..."
			w=$(showmount -e $host | grep "/")
			echo "[+]You can mount --> $w"
			echo "[*]Attempting to mount it on --> '/tmp/1'"
			q=$(showmount -e $host | grep "/" | cut -d " " -f1)
			mkdir /tmp/1 2>/dev/null
			sudo mount -t nfs $host:$q /tmp/1
			echo "[+]Done! --> Check /tmp/1"
			echo "[*]Learn more : https://book.hacktricks.xyz/pentesting/nfs-service-pentesting"
			echo ""
		fi
	done
}

function Dirbusting #Directory Bruteforcing
{
	echo "[*]Dirbusting in the background"

	if [[ "$d" == "http" ]]
			then
			feroxbuster -u http://$host:$p $x -d 2 -q -o Results/bust-$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt > f4;rm f4  # testing on it"
	elif [[ "$d" == "https" ]]
		then
			feroxbuster -u https://$host:$p $x -d 2 -q -k -o Results/bust-$p -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt  > f5;rm f5
	fi
}

#----------------------------------------------------------------------------------------------------------------------------------------------------------------
if [[ "$1" == "" ]]
then
	usage
elif [[ "$1" != "-u" ]]
	then
		echo "********ERROR! EXPECTED '-u' TO BE THE FIRST ARGUMENT"
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
	elif [[ "$a" == "wp" ]]; then
		wp $host $p

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
