function addSession(ex,cdsOrPath)
    %loadSessions is a method of the experiment class, and should be found
    %in the @experiment folder with the main class definition
    %
    %addSession takes adds data from a session indicated in cdsOrPath and
    %loads it into the fields of the experiment. addSession checks whether
    %cdsOrPath is a cds structure or a path, if it is a path, then
    %addSession will load the cds from the specified path, and then add the
    %data to the experiment. If cdsOrPath is a cell array of strings, then
    %addSession will loop through each cell loading the cds from the path
    %in the cell-string and then addign the data to the experiment
    %
    %ddSession will check the ex.meta.has* fields
    %to see what data to load. For example if ex.meta.hasKin==1 and
    %ex.meta.hasEmg==0; then addSession will load kinematics and ignore any
    %emg data in the cds.
    
    error('addSession:notDefined','addSession is not written yet')
    
end