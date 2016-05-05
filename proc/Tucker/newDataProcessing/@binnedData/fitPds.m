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
        unitMask=~cellfun(@(x)isempty(strfind(x,'CH')),binned.bins.Properties.VariableNames) & ~cellfun(@(x)isempty(strfind(x,'ID')),binned.bins.Properties.VariableNames);
    else
        %use the list the user supplied
        unitMask=binned.pdConfig.units;
    end
    uList=binned.bins.Properties.VariableNames(unitMask);
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
%             opt=setUpParallelProcessing(binned.pdConfig.useParallel);
            %% Set up parameters for bootstrap and GLM
            disp('starting GLM based PD computation')
            % set boot function by checking stats toolbox version number
            if(verLessThan('stats','10'))
                error('COMPUTE_TUNING requires Statistics Toolbox version 10.0(R2015a) or higher');
            end
            noiseModel=binned.pdConfig.glmNoiseModel;%if you don't abstract the noise model into a variable, then bootstrp will create copies of the whole binned object at each iteration.
            %% set up the modelSpec string that contains the wilkinson notation describing the model to fit
            fullInput={'x+y','vx+vy','fx+fy'};%,'speed'};
            inputMask=[binned.pdConfig.pos,binned.pdConfig.vel,binned.pdConfig.force];%,binned.pdConfig.speed];
            inputList=[];
            if binned.pdConfig.pos
                inputList=[inputList,{'x','y'}];
            end
            if binned.pdConfig.vel
                inputList=[inputList,{'vx','vy'}];
            end
            if binned.pdConfig.force
                inputList=[inputList,{'fx','fy'}];
            end
            inputSpec=strjoin(fullInput(inputMask),'+');
            %% build the data structure we will use to store all the PDs before merging into one big table
            pdType={'pos','vel','force'};
            for i=1:numel(pdType)
                type=pdType{i};
                if(binned.pdConfig.(pdType{i}))
                    data.(type).allPDs=zeros(numel(uList),1);
                    data.(type).allPDCI=zeros(numel(uList),2);
                    data.(type).allModdepth=zeros(numel(uList),1);
                    data.(type).allModdepthCI=zeros(numel(uList),2);
                    data.(type).allIstuned=zeros(numel(uList),1);
                end
            end
            %loop through each unit and compute tuning:
            tic
            for i=1:numel(uList)
                fprintf([uList{i},':','getting data subset(ET=',num2str(toc),'s).'])
                %% set up a mask for the columns we will use for this unit
                colMask=false(1,numel(binned.bins.Properties.VariableNames));
                for j=1:numel(inputList)
                    colMask=colMask | strcmp(inputList{j},binned.bins.Properties.VariableNames);
                end
                %% get subset of the data we will use for fitting:
                colMask=colMask | strcmp(uList{i},binned.bins.Properties.VariableNames);
                dataTable=binned.bins(rowMask,colMask);%if you don't make this sub-table, then bootstrp will include a copy of the WHOLE binned.bins table in the output for EVERY iteration
                %% run GLM
                fprintf(['  Bootstrapping GLM PD computation(ET=',num2str(toc),'s).'])
                %bootstrap for firing rates to get output parameters
                modelSpec=[uList{i},'~',inputSpec];
                bootfunc = @(data) fitglme(data,modelSpec,'Distribution',noiseModel);
                try
                    bootTuning = bootstrp(binned.pdConfig.bootstrapReps,@(data) {bootfunc(data)}, dataTable);
                    bootCoef = cell2mat(cellfun(@(x) x.Coefficients.Estimate',bootTuning,'uniformoutput',false));
                    bootPValues=cell2mat(cellfun(@(x) x.Coefficients.pValue',bootTuning,'uniformoutput',false));
                    %compute the full GLM so we can drop terms later and
                    %compute term significance
                    fullModel=fitglme(dataTable,modelSpec,'Distribution',noiseModel);

                    %% convert GLM data into PDs
                    fprintf(['  Converting GLM weights to PDs(ET=',num2str(toc),'s).\n'])
                    for j=1:numel(pdType)
                        if(binned.pdConfig.(pdType{j}))
                            %get the columns of intereste for this PD in the
                            %input:
                            reducedInputMask=inputMask;
                            switch(pdType{j})
                                case 'pos'
                                    xCol=find(strcmp('x',bootTuning{1}.CoefficientNames));
                                    yCol=find(strcmp('y',bootTuning{1}.CoefficientNames));
                                    reducedInputMask(1)=false;
                                case 'vel'
                                    xCol=find(strcmp('vx',bootTuning{1}.CoefficientNames));
                                    yCol=find(strcmp('vy',bootTuning{1}.CoefficientNames));
                                    reducedInputMask(2)=false;
                                case 'force'
                                    xCol=find(strcmp('fx',bootTuning{1}.CoefficientNames));
                                    yCol=find(strcmp('fy',bootTuning{1}.CoefficientNames));
                                    reducedInputMask(3)=false;
                            end
                            %get current PD type from GLM weights:
                            dirs=atan2(bootCoef(:,yCol),bootCoef(:,xCol));
                            %handle wrap around problems:
                            centeredDirs=dirs-mean(dirs);
                            while(sum(centeredDirs<-pi))
                                centeredDirs(centeredDirs<-pi) = centeredDirs(centeredDirs<-pi)+2*pi;
                            end
                            while(sum(centeredDirs>pi))
                                centeredDirs(centeredDirs>pi) = centeredDirs(centeredDirs>pi)-2*pi;
                            end
                            data.(pdType{j}).allPDs(i)=mean(dirs);
                            data.(pdType{j}).allPDCIs(i,:)=prctile(centeredDirs,[2.5 97.5])+mean(dirs);
                            %modulation depth is formatted this way for legacy
                            %reasons. moddepth will be the change in firing
                            %rate between the pd and antiPD for movements with
                            %unit velocity.
                            modExp=sqrt(sum(bootCoef(:,[xCol yCol]).^2,2));
                            temp=exp(bootCoef(:,1)).*(exp(modExp)-exp(-modExp));
                            data.(pdType{j}).allModdepth(i)=mean(temp);
                            data.(pdType{j}).allModdepthCI(i,:)=prctile(temp,[2.5 97.5]);
                            %check tuning:
                            if ~isempty(find(reducedInputMask,1))
                                reducedModelSpec=[uList{i},'~',strjoin(fullInput(inputMask),'+')];
                                reducedModel=fitglme(dataTable,reducedModelSpec,'Distribution',noiseModel);
                                log_LR = 2*(fullModel.LogLikelihood-reducedModel.LogLikelihood);
                                df_partial = fullModel.NumCoefficients-reducedModel.NumCoefficients;
                                data.(pdType{j}).allIstuned(i) = (1-chi2cdf(log_LR,df_partial))<.05;
                            else
                                data.(pdType{j}).allIstuned(i)=mean(bootPValues(:,xCol))<.05 || mean(bootPValues(:,yCol))<.05;
                            end
                        end
                    end
                catch ME
                    warning('fitPds:errorFittingGLM',['failed to fit glm for unit', uList{i}])
                    disp('failed with error:')
                    disp(ME.identifier)
                    disp(ME.message)
                    disp(ME.stack)
                    disp('inserting NaN values and continuing')
                    for j=1:numel(pdType)
                        if(binned.pdConfig.(pdType{j}))
                            data.(pdType{j}).allPDs(i)=nan;
                            data.(pdType{j}).allPDCIs(i,:)=[nan nan];
                            data.(pdType{j}).allModdepth(i)=nan;
                            data.(pdType{j}).allModdepthCI(i,:)=[nan nan];
                            data.(pdType{j}).allIstuned(i)=nan;
                        end
                    end
                end
            end
            %now compose table for the full set of tuning data:
            fprintf(['  Inserting PD data into binned.pdTable(',num2str(toc),').'])
            pdTable=[];
            for i=1:numel(pdType)
                type=pdType{i};
                if(binned.pdConfig.(type))
                    vNames={[type,'Dir'],[type,'DirCI'],[type,'Moddepth'],[type,'ModdepthCI'],[type,'Istuned']};
                    pdTable=[pdTable,table(data.(type).allPDs,data.(type).allPDCIs,data.(type).allModdepth,data.(type).allModdepthCI,data.(type).allIstuned,'VariableNames',vNames)];
                end
            end
            set(binned,'pdData',pdTable)
            evntData=loggingListenerEventData('fitPds',[]);
            notify(binned,'ranPDFit',evntData)
            disp('done computing PDs')
        otherwise
            error('fitPds:badMethod',[binned.pdConfig.method, ' is not a valid method. currently only the glm method is implemented'])
    end
   
end