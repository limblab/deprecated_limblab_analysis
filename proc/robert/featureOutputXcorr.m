function [XCx,XCy]=featureOutputXcorr(nameIn)

[BDFpathIn,BDFnameIn,ext,~]=fileparts(nameIn);

if isempty(BDFpathIn)
    BDFfullPath=findBDFonCitadel([BDFnameIn,ext]);
else
    BDFfullPathIn=nameIn;
end
load(BDFfullPathIn)
fpAssignScript
wsz=256;
binsize=0.05;
numfp=size(fp,1);

% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% calculate features of the fps as they happened during this brain-control file.
[featMat,y,t]=makefmatc_causal(fp,fptimes,numfp,binsize,samprate,analog_times,wsz,sig);

% find the decoder that was used, pull from it bestc,bestf.  Use these to
% index above-calculated feature matrix.
pathToDecoderMAT=decoderPathFromBDF(out_struct);
load(pathToDecoderMAT,'bestf','bestc')

[~,featind]=sortrows([bestc', bestf']);
FMindexed=featMat(:,featind);

% from the set of selected features, calculate the cross-correlation with
% outputs.  
for k=1:150
    [XCx(:,k),lags]=xcorr(FMindexed(:,k),sig(:,2),500);
    [XCy(:,k),lags]=xcorr(FMindexed(:,k),sig(:,3),500);
end
XCx=double(XCx);
XCy=double(XCy);








return



% for n=1:10
%     for k=1:150        
%         [XCx(:,k,n),lags]=xcorr(xtnew{n}(:,k),ytnew{n}(:,1),75);
%         [XCy(:,k,n),lags]=xcorr(xtnew{n}(:,k),ytnew{n}(:,2),75);
%     end
% end
% XCx=double(XCx);
% XCy=double(XCy);
% clear n k
