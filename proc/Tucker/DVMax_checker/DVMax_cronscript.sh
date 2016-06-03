#bash script that serves as a wrapper for using DVMax_checker inside a cron job
#cd /home/tucker/Desktop/GIT/limblab_analysis/proc/Tucker/DVMax_checker/
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/tucker/Desktop/GIT/limblab_analysis/DVMax');DVMax_checker;quit"

