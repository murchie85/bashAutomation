#!/bin/bash



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



echo '1. Start Ingestion Work'
echo '2. Complete Ingestion Work'
echo '3. Exit'

read -p "Enter Y to continue: " userChoice  