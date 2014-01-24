function bdf=load_sorted_NEV_to_bdf(fullpath)
    %takes a full path file name for an NEV file, finds the associated
    %_nodigital file, loads both and re-attaches the digital data. Then
    %converts the data into bdf format, saves the bef in a .mat file and
    %returns the bef to the calling program.

    [folderpath,fname,fext]=fileparts(fullpath);
    
    matchstring=strcat(fname,'_nodigital-');

    %find processed file. assume format of name_nodigital_#.nev and that the
    %highest number file is the correct file
    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    ind=-1;
    temp2=-1;
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
            if (strcmp(fnames{i}((length(fnames{i})-3):end),'.nev') & ~isempty(strfind(fnames{i},matchstring)))
                temp=str2num(fnames{i}((length(fnames{i})-5):(length(fnames{i})-4)));
                if temp>temp2
                    temp2=temp;
                    ind=i;
                end
            end
        end
    end
    if ind<0
        warning('LOAD_SORTED_NEV_TO_BDF:NoSortedFile','Did not find a file with a name matching the expected pattern')
    else
        fname_nodigital=fnames{ind};
    end

    NEVNSx=load_NEVNSX_object(strcat(folderpath,'\',fname,fext));
    NEV_nodigital=openNEV(strcat(folderpath,'\',fname_nodigital),'report','nomat','nosave');


    NEVNSx.NEV=merge_sorted_digital(NEVNSx.NEV,NEV_nodigital);
    clear('NEV_nodigital')


    bdf = get_nev_mat_data(NEVNSx,'verbose','progbar','noforce','noeye',3);%give text output and progreass bar. Ignore force and eyetracking. force lab3 parameters

end

