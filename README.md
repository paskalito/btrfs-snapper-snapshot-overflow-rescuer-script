# btrfs-snapper-snapshot-overflow-rescuer-script
A script that if regularely run with root priviledges (crontab) starts to delete oldest snapshots made with snapper if free disk space goes below a minimum you specified.

### FREESPACEMINIM

you're free too specifiy the FREESPACEMINIMUM variabel as you please. its the number of gigabytes you at least want to have free space. ( if you don't know if your btrfs filesystem gets filled up you are screwed!!)


# Be Aware

### root (don't be silly)

place the script somewhere like /usr/local/bin and give only root access to it !

### crontab

Possible entry in crontab ( runs every 1 minute)

*/1 * * * * /usr/local/bin/snapper-delete-old-snapshots.sh

### logs

Echo's of the script you should find in your system log.

### no snapshots left

if there is no snapshots left but space still below minimum it will stat a message in syslog warning in capital letters about it.



as always run at your own risk

ask if u have questions!

