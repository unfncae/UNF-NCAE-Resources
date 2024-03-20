#!/usr/bin/env python3

"""
This script was designed by Bombenheimer(Bruce) as part of the NCAE competition.

Follow me on GitHub for more projects like these and to collaborate!

https://github.com/Bombenheimer/

* THIS SCRIPT MUST BE RUN AS ROOT *
"""

# IMPORTING NECESSARY MODULES
from time import sleep
from subprocess import run
from sys import exit
from os import geteuid 

# CHECK IF THE SCRIPT IS BEING RAN AS ROOT
def CheckRoot():
    return geteuid() == 0

# PRINT WELCOME MESSAGE
def PrintWelcome():
    MSG = """
    Welcome to Linux Jumpstart!
    I will help you set everything up and make things easier!

    Press Enter to continue.
    """
    MSG_LECTURE = """
    As you are running this script as sudo, and many of
    the services that I will be setting up must be run as
    root or with sudo as well, you have to make sure you
    are responsible and manage things accordingly. So...

    """

    STEP_MSG = """
    We will be setting up your system in just a couple of easy steps:

        [1] - Identify your system
        [2] - Configure IP Address
        [3] - Upgrade and referesh the system
        [4] - Install vsftpd
        [5] - Set up UFW
        [6] - Set up SSH 

    Press Enter to continue.
    """

    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    for char in MSG_LECTURE:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("May i use sudo? (yes/no): ")

    if (userCont == "no"):
        exit(0)

    for char in STEP_MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    return 0

# IDENTIFY SYSTEM
def SystemIdentify():
    distroId = ""

    MSG = """
    Lets identify your system.

    Press Enter to continue.
    """
    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    with open('/etc/os-release', 'r') as file:
        lines = file.readlines()
        for line in lines:
            if ('ID=' in line) and not('_ID' in line):
                distroId = line.strip()
    
    if ("kali" in distroId):
        distroId = "Kali"
    elif ("ubuntu" in distroId):
        distroId = "Ubuntu"
    elif ("centos" in distroId):
        distroId = "CentOS"
    else:
        distroId = distroId[3:]

    print("    Finding distribution...")
    print()
    sleep(2)
    print(f"    Your distribution is {distroId} GNU/Linux!")
    sleep(2)
    
    return distroId

# CONFIGURE IP ADDRESS
def IpConfigure(distroId):
    teamNum = 0
    uuid_eth0 = ""
    uuid_eth1 = ""
    topology_ip = ""
    topology_ip_eth1 = ""

    MSG = """
    Lets configure your IP address.

    Press Enter to continue.
    """
    MSG_TEAM_NUMBER = """
    Enter your team number.
    """
    MSG_ENTER_TOPOLOGY = """
    Enter IP Address on Topology for eth0.
    """
    MSG_ENTER_TOPOLOGY_ETH1 = """
    Enter IP Address on Topology for eth1.
    """

    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    for char in MSG_TEAM_NUMBER:
        print(char, end='', flush=True)
        sleep(0.01)

    teamNum = input("Team number: ")

    if (distroId == "CentOS"):
        for char in MSG_ENTER_TOPOLOGY:
            print(char, end='', flush=True)
            sleep(0.01)

        topology_ip = input("Topology IP eth0: ")

        for char in MSG_ENTER_TOPOLOGY_ETH1:
            print(char, end='', flush=True)
            sleep(0.01)

        topology_ip_eth1 = input("Topology IP eth1: ")

    KALI_NET_CONFIG = f"""
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    source /etc/network/interfaces.d/*

    # The loopback network interface
    auto lo
    iface lo inet loopback

    auto eth0
    iface eth0 inet static
        address 172.20.{teamNum}.2
        netmask 255.255.0.0
        gateway 192.168.{teamNum}.2
    """
    UBUNTU_NET_CONFIG = f"""
    # Let NetworkManager manage all devices on this system
    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        ens18:
           addresses:
             - 192.168,{teamNum}.1/24
           gateway4: 192.168.{teamNum}.2
    """
    CENTOS_NET_CONFIG_ETH0 = f"""
    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=static
    DEFROUTE=yes
    IPV4_FAILIURE_FATAL=no
    IPV6INIT=yes
    IPV6_AUTOCONF=yes
    IPV6_DEFROUTE=yes
    IPV6_FAILURE_FATAL=no
    IPV6_ADDR_GEN_MODE=stable-privacy
    NAME=eth0
    DEVICE=eth0
    ONBOOT=yes
    IPADDR={topology_ip}
    NETMASK=255.255.0.0
    ZONE=external
    """
    CENTOS_NET_CONFIG_ETH1 = f"""
    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=static
    DEFROUTE=yes
    IPV4_FAILIURE_FATAL=no
    IPV6INIT=yes
    IPV6_AUTOCONF=yes
    IPV6_FAILURE_FATAL=no
    IPV6_ADDR_GEN_MODE=stable-privacy
    NAME=eth1
    DEVICE=eth1
    ONBOOT=yes
    IPADDR=
    NETMASK=255.255.255.0
    ZONE=internal
    """
    
    print(f"    Generating a config file for {distroId}...")

    if (distroId == "Kali"):
        with open('Kali-NetConfig.conf', 'w') as file:
            for char in KALI_NET_CONFIG:
                file.write(char)
        sleep(2)
    elif (distroId == "Ubuntu"):
        with open('Ubuntu-NetConfig.conf', 'w') as file:
            for char in UBUNTU_NET_CONFIG:
                file.write(char)
        sleep(2)
    elif (distroId == "CentOS"):
        with open('/etc/sysconfig/network-scripts/ifcfg-eth0', 'r') as netfile0:
            externalLines = netfile0.readlines()
            for line in externalLines:
                if ("UUID=" in line):
                    uuid_eth0 = line.strip()

        with open('/etc/sysconfig/network-scripts/ifcfg-eth1', 'r') as netfile1:
            internalLines = netfile1.readlines()
            for line in internalLines:
                if ("UUID=" in line):
                    uuid_eth1 = line.strip()

        with open('CentOS-NetConfig-eth0.conf', 'w') as file:
            for char in CENTOS_NET_CONFIG_ET0:
                file.write(char)
            file.write('UUID=', uuid_eth0)

        with open('CentOS-NetConfig-eth1.conf', 'w') as file2:
            for char in CENTOS_NET_CONFIG_ETH1:
                file2.write(char)
            file.write('UUID=', uuid_eth1)
        sleep(2)

    return 0

