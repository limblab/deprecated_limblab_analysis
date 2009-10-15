function Bin_FileNames = convertBatch2Binned(varargin)

        %varargin = BDF_FileNames, dataPath, binsize, starttime, stoptime, hpfreq,
        %lpfreq, MinFiringRate
        
    dataPath = 'C:\Monkey\Theo\Data';
    addpath ../
    
    if nargin == 0
        [BDF_FileNames, PathName] = uigetfile( { [dataPath '\BDFStructs\*.mat']},...
                                                'Open BDF Data File(s)', 'MultiSelect','on' );
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate] = convertBDF2binnedGUI;
    elseif nargin == 2
        BDF_FileNames = varargin{1};
        dataPath = varargin{2};
        [binsize, starttime, stoptime, hpfreq, lpfreq, MinFiringRate] = convertBDF2binnedGUI;
    elseif nargin == 8
        BDF_FileNames = varargin{1};
        binsize = varargin{3};
        starttime = varargin{4};
        stoptime = varargin{5};
        hpfreq = varargin{6};
        lpfreq = varargin{7};
        MinFiringRate = varargin{8};
    else
        disp('Wrong Number of argument in call to ''convertBatch2Binned''');
        return;
    end
        
    Bin_FileNames = BDF_FileNames;
    
    for i=1:size(BDF_FileNames,2)
        disp(sprintf('Binning %s structure...', BDF_FileNames{:,i} ));
        binnedData = convertBDF2binned([dataPath '\BDFStructs\' BDF_FileNames{:,i}],binsize,starttime,stoptime,hpfreq,lpfreq,MinFiringRate);
        disp(sprintf('Saving binned data file %s...',Bin_FileNames{:,i}));
        save([dataPath '\BinnedData\' Bin_FileNames{:,i} ], 'binnedData');
        disp('Done.');
    end
    
end