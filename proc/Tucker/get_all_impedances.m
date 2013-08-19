function impedance_array=get_all_impedances(folderpath,matchstring)
    %returns an array with impedances from every file in the folder
    %specified by folderpath where the filename contains the text in
    %matchstring
        
    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    impedance_array=[];
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
            if ~isempty(strfind(fnames{i},matchstring))
                disp(strcat('Working on: ',folderpath, fnames{i}))
                impedance_array=[   impedance_array,  get_impedance_data(strcat(folderpath, fnames{i}),'elec')    ];
            end
        end
    end
    
    save(strcat(folderpath,'All_impedances_',date,'.txt'),'impedance_array','-ascii')

end