# UPGRADE AND REFRESH THE SYSTEM
def UpgradeAndRefresh():
    MSG = """
    Lets upgrade and refresh your system.

    Press Enter to continue.
    """

    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    print("    Updating system...")
    print()
    systemUpdate = run(['apt-get', 'update'])
    print()
    print("    Upgrading system...")
    systemUpgrade = run(['apt-get', 'upgrade', '-y'])
    print()
    print("    Upgrading distribution...")
    distUpgrade = run(['apt-get', 'dist-upgrade', '-y'])
    print()
    print("    Removing unused packages...")
    autoRemove = run(['apt-get', 'autoremove', '-y'])
    print()
    print("    Removing orphaned dependencies...")
    autoClean = run(['apt-get', 'autoclean'])
    print()
    
    if ((systemUpdate.returncode == 0) and 
        (systemUpgrade.returncode == 0) and 
        (distUpgrade.returncode == 0) and
        (autoRemove.returncode == 0) and
        (autoClean.returncode == 0)):
        print()
        print("    Success!")
        sleep(2)

    return 0

# SET UP FTP
def FtpSet():
    MSG = """
    Lets install vsftpd.

    Press Enter to continue.
    """
    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    print("    Installing vsftpd...")
    print()
    installation = run(['apt-get', 'install', 'vsftpd'])
    print()

    return 0

# SET UP UFW RULES
def UfwRuling():
    MSG = """
    Lets install UFW.

    Press Enter to continue.
    """

    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    print("    Installing ufw...")
    print()
    installation = run(['apt-get', 'install', 'ufw'])
    print()
    print("    Starting ufw...")
    enable = run(['ufw', 'enable'])
    print()

    check_online = run(['ufw', 'status'], capture_output=True, text=True)
    stdout_lines = check_online.stdout.splitlines()

    for line in stdout_lines:
        if ("inactive" in line):
            print("    UFW is online.")

    return 0

# SET UP SSH
def SshSet():
    MSG = """
    Lets set up SSH.

    Press Enter to continue.
    """
    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)

    userCont = input("")

    print("    Installing ssh...")
    install = run(['apt-get', 'install', 'ssh'])
    print()
    print("    Starting ssh...")
    setup = run(['systemctl', 'start' 'ssh'])

    return 0

# DONE MESSAGE
def PrintDone():
    MSG = """
    Be sure that your network config files are 
    correct and cat them to the file, and save
    your ssh keys somewhere where they cannot
    tampered with. Bye!
    """
    for char in MSG:
        print(char, end='', flush=True)
        sleep(0.01)
    
    sleep(2)
    exit(0)

    return 0

# MAIN FUNCTION
def main():
    distroId = ""
    SKIP_MSG = """
    Because you do not have a Kali, Ubuntu, or CentOS machine, I will skip
    the IP configuration process for now. Is that okay?
    """

    PrintWelcome()
    distroId = SystemIdentify()
    setupSteps = [(IpConfigure, distroId)]
    
    for function, args in setupSteps:
        if (distroId != "Kali" and distroId != "Ubuntu" and distroId != "CentOS"):
            for char in SKIP_MSG:
                print(char, end='', flush=True)
                sleep(0.01)

            userCont = input("Enter an option (yes/no): ")

            if (userCont == "no"):
                exit(0)

            continue

    UpgradeAndRefresh()
    FtpSet()
    UfwRuling()
    SshSet()
    PrintDone()

    return 0

if __name__ == "__main__":
    if CheckRoot():
        main()
    else:
        print()
        print("    WARNING: Jumpstart must be run as root!")
        sleep(2)
        exit(0)
