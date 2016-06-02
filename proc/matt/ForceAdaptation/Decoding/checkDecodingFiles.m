function checkDecodingFiles(root_dirs,use_array,doFiles,epochs,kin_array,rewriteFiles)
    % check for binnedData and Decoder directories
    disp('Checking directories...');
    for iFile = 1:size(doFiles,1)
        root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
        
        out_dir = fullfile(root_dir,use_array,'BDFStructs',doFiles{iFile,2});
        if ~exist(out_dir,'dir')
            mkdir(out_dir);
        end
        out_dir = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2});
        if ~exist(out_dir,'dir')
            mkdir(out_dir);
        end
        out_dir = fullfile(root_dir,use_array,'Decoders',doFiles{iFile,2});
        if ~exist(out_dir,'dir')
            mkdir(out_dir);
        end
    end
    disp('Done.');
    
    % first check to make sure all of the BDFs exist
    if strcmpi(use_array,'pmd')
        for iFile = 1:size(doFiles,1)
            root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
            
            y = doFiles{iFile,2}(1:4);
            m = doFiles{iFile,2}(6:7);
            d = doFiles{iFile,2}(9:10);
            
            for iEpoch = 1:length(epochs)
                neural_data_file = fullfile(root_dir,use_array,'BDFStructs',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '.mat']);
                kin_data_file = fullfile(root_dir,kin_array,'BDFStructs',doFiles{iFile,2},[doFiles{iFile,1} '_' kin_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '.mat']);
                
                out_dir = fullfile(root_dir,use_array,'BDFStructs',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '_comp.mat']);
                if ~exist(out_dir,'file') || rewriteFiles
                    disp('Combining BDFs');
                    % load files
                    load(neural_data_file);
                    neur = out_struct;
                    clear out_struct;
                    
                    load(kin_data_file);
                    
                    % add neural data to other bdf
                    out_struct.units = neur.units;
                    
                    % save combined bdf
                    
                    save(out_dir,'out_struct','-v7.3');
                    clear neur out_struct;
                else
                    % maybe have check to make sure it has kinematic data?
                    disp('Comp BDF already exists')
                end
            end
        end
    end
    disp('Done.');