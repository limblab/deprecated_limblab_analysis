function out = nonparametricTuning(data,params,tuningPeriod,useArray,doPlots)
% bins firing rates for each movement direction and bootstraps to get CIs on mean

if nargin < 5
    doPlots = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get all of the parameters
movementTime = params.tuning.movementTime;
confLevel = params.tuning.confidenceLevel;
bootNumIters = params.tuning.numberBootIterations;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Nonparametric tuning, ' tuningPeriod ' movement, ' num2str(movementTime) ' second window...']);

%% Get data
sg = data.(useArray).sg;

[blockFR,blockTheta] = getFR(data,params,useArray,tuningPeriod);

% fr/theta will be cell arrays based on the number of blocks

for iBlock = 1:length(blockFR)
    fr = blockFR{iBlock};
    theta = blockTheta{iBlock};
    
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
            boot_fr{unit} = squeeze(bFR(:,unit,:));
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
    out(iBlock).boot_fr = boot_fr;
    out(iBlock).utheta = utheta;
    out(iBlock).sg = sg;
    out(iBlock).params = params;
end
