function hitRate=LFP_phaseRandomDecode_BCperformance(out_struct,H,P,bestc,bestf,badChannels)

% syntax hitRate=LFP_phaseRandomDecode_BCperformance(out_struct);
%
% this is the function to run for phase randomization!
%
%
%

fpAssignScript
fs=out_struct.raw.analog.adfreq(1);
fptimes=1/fs:1/fs:size(fp,2)/fs;
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% randomize phase of fp inputs
fp=pharand(fp')';
fp(badChannels,:)=zeros(length(badChannels),size(fp,2));

numfp=size(fp,1);
numsides=1;

Use_Thresh=0; words=[]; lambda=1;

disp('assigning tunable parameters and building the decoder...')
folds=10;
numlags=10;
wsz=256;
nfeat=150;
PolynomialOrder=3;
smoothfeats=0;
binsize=0.05;
if exist('fnam','var')~=1
    fnam='';
end
Hcell=cell(1,folds);
[Hcell{1:folds}]=deal(H);

[~,~,~,~,y_pred,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = ...
    predictionsfromfp6_inputDecoder(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    fs,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,Hcell,words,fs,lambda,smoothfeats,[bestc; bestf],P);
close

y_pred=cat(1,y_pred{:});
% in a previous version, we were just assigning velocity to be position!
% that was extremely wrong!
out_struct.posBAK=out_struct.pos;
% xlimits=[max(out_struct.pos(:,2)) min(out_struct.pos(:,2))];
% ylimits=[max(out_struct.pos(:,3)) min(out_struct.pos(:,3))];
out_struct.pos(size(y_pred,1)+1:end,:)=[];
for n=3:size(y_pred,1)
    out_struct.pos(n,2)=out_struct.pos(n-1,2)+y_pred(n-1,1)*diff(out_struct.pos(n-2:n-1,1)); 
%     if out_struct.pos(n,2) > xlimits(1)
%         out_struct.pos(n,2)=xlimits(1);
%     end
%     if out_struct.pos(n,2) < xlimits(2)
%         out_struct.pos(:,2)=xlimits(2);
%     end
    out_struct.pos(n,3)=out_struct.pos(n-1,3)+y_pred(n-1,2)*diff(out_struct.pos(n-2:n-1,1));
%     if out_struct.pos(n,3) > ylimits(1)
%         out_struct.pos(n,3)=ylimits(1);
%     end
%     if out_struct.pos(n,3) < ylimits(2)
%         out_struct.pos(:,3)=ylimits(2);
%     end    
end
% figure, plot(out_struct.pos(:,2),out_struct.pos(:,3))
[~,hitTimes,~,~]=reconstruct_cursorTargetInfo_v2(out_struct,4,0,0); 
hitRate=length(hitTimes)/size(out_struct.targets.centers,1);

% %%
% out_struct.pos=out_struct.posBAK;
