function filter = buildSpikePositionDecoder(BDFfileIn,interactive,singleUnitToUse)

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
    diary(fullfile(PathName,'decoderOutput.txt'))
    fprintf(1,'%s\n',fullfile(PathName,FileName))
    disp('importing data...')
    bdf=load(fullfile(PathName,FileName));
    fieldnames_list=fieldnames(bdf);
    bdfFound=find(cellfun(@isempty,regexp(fieldnames_list, ...
        'bdf|out_struct','match','once'))==0,1);
    if ~isempty(bdfFound)
        nameWithinFile=fieldnames_list{bdfFound(1)};
    else
        nameWithinFile='';
    end
    if ~isempty(nameWithinFile)
        bdf=bdf.(nameWithinFile);
    else
        error('neither "bdf" nor "out_struct" was found in the .mat file.')
    end
    interactive=0;
    varStr=nameWithinFile;
    assignin('base',nameWithinFile,bdf)
else    
    if ischar(BDFfileIn)
        [PathName,FileName,~,~]=FileParts(BDFfileIn);
        diary(fullfile(PathName,'decoderOutput.txt'))
        bdf=load(BDFfileIn);
        nameWithinFile=char(regexp(fieldnames(bdf),'bdf|out_struct','match','once'));
        if ~isempty(nameWithinFile)
            bdf=bdf.(nameWithinFile);
        else
            error('neither "bdf" nor "out_struct" was found in the .mat file.')
        end
        varStr=BDFfileIn;
    else % handed the BDF from outside the function.  Assume we're in the proper directory?
        diary(fullfile(pwd,'decoderOutput.txt'))
        bdf=BDFfileIn;
        varStr=inputname(1);
    end
    if nargin==1, interactive=0; end
end

% bdf.pos(:,2) = bdf.pos(:,2) - offsetx;
% bdf.pos(:,3) = bdf.pos(:,3) - offsety;

fprintf(1,'\n\nbuilding one-shot decoder using BuildModel.m\n\n')
params=struct('binsize',[],'starttime',[],'stoptime',[],'EMG_hp',[], ...
    'EMG_lp',[],'minFiringRate',[]);

if interactive
    [params.binsize,params.starttime,~,~,~,params.minFiringRate,~]=convertBDF2binnedGUI;
else
    params.binsize=0.05;
    params.starttime=0;
    params.minFiringRate=0.5;
end
params.stoptime=bdf.meta.duration;

disp('Converting BDF structure to binned data, please wait...');
binnedData = convertBDF2binned(bdf,params);
% assignin('base','binnedData',binnedData)

if interactive
    [options.fillen,~,options.PolynomialOrder,options.PredEMGs, ...
        options.PredForce,options.PredCursPos,options.PredVeloc] = ...
        BuildModelGUI(params.binsize,'');
else
    options.fillen=0.05;
    options.PolynomialOrder=3;
    options.PredEMGs=0; options.PredForce=0; options.PredCursPos=0; 
    options.PredVeloc=1;
end

if nargin>2
    unitIndexToUse=find(cellfun(@isempty,regexp(cellstr(binnedData.spikeguide), ...
        ['ee',sprintf('%02d',singleUnitToUse),'u1']))==0);
    binnedData.spikeguide=binnedData.spikeguide(unitIndexToUse,:);
    binnedData.spikeratedata=binnedData.spikeratedata(:,unitIndexToUse);
end
%       options             : structure with fields:
%           fillen              : filter length in seconds (tipically 0.5)
%           UseAllInputs        : 1 to use all inputs, 0 to specify a neuronID file, or a NeuronIDs array
%           PolynomialOrder     : order of the Weiner non-linearity (0=no Polynomial)
%           PredEMG, PredForce, PredCursPos, PredVeloc, numPCs :
%                               flags to include EMG, Force, Cursor Position
%                               and Velocity in the prediction model
%                               (0=no,1=yes), if numPCs is present, will
%                               use numPCs components as inputs instead of
%                               spikeratedata
%           Use_Thresh,Use_EMGs,Use_Ridge:
%                               options to fit only data above a certain
%                               threshold, use EMGs as inputs instead of
%                               spikes, or use a ridge regression to fit model
%           plotflag            : plot predictions after xval
[filter,OLPredData] = BuildModel(binnedData,options);
% clear binnedData;
disp('Done.');

if isempty(OLPredData)
    disp('file skipped')
    return
end

filter.P = filter.P';

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
fprintf(1,'PolynomialOrder=%d\n',options.PolynomialOrder)
fprintf(1,'\n')
fprintf(1,'binsize=%.2f\n',binsize)
fprintf(1,'\n')

OLPredData.vaf

if nargin && ischar(BDFfileIn)
	[pathstr,name,~]=fileparts(BDFfileIn);
	save(fullfile(pathstr,[name,'-spikedecoder.mat']),'H','P','T','binsize','fillen','filter', ...
		'neuronIDs','outnames','patch');
	fprintf(1,'saved decoder file in %s',pathstr)
	% looking forward to next section
elseif ~nargin
    save(fullfile(PathName,[regexp(FileName,'.*(?=\.mat)','match','once'),'-spikedecoder.mat']), ...
        'H','P','T','binsize','fillen','filter','neuronIDs','outnames','patch')
else
    % if the path name is not provided, default to saving on the network
    % since that's the solution we have in place for locating the bdf.
    if exist('FileName','var')==1
        BDFfileName=FileName;
    else
        BDFfileName=regexprep(bdf.meta.filename,'\.plx','\.mat');
    end
    if exist('PathName','var')==1
        BDFpathName=PathName;
    else
        % need to put in a findOnBumbleBee.m
%         BDFpathName=findBDFonGOB(BDFfileName,1);
%         BDFpathName=findBDFonBumbleBeeMan(BDFfileName,1);
        BDFpathName=findBDF_local(BDFfileName,1);
    end
    decoderPathName=regexprep(BDFpathName,'\.mat','-spikedecoder\.mat');
    decoderPathName(regexp(decoderPathName,sprintf('\n')))='';
	save(decoderPathName,'H','P','T','binsize','fillen','filter','neuronIDs','outnames','patch');
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
if params.minFiringRate==0 && (length(bdf.units)~= size(binnedData.spikeratedata,2))
	disp('size discrepancy in the one-shot vs. multi-fold methods of ')
	disp('determing the number of included units from bdf.units')
end
cells=[];

[vaf,~,~,~,~,~,~,~,~,~,~,~,~,~,~]=predictions_mwstikpolyMOD(bdf,signal, ...
    cells,params.binsize,folds,numlags,numsides,lambda,options.PolynomialOrder,Use_Thresh);
close

if exist('FileName','var')==1
    fprintf(1,'file %s\n',FileName)
else
    fprintf(1,'file %s\n',BDFfileName)
end
fprintf(1,'decoding %s\n',signal)
% fprintf(1,'folds=%d\n',folds)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'\n')
fprintf(1,'\n')
fprintf(1,'PolynomialOrder=%d\n',options.PolynomialOrder)
fprintf(1,'\n')
fprintf(1,'binsize=%.2f\n',params.binsize)
fprintf(1,'\n')

vaf

formatstr='mean vaf across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];
fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

assignin('base','vaf',vaf)
diary off