

# zBuster

### zBuster is an Bash script built to automate the process of portscanning,Vitual hosts finding,services enumeration and a Dirbusting option.
![Alt text](https://github.com/zAbuQasem/zBuster/blob/main/Screenshots/zbuster.svg)

## Tools:
 <ol>
    <li><div>Rustscan</a></li>
   <li><div>Nmap</a></li>
    <li><div>Smbclient & Smbmap & crackmapexec</a></li>
    <li><div>Wpscan</a></li>
    <li><div>Gobuster</a></li>
 <li><div>Gospider</a></li>
  </ol>

## Installation
```sh
   git clone https://github.com/zAbuQasem/zBuster
   cd zBuster
   chmod +x *
   sudo ./install.sh
   
   #Make sure to Download Rustsan From:
   https://github.com/RustScan/RustScan/releases/
   #Then
          dpkg -i ~/Downloads/rustscan_2.0.1_amd64.deb
   ```
<!-- USAGE EXAMPLES -->
## Usage
### Important Note:
Make sure to specify a domain name for better scan results.For HackTheBox, specify the domain name in `/etc/hosts` file
```txt
#Example /etc/hosts
127.0.0.1	localhost
127.0.1.1	kali

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
#HackTheBox
10.10.10.243	spider.htb
10.10.10.240	pivotapi.htb
10.10.11.114 bolt.htb
```

### All integrated checks
```sh
sudo ./zBuster.sh -u <TARGET-IP> -s all
```
### Specific check
```sh
sudo ./zBuster.sh -u Foo.htb -s <CHECK>
```
### Dirbusting [Dirbuster-meduim wordlist]
```sh
./zBuster.sh -u Foo.htb -p <PORT> -x <FILE-EXTENSIONS [OPTIONAL]> -d <HTTPS OR HTTP>  #Must be in this order or args.
```
### For more options:
```sh
./zBuster.sh -h
```
## Preview [Took ~7 minutes]
![Alt text](https://github.com/zAbuQasem/zBuster/blob/main/Screenshots/zbuster.gif)
  
## License

Distributed under the MIT License. See `LICENSE` for more information.

### TODO:
```txt
Add more checks
```
