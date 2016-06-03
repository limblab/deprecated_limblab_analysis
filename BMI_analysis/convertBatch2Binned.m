function Bin_FileNames = convertBatch2Binned(varargin)

        %varargin = BDF_FileNames, dataPath, binsize, starttime, stoptime, hpfreq,
        %lpfreq, MinFiringRate
        
    if nargin == 0
        [BDF_FileNames, PathName] = uigetfile( { '*.mat'},...
                                                'Open BDF Data File(s)', 'MultiSelect','on' );
        if ~PathName
            disp('User Action Cancelled');
            Bin_FileNames = {};
            return;
        else
            dataPath = PathName;
        end
        %Save directory:
        savePath = uigetdir([dataPath filesep '..' filesep '..'],'Select a Destination Directory for Binned Files');
        if ~savePath
            disp('User Action Cancelled');
            Bin_FileNames = {};
            return;
        end
        BDF2BinArgs = convertBDF2binnedGUI;
                
    elseif nargin == 2
        BDF_FileNames = varargin{1};
        dataPath = varargin{2};
        BDF2BinArgs = convertBDF2binnedGUI;
        %Save directory:
        savePath = uigetdir([dataPath filesep '..' filesep '..'],'Select a Destination Directory for Binned Files');
        if ~savePath
            disp('User Action Cancelled');
            Bin_FileNames = {};
            return;
        end
    elseif nargin == 4
        BDF_FileNames = varargin{1};
        dataPath = varargin{2};
        BDF2BinArgs = varargin{3};
        savePath = varargin{4};
    else
        disp('Wrong Number of argument in call to ''convertBatch2Binned''');
        Bin_FileNames = {};
        return;
    end
    
    if iscell(BDF_FileNames)
        numFiles = size(BDF_FileNames,2);
    elseif ischar(BDF_FileNames);
        numFiles = 1;
        BDF_FileNames = {BDF_FileNames};
    end        

    Bin_FileNames = strrep(BDF_FileNames,'_bdf','_bin');    
    
    
    
    for i=1:numFiles
        
        BDF = LoadDataStruct([dataPath filesep BDF_FileNames{:,i}]);
        
        if BDF2BinArgs.ArtRemEnable
            disp('Looking for Artifacts...');
            BDF = artifact_removal(BDF,BDF2BinArgs.NumChan,BDF2BinArgs.TimeWind, 1);
        end
        fprintf('Binning %s structure...', BDF_FileNames{:,i});
%         binnedData = convertBDF2binned([dataPath '\' BDF_FileNames{:,i}],BDF2BinArgs);
        binnedData = convertBDF2binned(BDF,BDF2BinArgs);
        fprintf('Saving binned data file %s...',Bin_FileNames{:,i});
        save([savePath filesep Bin_FileNames{:,i} ], 'binnedData');
        disp('Done.');
    end
    
end