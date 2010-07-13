function Bin_FileNames = convertBatch2Binned(varargin)

        %varargin = BDF_FileNames, dataPath, binsize, starttime, stoptime, hpfreq,
        %lpfreq, MinFiringRate
        
    dataPath = 'C:\Monkey\Keedoo\';
    
    if nargin == 0
        [BDF_FileNames, PathName] = uigetfile( { [dataPath '\BDFStructs\*.mat']},...
                                                'Open BDF Data File(s)', 'MultiSelect','on' );
        if ~PathName
            disp('User Action Cancelled');
            clear all;
            return;
        end
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate, NormData] = convertBDF2binnedGUI;
    elseif nargin == 2
        BDF_FileNames = varargin{1};
        dataPath = varargin{2};
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate, NormData] = convertBDF2binnedGUI;
    elseif nargin == 9
        BDF_FileNames = varargin{1};
        binsize = varargin{3};
        starttime = varargin{4};
        stoptime = varargin{5};
        hpfreq = varargin{6};
        lpfreq = varargin{7};
        MinFiringRate = varargin{8};
        NormData = varargin{9};
    else
        disp('Wrong Number of argument in call to ''convertBatch2Binned''');
        clear all;
        return;
    end
        
    Bin_FileNames = BDF_FileNames;
    %Save directory:
    savePath = uigetdir([PathName '\..\..'],'Select a Destination Directory');
    
    if ~savePath
        disp('User Action Cancelled');
        clear all;
        return;
    end
    
    for i=1:size(BDF_FileNames,2)
        disp(sprintf('Binning %s structure...', BDF_FileNames{:,i} ));
        binnedData = convertBDF2binned([PathName '\' BDF_FileNames{:,i}],binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate,NormData);
        disp(sprintf('Saving binned data file %s...',Bin_FileNames{:,i}));
        save([savePath '\' Bin_FileNames{:,i} ], 'binnedData');
        disp('Done.');
    end
    
end