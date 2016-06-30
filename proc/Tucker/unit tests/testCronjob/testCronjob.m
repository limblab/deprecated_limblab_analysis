function testCronjob
    %stupid function to give output for testing cronjobs
    folderpath='/home/tucker/Desktop/GIT/limblab_analysis/proc/Tucker/unit tests/testCronjob'
    cd(folderpath)
    d=datestr(clock);
    d(isspace(d))='-'
    filename=['/home/tucker/Desktop/GIT/limblab_analysis/proc/Tucker/unit tests/testCronjob/date_',d,'.txt']
    
    save(filename,'d','-ascii')
end