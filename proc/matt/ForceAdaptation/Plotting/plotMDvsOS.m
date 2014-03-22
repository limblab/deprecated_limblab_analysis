function plotMDvsOS(bl,ad,wo,classes,tracking,sigMethod,saveFilePath)
% bl etc would be tuning.BL

classColors = {'k','b','r','r','g'};
epochs = {'BL','AD','WO'};

baseDir = bl.meta.out_directory;
useDate = bl.meta.recording_date;
paramFile = fullfile(baseDir, [ useDate '_analysis_parameters.dat']);
params = parseExpParams(paramFile);
fontSize = str2double(params.font_size{1});
clear params;

arrays = bl.meta.arrays;

% want to make plots that show changes in PD as traces
fh = figure;
for iArray = 1:length(arrays)
    currArray = arrays{iArray};
    
    tuneMethods = fieldnames(bl.(currArray));
    tuningPeriods = fieldnames(bl.(currArray).(tuneMethods{1}));
    
    useComp = tracking.(currArray){1}.chan;
    
    % cycle along tuning periods
    for iPeriod = 1:length(tuningPeriods)
        
        tune_idx = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).tuned_cells;
        tune_sg = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
        tuned_cells = tune_sg(tune_idx,:);
        
        % get unit guides and pd matrices
        sg_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
        sg_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
        sg_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
        
        mds_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).mds;
        mds_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).mds;
        mds_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).mds;
        
        bos_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).bos;
        bos_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).bos;
        bos_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).bos;
        
        % check to make sure the unit guides are okay
        badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
        sg_master = setdiff(sg_bl,badUnits,'rows');
        
        cellClasses = classes.(currArray).(sigMethod).(tuningPeriods{iPeriod}).classes;
        
        set(0, 'CurrentFigure', fh);
        clf reset;
        hold all;
        
        for unit = 1:size(sg_master,1)
            
            % if the cell meets the tuning criteria
            %   and also if the cell is tracked across epochs
            if ismember(sg_master(unit,:),tuned_cells,'rows')
                
                % don't include cell if it fails KS test
                relCompInd = useComp(:,1)==sg_master(unit,1)+.1*sg_master(unit,2);
                if ~any(diff(useComp(relCompInd,:)))
                    
                    useInd = sg_bl(:,1)==sg_master(unit,1) & sg_bl(:,2)==sg_master(unit,2);
                    mds(1,:) = mds_bl(useInd,:);
                    bos(1,:) = bos_bl(useInd,:);
                    useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
                    mds(2,:) = mds_ad(useInd,:);
                    bos(2,:) = bos_ad(useInd,:);
                    useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
                    mds(3,:) = mds_wo(useInd,:);
                    bos(3,:) = bos_wo(useInd,:);
                    
                    classInd = tune_sg(:,1)==sg_master(unit,1) & tune_sg(:,2)==sg_master(unit,2);
                    % color the traces based on the classification
                    useColor = classColors{cellClasses(classInd)};
                    
                    plot(bos(1:2,1)',mds(1:2,1)','Color',useColor,'LineWidth',1);
                    
                    plot(bos(1,1),mds(1,1),'+','Color',useColor,'LineWidth',3);
                    plot(bos(2,1),mds(2,1),'d','Color',useColor,'LineWidth',3);
                    
                    rx = (bos(1,3)-bos(1,2))/2;
                    ry = (mds(1,3)-mds(1,2))/2;
                    ellipse(bos(1,2)+rx,mds(1,2)+ry,rx,ry,useColor)
                    
                    rx = (bos(2,3)-bos(2,2))/2;
                    ry = (mds(2,3)-mds(2,2))/2;
                    ellipse(bos(2,2)+rx,mds(2,2)+ry,rx,ry,useColor)
                    
                end
            end
        end
        
        xlabel('Offset (Hz)','FontSize',fontSize);
        ylabel('Modulation Depth (Hz)','FontSize',fontSize);
        axis('tight');
        V = axis;
        axis([0 V(2) 0 V(4)]);
        
        if ~isempty(saveFilePath)
            fn = fullfile(saveFilePath,[arrays{iArray} '_elec' num2str(sg_master(unit,1)) '_unit' num2str(sg_master(unit,2)) '_' tuningPeriods{iPeriod} '_md_os_comparison.png']);
            saveas(fh,fn,'png');
        else
            pause; %pause for viewing
        end
    end
