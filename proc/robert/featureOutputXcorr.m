function [XCx,XCy,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]=...
    featureOutputXcorr(out_struct,numlags,featMat,sigTrimmed,numfp)

% syntax [XCx,XCy,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]= ...
%           featureOutputXcorr(out_struct,numlags,featMat,sigTrimmed)
%
% 

% find the decoder that was used, pull from it bestc,bestf.  Use these to
% index above-calculated feature matrix.  NO SORTING OF featMat, since
% makefmatc_causal doens't re-do the feature selection, featMat is still in
% the order of channels.
pathToDecoderMAT=decoderPathFromBDF(out_struct);
load(pathToDecoderMAT,'bestc','bestf')

bestfeats=sortrows([bestc' bestf']);
featind=sub2ind([6,numfp],bestfeats(:,2),bestfeats(:,1));
% FMindexed=featMat(:,featind);
% try: keep all features, then will only index at the end (possibly using
% the decoder that takes out the most channels).
FMindexed=featMat;

% from the set of selected features, calculate the cross-correlation with
% outputs.  Set 'coeff' option to produce normalized cross-correlation
% sequences.
for k=1:size(FMindexed,2)
    if k==1
        [XCx(:,k),lags]=xcorr(FMindexed(:,k),sigTrimmed(:,2),numlags,'coeff');
        [XCy(:,k)]=xcorr(FMindexed(:,k),sigTrimmed(:,3),numlags,'coeff');
        timelags=-1*length(lags)*0.05/2:0.05:(length(lags)*0.05/2-0.05);
    else
        [XCx(:,k)]=xcorr(FMindexed(:,k),sigTrimmed(:,2),numlags,'coeff');
        [XCy(:,k)]=xcorr(FMindexed(:,k),sigTrimmed(:,3),numlags,'coeff');
    end
    [peakVal_x(k),indx]=max(abs(XCx(:,k)));
    peakInd_x(k)=timelags(indx);
    [peakVal_y(k),indy]=max(abs(XCy(:,k)));
    peakInd_y(k)=timelags(indy);
end
XCx=double(XCx);
XCy=double(XCy);


return

% some script stuff for doing testing...
%%
FMindexed=featMat;
sigTrimmed=evalin('base','sigTrimmed');
[~,~,~,~,~,~,~]=kinematicsHandControl(out_struct);
%sigTrimmed=out_struct.vel;
sigInd=false(size(sigTrimmed,1),1);
for n=1:length(start_reaches)
    sigInd(sigTrimmed(:,1)>=start_reaches(n) & sigTrimmed(:,1)<=end_reaches(n))=1;
end, clear n

FMindexed=FMindexed(sigInd,:);
sigTrimmed=sigTrimmed(sigInd,:);

%%
FMindexed=featMat;
sigTrimmed=evalin('base','sigTrimmed');
FMindexed=FMindexed(~sigInd,:);
sigTrimmed=sigTrimmed(~sigInd,:);