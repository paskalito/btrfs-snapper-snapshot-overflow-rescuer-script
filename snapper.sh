#!/bin/bash

#find configs

FREESPACEMINIMUM=6
echo FREESPACEMINIMUM = $FREESPACEMINIMUM


FILES=`find /etc/snapper/configs/ -type f` 

array=($FILES)

echo "The Following configs were found:"
for CONFIGS in ${array[*]}
do
    printf "   %s\n" $CONFIGS
done



for CONFIGS in ${array[*]}
do
	#find  the volumes
	VOLUMES=`cat $CONFIGS | grep SUBVOLUME | cut -d "=" -f 2 | cut -d '"' -f 2`
	echo VOLUMES = $VOLUMES

	#find free space in Gigabytes

	FREESPACE=`btrfs filesystem usage --gbytes $VOLUMES | grep Free | cut -f 3 | cut -d "." -f 1`
	echo FREESPACE = $FREESPACE

	while (( $FREESPACE < $FREESPACEMINIMUM ))
		do
		#list the oldest snapshot
		OLDESTSNAPSHOT=`btrfs subvolume list -s $VOLUMES | grep .snapshots | sort -nr | tail -1 | cut -d " " -f 14`
				
		if [ -n "$OLDESTSNAPSHOT" ] ;then

			echo OLDESTSNAPSHOT = $OLDESTSNAPSHOT

			#workaround because / ends up in // since default for all other subvolues is without / at the end.
			if [ $VOLUMES == / ] ; then
				#delete it and wait for deletion to happen (-C)
				btrfs subvolume delete -C $VOLUMES$OLDESTSNAPSHOT
	
			else
				#delete it and wait for deletion to happen (-C)
				btrfs subvolume delete -C $VOLUMES/$OLDESTSNAPSHOT
			fi
		 
			#Wait until the deletion of the subolume is finished/completed
			btrfs subvolume sync $VOLUMES
		
			#Make sure you at least get one block free'd in order to have an operatinf fs.
			btrfs balance start -v -dlimit=1 $VOLUMES
		
			#recalculate free space on the volume		
			FREESPACE=`btrfs filesystem usage $VOLUMES | grep Free | cut -f 3 | cut -d "." -f 1`
			echo FREESPACE = $FREESPACE
			echo More than $FREESPACEMINIMUM GB on Volume $VOLUMES available
		else
			echo You have Only $FREESPACE GB left on $VOLUMES but there are no snapshots left. - DELETE/MOVE SOME FILES!!!
			#In order to exit the while loop
			break
		fi

		done
	
done

