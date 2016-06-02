function superBatch(animal,dateNumber,pathOverride)

% syntax superBatch(animal,dateNumber)
% 
% runs as function.

diary off

% because this takes a long time to run, it is useful to know when any
% errors occurred, independently of information about what the error
% actually was.

try    
    % preliminary -- copy the files over.  Doesn't take too long.
    if ~nargin
        % have to run interactively
        [CEBorPLX,remoteFolder,~]=getDataByDate;
    elseif nargin==1
        % still have to run interactively
        [CEBorPLX,remoteFolder,~]=getDataByDate(animal);
    else % the expected number of inputs (2), or even 3
        % can run by remote, if we ever figure that out.
        if dateNumber<datenum('09-29-2011')
            %          disp('superBatch.m is not valid for recordings earlier than 09/29/2011.')
            %          disp('blame the data server update.')
            %          return
        end
        
        if nargin==3
            [CEBorPLX,remoteFolder,~]=getDataByDate(animal,dateNumber,pathOverride);
        else
            [CEBorPLX,remoteFolder,~]=getDataByDate(animal,dateNumber);
        end
    end
    if isequal(animal,'Chewie')
        remoteFolder2=regexprep(remoteFolder,'BDFs','Filter files');
    elseif isequal(animal,'Mini')
        remoteFolder2=regexprep(remoteFolder,'bdf','FilterFiles');
    elseif isequal(animal,'Jaco')
        remoteFolder2=regexprep(remoteFolder,'bdf','FilterFiles');
    end
    
    % the long-winded stuff.
    PathName=pwd;
    diary(fullfile(PathName,'decoderOutput.txt'))
    switch CEBorPLX
        case 'ceb' % this makes .plx the default
            batch_get_cerebus_data % runs as script.  uses PathName
            % put .mat files on the data server in an appropriate folder
            % put EMGonly files
            %     batch_buildLFP_EMGdecoder
            %     batch_buildLFPpositionDecoderRDF
        case 'plx'
            batch_get_plexon_data % runs as script.  uses PathName
            batch_buildLFPpositionDecoderRDF    % only runs on hand-control files
            diary off
            batch_build1FeatureDecoders
            try
                save('singleFeatureDecoders.mat','vaf1feat_all', ...
                    'bestf1feat_all','bestc1feat_all','VAFstruct')
            end
            diary(fullfile(PathName,'decoderOutput.txt'))
            batch_buildSpikePositionDecoderRDF  % only runs on hand-control files
        otherwise
            % there is no data for that date.  delete the folder that was
            % created, and exit.
            diary off
            cd ..
            [~,folderToDelete,~]=FileParts(PathName);
            if exist(folderToDelete,'file')==7
                rmdir(folderToDelete,'s')
            end
            return
    end
    
    % copy the newly created data into appropriate location on citadel.
    diary(fullfile(PathName,'decoderOutput.txt'))
    mkdir(remoteFolder)
    D=dir(PathName);
    MATfiles={D(cellfun(@isempty,regexp({D.name},'_Spike_LFP.*(?<!poly.*|-spike.*)\.mat'))==0).name};
    for copyfileIndex=1:length(MATfiles)
        copyfile(MATfiles{copyfileIndex},fullfile(remoteFolder,MATfiles{copyfileIndex}))
        fprintf(1,'%s copied to %s\n',MATfiles{copyfileIndex},fullfile(remoteFolder,MATfiles{copyfileIndex}))
    end
    
    % copy the decoders, and the log, into their appropriate place
    decoderFiles={D(cellfun(@isempty,regexp({D.name},'.*poly.*|.*-spike.*\.mat','match','once'))==0).name};
    mkdir(remoteFolder2)
    for copyfileIndex=1:length(decoderFiles)
        copyfile(decoderFiles{copyfileIndex},fullfile(remoteFolder2,decoderFiles{copyfileIndex}))
        fprintf(1,'%s copied to %s\n',decoderFiles{copyfileIndex},fullfile(remoteFolder2,decoderFiles{copyfileIndex}))
    end
    if exist('allFPsToPlot.mat','file')==2
        copyfile('allFPsToPlot.mat',remoteFolder2)
        fprintf(1,'allFPsToPlot.mat copied successfully to %s\n',remoteFolder2)
    end
    if exist('singleFeatureDecoders.mat','file')==2
        copyfile('singleFeatureDecoders.mat',remoteFolder2)
        fprintf(1,'singleFeatureDecoders.mat copied successfully to %s\n',remoteFolder2)
    end
    
    % get cursor kinematics for brain control files.  Was previously
    % attempting to be clever with this, but was forgetting the fact that in
    % superBatch, the network copies of the files are going to be
    % overwritten every time, because that's what superBatch does.  So, by
    % the time we get to this point we'll need to re-run
    % batch_get_cursor_kinematics using scratch files anyway.
    
    % update 03-12-2013: improved the logic that determines what is a brain
    % control file and what isn't, meaning that the brain control files on
    % citadel should once again start having properly imported .pos and
    % .vel fields.  However, kinematicsHandControl is still broken for CO
    % files.  It doesn't look for the proper starting word, and there may
    % be other problems as well.  So, the kinStructs for these days will
    % still be off until that function is debugged.
    batch_get_cursor_kinematics
    if exist('kinStruct','var')==1
        save(fullfile(remoteFolder2,'kinStruct.mat'),'kinStruct')
    end
    
    diary off
    copyfile(fullfile(PathName,'decoderOutput.txt'),remoteFolder2)
    fprintf(1,'decoderOutput.txt copied successfully to %s\n',remoteFolder2)
    
    try
        % if we're on BumblebeeMan, clean up...
        if strcmpi(machineName,'bumblebeeman')
            localAnalysisFolder=fullfile(['E:\personnel\RobertF\',...
                'monkey_analyzed'],animal,datestr(dateNumber,'mm-dd-yyyy'));
            mkdir(localAnalysisFolder)
            movefile('allFPsToPlot.mat',fullfile(localAnalysisFolder, ...
                'allFPsToPlot.mat'))
            for moveFileIndex=1:length(decoderFiles)
                movefile(decoderFiles{moveFileIndex}, ...
                    fullfile(localAnalysisFolder,decoderFiles{moveFileIndex}))
                fprintf(1,'%s copied to %s\n',decoderFiles{moveFileIndex}, ...
                    fullfile(localAnalysisFolder,decoderFiles{moveFileIndex}))
            end
            movefile('decoderOutput.txt', ...
                fullfile(localAnalysisFolder,'decoderOutput.txt'))
            movefile('singleFeatureDecoders.mat', ...
                fullfile(localAnalysisFolder,'singleFeatureDecoders.mat'))
        end
    end
    
catch ME
    fprintf(1,'\nThe time of the error was %s.\n',datestr(now))
    rethrow(ME)
end
    
    
