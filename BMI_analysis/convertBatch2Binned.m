function Bin_FileNames = convertBatch2Binned(varargin)

        %varargin = BDF_FileNames, dataPath, binsize, starttime, stoptime, hpfreq,
        %lpfreq, MinFiringRate
        
    dataPath = 'C:\Monkey\Keedoo\';
        
    if nargin == 0
        [BDF_FileNames, PathName] = uigetfile( { [dataPath '\BDFStructs\*.mat']},...
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
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate, NormData] = convertBDF2binnedGUI;
                
    elseif nargin == 2
        BDF_FileNames = varargin{1};
        dataPath = varargin{2};
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate, NormData] = convertBDF2binnedGUI;
        %Save directory:
        savePath = uigetdir([dataPath '\..\..'],'Select a Destination Directory for Binned Files');
        if ~savePath
            disp('User Action Cancelled');
            Bin_FileNames = {};
            return;
        end
    elseif nargin == 10
        BDF_FileNames = varargin{1};
        dataPath = varargin{2};
        binsize = varargin{3};
        starttime = varargin{4};
        stoptime = varargin{5};
        hpfreq = varargin{6};
        lpfreq = varargin{7};
        MinFiringRate = varargin{8};
        NormData = varargin{9};
        savePath = varargin{10};
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
        binnedData = convertBDF2binned([dataPath '\' BDF_FileNames{:,i}],binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate,NormData);
        disp(sprintf('Saving binned data file %s...',Bin_FileNames{:,i}));
        save([savePath '\' Bin_FileNames{:,i} ], 'binnedData');
        disp('Done.');
    end
    
end