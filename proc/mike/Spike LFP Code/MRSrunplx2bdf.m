%filelist={'Mini_Spike_LFPL_052','Mini_Spike_LFPL_055','Mini_Spike_LFPL_064'...
%    'Mini_Spike_LFPL_066','Mini_Spike_LFPL_072'};
   
direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Chewie';
cd(direct)

Files=dir(pwd);
Files(1:2)=[];
FileNames={Files.name};
PLXfiles=FileNames(cellfun(@isempty,regexp(FileNames,'\.plx'))==0);
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<!poly.*)\.mat'))==0);

for batch_get_plx_ind=1:length(PLXfiles)
    FileName=PLXfiles{batch_get_plx_ind}; 
    if isempty(intersect(regexp(FileName,'.*(?=\.plx)','match','once'), ...
            regexp(MATfiles,'.*(?=\.mat)','match','once')))
        try
        bdf=get_plexon_data(FileName);   %number is the LAB NUMBER!! Should be 1 for Mini
        flag=1;
        catch exception
        disp('file could not be converted')
        flag =0;
        end
        
        if flag == 1
        save([FileName(1:end-4),'.mat'],'bdf')
        end
        
    else
        fprintf(1,'%s already exists.\n',[regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'])
    end



end