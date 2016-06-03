function NEVNSX=load_NEVNSX_object(filepath)
    %takes a path to an nev or nsx file and loads the data for that file
    %into an NEVNSX object
    
    [basepath,fname,fext]=fileparts(filepath);
    
    foldercontents=dir(basepath);
    fname_list={foldercontents.name};%extracts just the names from the foldercontents
    
    %load the data portion if it exists:
    if ~isempty(strmatch(strcat(fname,'.nev'),fname_list))
        disp(strcat('Found .nev file. loading', fname,'.nev'))
        NEVNSX.NEV=openNEV('read', [basepath '\' fname '.nev'],'nosave','nomat','report');
    else
        warning('LOAD_NEVNSX_OBJECT:NoNEVFound',strcat('Could not find: ',basepath, '\' ,fname,'.nev'))
        NEVNSX.NEV=[];
    end
    %load the NSx portions if they exist:
    if ~isempty(strmatch(strcat(fname,'.ns2'),fname_list))
        disp(strcat('Found .ns2 file. loading', fname,'.ns2'))
        NEVNSX.NS2=openNSx('read', [basepath '\' fname '.ns2'],'precision','short');
    else
        disp(strcat('did not find an NS2 file. was looking for: ',basepath, '\' , fname,'.ns2' ))
        NEVNSX.NS2=[];
    end
    if ~isempty(strmatch(strcat(fname,'.ns3'),fname_list))
        disp(strcat('Found .ns3 file. loading', fname,'.ns32'))
        NEVNSX.NS3=openNSx('read', [basepath '\' fname '.ns3'],'precision','short');
    else
        disp(strcat('did not find an NS3 file. was looking for: ',basepath, '\' , fname,'.ns3' ))
        NEVNSX.NS3=[];
    end
    if ~isempty(strmatch(strcat(fname,'.ns4'),fname_list))
        disp(strcat('Found .ns42 file. loading', fname,'.ns42'))
        NEVNSX.NS4=openNSx('read', [basepath '\' fname '.ns4'],'precision','short');
    else
        disp(strcat('did not find an NS4 file. was looking for: ',basepath, '\' , fname,'.ns4' ))
        NEVNSX.NS4=[];
    end    
    if ~isempty(strmatch(strcat(fname,'.ns5'),fname_list))
        disp(strcat('Found .ns5 file. loading', fname,'.ns5'))
        NEVNSX.NS5=openNSx('read', [basepath '\' fname '.ns5'],'precision','short');
    else
        disp(strcat('did not find an NS5 file. was looking for: ',basepath, '\' , fname,'.ns5' ))
        NEVNSX.NS5=[];
    end
   
end