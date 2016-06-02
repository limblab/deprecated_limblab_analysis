function binDataFiles(root_dirs,use_array,doFiles,epochs,rewriteFiles)

for iFile = 1:size(doFiles,1)
    root_dir = root_dirs{strcmpi(root_dirs(:,1),doFiles{iFile,1}),2};
    
    y = doFiles{iFile,2}(1:4);
    m = doFiles{iFile,2}(6:7);
    d = doFiles{iFile,2}(9:10);
    
    for iEpoch = 1:length(epochs)
        
        if strcmpi(use_array,'pmd')
            bdf_file = fullfile(root_dir,use_array,'BDFStructs',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '_comp.mat']);
        else
            bdf_file = fullfile(root_dir,use_array,'BDFStructs',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '.mat']);
        end
        
        out_file = fullfile(root_dir,use_array,'BinnedData',doFiles{iFile,2},[doFiles{iFile,1} '_' use_array '_' doFiles{iFile,4} '_' doFiles{iFile,3} '_' epochs{iEpoch} '_' m d y '.mat']);
        
        if ~exist(out_file,'file') || rewriteFiles
            BDF2BinArgs = struct('binsize',0.05,'starttime',0,'stoptime',0,'EMG_hp',50,'EMG_lp',10,'minFiringRate',0,'NormData',0,'FindStates',0,'Unsorted',0,'TriKernel',0,'sig',0.04,'ArtRemEnable',0,'NumChan',10,'TimeWind',5e-04);
            disp('Loading BDF...')
            BDF = LoadDataStruct(bdf_file);
            
            if BDF2BinArgs.ArtRemEnable
                disp('Looking for Artifacts...');
                BDF = artifact_removal(BDF,BDF2BinArgs.NumChan,BDF2BinArgs.TimeWind, 1);
            end
            
            disp('Converting BDF structure to binned data...');
            binnedData = convertBDF2binned_Matt(BDF,BDF2BinArgs);
            
            disp('Done.');
            
            disp('Saving binned data...');
            save(out_file,'binnedData');
        else
            disp('Binned data already exists')
        end
        
        clear binsize starttime stoptime hpfreq lpfreq MinFiringRate NormData FindStates;
        clear binnedData BDF;
    end
end
disp('Done.');
