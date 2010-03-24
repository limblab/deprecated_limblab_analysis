function [Xpsd]=PowerSpect(X,Fs)
%h=spectrum.welch('Hann',window,100*noverlap/window)
h=spectrum.welch
hopts = psdopts(h)

% figure;
% 
% Xpsd_temp = psd(h,X(:,1),'Fs',Fs);
% W=Xpsd_temp.Frequencies;
% 
% Xpsd = dspdata.psd(zeros(size(Xpsd_temp.Data,1),size(X,2)),W,'Fs',Fs);
% Xpsd.Data(:,1)=Xpsd_temp.Data;
% 
% if size(X,2)>1
%     for i=size(X,2):-1:2
%         Xpsd_temp = psd(h,X,'Fs',Fs);
%         Xpsd.Data(:,i)=Xpsd_temp.Data;
%     end
% end 
% plot(Xpsd);

numSigs = size(X,2);
Data_temp=zeros(h.SegmentLength*2+1,numSigs);
% Data_temp=zeros(129,numSigs);
% Data_temp=zeros(ceil(h.SegmentLength*100/h.OverlapPercent),numSigs);
for i=1:numSigs
    hpsd = psd(h,X(:,i),'Fs',Fs);
    Data_temp(:,i)= hpsd.Data;
end
W = hpsd.Frequencies;
Xpsd = dspdata.psd(Data_temp,W,'Fs',Fs);
figure;
plot(Xpsd);
end