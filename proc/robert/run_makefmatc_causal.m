function run_makefmatc_causal(nameIn,numlags)

% syntax run_makefmatc_causal(nameIn,numlags)
%
% numlags is optional, if want to automatically run featureOutputXcorr.m
% inline.
%
% TODO: make smarter, so that it can be handed in a bdf-struct and not have
% to load it from path.



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

for j=2:size(sigTrimmed,2)
    clear badinds badepoch badstartinds badendinds
    badinds=find(abs(sigTrimmed(:,j)) > 40);
    if ~isempty(badinds)
        badepoch=find(diff(badinds)>1);
        badstartinds=[badinds(1); badinds(badepoch+1)];
        badendinds=[badinds(badepoch); badinds(end)];
        if badendinds(end)==size(sigTrimmed,1)
            badendinds(end)=badendinds(end)-1;
        end
        if badstartinds(1)==1 %If at the very beginning of the file need a 0 at start of file
            sigTrimmed(1,j)=sigTrimmed(badendinds(1)+1,j);
            badstartinds(1)=2;
        end
        for i=1:length(badstartinds)
            sigTrimmed(badstartinds(i):badendinds(i),j)=interp1([(badstartinds(i)-1); ...
                (badendinds(i)+1)],[sigTrimmed(badstartinds(i)-1,j); ...
                sigTrimmed(badendinds(i)+1,j)], (badstartinds(i):badendinds(i)));
        end
%     else
%         cgnew(j,:)=cgz(j,:);
    end
end

% save([BDFnameIn,'featMat.mat'],'featMat','sigTrimmed')

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
 
 
 