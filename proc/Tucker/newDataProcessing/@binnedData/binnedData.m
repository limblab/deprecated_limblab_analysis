classdef binnedData < matlab.mixin.SetGet
    properties(SetAccess = public)
        weinerConfig
        pdConfig
        gpfaConfig
        kalmanConfig
    end
    properties (Access = private)
        bins
        weiner
        pd
        gpfa
        kalman
    end
    methods (Static = true)
        %constructor
        function binned=binnedData()
            weinerConfig=[];
            glmConfig=struct('labels',{},'posPD',0,'velPD',0,'forcePD',0);
            gpfaConfig=[];
            kalmanConfig=[];
            
            bins=cell2table(cell{0,2},'VariableNames',{'t','data'});
            weiner=[];
            pd=[];
            gpfa=[];
            kalman=[];
        end
    end
    methods
        %set methods
        function set.weinerConfig(binned,wc)
            if ~isstruct(wc)
                error('weinerConfig:notAStruct','weinerConfig must be a struct')
            else
            end
        end
        function set.pdConfig(binned,pdc)
        end
        function set.gpfaConfig(binned,gpfac)
        end
        function set.kalmanConfig(binned,kfc)
        end
        
        function set.bins(binned,bd)
        end
        function set.weiner(binned,w)
        end
        function set.pd(binned,pd)
        end
        function set.gpfa(binned,gpfa)
        end
        function set.kalman(binned,kf)
        end
    end
end