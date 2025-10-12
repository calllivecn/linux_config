#!/usr/bin/bash

EFI=/boot/efi

mount -v UUID=76BC-C31C $EFI

COUNT_TXT=$EFI/EFI/count.txt

if [ -f $COUNT_TXT ];then
	source $COUNT_TXT
else
	echo "COUNT=3" > $COUNT_TXT
	exit 0
fi

if [ $COUNT -le 0 ];then
	echo "COUNT=3" > $COUNT_TXT
else
	COUNT=$[COUNT - 1]
	echo "COUNT=${COUNT}" > $COUNT_TXT
fi

umount -v $EFI
