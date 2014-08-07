%runPDfromspikes runs PDs_from_spikes for multiple files
% 'Chewie_Spike_LFP_0215201200','Chewie_Spike_LFP_0217201200',
%  filelist={'Chewie_Spike_LFP_0902201100','Chewie_Spike_LFP_0906201100',...
%     'Chewie_Spike_LFP_0907201100','Chewie_Spike_LFP_0908201100',...
%     'Chewie_Spike_LFP_0919201100','Chewie_Spike_LFP_1024201100','Chewie_Spike_LFP_0106201200',...
%     'Chewie_Spike_LFP_0117201200','Chewie_Spike_LFP_0130201200','Chewie_Spike_LFP_0215201200','Chewie_Spike_LFP_0217201200',...
%    'Chewie_Spike_LFP_0217201200','Chewie_Spike_LFP_0321201200'}
% numlist = {'1','1','1','1','1','4','1','6','1','6','1','5','1'}; % HAND CONTROL FILE NUMBERS!numlist={{'3','7'},{'5','2'},{'3','5'} };%,' 4_pdsallchans'}
% postfix='_spikepds_allunits-bs200';

% filelist=BDFlistshort;
filelist= Mini_MSP_DaysNames;
% Dir='Y:\Chew
lag=-0.1;
binlen=0.1;
pval=0.05;

% chinds=1:96;
for i=1:length(filelist)
    
    %     for i=1:length(numlist)
    postfix='spikePDs_allchans_bs-1cos';   %LFP control file

    filewithpath=findBDFonCitadel(filelist{i},1);
    if strncmpi(filelist{i},'Mini',4)
        if strncmpi(filewithpath(44),'0',1)
            fnam=filewithpath(1:54)     %for Mini long format (date included) filenames; Chewie is 56
                savename=[filelist{i}(1:27),postfix,'.mat'];
        else
            fnam=filewithpath(1:46) %For Mini short format
                savename=[filelist{i}(1:19),postfix,'.mat'];
        end
    else
        fnam=filewithpath(1:58)     %for Chewie
            savename=[filelist{i}(1:28),postfix,'.mat'];
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
    clear bdf *PD*
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
