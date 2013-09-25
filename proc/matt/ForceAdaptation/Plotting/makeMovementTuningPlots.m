function makeMovementTuningPlots(data,tuning,saveFilePath)


if nargin < 3
    saveFilePath = [];
end

% Load some parameters
paramFile = fullfile(data.meta.out_directory, [data.meta.recording_date '_plotting_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

useArrays = data.meta.arrays;
epoch = data.meta.epoch;

fh = figure;
% get units from data, and for each, plot all of the waveforms
for iArray = 1:length(useArrays)
    currArray = useArrays{iArray};
    
    % get the spike guide showing electrodes and units
    sg = data.(currArray).unit_guide;
    
    % find how many different types of tuning periods there are to plot
    tuningMethods = fieldnames(tuning.(currArray));
    tuningPeriods = fieldnames(tuning.(currArray).(tuningMethods{1}));
    
    % these plots don't make sense for the whole file tuning
    tuningPeriods = setdiff(tuningPeriods,'file');
    
    for iPeriod = 1:length(tuningPeriods)
        tuneType = tuningPeriods{iPeriod};
        
        % I'd prefer to use the nonparametric cis
        if ismember('nonparametric',tuningMethods)
            
            useMethod = 'nonparametric';
            
            disp('Using nonparametric tuning for plots');
            utheta = tuning.(currArray).(useMethod).(tuneType).utheta;
            mFR = tuning.(currArray).(useMethod).(tuneType).mfr;
            sFR_l = tuning.(currArray).(useMethod).(tuneType).cil;
            sFR_h = tuning.(currArray).(useMethod).(tuneType).cih;
            
            % we went +pi to be the highest index, so if -pi is used...
            if abs(utheta(1)) > utheta(end)
                utheta = [utheta; abs(utheta(1))];
                utheta(1) = [];
                
                mFR = [mFR mFR(:,1)];
                sFR_l = [sFR_l sFR_l(:,1)];
                sFR_h = [sFR_h sFR_h(:,1)];
                
                mFR(:,1) = [];
                sFR_l(:,1) = [];
                sFR_h(:,1) = [];
                
            end
            
            
        else % in the absence of that...
            % doesn't matter which of these I pick as long as it exists
            if ismember('regression',tuningMethods)
                useMethod = 'regression';
            elseif ismember('vectorsum',tuningMethods)
                useMethod = 'vectorsum';
            else
                error('Could not find data')
            end
            
            for unit = 1:size(sg,1)
                
                
                
                fr = tuning.(currArray).(useMethod).(tuneType).fr(:,unit);
                theta = tuning.(currArray).(useMethod).(tuneType).theta;
                utheta = unique(theta);
                
                % find the mean firing rate
                mFR = zeros(size(fr,1),length(utheta));
                sFR_l = zeros(size(fr,1),length(utheta));
                sFR_h = zeros(size(fr,1),length(utheta));
                for it = 1:length(utheta)
                    relFR = fr(theta==utheta(it));
                    mFR(unit,it) = mean(relFR);
                    sFR_l(unit,it) = mFR(unit,it) - std(relFR);
                    sFR_h(unit,it) = 2*std(relFR);
                end
            end
        end
        
        for unit = 1:size(sg,1)
            
            set(0, 'CurrentFigure', fh);
            clf reset;
            
            hold all;
            % h = area(utheta.*(180/pi),[sFR_l(unit,:)' sFR_h(unit,:)']);
            % set(h(1),'FaceColor',[1 1 1]);
            % set(h(2),'FaceColor',[0.8 0.9 1],'EdgeColor',[1 1 1]);
            plot(utheta.*(180/pi),mFR(unit,:),'b','LineWidth',2);
            plot(utheta.*(180/pi),sFR_l(unit,:),'b--','LineWidth',2);
            plot(utheta.*(180/pi),sFR_h(unit,:),'b--','LineWidth',2);
            
            ylabel('Firing Rate (Hz)','FontSize',fontSize);
            xlabel('Movement Direction (deg)','FontSize',fontSize);
            axis('tight');
            
            V = axis;
            axis([min(utheta)*180/pi max(utheta)*180/pi 0 V(4)]);
            
            if ~isempty(saveFilePath)
                fn = fullfile(saveFilePath,[currArray '_elec' num2str(sg(unit,1)) 'unit' num2str(sg(unit,2)) '_' epoch '_tc_' tuneType '.png']);
                saveas(fh,fn,'png');
            else
                pause;
            end
            
        end
    end
end
