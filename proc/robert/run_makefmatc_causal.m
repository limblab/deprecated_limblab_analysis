function run_makefmatc_causal(nameIn,numlags)

% syntax run_makefmatc_causal(nameIn,numlags)
%
% numlags is optional, if want to automatically run featureOutputXcorr.m
% inline.



[BDFpathIn,BDFnameIn,ext,~]=FileParts(nameIn);

if isempty(BDFpathIn)
    BDFfullPath=findBDFonCitadel([BDFnameIn,ext]);
else
    BDFfullPath=[nameIn ext];
end
load(BDFfullPath)
fpAssignScript
wsz=256;
binsize=0.05;
numfp=size(fp,1);

% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% calculate features of the fps as they happened during this brain-control file.
[featMat,sigTrimmed,~]=makefmatc_causal(fp,fptimes,numfp,binsize,samprate,analog_times,wsz,sig);
% can depend on BDFnameIn to be the name without extension, regardless of
% what was passed in as nameIn
save([BDFnameIn,'featMat.mat'],'featMat')

if nargin > 1
    [~,~,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]= ...
        featureOutputXcorr(out_struct,numlags,featMat,sigTrimmed,numfp);
    assignin('base','out_struct',out_struct)
    assignin('base','featMat',featMat)
    assignin('base','sigTrimmed',sigTrimmed)
    assignin('base','timelags',timelags)
    assignin('base','peakInd_x',peakInd_x)
    assignin('base','peakInd_y',peakInd_y)
    assignin('base','peakVal_x',peakVal_x)
    assignin('base','peakVal_y',peakVal_y)
end
 
 
 