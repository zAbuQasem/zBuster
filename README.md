

# zBuster

### zBuster is an Bash script built to automate the process of portscanning and service enumeration including a Dirbusting option.
![Alt text](https://github.com/zAbuQasem/zBuster/blob/main/Screenshots/zbuster2021.png)

## Installation
```sh
   git clone https://github.com/zAbuQasem/zBuster
   cd zBuster
   chmod +x *
   sudo ./install.sh
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
## Preview
![Alt text]()
  
## License

Distributed under the MIT License. See `LICENSE` for more information.

### TODO:
```sh
1- Add more checks
