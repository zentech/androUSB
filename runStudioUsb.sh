#!/bin/bash
#name: runStudioUsb.sh v 0.1
#date: 11/21/2016
#author: George Louis
#purpose: Running android studio from usb. shell script

device=''					#detect usb device
moPoint=~/androidUSB				#mount point for usb
droidSDK=~/Android				#symlink pointer to usb sdk
projects=~/AndroidStudioProjects		#symlink pointer to usb projects
log=$HOME/runlog.log				#log ouput of running this file
binPath=$moPoint/android-studio/bin		#binary path
toolPath=~/Android/tools			#tool path
platformlPath=~/Android/platform-tools		#platform tools
gradlePath=$moPoint/android-studio/gradle/gradle-2.14.1/bin/gradle  #gradle path
newPath=''					#new path to be added to bashrc
param="${$@:=null}"				#set parameters to arg otherwise null


#help (how to use this script
print_help() {
	echo "USAGE 1: $(basename $0) [to mount drive and add binary to ENV]"
	echo "USAGE 2: $(basename $0) studio [everything above and run studio]"
}

#mount usb drive
mount_usb() {
	device=$(fdisk -l | grep sda[0-9] | cut -d' ' -f1)
	if [ -d $moPoint ]; then
		mount -o rw $device $moPoint &>$log
	else
		mkdir $moPoint 
		mount -o rw $device $moPoint &>$log
	fi	
}

#creating Android sym links
create_links() {
	if [ ! -e "${droidSDK}" ]; then
		ln -s $moPoint/Android	$droidSDK &>$log
	fi
	if [ ! -e "${projects}" ]; then
		ln -s $moPoint/AndroidStudioProjects $pojects &>$log
	fi
}

#if no studio path found, export path and add to bashrc file
setting_paths() {
	export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
	#checking for android studio bin path
	echo $PATH | grep $binPath &>$log
	if [ $? -ne 0 ]; then
		#preparing new path
		newPath="$PATH:$binPath:$toolPath:$platformlPath:$gradlePath"
		export PATH="${newPath}"
		sed -i  "s|^export PATH.*|export PATH="$newPath"|g" $HOME/.bashrc
	fi	
}

#running studio
run_studio() {
	#number of parameters eq 1 and is studio or Studio, we launch android studio
	if ((${#param[@]} -eq 1 && ${param[0]} == "studio" || ${param[0]} == "Studio")); then
		bash $binPath/studio.sh
	elif [ ${#param[@]} -gt 1 ]; then
		print_help
	else
		echo "Finished..."
	fi
	#if studio didn't run or error were detected check log
	if [ $? -ne 0 ]; then
		echo "Check the logs for errors!..."
		ls $log
	fi
}


########################
#	MAIN
########################

touch $log
mount_usb
create_links
setting_paths
run_studio ${param[@]}


#END
	