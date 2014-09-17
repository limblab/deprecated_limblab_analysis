% This script runs PDs_from_LFPs_MWSposlog2 and PDs_from_LFPs_MWSposlogLMP...
% for multiple files
% 4/17/14

chinds=1:96;
LMPbandstart=[];
LMPbandend=[];
bandstart=  [0, 7, 70, 130, 200];
bandend=    [4, 20, 115, 200, 300];


filelist= Chewie_MSP_tsNum;
varname = 'Chewie_MSP_tsNum';

if ~exist('chinds','var')
    disp('Please tell me which channels to run!')
    break
end
% tic

lag= -0.15;
binlen= 0.15;
pval=0.05;

for i=1:length(filelist)
    %     for i=1:length(numlist)
    
    filewithpath=findBDFonCitadel(filelist{i});
    postfix='_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts';   %LFP control file
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
    
try
    tic
    [LFPcounts]=PDs_from_LFPs_MWSposlog2(fnam,chinds,bandstart,bandend,18,32,0,lag,binlen,pval);
    toc
catch exception
    filesThatDidNotRun{i,2} = exception;
    filesThatDidNotRun{i,1} = fnam
    continue
end

tic
[LMPcounts]=PDs_from_LFPs_MWSposlogLMP(fnam,chinds,LMPbandstart,LMPbandend,18,32,0,lag,binlen,pval);
toc

save(savename,'LFPcounts','LMPcounts',sprintf(varname));
    clear bdf *PD*
end





% toc