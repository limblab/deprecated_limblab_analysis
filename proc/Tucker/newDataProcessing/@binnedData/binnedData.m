classdef binnedData < matlab.mixin.SetGet
    properties(Access = public)
        weinerConfig
        glmConfig
        gpfaConfig
        kalmanConfig
    end
    properties (SetAccess = protected,GetAccess=public,SetObservable=true)
        bins
        meta
        weinerData
        glmData
        pdData
        gpfaData
        kalmanData
    end
    methods (Static = true)
        %constructor
        function binned=binnedData()
            %source data
            set(binned,'bins',cell2table(cell(0,2),'VariableNames',{'t','data'}));
            set(binned,'meta',struct('dateTime','noData','binSize',0,'numLags',0,'offset',0));
            %configs
            set(binned,'weinerConfig',struct('inputLabels',{'all'},'outputLabels',{'all'},'numFolds',0));
            set(binned,'glmConfig',struct('labels',{},'posPD',0,'velPD',0,'forcePD',0,'numRep',100,'noiseModel','poisson'));
            set(binned,'gpfaConfig',struct('structData','this is a stub struct that needs to be coded'));
            set(binned,'kalmanConfig',struct('structData','this is a stub struct that needs to be coded'));
            %output data
            set(binned,'weinerData',struct('structData','this is a stub struct that needs to be coded'));
            PDs={cell2table(cell(0,8),'VariableNames',{'chan','ID','array','posDir','posDirCI','posModdepth','posModdepthCI','isTuned'}),...
                    cell2table(cell(0,8),'VariableNames',{'chan','ID','array','velDir','velDirCI','velModdepth','velModdepthCI','isTuned'}),...
                    cell2table(cell(0,8),'VariableNames',{'chan','ID','array','forceDir','forceDirCI','forceModdepth','forceModdepthCI','isTuned'})};
            set(binned,'pdData',PDs);
            set(binned,'glmData',[]);
            set(binned,'gpfaData',[]);
            set(binned,'kalmanData',[]);
        end
    end
    methods
        %set methods
        function set.bins(binned,data)
            if ~istable(data)
                error('bins:NotATable','the bins field of a binnedData class object must be a table')
            elseif isempty(find(strcmp('t',data.Properties.VariableNames),1))
                error('bins:NoTimeColumn','the bins table of a binnedData class object must have a time column')
            else
                binned.bins=data;
            end
        end
        function set.meta(binned,meta)
            if ~isstruct(meta)
                error('meta:notAStruct','meta must be a struct')
            elseif ~isfield(meta,'binSize') & ~isa(meta.binSize,'double')
                error('meta:noBinSize','meta must contain a binSize field with the size of the bins in ms')
            elseif ~isfield(meta,'numLags') & ~isa(meta.numLags,'double')
                error('meta:noNumLags','meta must contain a numLags field with the number of lags used to generate the binned data')
            elseif ~isfield(meta,'dateTime') & ~isa(meta.dateTime,'char')
                error('meta:noNumLags','meta must contain a numLags field with the number of lags used to generate the binned data')
            end
            binned.meta=meta;
        end
        function set.weinerConfig(binned,wc)
            if ~isstruct(wc)
                error('weinerConfig:notAStruct','weinerConfig must be a struct')
            else
                binned.weinerConfig=wc;
            end
        end
        function set.glmConfig(binned,glmc)
            if ~isstruct(glmc)
                error('glmConfig:notAStruct','glmConfig must be a struct')
            else
                binned.glmConfig=glmc;
            end
        end
        function set.gpfaConfig(binned,gpfac)
            if ~isstruct(gpfac)
                error('gpfaConfig:notAStruct','gpfaConfig must be a struct')
            else
                binned.gpfaConfig=gpfac;
            end
        end
        function set.kalmanConfig(binned,kfc)
            if ~isstruct(kfc)
                error('kalmanConfig:notAStruct','kalmanConfig must be a struct')
            else
                binned.kalmanConfig=kfc;
            end
        end
        
        function set.weinerData(binned,wData)
            warning('weinerData:SetNotImplemented','set method for the weinerData field of the binnedData class is not implemented')
            binned.weinerData=[];
        end
        function set.pdData(binned,pdData)
            if ~iscell(pdData)
                error('pdData:not a cell array','pdData must be a cell array')
            end
            prefix={'pos','vel','force'};
            for i=1:length(pdData)
                if ~istable(pdData{i})
                    error('pdData:notATable',['Each cell of pdData must contain a table. Cell ',num2str(i),'is a: ',class(pdData{i})])
                elseif size(pdData{i},2)~=8 ...
                    || isempty(find(strcmp('chan',pdData{i}.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('ID',pdData{i}.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp([prefix{i},'Dir'],pdData{i}.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp([prefix{i},'DirCI'],pdData{i}.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp([prefix{i},'Moddepth'],pdData{i}.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp([prefix{i},'ModdepthCI'],pdData{i}.Properties.VariableNames),1)) ...
                    || isempty(find(strcmp('isTuned',pdData{i}.Properties.VariableNames),1))
                    disp(['the table for ',prefix{i},'has the following columns:'])
                    disp(pdData{i}.Properties.VariableNames)
                    error('pdData:badColumnSpec',['cell: ',num2str(i),'is the ',prefix{i}, ' PD table, and must have the following columns: chan, ID',prefix{i},'Dir',prefix{i},'DirCI',prefix{i},'Moddepth',prefix{i},'ModdepthCI','isTuned'])
                end
            end
        end
        function set.glmData(binned,glmData)
            warning('glmData:SetNotImplemented','set method for the glmData field of the binnedData class is not implemented')
            binned.glmData=[];
        end
        function set.gpfaData(binned,gpfaData)
            warning('gpfaData:SetNotImplemented','set method for the gpfaData field of the binnedData class is not implemented')
            binned.gpfaData=[];
        end
        function set.kalmanData(binned,kfData)
            warning('kalmanData:SetNotImplemented','set method for the kalmanData field of the binnedData class is not implemented')
            binned.kalmanData=[];
        end
    end
    methods (Static = false)
        %general methods
        fitGlm(binned)
        fitWeiner(binned)
        fitGpfa(binned)
        fitKalman(binned)
        
        tuningCircle(binned,label)%plots an empirical tuning circle for a single neuron against the variable 'label'
        polarPDs(binned,units)%makes a polar plot of the PDs associated with the units defined in 'units'    
    end
end