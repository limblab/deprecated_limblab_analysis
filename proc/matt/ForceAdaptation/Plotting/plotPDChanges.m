function plotPDChanges(bl,ad,wo,classes,tracking,sigMethod,saveFilePath)
% bl etc would be tuning.BL

classColors = {'k','b','r','r','g'};
epochs = {'BL','AD','WO'};

baseDir = bl.meta.out_directory;
useDate = bl.meta.recording_date;
paramFile = fullfile(baseDir, [ useDate '_plotting_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

arrays = bl.meta.arrays;

% want to make plots that show changes in PD as traces
fh = figure;
for iArray = 1:length(arrays)
    currArray = arrays{iArray};

    tuneMethods = fieldnames(classes.(currArray));
    tuningPeriods = fieldnames(classes.(currArray).(tuneMethods{1}));
    
    useComp = tracking.(currArray){1}.chan;
    
    % cycle along tuning periods
    for iPeriod = 1:length(tuningPeriods)
        
        tune_idx = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
        tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
        tuned_cells = tune_sg(tune_idx,:);
        
        % get unit guides and pd matrices
        sg_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
        sg_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
        sg_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).unit_guide;
        
        pds_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).pds;
        pds_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).pds;
        pds_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).pds;
        
        % check to make sure the unit guides are okay
        badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
        sg_master = setdiff(sg_bl,badUnits,'rows');
        
        set(0, 'CurrentFigure', fh);
        clf reset;
        hold all;
        
        cellClasses = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).classes;
        
        allPDs = [];
        allDiffPDs = [];
        for unit = 1:size(sg_master,1)
            % if the cell meets the tuning criteria
            %   and also if the cell is tracked across epochs
            if ismember(sg_master(unit,:),tuned_cells,'rows')
                
                % don't include cell if it fails KS test
                relCompInd = useComp(:,1)==sg_master(unit,1)+.1*sg_master(unit,2);
                if ~any(diff(useComp(relCompInd,:)))
                    
                    useInd = sg_bl(:,1)==sg_master(unit,1) & sg_bl(:,2)==sg_master(unit,2);
                    pds(1) = pds_bl(useInd,1);
                    useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
                    pds(2) = pds_ad(useInd,1);
                    useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
                    pds(3) = pds_wo(useInd,1);
                    
                    diffPDs = [pds(1)-pds(1), pds(2)-pds(1), pds(3)-pds(1)];
                    
                    classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
                    
                    % color the traces based on the classification
                    useColor = classColors{cellClasses(classInd)};
                    
                    plot([0 1 2],diffPDs.*180/pi,useColor,'LineWidth',2);
                    plot([0 1 2],diffPDs.*180/pi,[useColor 'd'],'LineWidth',3);
                    
                    allPDs = [allPDs; pds];
                    % BL->AD, AD->WO, BL->WO
                    allDiffPDs = [allDiffPDs; pds(2)-pds(1), pds(3)-pds(2), pds(3)-pds(1)];
                end
            end
        end
        xlabel('Epoch','FontSize',fontSize);
        ylabel('Change in PD (deg)','FontSize',fontSize);
        axis('tight');
        V = axis;
        axis([V(1) V(2) -60 60]);
        
        if ~isempty(saveFilePath)
            fn = fullfile(saveFilePath,[arrays{iArray} '_' tuningPeriods{iPeriod} '_pd_changes.png']);
            saveas(fh,fn,'png');
        else
            pause; %pause for viewing
        end
        
        if ~isempty(allPDs)
            % now make plot showing histograms of all PDs in each epoch
            for iEpoch = 1:length(epochs)
                set(0, 'CurrentFigure', fh);
                clf reset;
                hold all;
                
                hist(allPDs(:,iEpoch).*180/pi)
                xlabel('PD(deg)','FontSize',fontSize);
                ylabel('Count','FontSize',fontSize);
                axis('tight');
                V = axis;
                axis([-180 180 0 V(4)]);
                
                if ~isempty(saveFilePath)
                    fn = fullfile(saveFilePath,[arrays{iArray} '_' tuningPeriods{iPeriod} '_' epochs{iEpoch} '_pd_histogram.png']);
                    saveas(fh,fn,'png');
                else
                    pause; %pause for viewing
                end
            end
            
            % make plots showing histograms of change in pd
            set(0, 'CurrentFigure', fh);
            clf reset;
            hold all;
            
            % first do BL->AD
            hist(allDiffPDs(:,1).*180/pi);
            xlabel('Change in PD(deg)','FontSize',fontSize);
            ylabel('Count','FontSize',fontSize);
            axis('tight');
            V = axis;
            axis([-60 60 0 V(4)]);
            
            if ~isempty(saveFilePath)
                fn = fullfile(saveFilePath,[arrays{iArray} '_' tuningPeriods{iPeriod} '_change_pd_hist_BL-AD.png']);
                saveas(fh,fn,'png');
            else
                pause; %pause for viewing
            end
            
            set(0, 'CurrentFigure', fh);
            clf reset;
            hold all;
            
            % Now do AD->WO
            hist(allDiffPDs(:,2).*180/pi);
            xlabel('Change in PD(deg)','FontSize',fontSize);
            ylabel('Count','FontSize',fontSize);
            axis('tight');
            V = axis;
            axis([-60 60 0 V(4)]);
            
            if ~isempty(saveFilePath)
                fn = fullfile(saveFilePath,[arrays{iArray} '_' tuningPeriods{iPeriod} '_change_pd_hist_AD-WO.png']);
                saveas(fh,fn,'png');
            else
                pause; %pause for viewing
            end
            
            set(0, 'CurrentFigure', fh);
            clf reset;
            hold all;
            
            % Now do BL->WO
            hist(allDiffPDs(:,3).*180/pi);
            xlabel('Change in PD(deg)','FontSize',fontSize);
            ylabel('Count','FontSize',fontSize);
            axis('tight');
            V = axis;
            axis([-60 60 0 V(4)]);
            
            if ~isempty(saveFilePath)
                fn = fullfile(saveFilePath,[arrays{iArray} '_' tuningPeriods{iPeriod} '_change_pd_hist_BL-WO.png']);
                saveas(fh,fn,'png');
            else
                pause; %pause for viewing
            end
        end
    end
end
