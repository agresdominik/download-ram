# RAM-Downloader

RAM prices have increased by almost 100% in the past few months. Why buy RAM when one can just download it?\
That is why you can use this script to automate the downloading and installing of RAM on your device.

## Requirements

- Works only on GNU/Linux devices
- bash/zsh/fish or any other shell
- sudo access to the device 
- Enough free disk space on your device to download the RAM (on the partition mounted on /)

## Installation

Clone the repository:

```bash 
git clone https://github.com/agresdominik/download-ram.git
cd download-ram
```

Make the script executable:

```bash 
chmod +x download-ram.sh
```

Run the script:

```bash
sudo ./download-ram.sh
```

Select how much ram you want (e.g. 4GiB):

```bash 
Please select how much RAM you want to download:
1) 4GiB of RAM
2) 8GiB of RAM
3) 16GiB of RAM
Plese note you need at least the chosen amount of space on your drive + 4GiB

> 1
```

After the script is done downloading the RAM check if your system recognises it:

```bash 
$ free -h
total        used        free      shared  buff/cache   available
Mem:            15Gi       8,7Gi       911Mi        78Mi       5,1Gi       6,8Gi
Swap:          4,0Gi          0B       4,0Gi    # <-- This is what you are looking for
```

## FAQ

### Is this real?

Yes.

### How do i remove the downloaded RAM?

Check what name was assigned to your new RAM (e.g. in this example `/var/swap/swapfile0`)

```bash 
$ swapon --show
NAME                TYPE        SIZE  USED  PRIO
/var/swap/swapfile0 partition   4G    0B    -2
```

And remove with the following commands:

```bash 
$ sudo swapoff /var/swap/swapfile0
$ sudo rm /var/swap/swapfile0
```

And !!IMPORTANT!! delete the entry with the same name from fstab:

```bash 
sudo nano /etc/fstab
```

The entry looks usually like this:

```
/var/swap/swapfile0 none swap defaults 0 0
```

If you dont do this Linux may decline to boot until you fix it in safe mode.

## Disclaimer

This project is for educational and entertainment purposes only.

You are solely responsible for: \
Understanding what the script does before running it. \
Reviewing any shell scripts you download from the internet. \
Any effects (good, bad, or spectacularly unfortunate) that result from running this code on your systems.

By using this repository, you acknowledge that the author is not responsible for any data loss, downtime, misconfiguration, or other issues caused by running these scripts. :)

## Tested on:

- Debian 13
- Fedora Asahi Remix 42
- Arch Linux
