Nfiles = 1;
targetFiles = cell(Nfiles,1);
targetPaths = cell(Nfiles,1);

dataPath = uigetdir;
%dataPath = 'C:\Users\limblab\Desktop\David SD analysis';
for i = 1:Nfiles
    [targetFiles{i} targetPaths{i}] = uigetfile({'*.nev;*.plx'},'Open .nev or .plx file',dataPath,'Multiselect','on');
end


for ii = 1:size(targetFiles)
       fullFilename = fullfile(targetPaths{ii},targetFiles{ii});
      if strcmp(targetFiles{ii}(end-3:end),'.nev')
            disp('Converting .nev file to BDF structure, please wait...');
            out_struct = get_cerebus_data(fullFilename,'verbose');
            disp('Done.');
            BDF_FileName =  strrep(targetFiles{ii},'.nev','.mat');
        elseif strcmp(targetFiles{ii}(end-3:end),'.plx')
            disp('Converting .plx file to BDF structure, please wait...');
            out_struct = get_plexon_data(fullFilename,'verbose');
            disp('Done.');
            BDF_FileName =  strrep(targetFiles{ii},'.plx','.mat');            
      end  
        fullBDFname = fullfile(targetPaths{ii},BDF_FileName);
        
        names = fieldnames(out_struct);
        for j = 1:size(names)
            if strcmp('analog',names(j))
                out_struct = rmfield(out_struct,'analog');
                break;
            end;
        end

        disp('Saving BDF struct...');
        save(fullBDFname,'out_struct');
        
       % binnedData = convertBDF2binned(fullBDFname);
end