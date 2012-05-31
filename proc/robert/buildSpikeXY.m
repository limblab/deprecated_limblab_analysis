function [fullX,y] = buildSpikeXY(BDFfileIn)

% syntax [fullX,sig] = buildSpikeXY(BDFfileIn);
%
% 


% diary(fullfile(pwd,'decoderOutput.txt'))
bdf=BDFfileIn;
varStr=inputname(1);

binsize=0.05;
starttime=0;
MinFiringRate=0;
stoptime=bdf.meta.duration;

disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned(varStr,binsize,starttime,stoptime);

fillen=0.5;
PolynomialOrder=3;
Pred_EMG=0; Pred_Force=0; Pred_CursPos=0;
Pred_Veloc=1;

fprintf(1,'\n')
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'\n')
fprintf(1,'binsize=%.2f\n',binsize)
fprintf(1,'\n')

fprintf(1,'\n\nRunning multi-fold analysis using predictions_mwstikpoly.m\n\n')

signal='vel';
numsides=1;
Use_Thresh=0; lambda=1;
folds=10; 
numlags=10; % this seems to be the standard set in buildModel.m

% default to multi-units (max. 1 unit per channel).  There will be at most
% 96 channels, and a constant number of deactivated channels.  However,
% can't account for channels that might for some mysterious reason just not
% spike on a certain day.  Therefore, keep every channel in his assigned
% seat.
bestc=cat(1,bdf.units.id);
bestc(:,2)=[];
% the x matrix can be padded according to this:
%       ismember(1:96,bestc)

% 1st way to try to get the bdf.units trimmed down to good numbers of cells
uList=unit_list(bdf);
bdf.units(uList(:,2)==0)=[];
% 2nd way to try
bdf.units(size(cat(1,bdf.units.id),1)+1:end)=[];
cells=[];

[vaf,~,~,~,~,~,~,~,~,~,x,y,~,~,~]=predictions_mwstikpolyMOD(bdf,signal, ...
    cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
close

% fullXind=ismember(1:96,bestc);
fullX=zeros(size(x,1),96);
k=1;
for n=1:96
    if ~isempty(intersect(n,bestc))
        fullX(:,n)=x(:,k);
        k=k+1;
    end
end
% diary off