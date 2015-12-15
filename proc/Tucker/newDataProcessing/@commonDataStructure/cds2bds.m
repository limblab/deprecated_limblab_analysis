function bds=cds2bds(cds,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %

    %% parse inputs
        recalcFR=0;
        for i=1:2:length(varargin)
            switch varargin{i}
                case 'recalcFR'
                    recalcFR=varargin{i+1};
                case 'timeWindows'
                    timeWindows=varargin{i+1};
                case 'dataFeatures'
                    features=varargin{i+1};
                otherwise
                    if ~ischar(varargin{i})
                        error('calcFR:badOptionFormat','cds2bds takes options in key-value pairs. Keys must be strings specifying a valid option, e.g. method')
                    else
                        error('calcFR:unrecognizedOption',['The option: ',varargin{i},'is not recognized'])
                    end
            end
        end

        if ~exist('timeWindows','var')
            timeWindows=[0 cds.meta.duration];
        end
        if ~exist('features','var')
            features={'FR','pos','vel','acc','force','EMG','LFP','analog'};
        end
    
    %% if necessary recompute FR
        if ~isempty(find(strcmp('FR',features))) && (isempty(cds.FR) || recalcFR)
            cds.calcFR('method',cds.binConfig.FR.Method,'SR',cds.binConfig.filter.SR,'offset',cds.binConfig.FR.offset)
        end
        
    %% instatiate the bds
        bds=binnedDataStructure();
    
    %% build the meta field for the bds
        meta=cds.meta;
        %modify some meta fields:
        meta.dataSource='cds';
        meta.includedData=dataList;
        %add some new meta fields
        meta.bdsVersion=bds.meta.bdsVersion;
        meta.SR=cds.binConfig.SR;
        meta.offset=cds.binConfig.offset;
        if(isempty(features))
            error('cds2bds:NoFeatures','cannot construct bds with no features')
        end
    %% start main data table using a single time column:
        data=table(cds.meta.dataWindow(1):1/bds.meta.SR:cds.meta.dataWindow(2),'VariableNames',{'t'});
    %% loop through features and add them to the table if they exist in the cds
        for i=1:length(features)
            switch features{i}
                case 'FR'
                    if ~isempty(cds.FR)

                    end
                case 'pos'
                    if ~isempty(cds.pos)

                    end
                case 'vel'
                    if ~isempty(cds.vel)

                    end
                case 'acc'
                    if ~isempty(cds.acc)

                    end
                case 'force'
                    if ~isempty(cds.force)

                    end
                case 'EMG'
                    if ~isempty(cds.EMG)

                    end
                case 'LFP'
                    if ~isempty(cds.LFP)

                    end
                case 'analog'
                    if ~isempty(cds.analog)

                    end
                otherwise
                    if ~ischar(features{i})
                        error('bds2cds:featureNotString','All features must be strings')
                    else
                        error('bds2cds:unrecognizedFeature',['the feature ',features{i},' is not a recognized data feature in cds that can be included in the bds'])
                    end
            end
        end
    %% use timeWindows to limit data to rows of interest
end