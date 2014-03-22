function out = nonparametricTuning(data,tuningPeriod,epoch,useArray,paramSetName,doPlots)
% bins firing rates for each movement direction and bootstraps to get CIs on mean

if nargin < 5
    doPlots = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load all of the parameters
paramFile = fullfile(data.meta.out_directory, paramSetName, [data.meta.recording_date '_' paramSetName '_tuning_parameters.dat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params = parseExpParams(paramFile);
movementTime = str2double(params.movement_time{1});
blocks = params.ad_exclude_fraction;
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
confLevel = str2double(params.confidence_level{1});
bootNumIters = str2double(params.number_iterations{1});
clear params;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Nonparametric tuning, ' tuningPeriod ' movement, ' num2str(movementTime) ' second window...']);

%% Get data
sg = data.(useArray).sg;

% see if file is being divided into blocks
if strcmpi(epoch,'AD')
    numBlocks = length(blocks)-1;
else
    numBlocks = 1;
end

for iBlock = 1:numBlocks
    
    [fr,theta] = getFR(data,useArray,tuningPeriod,paramSetName,iBlock);
    
    utheta = unique(theta);
    
    % bootstrap on the mean firing rate for each direction
    bFR = zeros(bootNumIters, size(fr,2));
    disp(['Running bootstrap with ' num2str(bootNumIters) ' iterations...'])
    for iter = 1:bootNumIters
        tempfr = zeros(size(fr));
        tempTheta = zeros(size(fr));
        for unit = 1:size(fr,2)
            randInds = randi([1 size(fr,1)],size(fr,1),1);
            tempfr(:,unit) = fr(randInds,unit);
            tempTheta(:,unit) = theta(randInds);
            
            % now group movements by direction and find a mean
            for ith = 1:length(utheta)
                bFR(iter,unit,ith) = mean(tempfr(tempTheta(:,unit)==utheta(ith),unit));
            end
        end
    end
    
    
    for unit = 1:size(fr,2)
        for ith = 1:length(utheta)
            useFR = squeeze(bFR(:,unit,ith));
            useFR(isnan(useFR)) = [];
            mFRs = sort(useFR,'ascend');
            
            mfr(unit,ith) = mean(useFR);
            cil(unit,ith) = mFRs(ceil(length(useFR) - confLevel*length(useFR)));
            cih(unit,ith) = mFRs(floor(confLevel*length(useFR)));
        end
    end
    
    if doPlots
        for unit = 1:size(fr,2)
            figure;
            hold all;
            h = area(utheta.*(180/pi),[cil(unit,:)' cih(unit,:)']);
            set(h(1),'FaceColor',[1 1 1]);
            set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
            plot(utheta.*(180/pi),mfr(unit,:),'b','LineWidth',2);
            axis('tight');
            xlabel('Movement Direction')
            ylabel('Firing Rate')
            pause;
            close all
        end
    end
    
    out(iBlock).mfr = mfr;
    out(iBlock).cil = cil;
    out(iBlock).cih = cih;
    out(iBlock).utheta = utheta;
    out(iBlock).unit_guide = sg;
    out(iBlock).params.boot_num_iter = bootNumIters;
    out(iBlock).params.conf_level = confLevel;
end
