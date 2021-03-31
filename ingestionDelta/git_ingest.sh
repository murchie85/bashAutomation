#!/bin/bash

# AUTHOR: Adam McMurchie
# This job is triggered when a developer wants to do ingestion work
# Background
# -----------
# Because of environment limitations set upon us, we can not build of branches
# Nor can we develop locally or in notebook, we can only develop on cluster
# This means, due to file cross contamination - a process has been devised to allow 
# one developer to change  and test ingestion at a time by stashing changes.
# Usage
# ------
# Use Developer runs this job once they wish to begin work
# The developer makes changes locally and merges to master as normal
# Tests the jobs as normal
# Once happy, runs this a second time chosing option 2 
# Changes are then consolidated and updated on both branch and master
# Summary
# --------
# Choice: Promts user to pick which step they are performing

# Option 1: Starting ingestion work
# Gets branch name from user
# pulls updates
# Checks out branch or exit if not exists
# rebases
# CDs to working dir
# checks if in_use lockfile, exits if in use
# Creates lockfile
# Backs up all config files to delta folder
# Clears out config files and creates empty ones
# Adds changes
# updates branch
# merges branch to master
# switches back to branch

# Option 2: 
# Gets branch name from user
# pulls updates
# Adds, commits and pushes changes
# Appends developers changes to delta stash
# Clears out config
# Copies full configs back from Delta
# Gives the developer a chance to make changes if required
# Removes lockfile
# pushes to branch
# merges into master
# switches back to branch



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

	#clear
	echo '**************************************************************************************************************'
	echo '* Complete - you can now begin to make changes'
	echo '* Once done, merge to master and run this again '
	echo '* selecting option 2' 
	echo '**************************************************************************************************************'



	exit

fi

if [ $userChoice = 2 ]
then
	echo 'Checking in your changes'
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

	echo 'Adding your changes'
	git add . && \
	git add -u && \
	git commit -m 'Ingestion Work in Progress! Config Files cleared out'
	git push 
	echo 'Done!'


	cd $target_working_dir




	echo ''
	echo 'Stashing and Appending Developer changes'
	
	tail -n +2 ../$FILE_PATH_A$FILEA > "$FILE.tmp" && mv "$FILE.tmp" ../$FILE_PATH_A$FILEA 

	if [ -s ../$FILE_PATH_A$FILEA  ]
	then
		echo "" >> delta/$FILEA
		cat ../$FILE_PATH_A$FILEA >> delta/$FILEA
	else 
		echo 'File empty not copying'
	fi


	if [ -s ../$FILE_PATH_B$FILEB  ]
	then
		echo "" >> delta/$FILEB
		cat ../$FILE_PATH_B$FILEB >> delta/$FILEB
	else 
		echo 'File empty not copying'
	fi

	if [ -s ../$FILE_PATH_C$FILEC  ]
	then
		echo "" >> delta/$FILEC
		cat ../$FILE_PATH_C$FILEC >> delta/$FILEC
	else 
		echo 'File empty not copying'
	fi

	if [ -s ../$FILE_PATH_D$FILED  ]
	then
		echo "" >> delta/$FILED
		cat ../$FILE_PATH_D$FILED >> delta/$FILED
	else 
		echo 'File empty not copying'
	fi

	if [ -s ../$FILE_PATH_E$FILEE  ]
	then
		echo "" >> delta/$FILEE
		cat ../$FILE_PATH_E$FILEE >> delta/$FILEE
	else 
		echo 'File empty not copying'
	fi







	echo 'Clearing out config files'

	rm ../$FILE_PATH_A$FILEA 
	rm ../$FILE_PATH_B$FILEB 
	rm ../$FILE_PATH_C$FILEC
	rm ../$FILE_PATH_D$FILED
	rm ../$FILE_PATH_E$FILEE
	echo ''
	echo 'Done'


	echo 'Copying delta over to config'

	cp delta/$FILEA ../$FILE_PATH_A$FILEA 
	cp delta/$FILEB ../$FILE_PATH_B$FILEB 
	cp delta/$FILEC ../$FILE_PATH_C$FILEC 
	cp delta/$FILED ../$FILE_PATH_D$FILED
	cp delta/$FILEE ../$FILE_PATH_E$FILEE 
	echo ' '
	echo 'Done'



	echo 'Please have a look at the configuration files  - does this look good? If not, amend them now before proceeding.'
	read -p "Enter any key and press enter" dummy  

	#rm delta/$FILEA
	#rm delta/$FILEB
	#rm delta/$FILEC 
	#rm delta/$FILED
	#rm delta/$FILEE 

	rm $LOCKFILE


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

	#clear
	echo '**************************************************************************************************************'
	echo '* Complete - Please check your changes in master'
	echo '* If there are any issues please contact Adam McMurchie'
	echo '**************************************************************************************************************'


	exit
fi

if [ $userChoice = 3 ]
then
	echo 'exiting ...'
fi