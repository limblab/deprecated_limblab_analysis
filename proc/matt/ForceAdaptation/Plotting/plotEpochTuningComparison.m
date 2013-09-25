function plotEpochTuningComparison(blt,adt,wot,saveFilePath)
% only need one data struct (baseline probably)
% make plot that overlays tuning in BL, AD, WO with confidence bounds

plotColors = {{'b',[0.8 0.9 1]},{'r',[1 0.9 0.8]},{'g',[0.9 1 0.8]}};

if nargin < 4
    saveFilePath = [];
end
% Load some parameters
paramFile = fullfile(blt.meta.out_directory, [blt.meta.recording_date '_plotting_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

useArrays = blt.meta.arrays;

fh = figure;
% get units from data, and for each, plot all of the waveforms
for iArray = 1:length(useArrays)
    currArray = useArrays{iArray};
    
    % find how many different types of tuning periods there are to plot
    tuningMethods = fieldnames(blt.(currArray));
    tuningPeriods = fieldnames(blt.(currArray).(tuningMethods{1}));
    
    % these plots don't make sense for the whole file tuning
    tuningPeriods = setdiff(tuningPeriods,'file');
    
    if ismember('nonparametric',tuningMethods)
        
        useMethod = 'nonparametric';
        for iPlot = 1:length(tuningPeriods)
            tuneType = tuningPeriods{iPlot};
            
            
            sg_bl = blt.(currArray).(useMethod).(tuneType).unit_guide;
            sg_ad = adt.(currArray).(useMethod).(tuneType).unit_guide;
            sg_wo = wot.(currArray).(useMethod).(tuneType).unit_guide;
            badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
            
            sg_master = setdiff(sg_bl,badUnits,'rows');
            
            for i = 1:size(sg_master,1)
                e = sg_master(i,1);
                u = sg_master(i,2);
                
                set(0, 'CurrentFigure', fh);
                clf reset;
                
                hold all;
                
                % prefer to use nonparametric tuning curves
                
                % baseline
                unit = find(sg_bl(:,1)==e & sg_bl(:,2)==u,1);
                utheta = blt.(currArray).(useMethod).(tuneType).utheta;
                mFR = blt.(currArray).(useMethod).(tuneType).mfr;
                sFR_l = blt.(currArray).(useMethod).(tuneType).cil;
                sFR_h = blt.(currArray).(useMethod).(tuneType).cih;
                
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
                
                useColors = plotColors{1};
                h = area(utheta.*(180/pi),[sFR_l(unit,:)' sFR_h(unit,:)']);
                set(h(1),'FaceColor',[1 1 1]);
                set(h(2),'FaceColor',useColors{2},'EdgeColor',[1 1 1]);
                plot(utheta.*(180/pi),mFR(unit,:),useColors{1},'LineWidth',2);
                
                % adaptation
                unit = find(sg_ad(:,1)==e & sg_ad(:,2)==u);
                utheta = adt.(currArray).(useMethod).(tuneType).utheta;
                mFR = adt.(currArray).(useMethod).(tuneType).mfr;
                sFR_l = adt.(currArray).(useMethod).(tuneType).cil;
                sFR_h = adt.(currArray).(useMethod).(tuneType).cih;
                
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
                
                useColors = plotColors{2};
                h = area(utheta.*(180/pi),[sFR_l(unit,:)' sFR_h(unit,:)']);
                set(h(1),'FaceColor',[1 1 1]);
                set(h(2),'FaceColor',useColors{2},'EdgeColor',[1 1 1]);
                plot(utheta.*(180/pi),mFR(unit,:),useColors{1},'LineWidth',2);
                
                % washout
                unit = find(sg_wo(:,1)==e & sg_wo(:,2)==u,1);
                utheta = wot.(currArray).(useMethod).(tuneType).utheta;
                mFR = wot.(currArray).(useMethod).(tuneType).mfr;
                sFR_l = wot.(currArray).(useMethod).(tuneType).cil;
                sFR_h = wot.(currArray).(useMethod).(tuneType).cih;
                
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
                
                useColors = plotColors{3};
                h = area(utheta.*(180/pi),[sFR_l(unit,:)' sFR_h(unit,:)']);
                set(h(1),'FaceColor',[1 1 1]);
                set(h(2),'FaceColor',useColors{2},'EdgeColor',[1 1 1]);
                plot(utheta.*(180/pi),mFR(unit,:),useColors{1},'LineWidth',2);
                
                ylabel('Firing Rate (Hz)','FontSize',fontSize);
                xlabel('Movement Direction (deg)','FontSize',fontSize);
                axis('tight');
                
                V = axis;
                axis([min(utheta)*180/pi max(utheta)*180/pi 0 V(4)]);
                
                if ~isempty(saveFilePath)
                    fn = fullfile(saveFilePath,[currArray '_elec' num2str(sg_master(i,1)) 'unit' num2str(sg_master(i,2)) '_all_tc_' tuneType '.png']);
                    saveas(fh,fn,'png');
                else
                    pause;
                end
            end
        end
    else
        % if nonparametric not done, do another
        error('Only nonparametric plotting implemented for now');
        
    end
end
