function server2bdf(fileinfo)

datapath = fileinfo.datapath;
if ~exist([datapath 'Processed\' fileinfo.name '.mat'],'file')
    sorted_files = dir([datapath 'Sorted\' fileinfo.name '*.nev']);
    if isempty(sorted_files)
        sorted = 0;
        if ~exist([datapath 'Raw\' fileinfo.name '.nev'],'file')
            disp('Waiting for file to be copied to server')
            while ~exist([fileinfo.serverdatapath fileinfo.name '.nev'],'file')              
                pause(30) 
                why
            end
            disp('Done')
            copied=0;
            while copied==0
                try
                    copyfile([fileinfo.serverdatapath '\' fileinfo.name '.nev'],[datapath 'Raw\']);
                    copied=1;
                end
            end
            all_files = dir([fileinfo.serverdatapath '\' fileinfo.name '*']);
            for i=1:length(all_files)
                copyfile([fileinfo.serverdatapath '\' all_files(i).name],[datapath 'Raw\']);
            end                    
        end
    else
        sorted = 1;
    end
    currdir = pwd;
%cd 'D:\Ricardo\Miller Lab\Matlab\s1_analysis\bdf';
    if sorted            
        for iSorted = 1:length(sorted_files)
            bdf = get_cerebus_data([datapath 'Sorted\' sorted_files(iSorted).name],2);
            save([datapath 'Processed\' sorted_files(iSorted).name(1:end-4)],'bdf');
        end
    else
        bdf = get_cerebus_data([datapath 'Raw\' fileinfo.name '.nev'],2);
        save([datapath 'Processed\' fileinfo.name],'bdf');
    end        
    cd(currdir);
end
