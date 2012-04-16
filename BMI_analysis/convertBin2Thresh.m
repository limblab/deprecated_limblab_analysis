function Thresh_FileNames = convertBin2Thresh(varargin)

        %varargin = Bin_FileNames, dataPath, binsize, starttime, stoptime, hpfreq,lpfreq, MinFiringRate
        
    dataPath = 'D:\Monkey\';

    [Bin_FileNames, PathName] = uigetfile( { [dataPath '\*.mat']},...
                                            'Open Binned Data File(s)', 'MultiSelect','on' );
    if ~PathName
        disp('User Action Cancelled');
        Bin_FileNames = {};
        return;
    else
        dataPath = PathName;
    end
    %Save directory:
    savePath = PathName;
    
    if iscell(Bin_FileNames)
        numFiles = size(Bin_FileNames,2);
    elseif ischar(Bin_FileNames);
        numFiles = 1;
        Bin_FileNames = {Bin_FileNames};
    end        

    for i=1:size(Bin_FileNames,2)
        disp(sprintf('Converting Unit ID for file %s...', Bin_FileNames{:,i} ));
        Thresh_data = convNeurIDsTo96chID1([dataPath '\' Bin_FileNames{:,i}]);
        Thresh_FileName = strrep(Bin_FileNames{:,i},'.mat','_thresh.mat');
        disp(sprintf('Saving Threshed data file %s...',Thresh_FileName));
        save([savePath '\' Thresh_FileName ], 'Thresh_data');
        disp('Done.');
    end
    
end

function Thresh_data = convNeurIDsTo96chID1(binnedData)
    %Load the file or structure
    binnedData = LoadDataStruct(binnedData);
    
    numpts  = size(binnedData.spikeratedata,1);
    NeurIDs = spikeguide2neuronIDs(binnedData.spikeguide);
        
    spikeratenew = zeros(numpts,96);
    
    for ch=1:96
        units_idx = find(NeurIDs(:,1)==ch);
        spikeratenew(:,ch) = sum(binnedData.spikeratedata(:,units_idx),2);
    end
    
    Thresh_data = binnedData;
    Thresh_data.spikeratedata = spikeratenew;
    Thresh_data.NeuronIDs = [(1:96)' ones(96,1)];
    Thresh_data.spikeguide= NeuronIDs2spikeguide(Thresh_data.NeuronIDs);
end    
   

