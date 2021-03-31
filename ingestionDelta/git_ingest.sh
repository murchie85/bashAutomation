#!/bin/bash

target_working_dir='ingestionDelta'
LOCKFILE=in_use.txt

FILEA="create_fi_env_config_sdp.csv"
FILEB="DQ_file_check_ctl.csv"
FILEC="DQ_rules_configuration.csv"
FILED="FILE_SCHEMA_INFO.csv"
FILEE="File_expected_list.csv"

FILE_PATH_A="bucketA/config/"
FILE_PATH_B="bucketB/xdp/fileingestion/master_data/"
FILE_PATH_C="bucketB/xdp/fileingestion/master_data/"
FILE_PATH_D="bucketB/xdp/fileingestion/master_data/"
FILE_PATH_E="bucketB/xdp/fileingestion/master_data/"




# Runs from Delta repo
# if start
# get branch name
# checkout branch
# git rebase
# Looks for inuseflag, otherwise adds
# if in use, exit
# Save all current config to delta folder
# Empties all config, airflow folder keeps top line
# pushes to branch
# merges to master



# if finish 
# Append changes to delta
# Copies those changed files back out to each folder
# Ask the user 'does this look good?'
# purges delta folder, removes lock
# add,commit,push, merge to master

clear
echo ''
echo ''
echo ''

echo '1. Start Ingestion Work'
echo '2. Complete Ingestion Work'
echo '3. Exit'
echo ''

read -p "Please pick an option: " userChoice  


if [ $userChoice = 1 ]
then

	clear
	echo '***Ingestion Checkout****'
	echo ' '
	# GET BRANCH NAME
	read -p "Please provide the branch name, i.e. release/new_branch: " branch_name
	echo ' '
	# CHANGE DIRECTORY BACK TO BASE
	cd ..
	echo 'Pulling updates'
	git pull
	echo 'Done'
	echo ''
	echo 'About to checkout branch, currently in location: '
	pwd

	# IF BRANCH EXISTS CHECK IT OUT 

	{
		git checkout $branch_name
	} || { 
		echo ''
		echo 'Branch not valid, please check on bitbuket - exiting'
		exit
	}

	echo 'Rebasing changes'
	git rebase
	echo 'Done'
	echo ''

	#clear
	echo '**************************************************************************************************************'
	echo '* Complete - you can now begin to make changes'
	echo '* Once done, merge to master and run this again '
	echo '* selecting option 2' 
	echo '**************************************************************************************************************'



	# IF FILE EXISTS, INGESTION IN USE
	cd $target_working_dir
	if test -f "$LOCKFILE"; then
		clear
		echo '*************************************************************************************************************'
	    echo "Sorry, Ingestion work is already being carried out by $(cat in_use.txt) please wait until they are finished."
	    echo '*************************************************************************************************************'
	    exit
	fi

	whoami > $LOCKFILE

	echo 'BACKING UP FILES'

	cp ../$FILE_PATH_A$FILEA delta 
	cp ../$FILE_PATH_B$FILEB delta 
	cp ../$FILE_PATH_C$FILEC delta 
	cp ../$FILE_PATH_D$FILED delta
	cp ../$FILE_PATH_E$FILEE delta 
	echo ' '
	echo 'Done'
	read -p "Please pick an option: " userChoice 

	echo 'Config files backed up and stored in Delta folder while developer makes changes and tests them'
	echo ' '
	echo 'Clearing out config files for development work to begin'

	rm ../$FILE_PATH_A$FILEA 
	rm ../$FILE_PATH_B$FILEB 
	rm ../$FILE_PATH_C$FILEC
	rm ../$FILE_PATH_D$FILED
	rm ../$FILE_PATH_E$FILEE
	echo ''
	echo 'Done'

	echo ''
	echo 'Populating empty files'

	echo 'Name,Value' > ../$FILE_PATH_A$FILEA 
	touch ../$FILE_PATH_B$FILEB 
	touch ../$FILE_PATH_C$FILEC
	touch ../$FILE_PATH_D$FILED
	touch ../$FILE_PATH_E$FILEE

	echo 'Done'


	echo 'Adding your changes to branch and updating master'
	git add . && \
	git add -u && \
	git commit -m 'Ingestion Work in Progress! Config Files cleared out'
	git push 
	echo 'Done!'
	echo ''

	echo 'merging to master'
	git checkout master
	git pull 
	git merge $branch_name
	git push

	echo 'switching back to dev branch'
	git checkout $branch_name


	exit

fi

if [ $userChoice = 2 ]
then
	echo 'Beginning ingestion work'
	echo ' '











	echo ''
	echo 'Stashing and Appending Developer changes'
	echo "" >> delta/$FILEA
	cat ../$FILE_PATH_A$FILEA >> delta/$FILEA
	echo "" >> delta/$FILEB
	cat ../$FILE_PATH_B$FILEB >> delta/$FILEB
	echo "" >> delta/$FILEC
	cat ../$FILE_PATH_C$FILEC >> delta/$FILEC
	echo "" >> delta/$FILED
	cat ../$FILE_PATH_D$FILED >> delta/$FILED
	echo "" >> delta/$FILEE
	cat ../$FILE_PATH_E$FILEE >> delta/$FILEE



	echo 'Please have a look at the configuration files  - does this look good?'
	read -p "y/n : " validate  
	if [ $validate != 'y' ]
	then
		echo 'Sorry, it looks like the append step failed. Please contact Adam McMurchie or fix the config files, then push to branch and create pull request. Delete the in_use.txt and remove conents of delta once done.'
	fi

	echo "Updating repo"

	exit
fi

if [ $userChoice = 3 ]
then
	echo 'exiting ...'
fi