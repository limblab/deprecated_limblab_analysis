classdef binnedData < matlab.mixin.SetGet
    properties(Access = public)
        weinerConfig
        glmConfig
        gpfaConfig
        kalmanConfig
        pdConfig
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
    events
        ranGLMFit
        ranWeinerFit
        ranGPFAFit
        ranKalmanFit
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
            pdc.method='glm';
            pdc.units=[];
            pdc.pos=false;
            pdc.vel=false;
            pdc.force=false;
            pdc.speed=false;
            pdc.glmNoiseModel='poisson';
            pdc.bootstrapReps=100;
            pdc.windows=[];
            pdc.useParallel=false;
            set(binned,'pdConfig',pdc);
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
            elseif ~isfield(meta,'binSize') && ~isa(meta.binSize,'double')
                error('meta:noBinSize','meta must contain a binSize field with the size of the bins in ms')
            elseif ~isfield(meta,'numLags') && ~isa(meta.numLags,'double')
                error('meta:noNumLags','meta must contain a numLags field with the number of lags used to generate the binned data')
            elseif ~isfield(meta,'dateTime') && ~isa(meta.dateTime,'char')
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
        function set.pdConfig(binned,pdc)
            if ~isstruct(pdc)
                error('pdConfig:notAStruct','the pdConfig field must be a struct describing the way that PDs will be computed')
            elseif ~isfield(pdc,'method') || ~ischar(pdc.method)
                error('pdConfig:badMethod','the method field of pdConfig must be a string describing the method to compute PDs')
            elseif ~isfield(pdc,'units') || (~isempty(pdc.units)&& ~isnumeric(pdc.units))
                error('pdConfig:badUnitsConfiguration','the pdConfig must have a units field that is either empty or contains a set of unit labels')
            elseif ~isfield(pdc,'pos') || ~islogical(pdc.pos)
                error('pdConfig:badPosConfiguration','pdConfig must have a pos field that must have a logical value. Note that 0 or 1 do not count as logicals, you must use the true/false keywords')
            elseif ~isfield(pdc,'vel') || ~islogical(pdc.vel)
                error('pdConfig:badVelConfiguration','pdConfig must have a vel field that must have a logical value. Note that 0 or 1 do not count as logicals, you must use the true/false keywords')
            elseif ~isfield(pdc,'force') || ~islogical(pdc.force)
                error('pdConfig:badForceConfiguration','pdConfig must have a force field that must have a logical value. Note that 0 or 1 do not count as logicals, you must use the true/false keywords')
            elseif ~isfield(pdc,'speed') || ~islogical(pdc.speed)
                error('pdConfig:badspeedConfiguration','pdConfig must have a speed field that must have a logical value. Note that 0 or 1 do not count as logicals, you must use the true/false keywords')
            elseif ~isfield(pdc,'useParallel') || ~islogical(pdc.useParallel)
                error('pdConfic:badUseParallelConfig','pdConfig must have a field useParalle that contains a logical value. Note that 0 or 1 do not count as logicals, you must use the true/false keywords')
            elseif ~isfield(pdc,'windows') || ~isnumeric(pdc.windows) || size(pdc.windows,2)~=2
                error('pdConfig:badWindowConfiguration','pdConfig must have a windows field that contains the 
            else
                binned.pdConfig=pdc;
            end
        end
        function set.weinerData(binned,wData)
            warning('weinerData:SetNotImplemented','set method for the weinerData field of the binnedData class is not implemented')
            binned.weinerData=[];
        end
        function set.pdData(binned,pdData)
            if ~iscell(pdData)
                error('pdData:notCellArray','pdData must be a cell array')
            end
            if ~istable(pdData)
                error('pdData:notATable',['pdData must contain a table. Instead a variabley of type: ',class(pdData),' was passed'])
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
        updateBins(binned,bins)
        %general methods
        fitGlm(binned)
        fitWeiner(binned)
        fitGpfa(binned)
        fitKalman(binned)
        fitPds(binned)
        tuningCircle(binned,label)%plots an empirical tuning circle for a single neuron against the variable 'label'
        polarPDs(binned,units)%makes a polar plot of the PDs associated with the units defined in 'units'    
    end
end