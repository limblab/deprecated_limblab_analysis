function [] = runPDfromspikesMRS(filelist) 
%  runPDfromspikes runs PDs_from_spikes for multiple files
postfix='spikePDs_allchans_bs-1cos';   %LFP control file
lag=-0.1;
binlen=0.1;
pval=0.05;

for i=1:length(filelist)
    
    filewithpath=findBDFonCitadel(filelist{i},1);
    if strncmpi(filelist{i},'Mini',4)
        if length(filewithpath) == 58
            fnam=filewithpath(1:54)     %for Mini long format (date included) filenames; Chewie is 56
                savename=[filelist{i}(1:27),postfix,'.mat'];
        else
            fnam=filewithpath(1:46) %For Mini short format
                savename=[filelist{i}(1:19),postfix,'.mat'];
        end
    else
        if length(filewithpath) == 62
            fnam = filewithpath(1:58)     %for Chewie long form
            savename = [filelist{i}(1:28),postfix,'.mat'];            
        elseif length(filewithpath) == 54
            fnam = filewithpath(1:50)     %for Chewie short form
            savename = [filelist{i}(1:20),postfix,'.mat'];
        elseif length(filewithpath) == 55
            fnam = filewithpath(1:51)     %for Chewie short form LFP2
            savename = [filelist{i}(1:21),postfix,'.mat'];
        end
    end
    if ~exist(filewithpath,'file')
        disp(['File ',filewithpath,'did not exist in this folder'])
        continue
    end
    %         fnam=[filelist{i}(1:28)]
    %          if ~exist(filelist{i},'file')
    %             disp(['File ',fnam,'did not exist in this folder'])
    %             continue
    %         end
    [spikePDs,bootstrapPDS,spike_counts]=PDs_from_spikes(fnam,18,32,0,lag,binlen,pval);
    
    save(savename,'spikePDs','bootst*','spike_counts');

    %         %%% Now do spike control file
    %         postfix='spikePDs_SCont';
    %          savename=[filelist{i},numlist{i}{2},postfix];
    %         fnam=[filelist{i},numlist{i}{2}]
    %
    %         [spikePDs,bootstrapPDS]=PDs_from_spikes(fnam,18,32,0,lag,binlen,pval);
    %
    %         save(savename,'spikePDs','bootst*');
    %         clear bdf *PD*
    %     end
end
