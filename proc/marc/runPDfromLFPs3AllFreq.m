%This script runs PDs_from_LFPs_MWS for multiple files
%11/28/11

chinds=1:96;

% 'Chewie_Spike_LFP_0919201100','Chewie_Spike_LFP_0926201100','Chewie_Spike_LFP_1024201100','Chewie_Spike_LFP_0106201200',...
%     'Chewie_Spike_LFP_0117201200','Chewie_Spike_LFP_0130201200','Chewie_Spike_LFP_0215201200','Chewie_Spike_LFP_0217201200'}
% numlist={'2','4','7','9','8','2','3','3'};
% chinds=chanIDs;
% bandstart=[0 70 130];
% bandend=[4 115 199];
% bandstart=[];
% bandend=[];
%
% filelist={'Chewie_Spike_LFP_0902201100','Chewie_Spike_LFP_0906201100',...
%     'Chewie_Spike_LFP_0907201100','Chewie_Spike_LFP_0908201100',...
%     'Chewie_Spike_LFP_0919201100','Chewie_Spike_LFP_1024201100','Chewie_Spike_LFP_0106201200',...
%     'Chewie_Spike_LFP_0117201200','Chewie_Spike_LFP_0130201200','Chewie_Spike_LFP_0215201200','Chewie_Spike_LFP_0217201200',...
%    'Chewie_Spike_LFP_0217201200','Chewie_Spike_LFP_0321201200'}
% numlist = {'1','1','1','1','1','4','1','6','1','6','1','5','1'}; % HAND CONTROL FILE NUMBERS!
% % filelist={'Chewie_Spike_LFP_0902201100','Chewie_Spike_LFP_0902201100','Chewie_Spike_LFP_0906201100',...
% %     'Chewie_Spike_LFP_0907201100','Chewie_Spike_LFP_0907201100','Chewie_Spike_LFP_0908201100','Chewie_Spike_LFP_0908201100',...
% %     'Chewie_Spike_LFP_0321201200','Chewie_Spike_LFP_0321201200'};
% % numlist={'2','3','2','3','4','2','3','2','3'};
% % bandstart=70;
% % bandend=115;
% if ~exist('chinds','var')
%     disp('Please tell me which channels to run!')
%     break
% end
%%
% load 'filelist_Xcorr_decoder2.mat'
bandstart=[0, 7, 70, 130, 200];
bandend=[4, 20, 115, 200, 300];

filelist= Chewie_LFP_BC_Decoder1_filenames;
%     'Chewie_Spike_LFP_0919201100','Chewie_Spike_LFP_1024201100','Chewie_Spike_LFP_0106201200',...
%     'Chewie_Spike_LFP_0117201200','Chewie_Spike_LFP_0130201200','Chewie_Spike_LFP_0215201200','Chewie_Spike_LFP_0217201200',...
%    'Chewie_Spike_LFP_0217201200','Chewie_Spike_LFP_0321201200'}
% for i=1:length(BDFlist_all)
% filelist=BDFlist_all(1:76)';
% filelist=filesC(1:2:end);

% end
% numlist = {'1','1','1','1','1','4','1','6','1','6','1','5','1'}; % HAND CONTROL FILE NUMBERS!
if ~exist('chinds','var')
    disp('Please tell me which channels to run!')
    break
end
% tic

lag=-0.1;
binlen=0.1;
pval=0.05;

for i=1:length(filelist)
    %     for i=1:length(numlist)
    
    filewithpath=findBDFonCitadel(filelist{i},1);
    postfix='_pdsallchanspos_bs-1wsz100mnpowlogAllFreqcos';   %LFP control file
    %         savename=[filelist{i}(1:27),postfix]; %For Mini; Chewie would be 28
    %        fnam=filewithpath(1:54); %for Mini; Chewie would be 57
    %         if ~exist(filewithpath,'file')
    %             disp(['File ',filewithpath,'did not exist in this folder'])
    %             continue
    %         end
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
    
    [LFPfilesPDs,bootstrapPDS]=PDs_from_LFPs_MWSposlog(fnam,chinds,bandstart,bandend,18,32,0,lag,binlen,pval);
    
    save(savename,'LFPfilesPDs','bootst*');
    clear bdf *PD*
end





% toc