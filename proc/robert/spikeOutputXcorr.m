function [XCx,XCy,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]=...
    spikeOutputXcorr(numlags,fullX,sigTrimmed)

% syntax [XCx,XCy,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]= ...
%           spikeOutputXcorr(numlags,fullX,sigTrimmed)
%
%           assume sigTrimmed is WITHOUT time vector 

% from the set of selected features, calculate the cross-correlation with
% outputs.  Set 'coeff' option to produce normalized cross-correlation
% sequences.
for k=1:size(fullX,2)
    if k==1
        [XCx(:,k),lags]=xcorr(fullX(:,k),sigTrimmed(:,1),numlags,'coeff');
        [XCy(:,k)]=xcorr(fullX(:,k),sigTrimmed(:,2),numlags,'coeff');
        timelags=-1*length(lags)*0.05/2:0.05:(length(lags)*0.05/2-0.05);
    else
        [XCx(:,k)]=xcorr(fullX(:,k),sigTrimmed(:,1),numlags,'coeff');
        [XCy(:,k)]=xcorr(fullX(:,k),sigTrimmed(:,2),numlags,'coeff');
    end
    [peakVal_x(k),indx]=max(abs(XCx(:,k)));
    peakInd_x(k)=timelags(indx);
    [peakVal_y(k),indy]=max(abs(XCy(:,k)));
    peakInd_y(k)=timelags(indy);
end
XCx=double(XCx);
XCy=double(XCy);
