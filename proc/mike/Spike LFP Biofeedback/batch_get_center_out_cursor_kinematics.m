% Runs batch_get_cursor_kinematics on a list of files

[DateNames FileList] = CalcDecoderAge(Mini_Gam3_SingleFeat_Ch94, '02-11-2013');

for i = 2:length(FileList)
    
    if (i== 1)
        
        fnam =  findBDFonCitadel(Mini_Gam3_SingleFeat_Ch94{i,1})
        
        PathName = fnam(1:27)
        
        batch_get_cursor_kinematics
    end
        
    if i ~= 1 
        if (FileList{i,2} ~= FileList{i-1,2})
            
            fnam =  findBDFonCitadel(Mini_Gam3_SingleFeat_Ch94{i,1})

            PathName = fnam(1:27)

            batch_get_cursor_kinematics
            
        else
            continue
        end
    end
end