function [] = runPDfromLFPs3_LMPandAllFreq(filelist)

% This script runs PDs_from_LFPs_MWSposlog2 and PDs_from_LFPs_MWSposlogLMP...
% for multiple files
% 4/17/14

% filelist = Mini_LFP1_DaysNames;
chinds=1:96;
LMPbandstart=[];
LMPbandend=[];
bandstart=  [0];
bandend=    [4];

bootstrapPDsCalc = 0; % Imaginary flag to calc bootstrap PDs or not (haven't implemented it yet)

i = 1;
lag= -0.256;
binlen= 0.10;
pval=0.05;

% for i=1:length(filelist)
%     for i=1:length(numlist)

filewithpath=findBDFonCitadel(filelist{i});
postfix='_pdsallchanspos_bs-1wsz150mnpow_Delta_LFPcounts';   %LFP control file

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
    return
end

try
    tic
    [~,~,LFP_counts] = PDs_from_LFPs_MWSposlog2(fnam,chinds,bandstart,bandend,18,32,0,lag,binlen,pval);   
    toc
catch exception
    filesThatDidNotRun{i,2} = exception;
    filesThatDidNotRun{i,1} = fnam
    return
end

% tic
% [LMPfilesPDs,LMPbootstrapPDS,LMPcounts] = PDs_from_LFPs_MWSposlogLMP(fnam,chinds,LMPbandstart,LMPbandend,18,32,0,lag,binlen,pval);
% toc

save(savename,'LFP*','LMP*','boot*');
clear bdf *PD*
% end





% toc