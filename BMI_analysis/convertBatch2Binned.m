function Bin_FileNames = convertBatch2Binned(varargin)

        %varargin = BDF_FileNames, dataPath, binsize, starttime, stoptime, hpfreq,
        %lpfreq, MinFiringRate
        
    dataPath = 'D:\Monkey\';
        
    if nargin == 0
        [BDF_FileNames, PathName] = uigetfile( { [dataPath '\*.mat']},...
                                                'Open BDF Data File(s)', 'MultiSelect','on' );
        if ~PathName
            disp('User Action Cancelled');
            Bin_FileNames = {};
            return;
        else
            dataPath = PathName;
        end
        %Save directory:
        savePath = uigetdir([dataPath '\..\..'],'Select a Destination Directory for Binned Files');
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
        savePath = uigetdir([dataPath '\..\..'],'Select a Destination Directory for Binned Files');
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

    Bin_FileNames = BDF_FileNames;    
    
    for i=1:size(BDF_FileNames,2)
        disp(sprintf('Binning %s structure...', BDF_FileNames{:,i} ));
        binnedData = convertBDF2binned([dataPath '\' BDF_FileNames{:,i}],BDF2BinArgs);
        disp(sprintf('Saving binned data file %s...',Bin_FileNames{:,i}));
        save([savePath '\' Bin_FileNames{:,i} ], 'binnedData');
        disp('Done.');
    end
    
end