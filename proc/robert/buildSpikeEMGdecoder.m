%% file info
[FileName,PathName,~] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.nev file','*.nev');
cd(PathName)
fnam=FileName(1:end-4);

%% load the file (cerebus)
% for lab 3, must put in lab2!!  if you put in lab3, it will actually hit
% the default in calc_from_raw (line 122), which is lab1.
% modified from get_cerebus_data with more liberal tag names for the EMGs.
% IT DOES LOAD THE UNITS.
bdf=get_cerebus_dataRDF(FileName,1);  
%% input parameters - Do not Change, just run.
disp('assigning static parameters')
% extract the sorted units from bdf.units
uList=unit_list(bdf);
bdf.units(uList(:,2)==0)=[];
signal='emg';
numsides=1;
Use_Thresh=0; lambda=1;
analog_times=bdf.emg.data(:,1);
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
folds=10; 
numlags=10; 
PolynomialOrder=2;
binsize=0.1;
cells=[]; % will be read in from .nev

[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H,x,y,ytnew,xtnew] = ...
    predictions_mwstikpoly(bdf,signal,cells,binsize,folds,numlags,numsides, ...
    lambda,PolynomialOrder,Use_Thresh);

disp(sprintf('\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n'))

%% examine r2
EMGchanNames={'BI','TRI','Adelt','Pdelt'};
r2
if exist('FileName','var')==2
    disp(FileName)
end
disp(sprintf('overall mean r2 %.4f',mean(r2(:))))
[val,ind]=max(mean(r2,2));
disp(sprintf('fold %d had highest mean over all EMGs: mean %.4f',ind,val))
[val,ind]=max(sum(r2,2));
disp(sprintf('fold %d had highest sum over all EMGs: sum %.4f',ind,val))
[val,ind]=max(r2(:));
[r,c]=ind2sub(size(r2),ind);
disp(sprintf('fold %d had the highest individual r2, in %s: %.4f', ...
    r,EMGchanNames{c},r2(r,c)))
[~,c]=max(mean(r2));
disp(sprintf('the best muscle across folds was %s',EMGchanNames{c}))
