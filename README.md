# MeasureFileTransferSpeed

Some tools like cp or local copying using scp, don't give you a progress bar
or show you transfer speeds. This is a bash script which measures the change
in file size over time to give you a report in real time. 

Usage:

mfts.sh [destination_file] [origination_file]

If there's only one filename provided it will tell you speed only. If there are two files 
given then it also will tell you the percent done and estimated completion time. 
