# macchanism/ubuntu-server-setup
Bash setup script for Ubuntu servers

Forked from [jasonheecs/ubuntu-server-setup](https://github.com/jasonheecs/ubuntu-server-setup)

This is a setup script to automate the setup and provisioning of Ubuntu servers. It does the following:
* Adds or updates a user account with sudo access
* Adds a public ssh key for the new user account
* Disables password authentication to the server
* Deny root login to the server
* Setup Uncomplicated Firewall
* Create Swap file based on machine's installed memory
* Setup the timezone for the server (Default to "Asia/Tokyo")
* Install Network Time Protocol

Customized by Matchaism:
* Change SSH port num.
* Put secret scripts in private dir.

## Installation
1st step:
```bash
sudo apt update
sudo apt -y upgrade
sudo apt -y install git
sudo apt -y install ufw
sudo apt -y install ntp
sudo apt -y install systemd-timesyncd
```

2nd, clone this repository into your home directory. Then, scp files in private dir. from your local machine.
```bash
cd ~
git clone https://github.com/macchanism/ubuntu-server-setup.git
scp -r /path/to/ubuntu-server-setup/private server:/path/to/ubuntu-server-setup/
```

3rd, run the setup script.
```bash
cd ubuntu-server-setup
chmod +x setup.sh
sudo ./setup.sh
```

Additionaly, registar new password for the new user because the new user has no password. (Optional)
```bash
su -
sudo passwd <new_username>
```

## Setup prompts
When the setup script is run, you will be prompted to enter the username of the new user account. 

Following that, you will then be prompted to add a public ssh key (which should be from your local machine) for the new account. To generate an ssh key from your local machine:
```bash
ssh-keygen -f ~/.ssh/<keyfile_name>
cat ~/.ssh/<keyfile_name>.pub
```

Finally, you will be prompted to specify a [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for the server. It will be set to 'Asia/Tokyo' if you do not specify a value.