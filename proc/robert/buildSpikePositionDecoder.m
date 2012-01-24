function filter = buildSpikePositionDecoder(BDFfileIn)

if ~nargin
    [FileName,PathName,~]=uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\', ...
        'select data file');
    if isnumeric(PathName) && PathName==0
        filter=[]; return
    end
    if exist(fullfile(PathName,FileName),'file')~=2
        disp('file not valid.  aborting...')
        filter=[]; return
    end
    fprintf(1,'%s\n',fullfile(PathName,FileName))
    disp('importing data...')
    bdf=load(fullfile(PathName,FileName));
    nameWithinFile=char(regexp(fieldnames(bdf),'bdf|out_struct','match','once'));
    if ~isempty(nameWithinFile)
        bdf=bdf.(nameWithinFile);
    else
        disp('neither "bdf" nor "out_struct" was found in the .mat file.  quitting...')
    end
else    
    if ischar(BDFfileIn)
        bdf=load(BDFfileIn);
        if length(fieldnames(bdf))~=1
            disp('too many variables in the BDF file.  quitting...')
        else
            nameWithinFile=char(fieldnames(bdf));
            bdf=bdf.(nameWithinFile);
        end
    else
        bdf=BDFfileIn;
    end
end
% bdf.pos(:,2) = bdf.pos(:,2) - offsetx;
% bdf.pos(:,3) = bdf.pos(:,3) - offsety;

fprintf(1,'\n\nbuilding one-shot decoder using BuildModel.m\n\n')

[binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate,NormData] = convertBDF2binnedGUI;
stoptime=bdf.meta.duration;

disp('Converting BDF structure to binned data, please wait...');
if ischar(BDFfileIn) % if there were >1 fieldnames we wouldn't have gotten this far
	str=BDFfileIn;         % nameWithinFile
else				% was passed in as an argument from the base workspace
	str=inputname(1);
end
binnedData = convertBDF2binned(str,binsize,starttime,stoptime,hpfreq,lpfreq, ...
	MinFiringRate,NormData);

[fillen,~,PolynomialOrder,Pred_EMG,Pred_Force,Pred_CursPos,Use_Thresh] = ...
	BuildModelGUI(binsize,'');
if ismac
    [filter,OLPredData] = BuildModel(binnedData, ...
        '/Users/rdflint/work/Dropbox/MATLAB_code/s1_analysis', fillen, 1, PolynomialOrder, ...
        Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh);
else
    [filter,OLPredData] = BuildModel(binnedData, ...
        'C:\Documents and Settings\Administrator\Desktop\s1_analysis', fillen, 1, PolynomialOrder, ...
        Pred_EMG, Pred_Force, Pred_CursPos,Use_Thresh);    
end
% clear binnedData;
disp('Done.');

filter.P = filter.P';

FromData='';	% eventually, the file the data came from
H = filter.H;
P = filter.P;
T=filter.T;
binsize = filter.binsize;
fillen = filter.fillen;
neuronIDs = filter.neuronIDs;
outnames=filter.outnames;
patch=filter.patch;

datlen=length(OLPredData);

fprintf(1,'\n')
fprintf(1,'\n')
fprintf(1,'\n')
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'\n')
fprintf(1,'binsize=%.2f\n',binsize)
fprintf(1,'\n')

OLPredData.vaf

if ischar(BDFfileIn)
	[pathstr,name,~]=fileparts(BDFfileIn);
	save(fullfile(pathstr,[name,'-spikedecoder.mat']),'H','P','T','binsize','fillen','filter', ...
		'neuronIDs','outnames','patch');
	fprintf(1,'saved decoder file in %s',pathstr)
	% looking forward to next section
	fnam=name;
elseif ~nargin
    save(fullfile(PathName,[regexp(FileName,'.*(?=\.mat)','match','once'),'-spikedecoder.mat']), ...
        'H','P','T','binsize','fillen','filter','neuronIDs','outnames','patch')
else
	save('currentDecoder.mat','H','P','T','binsize','fillen','filter','neuronIDs', ...
		'outnames','patch');
	fprintf(1,'saved decoder file in current directory\n')
	fnam='current';
end

% in case we want to re-generate them, avoid confusion
clear H P

fprintf(1,'\n\nRunning multi-fold analysis using predictions_mwstikpoly.m\n\n')

signal='vel';
numsides=1;
Use_Thresh=0; lambda=1; % words=[]; 
folds=10; 
numlags=10; % this seems to be the standard set in buildModel.m

fprintf(1,'number of units: %d\n',length(bdf.units))
fprintf(1,'number of non-empty units: %d\n',size(cat(1,bdf.units.id),1))
if length(bdf.units)~=size(cat(1,bdf.units.id),1)
	disp('attempting to equalize sizes across different decoder builds,')
	disp('however, the raw BDF must be trimmed to only non-empty units')
	disp('in order to use as input to BrainReader offline')
end

% 1st way to try to get the bdf.units trimmed down to good numbers of cells
uList=unit_list(bdf);
bdf.units(uList(:,2)==0)=[];
% 2nd way to try
bdf.units(size(cat(1,bdf.units.id),1)+1:end)=[];
if MinFiringRate==0 && (length(bdf.units)~= size(binnedData.spikeratedata,2))
	disp('size discrepancy in the one-shot vs. multi-fold methods of ')
	disp('determing the number of included units from bdf.units')
end
cells=[];

[vaf,~,~,~,~,~,~,~,~,~,~,~,~,~,~]=predictions_mwstikpolyMOD(bdf,signal, ...
    cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
close

fprintf(1,'folds=%d\n',folds)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'\n')
fprintf(1,'\n')
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'\n')
fprintf(1,'binsize=%.2f\n',binsize)
fprintf(1,'\n')

vaf

formatstr='mean vaf across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];
fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))


return
% % LFP stuff
% fp=cat(2,bdf.raw.analog.data{:})';
% samprate=bdf.raw.analog.adfreq(1);
% wsz=256; 
% nfeat=100; 
% smoothfeats=1;
% numfp=size(fp,1);
% fptimes=1/samprate:1/samprate:size(bdf.raw.analog.data{1},1)/samprate;
% analog_times=sig(:,1);

