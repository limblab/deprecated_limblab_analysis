function vaf = build1chanSpikePositionDecoder(BDFfileIn,chanToUse,binsize,PolynomialOrder)

if ~nargin
    [FileName,PathName,~]=uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\', ...
        'select data file');
    if isnumeric(PathName) && PathName==0
        return
    end
    if exist(fullfile(PathName,FileName),'file')~=2
        disp('file not valid.  aborting...')
        return
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
end

signal='vel';
numsides=1;
Use_Thresh=0; lambda=1; % words=[]; 
folds=10; 
numlags=10; % this seems to be the standard set in buildModel.m

% 1st way to try to get the bdf.units trimmed down to good numbers of cells
uList=unit_list(bdf);
bdf.units(uList(:,2)==0)=[];

% % 2nd way to try
% bdf.units(size(cat(1,bdf.units.id),1)+1:end)=[];
% if MinFiringRate==0 && (length(bdf.units)~= size(binnedData.spikeratedata,2))
% 	disp('size discrepancy in the one-shot vs. multi-fold methods of ')
% 	disp('determing the number of included units from bdf.units')
% end

% THIS IS THE LINE THAT DIFFERENTIATES THIS FUNCTION FROM
% buildSpikePositionDecoder.m
bdf.units(setdiff(1:length(bdf.units),chanToUse))=[];

cells=[];

[vaf,~,~,~,~,~,~,~,~,~,~,~,~,~,~]=predictions_mwstikpolyMOD(bdf,signal, ...
    cells,binsize,folds,numlags,numsides,lambda,PolynomialOrder,Use_Thresh);
close 

fprintf(1,'decoding %s\n',signal)
% fprintf(1,'folds=%d\n',folds)
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

assignin('base','vaf',vaf)
diary off