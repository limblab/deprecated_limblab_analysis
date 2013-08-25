% Runs batch_get_cursor_kinematics on a list of files

[DateNames FileList] = CalcDecoderAge(AllFiles, '02-11-2013');

for i = 40:length(FileList)
    
    if (i== 1)
        
        [fnam,~,~] =  fileparts(findBDF_local(FileList{i,1}))
        
        PathName = fnam
        
        batch_get_cursor_kinematics
        [citadelPathstr,~,~]=fileparts(regexprep(findBDFonCitadel(FileList{i,1}),'BDFs','Filter files'));
        save(fullfile(citadelPathstr,'kinStruct.mat'),'kinStruct')

    end
        
    if i ~= 1 
        if (FileList{i,2} ~= FileList{i-1,2})
            
            [fnam,~,~] =  fileparts(findBDF_local(FileList{i,1}))

            PathName = fnam

            batch_get_cursor_kinematics
            [citadelPathstr,~,~]=fileparts(regexprep(findBDFonCitadel(FileList{i,1}),'BDFs','Filter files'));
            save(fullfile(citadelPathstr,'kinStruct.mat'),'kinStruct')
        else
            continue
        end
    end
end