function [XCx,XCy,timelags,peakInd_x,peakInd_y]=featureOutputXcorr(nameIn,numlags)

% syntax [XCx,XCy,timelags,peakInd_x,peakInd_y]=featureOutputXcorr(nameIn,numlags)
%
% 



[BDFpathIn,BDFnameIn,ext,~]=FileParts(nameIn);

if isempty(BDFpathIn)
    BDFfullPath=findBDFonCitadel([BDFnameIn,ext]);
else
    BDFfullPath=nameIn;
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

% find the decoder that was used, pull from it bestc,bestf.  Use these to
% index above-calculated feature matrix.  NO SORTING OF featMat, since
% makefmatc_causal doens't re-do the feature selection, featMat is still in
% the order of channels.
pathToDecoderMAT=decoderPathFromBDF(out_struct);
load(pathToDecoderMAT,'bestc','bestf')

bestfeats=sortrows([bestc' bestf']);
featind=sub2ind([6,numfp],bestfeats(:,2),bestfeats(:,1));
FMindexed=featMat(:,featind);

% from the set of selected features, calculate the cross-correlation with
% outputs.  
for k=1:size(FMindexed,2)
    if k==1
        [XCx(:,k),lags]=xcorr(FMindexed(:,k),sigTrimmed(:,2),numlags);
        [XCy(:,k),lags]=xcorr(FMindexed(:,k),sigTrimmed(:,3),numlags);
        timelags=-1*length(lags)*0.05/2:0.05:(length(lags)*0.05/2-0.05);
    else
        [XCx(:,k)]=xcorr(FMindexed(:,k),sigTrimmed(:,2),numlags);
        [XCy(:,k)]=xcorr(FMindexed(:,k),sigTrimmed(:,3),numlags);
    end
    [~,indx]=max(XCx(:,k));
    peakInd_x(k)=timelags(indx);
    [~,indy]=max(XCy(:,k));
    peakInd_y(k)=timelags(indy);
end
XCx=double(XCx);
XCy=double(XCy);
