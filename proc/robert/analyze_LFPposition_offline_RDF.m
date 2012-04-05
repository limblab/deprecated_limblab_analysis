function analyze_LFPposition_offline_RDF(out_struct,signal,fnam)

if isequal(get(0,'Diary'),'off')
    diary(fullfile(pwd,'decoderOutput.txt'))
end

disp('assigning static variables')
sig=out_struct.(signal);
analog_times=sig(:,1);

% assign FPs, offloaded to script so it can be used in other places.
fpAssignScript

disp('static variables assigned')
%%
% 1st (and last?) second of data gets eliminated by calc_from_raw for the encoder
% timestampe (see out_struct.raw.analog.pos or .vel, so is inappropriate to
% include them in the fp signals.
if 0
    fp(:,fptimes<1 | fptimes>analog_times(end))=[];
    fptimes(fptimes<1 | fptimes>analog_times(end))=[];
end
%%
% downsample, so the delta band isn't empty at wsz=256; this is a current
% limitation of BrainReader.
if 0%samprate > 1000
    % want final fs to be 1000
    disp('downsampling to 1 kHz')
    samp_fact=samprate/1000;
    downsampledTimeVector=linspace(fptimes(1),fptimes(end),length(fptimes)/samp_fact);
    fp=interp1(fptimes,fp',downsampledTimeVector)';
    fptimes=downsampledTimeVector;
    downsampledTimeVector=linspace(analog_times(1),analog_times(end),length(analog_times)/samp_fact);
    downSampledBehaviorSignal=interp1(analog_times,sig(:,2:3),downsampledTimeVector);
    analog_times=downsampledTimeVector; clear downsampledTimeVector
    sig=[rowBoat(analog_times),downSampledBehaviorSignal];
    samprate=1000;
end

numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
numlags=10; 
wsz=256; 
nfeat=150;
% nfeat=6*size(fp,1);
PolynomialOrder=3; 
smoothfeats=0;
binsize=0.05;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
folds=10;
[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
    featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
    predictionsfromfp6(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,words,emgsamplerate,lambda,smoothfeats);

close
% examine vaf
fprintf(1,'file %s\n',fnam)
fprintf(1,'decoding %s\n',signal)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d\n',nfeat)
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)

vaf

formatstr='vaf mean across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];

fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

assignin('caller','vaf',vaf)
assignin('caller','bestc',bestc)
assignin('caller','bestf',bestf)
assignin('caller','H',H)
assignin('caller','featMat',featMat)
assignin('caller','x',x)
assignin('caller','y',y)
assignin('caller','signal',signal)
assignin('caller','numlags',numlags)
assignin('caller','wsz',wsz)
assignin('caller','nfeat',nfeat)
assignin('caller','PolynomialOrder',PolynomialOrder)
assignin('caller','smoothfeats',smoothfeats)
assignin('caller','binsize',binsize)

diary off