

# zBuster

### zBuster is an Bash script built to automate the process of portscanning and service enumeration including a Dirbusting option.
![Alt text](https://github.com/zAbuQasem/zBuster/blob/main/Screenshots/zbuster.png)

## Tools:
 <ol>
    <li><div>Rustscan</a></li>
   <li><div>Nmap</a></li>
    <li><div>Smbclient & Smbmap</a></li>
    <li><div>Wpscan</a></li>
    <li><div>Gobuster</a></li>
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
### All integrated checks
```sh
./zBuster.sh -u <TARGET-IP> -s all
```
### Specific check
```sh
./zBuster.sh -u <TARGET-IP> -s <CHECK>
```
### Dirbusting [Dirbuster-meduim wordlist]
```sh
./zBuster.sh -u <TARGET-IP> -p <PORT> -x <FILE-EXTENSIONS [OPTIONAL]> -d <HTTPS OR HTTP>  #Must be in this order or args.
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
```sh
1- Add more checks
