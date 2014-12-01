filelist = [Chewie_handControlDays(:,1); Mini_handControlDays(:,1)];
LFP = 1;
Spike = 0;

if LFP == 1
    postfix='_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts';
else
    postfix='spikePDs_allchans_bs-1cos';
end

parfor i = 1:length(filelist)
      try  
        if strncmpi(filelist{i},'Mini',4)
            if length(filelist{i}) == 31 %for Mini long format (date included) filenames; Chewie is 56
                savename=[filelist{i}(1:27),postfix,'.mat'];
            else %For Mini short format
                savename=[filelist{i}(1:19),postfix,'.mat'];
            end
        else
            if length(filelist{i}) == 32  %for Chewie
                savename = [filelist{i}(1:28),postfix,'.mat'];
            elseif length(filelist{i}) == 25 %for Chewie
                savename = [filelist{i}(1:21),postfix,'.mat'];
            elseif length(filelist{i}) == 24 %for Chewie
                savename = [filelist{i}(1:20),postfix,'.mat'];
            end
        end
        
        if exist(savename,'file')
            continue
        elseif Spike == 1
            runPDfromspikesMRS(filelist(i)) 
        elseif LFP == 1
            runPDfromLFPs3_LMPandAllFreq(filelist(i))
        end
      catch exception
          
          FilesNotRun{i} = filelist{i};
          FileExceptions{i} = exception;
          continue
      end
end