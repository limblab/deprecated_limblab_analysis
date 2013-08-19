function PD_array=get_all_PDS(folderpath,matchstring)
    %returns an array with impedances from every file in the folder
    %specified by folderpath where the filename contains the text in
    %matchstring
        
    foldercontents=dir(folderpath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    PD_array=[];
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
            temp=strcat(folderpath,fnames{i},'\');
            sub=dir(temp);
            fnames_sub={sub.name};
            for j=1:length(sub)
                if ~isempty(strfind(fnames_sub{j},matchstring))
                    disp(strcat('Working on: ',temp, fnames_sub{j}))
                    PD=load(strcat(temp,fnames_sub{j}));
                    [numrows numcols]=size(PD_array);
                    PD_array=[PD_array , zeros(numrows,1)];
                    for k=1:length(PD(:,1))
                        PD_array(PD(k,1),numcols+1)=PD(k,2);
                    end
                    
                end
            end
        end
    end
    
    save(strcat(folderpath,'All_PDs_',date,'.txt'),'PD_array','-ascii')
end