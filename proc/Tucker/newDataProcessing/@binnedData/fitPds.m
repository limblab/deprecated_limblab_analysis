function fitPds(binned)
    %this is a method function of the binnedData class and should be saved
    %in the @binnedData folder with the class definition and other methods
    %files
    %
    %bd.fitPds uses the configuration in the bd.pdConfig field to compute
    %preferred directions for each unit and stores the result in the
    %bd.pdData field
    
    %get our list of units
    if isempty(binned.pdConfig.units)
        %find all our units and make a cell array containing the whole list
        mask=false(1,numel(binned.bins.Properties.VariableNames));
        for i=1:numel(mask);
            if ~isempty(strfind(binned.bins.Properties.VariableNames{i},'CH')) && ~isempty(strfind(binned.bins.Properties.VariableNames{i},'ID'))
                mask(i)=true;
            end
        end
    else
        %use the list the user supplied
        mask=binned.pdConfig.units;
    end
    uList=binned.bins.Properties.VariableNames(mask);
    %get the mask for the rows of 
    if isempty(binned.pdConfig.windows)
        rowMask=true(size(binned.bins.t));
    else
        rowMask=windows2mask(binned.bins.t,binned.pdConfig.windows);
    end
    % check the method and compute PDs
    switch binned.pdConfig.method
        case 'glm'
            %% set up parallel processing
            opt=setUpParallelProcessing(binned.pdConfig.useParallel);
            %% set up the modelSpec string that contains the wilkinson notation describing the model to fit
            fullInput={'x+y','vx+vy','fx+fy','speed'};
            inputMask=[pdConfig.pos,pdConfig.vel,pdConfig.force,pdConfig.speed];
            modelSpec=[strjoin(fullInput(inputMask),'+'),'~',strjoin(uList,',')];
            %% Set up parameters for bootstrap and GLM
            % set boot function by checking stats toolbox version number
            if(verLessThan('stats','8.0'))
                error('COMPUTE_TUNING requires Statistics Toolbox version 8.0(R2012a) or higher');
            elseif(verLessThan('stats','9.1'))
                bootfunc = @(data) GeneralizedLinearModel.fit(data,modelSpec,'Distribution',binned.pdConfig.glmNoiseModel);
            else
                bootfunc = @(data) fitglm(data,modelSpec,'Distribution',binned.pdConfig.glmNoiseModel);
            end
            
            %% run GLM
            %Full GLM
            whole_tuning = bootfunc(binned.bins(rowMask,:));

            %bootstrap for firing rates to get output parameters
            boot_tuning = bootstrp(bootstrap_params.num_rep,@(data) {bootfunc(data)}, binned.bins(rowMask,:),'Options',opt);
            
            %% convert GLM data into PDs
            
            %% put PD data into output table
            pdType={'pos','vel','force','speed'};
            pdData=table(reshape(uList,numel(uList),1),'VariableNames','');
            for i=1:numel(pdType)
                if(inputMask(i))
%                     dir=
%                     dirCI=
%                     moddepth=
%                     moddepthCI=
                    
                    %construct column names for the table
                    type=pdType{inputMask(i)};
                    vNames={[type,'Dir'],[type,'DirCI'],[type,'Moddepth'],[type,'ModdepthCI'],[type,'Istuned']};
                    
                    pdData=[pdData,table(dir,dirCI,moddepth,moddepthCI ,'VariableNames',vNames)];
                end
            end
            set(binned,'pdData',pdData)
        otherwise
            error('fitPds:badMethod',[binned.pdConfig.method, ' is not a valid method. currently only the glm method is implemented'])
    end
    
end

function opt=setUpParallelProcessing(useParallel)
    if(useParallel)
        try
            if(isempty(gcp))
                parpool;
            end
            opt = statset('UseParallel',true);
        catch
            warning('Problem with Parallel Computing Toolbox. Code may not execute properly')
        end
    else
        opt = statset('UseParallel',false);
    end
end