function [fileVAFs, fileR2,fileFR] = doBaselineDecoding(root_dirs,use_array,doFiles,decoder,foldLength,numlags)
% predFlags: (bool} [predpos, predvel, predtarg]

switch lower(decoder)
    case 'position'
        predFlags = [1 0 0 0 0 0];
    case 'velocity'
        predFlags = [0 1 0 0 0 0];
    case 'target'
        predFlags = [0 0 1 0 0 0];
    case 'force'
        predFlags = [0 0 0 1 0 0];
    case 'compvelocity'
        predFlags = [0 0 0 0 1 0];
    case 'movedir'
        predFlags = [0 0 0 0 0 1];
end

fileVAFs = cell(size(doFiles,1),1);
fileR2 = cell(size(doFiles,1),1);
fileFR = cell(size(doFiles,1),1);

% now, build decoder for baseline
for iFile = 1:size(doFiles,1)
    root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
    
    y = doFiles{iFile,2}(1:4);
    m = doFiles{iFile,2}(6:7);
    d = doFiles{iFile,2}(9:10);
    
    bin_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_trim.mat']);
    filt_file = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_BL_' m d y '_Decoder_' decoder '.mat']);
    
    load(bin_file);
    try
    binsize=binnedData.timeframe(2)-binnedData.timeframe(1);
    catch
        keyboard
    end
    DecoderOptions = struct('foldlength',foldLength,'PredEMGs',0,'PredCursPos',predFlags(1),'PredVeloc',predFlags(2),'PredTarg',predFlags(3),'PredForce',predFlags(4),'PredCompVeloc',predFlags(5),'PredMoveDir',predFlags(6),'fillen',numlags*binsize,'UseAllInputs',1,'PolynomialOrder',3,'numPCs',0,'Use_Thresh',0,'Use_EMGs',0,'Use_Ridge',0,'Use_SD',0);
    
    [filt_struct, ~] = BuildModel_Matt(binnedData, DecoderOptions);
    
    disp('Done.');
    if isempty(filt_struct)
        disp('Model Building Failed');
        return;
    end
    
    disp('Saving prediction model...');
    save(filt_file,'filt_struct');
    
    % Now, do mfxval for baseline and get VAFs
    DecoderOptions = struct('PredEMGs',0,'PredCursPos',predFlags(1),'PredVeloc',predFlags(2),'PredTarg',predFlags(3),'PredForce',predFlags(4),'PredCompVeloc',predFlags(5),'PredMoveDir',predFlags(6),'fillen',numlags*binsize,'UseAllInputs',1,'PolynomialOrder',3,'Use_SD',0,'foldlength',foldLength);
    disp(sprintf('Proceeding to multifold cross-validation using %g sec folds...', DecoderOptions.foldlength));
    
    [mfxval_R2, mfxval_vaf, mfxval_mse, ~] = mfxval_Matt(binnedData, DecoderOptions);
    fileVAFs{iFile} = mfxval_vaf;
    fileR2{iFile} = mfxval_R2;
    
    fileFR{iFile,1} = {binnedData.spikeguide,rms(binnedData.spikeratedata,1)};
    
    disp('Done.');
    
    clear binnedData OLPredData DecoderOptions mfxval_r2 mfxval_vaf mfxval_mse;
    
end
disp('Done.');