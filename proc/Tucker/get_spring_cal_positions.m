%script to extract calibration data for the LSB motors:

%set folder to look at
folderpath='E:\LSB motor cal\'


%get list of nev files
foldercontents=dir(folderpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
file_list=[];
for i=1:length(foldercontents)
    if (length(fnames{i})>3)
        if (strcmp(fnames{i}((length(fnames{i})-3):end),'.nev') )
            file_list(length(file_list)+1)=i;
        end
    end
end
%loop across list
for i=1:length(file_list)
    %open file
    if isempty(strmatch( strcat( fnames{file_list(i)}(1:(length(fnames{file_list(i)})-3)), 'mat'),fnames))
        %if we haven't found a .mat file to match the .nev then make
        %one

        disp(strcat('Working on: ',folderpath, fnames{file_list(i)}))
        try
            bdf=get_cerebus_data(strcat(folderpath, fnames{file_list(i)}),3,'verbose','noeye');
            disp(strcat('Saving: ',strcat(folderpath, fnames{file_list(i)}(1:(length(fnames{file_list(i)})-3)), 'mat')))
            save( strcat(folderpath, fnames{file_list(i)}(1:(length(fnames{file_list(i)})-3)), 'mat'), 'bdf','-v7.3')
        catch temperr
            disp(strcat('Failed to process: ', folderpath,fnames{file_list(i)}))
            disp(temperr.identifier)
            disp(temperr.message)
        end
    else
        load(strcat(folderpath, fnames{file_list(i)}(1:(length(fnames{file_list(i)})-3)), 'mat'));
    end
    
    %make tdf
    make_tdf
    %delete trials in the 0deg direction
    bdf.TT=bdf.TT(   bdf.TT(:,bdf.TT_hdr.bump_dir)>90   ,:);
    % find time during the bump where the handle is still and take mean
    % position
    for j=1:length(bdf.TT(:,1))
        spd=squrt(bdf.xvel.^2+bdf.yvel.^2);
        acc=diff(spd);
        px(j)=mean(bdf.xpos( spd<.001 & acc<.001  ));
        py(j)=mean(bdf.ypos( spd<.001 & acc<.001  ));
        
    end
    
    %average across the trials to produce an estimate of the displacement
    posx(i)=mean(px);
    posy(i)=mean(py);
    
    
end