end
end

function ellipse(x,y,rx,ry,useColor)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang=0:0.01:2*pi; 
xp=rx*cos(ang);
yp=ry*sin(ang);
plot(x+xp,y+yp,'Color',useColor);


end
















% function plotPDvsMD(bl,ad,wo,saveFilePath)
% % bl etc would be tuning.BL
%
% epochs = {'BL','AD','WO'};
% sigMethod = 'regression';
%
% baseDir = bl.meta.out_directory;
% useDate = bl.meta.recording_date;
% paramFile = fullfile(baseDir, [ useDate '_plotting_parameters.dat']);
% params = parseExpParams(paramFile);
% fontSize = str2double(params.font_size{1});
% clear params;
%
% arrays = bl.meta.arrays;
%
% % want to make plots that show changes in PD as traces
% fh = figure;
% for iArray = 1:length(arrays)
%     currArray = arrays{iArray};
%
%     tuneMethods = fieldnames(bl.(currArray));
%     tuningPeriods = fieldnames(bl.(currArray).(tuneMethods{1}));
%
%     % cycle along tuning periods
%     for iPeriod = 1:length(tuningPeriods)
%
%         % get unit guides and pd matrices
%         sg_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
%         sg_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
%         sg_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).sg;
%
%         pds_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).pds;
%         pds_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).pds;
%         pds_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).pds;
%
%         mds_bl = bl.(currArray).(sigMethod).(tuningPeriods{iPeriod}).mds;
%         mds_ad = ad.(currArray).(sigMethod).(tuningPeriods{iPeriod}).mds;
%         mds_wo = wo.(currArray).(sigMethod).(tuningPeriods{iPeriod}).mds;
%
%         % check to make sure the unit guides are okay
%         badUnits = checkUnitGuides(sg_bl,sg_ad,sg_wo);
%         sg_master = setdiff(sg_bl,badUnits,'rows');
%
%         for unit = 1:size(sg_master,1)
%             set(0, 'CurrentFigure', fh);
%             clf reset;
%             hold all;
%
%             useInd = sg_bl(:,1)==sg_master(unit,1) & sg_bl(:,2)==sg_master(unit,2);
%             pds(1,:) = pds_bl(useInd,:);
%             mds(1,:) = mds_bl(useInd,:);
%             useInd = sg_ad(:,1)==sg_master(unit,1) & sg_ad(:,2)==sg_master(unit,2);
%             pds(2,:) = pds_ad(useInd,:);
%             mds(2,:) = mds_ad(useInd,:);
%             useInd = sg_wo(:,1)==sg_master(unit,1) & sg_wo(:,2)==sg_master(unit,2);
%             pds(3,:) = pds_wo(useInd,:);
%             mds(3,:) = mds_wo(useInd,:);
%
%             plot(mds(1,1),pds(1,1).*180/pi,'kd','LineWidth',3);
%             plot(mds(2,1),pds(2,1).*180/pi,'bd','LineWidth',3);
%             plot(mds(3,1),pds(3,1).*180/pi,'rd','LineWidth',3);
%
%             xlabel('Modulation Depth (Hz)','FontSize',fontSize);
%             ylabel('Preferred Direction (Deg)','FontSize',fontSize);
%             axis('tight');
%             V = axis;
%             axis([0 30 -180 180]);
%
%             if ~isempty(saveFilePath)
%                 fn = fullfile(saveFilePath,[arrays{iArray} '_elec' num2str(sg_master(unit,1)) '_unit' num2str(sg_master(unit,2)) '_' tuningPeriods{iPeriod} '_md_pd_comparison.png']);
%                 saveas(fh,fn,'png');
%             else
%                 pause; %pause for viewing
%             end
%         end
%     end
% end

