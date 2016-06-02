function VAFstruct=handControl_decoderPerformance_predictions2(bdf,decoderPath)

% syntax varargout=handControl_decoderPerformance_predictions2(bdf,decoderPath)
%
%              INPUT:
%                   bdf         - a BDF-formatted .mat file
%                   decoderPath - path to the original decoder.  The actual
%                                 decoder used may vary from this one, if
%                                 an updated version of this decoder was
%                                 used for brain control that day.
%                               
%              OUTPUT:
%                   VAFstruct - if specified, will return a 
%                               struct with the following 
%                               fields: name, decoder age, 
%                               vaf
%
% this version runs the predictions code for bdf, using H [AND P!!!] 
% from the decoder specified by decoderPath (the decoder may be updated, 
% if an updated version was used on the day bdf was recorded.  
% This to allow the calculation of vaf in (for instance) hand
% control files when using a particular kind of decoder (e.g. LFP or
% spike).

startingPath=pwd;

pathToBDF=findBDFonCitadel(bdf.meta.filename);
% strip out trailing CR, if present.
pathToBDF(regexp(pathToBDF,sprintf('\n')))='';

dayStr=regexp(pathToBDF,'[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once');
animal=regexp(bdf.meta.filename,'Chewie|Mini','match','once');

% find a file from the current day's directory that was under Brain Control

if ~isempty(regexp(decoderPath,'spikedecoder','once'))
    controlType='Spike';
else
    controlType='LFP';
end
BDFlist=findBDF_withControl(animal,dayStr,controlType);
% BDFlist is already sorted in every case?
BDFlist=sort(BDFlist);

% double-check: find the decoder NAME, not just the type, and make sure
% we're not using a wrong decoder that's of right type (e.g., causal
% instead of acausal LFP decoder).
if ispc
    fsep=[filesep filesep]; % because regexp chokes on 1 backslash
else
    fsep=filesep;
end
switch animal
    case 'Mini'
        BDF_MF='bdf';
        ff='FilterFiles';
    case 'Chewie'
        BDF_MF='BDFs';
        ff='Filter files';
end

[~,decoderName,~]=FileParts(decoderPath);

for n=1:length(BDFlist)
    bdfPathTemp=findBDFonCitadel(BDFlist{n});
    bdfBRpath=regexprep(bdfPathTemp,{BDF_MF,'\.mat'}, ...
        {['BrainReader logs',fsep,'online'],'\.txt'});
    % just in case there's a lurkind cr
    bdfBRpath(regexp(bdfBRpath,sprintf('\n')))='';    
    % been burned too many times.  Check to see if file exists
    if exist(bdfBRpath,'file')~=2
        continue
    end
    fid=fopen(bdfBRpath);
    modelLine=fgetl(fid);
    fclose(fid);
    [~,modelName,~]=FileParts(modelLine);
    decoderFile=regexp(modelLine,'/','split');
    decoderFile=decoderFile(end-1:end);
    decoderFile{2}(end)=[];
    % for now, exclude causal.  We're going to have to make it a special
    % case if we really want to optionally allow it.
    baseDecoderName=regexp(decoderName,'.*decoder','match','once');
    baseModelName=regexp(modelName,'.*decoder','match','once');
    if (isempty(regexp(baseDecoderName,'causal','once')) && ...
            isempty(regexp(baseModelName,'causal','once'))) && ...
            strcmp(baseDecoderName,baseModelName)
        break
    end
end

if isempty(n) || n==length(BDFlist) && ~strcmp(baseDecoderName,baseModelName)
    % options when no brain control files with the proper decoder can be
    % found in the current day:
    %       - default to original (input) decoder
    %       - throw error
    %
    % this will let us re-default to the input decoder...
    decoderFile=regexp(decoderPath,fsep,'split');
    decoderFile=decoderFile(end-1:end);
    clear bdfBRpath
%     decoderFile{2}(end)=[];
    % ... but to begin with, just throw error.  get current date folder.
%     error('could not find a brain control file on %s that used \n %s', ...
%         dayStr,decoderName)
end
[BDFpathStr,BDFname,~]=fileparts(pathToBDF);
pathToDecoderMAT=regexprep(BDFpathStr,regexpi(BDFpathStr, ...
    ['(?<=',fsep,')','bdfs*(?=',fsep,')'],'match','once'),ff);
pathToDecoderMAT=fullfile(regexprep(pathToDecoderMAT, ...
    '[0-9]{2}-[0-9]{2}-[0-9]{4}',decoderFile{1}),decoderFile{2});


fprintf(1,'overriding decoder %s...\n',decoderPath)
if exist(pathToDecoderMAT,'file')==2
    if strcmp(controlType,'LFP')
        load(pathToDecoderMAT,'H','P','bestf','bestc')
    else
        load(pathToDecoderMAT,'H','P','neuronIDs')
    end
    fprintf(1,'successfully loaded %s\n',pathToDecoderMAT)
    try % to use the actual file from that day
        decoderDate=decoderDateFromLogFile(bdfBRpath,1);
    catch ME 
        % if no bdfBRpath, use decoderPath
        if strcmp(ME.identifier,'MATLAB:UndefinedFunction') || ...
            strcmp(ME.identifier,'MATLAB:refClearedVar')
            decoderDateStr=regexp(decoderPath,'[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once');
            if ~isempty(decoderDateStr)
                decoderDate=datenum(decoderDateStr,'mm-dd-yyyy');
            else
                rethrow(ME)
            end
        end
    end
else
    error('decoder %s could not be loaded',pathToDecoderMAT)
end

bdfDate=datenum(regexp(bdf.meta.datetime,'\s*[0-9]+/\s*[0-9]+/[0-9]+','match','once'));

% constants that are the same whether decoding with LFPs or spikes
signal='vel';
numsides=1;
numlags=10;
PolynomialOrder=3;
binsize=0.05;
Use_Thresh=0; lambda=1;
folds=10;
% BDFname=bdf.meta.filename(1:end-4);
Hcell=cell(1,folds);
[Hcell{1:folds}]=deal(H);
% P(1:(size(P,1)-1),:)=zeros(size(P,1)-1,size(P,2));

if strcmp(controlType,'LFP')
    % switch variable name since the below is copied from a different batch
    % function.
    out_struct=bdf; clear bdf
    
    disp('assigning static variables')
    % behavior
    sig=out_struct.(signal);
    analog_times=sig(:,1);
    
    % assign FPs, offloaded to script so it can be used in other places.
    fpAssignScript
    % since we are evaluating rather than building a decoder, we want to leave
    % all channels intact rather than finding & removing badChannels.  If any
    % channels are bad, we want that to be revealed by the poor performance of
    % the decoder
    disp('static variables assigned')
    
    numfp=size(fp,1);
    words=[]; emgsamplerate=[];
    disp('done')
    % Input parameters to play with.
    disp('assigning tunable parameters and building the decoder...')
    wsz=256;
    nfeat=150;
    smoothfeats=0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
    % predictionsfromfp6_inputDecoder needs to be modified so that the P is
    % input as well.
    [vaf,~,~,~,~,~,~,r2,~,~,~,~,~,~,~,~,ytnew,~,~,~,~,~,bankRatio] = ...
        predictionsfromfp6_inputDecoder(sig,signal,numfp,binsize,folds,numlags,numsides, ...
        samprate,fp,fptimes,analog_times,BDFname,wsz,nfeat,PolynomialOrder, ...
        Use_Thresh,Hcell,words,emgsamplerate,lambda,smoothfeats,[bestc; bestf],P);
    
    % examine vaf
    fprintf(1,'file %s\n',BDFname)
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
else    % controlType is 'Spike'
    % 1st way to try to get the bdf.units trimmed down to good numbers of cells
    uList=unit_list(bdf);
    bdf.units(uList(:,2)==0)=[];
    % 2nd way to try
    bdf.units(size(cat(1,bdf.units.id),1)+1:end)=[];
    % the decoder is under constraint to accept no unit that fired at less
    % than 0.5 Hz.  Therefore, must trim such units from the bdf, lest the
    % bdf not match the input decoder.
    bdf.units((cellfun(@length,{bdf.units.ts})/bdf.meta.duration <= 0.5))=[];
    cells=unit_list(bdf);

    [commonVals,cellsGoodInds,NeuronIDgoodInds]=intersect(cells,neuronIDs,'rows');
    badNeuronIDvals=setdiff(neuronIDs,neuronIDs(NeuronIDgoodInds,:),'rows');
    if ~isempty(badNeuronIDvals)
        badChannelInds=find(ismember(neuronIDs,badNeuronIDvals,'rows'))';    
        badChannelStartInds=(badChannelInds-1)*numlags+1;
        indMat=repmat(badChannelStartInds,numlags,1)+repmat((0:9)',1,length(badChannelInds));
        for innerInd=1:length(Hcell)
            Hcell{innerInd}(indMat(:),:)=[];
        end
    end
    badCellVals=setdiff(cells,cells(cellsGoodInds,:),'rows');
    if ~isempty(badCellVals)
        bdf.units(ismember(cells,badCellVals,'rows'))=[];
    end

    [vaf,~,~,~,~,~,~,r2,~,~,~,~,~,~,~]=predictions_mwstikpolyMOD_inputDecoder(bdf,signal, ...
        commonVals,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh,BDFname,5,Hcell,P);
    close                                            
    
    % examine vaf
    fprintf(1,'file %s\n',BDFname)
    fprintf(1,'decoding %s\n',signal)
    fprintf(1,'numlags=%d\n',numlags)
    fprintf(1,'\n')
    fprintf(1,'\n')
    fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
    fprintf(1,'\n')
    fprintf(1,'binsize=%.2f\n',binsize)
    
    vaf
    
    formatstr='vaf mean across folds: ';
    for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
    formatstr=[formatstr, '\n'];
    
    fprintf(1,formatstr,mean(vaf,1))
    fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))    
end

if exist('bankRatio','var')~=1
    bankRatio=[];
end

VAFstruct=struct('name',BDFname,'decoder_age',bdfDate-decoderDate, ...
    'vaf',vaf,'r2',r2,'bankRatio',bankRatio,'decoder_path',pathToDecoderMAT);


% to get predicted position from predicted velocity, could do a simple
% integration or could try to emulate the online case by doing an
% implementation of the adaptive offset procedure.  If we're going to go
% that far, it might be smarter to just do the pseudo-online case, that's
% by far the more fair comparison.  If we're going to do it here, will want
% ytnew.


% make sure we end where we started.
cd(startingPath)