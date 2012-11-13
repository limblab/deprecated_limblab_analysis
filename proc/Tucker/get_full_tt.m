% check a directory and create a full trial table from the individual
% trials found there. The full trial table will be concatenated in
% alphabetical order, so files must be alphabetized if sequence is
% important

%
%set the mount drive to scan and convert
folderpath='C:\Users\limblab\Desktop\dail_data\11092012\';
savestring='11092012_full_tt';
%addpath(folderpath);
foldercontents=dir(folderpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
full_tt=[];
for i=1:length(foldercontents)
    if (length(fnames{i})>3)
        if strcmp(fnames{i}((length(fnames{i})-3):end),'.mat')
            
                %if we have a .mat file
                disp(strcat('Working on: ',folderpath, fnames{i}))

                load(strcat(folderpath, fnames{i}));
                %append trials from the newly opened file to the full tt 
                %first offset the timestamps:
                make_tdf
                if isempty(full_tt)
                    full_tt=bdf.tt;
                    tt_hdr=bdf.tt_hdr;

                else
                    temp_tt=bdf.tt;
                    tshift=bdf.tt(1,tt_hdr.start_time)-full_tt(end,tt_hdr.end_time)+10;
                    temp_tt(:,tt_hdr.start_time)=temp_tt(:,tt_hdr.start_time)-tshift;
                    temp_tt(:,tt_hdr.end_time)=temp_tt(:,tt_hdr.end_time)-tshift;
                    temp_tt(:,tt_hdr.bump_time)=temp_tt(:,tt_hdr.bump_time)-tshift;
                    temp_tt(:,tt_hdr.go_cue)=temp_tt(:,tt_hdr.go_cue)-tshift;
                    full_tt=[full_tt;temp_tt];
                end
                clear bdf
            
        end
    end
end
savename=strcat(folderpath,savestring,'.mat');
save(savename, 'full_tt','tt_hdr');