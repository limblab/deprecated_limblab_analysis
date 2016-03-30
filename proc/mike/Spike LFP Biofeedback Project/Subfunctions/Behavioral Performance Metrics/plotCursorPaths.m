function [] = plotCursorPaths(HC_I, BC_I, ControlCh, flag_SpHG, flag_LGHG, Trials, meanTTT, steTTT, segment)

% Input
% HC_I - index for hand control files
% BC_I - index for brain control files
% ControlCh - channels of interest
% flag_SpHG - look at Spike-High Gamma correlations
% flag_LGHG - look at low-high gamma correlations
% Trials - parsed data from CreateONF_TrialFormat script

% Output
% Plots of cursor paths

HC_timeIndex_MO = [1750:2250]; % Movement onset
HC_timeIndex_Reward = [1400:1900]; % Before reward
BC_timeIndex_MO = [35:45];
BC_timeIndex_Reward = [29:38];

k = 1;
if segment == 0
    Rows = ceil((nnz(~cellfun(@isempty,Trials(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)])))+1)/4);
else
    Rows = ceil((nnz(~cellfun(@isempty,Trials(ControlCh,BC_I(1):BC_I(end))))+1)/4);
end
Rows=1;
figure(3)
CursorPathsByTrial = struct;
clear MeanCursorPath CursorPathXY

for j = [BC_I(1:end)] % HC_I(1):HC_I(end)
    CursorPaths = [];
    if isfield(Trials{ControlCh,j},'Path_MO')
        %% This section is just for drawing the targets (still has some bugs)
        
        figure(3)
        subplot(Rows,4,k)
        
        TC = unique(Trials{ControlCh,j}.Targets.corners(:,2:5),'rows');
        % Need this to remove junk targets that come in the
        % Targets.Corners of the bdf
        if sum(sum(abs(TC),2)) > 1000
            TC = TC(sum(abs(TC),2) < 100,:)
        end
        
        if sum(sum(abs(TC) < 0.01,2))
            TC = TC(sum(abs(TC) < 0.01,2) == 0,:)
        end
        
        if size(TC,1) >3 && j >= BC_I(1) && j<= BC_I(end) % if this is 4 target ONF control
            Center = (TC(1,1)-TC(1,3))/2;
        else % if this is anything else
            Center = min(min(abs(TC)));
        end
        
        % Need this kludge to remove other junk targets that appear in some
        % of the brain control files
        
        
        h = fill([Center,Center,-1*Center,-1*Center],[Center,-1*Center,-1*Center,Center],'r');
        % TC = target coordinates
        hold on
        for i = 1:size(TC,1)
            h = fill([TC(i,1),TC(i,1),TC(i,3),TC(i,3)],[TC(i,2),TC(i,4),TC(i,4),TC(i,2)],'r');
            
%             set(h,'FaceAlpha',.3)
            xlim([-15 15])
            ylim([-15 15])
        end
        if j ==1
            xlabel('X cursor position')
            ylabel('Y cursor position')
        end
        
        
        %%  Now let's start collecting the trajectories to plot
        figure(3)
        subplot(Rows,4,k)
        title(['Mean TTT = ',sprintf('%2f',double(meanTTT(j))),'+/-',sprintf('%2f',double(steTTT(j)))])
        
        %         figure(2)
        %         subplot(Rows,4,k)
        %         title(['Corr=',sprintf('%2f',double(AvgCorr.MovementOnset(ControlCh,j)))])
        for i = 1:length(Trials{ControlCh,j}.Path_Reward)
            if ~isempty(Trials{ControlCh,j}.Path_Reward{i})
                if  j <= HC_I(end) && j >= HC_I(1)
                    
                    % This line dynamically names the struct field based on
                    % the target number and appends the trajectory for that
                    % trial to that struct field
                    if ~isfield(CursorPathsByTrial,sprintf('%s%d','HC_Reward_Targ',Trials{ControlCh,j}.TargetID(i)))
                        CursorPathsByTrial.(sprintf('%s%d','HC_Reward_Targ',Trials{ControlCh,j}.TargetID(i))) = cell([length(HC_I) 1]);
                    end
                    % Concatenate XY cursor paths by column
                    CursorPathsByTrial.(sprintf('%s%d','HC_Reward_Targ',Trials{ControlCh,j}.TargetID(i))){j} = ...
                        [CursorPathsByTrial.(sprintf('%s%d','HC_Reward_Targ',Trials{ControlCh,j}.TargetID(i))){j} ...
                        Trials{ControlCh,j}.Path_Reward{i}(HC_timeIndex_Reward,2:3)];
                    
                    
                    CursorPathsByTrial.HC_Reward{j,i} = Trials{ControlCh,j}.Path_Reward{i}(HC_timeIndex_Reward,2:3);
                    CursorPathsByTrial.HC_MO{j,i} = Trials{ControlCh,j}.Path_MO{i}(HC_timeIndex_MO,2:3);
                    CursorPathsByTrial.TrialLength{j}(i,:) = [i length(Trials{ControlCh,j}.Path_Whole{i}(:,2))];
                    
                    CursorPaths = [CursorPaths; Trials{ControlCh,j}.Path_Whole{i}(:,2),Trials{ControlCh,j}.Path_Whole{i}(:,3)];
                    
                else %if length(Trials{ControlCh,j}.Path_MO{i}) < 50
                    
                    if ~isfield(CursorPathsByTrial,sprintf('%s%d','BC_Reward_Targ',Trials{ControlCh,j}.TargetID(i)))
                        CursorPathsByTrial.(sprintf('%s%d','BC_Reward_Targ',Trials{ControlCh,j}.TargetID(i))) = cell([BC_I(end) 1]);
                    end
                    CursorPathsByTrial.(sprintf('%s%d','BC_Reward_Targ',Trials{ControlCh,j}.TargetID(i))){j} = ...
                        [CursorPathsByTrial.(sprintf('%s%d','BC_Reward_Targ',Trials{ControlCh,j}.TargetID(i))){j} ...
                        Trials{ControlCh,j}.Path_Reward{i}(BC_timeIndex_Reward,2:3)];
                    
                    CursorPathsByTrial.BC_Reward{j,i} = Trials{ControlCh,j}.Path_Reward{i}(BC_timeIndex_Reward,2:3);
                    CursorPathsByTrial.BC_MO{j,i} = Trials{ControlCh,j}.Path_MO{i}(BC_timeIndex_MO,2:3);
                    CursorPathsByTrial.BC_TrialLength{j}(i,:) = [i length(Trials{ControlCh,j}.Path_Whole{i}(:,2))];
                    
                end
            end
        end
        
        % Need an extra loop to plot HC trajectories in order to correct
        % for the systematic offset in the paths.
        % The term "+ abs(mean(CursorPaths(:,2))" is meant to correct for
        % the y offset present in the hand control data cursor paths.
        
        %% Now plot the trajectories
        if j <= HC_I(end) && j >= HC_I(1) % Plot HC traj for each time period (MO - Movement Onset and Reward)
            for i = 1:sum(cellfun(@isempty,CursorPathsByTrial.HC_Reward(j,:))==0)
                if ~isempty(CursorPathsByTrial.HC_Reward{j,i})
                    figure(3)
                    subplot(Rows,4,k)
                    %                         plot(CursorPathsByTrial.HC_Reward{j,i}(:,1), ...
                    %                              CursorPathsByTrial.HC_Reward{j,i}(:,2) + abs(mean(CursorPaths(:,2))))
                end
            end
            MeanCursorPath.Targ64(:,1) = mean(CursorPathsByTrial.HC_Reward_Targ64{j}(:,1:2:end),2);
            MeanCursorPath.Targ64(:,2) = mean(CursorPathsByTrial.HC_Reward_Targ64{j}(:,2:2:end),2);
            MeanCursorPath.Targ64_STE(:,1) = std(CursorPathsByTrial.HC_Reward_Targ64{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ64{j}(:,1:2:end),2))
            MeanCursorPath.Targ64_STE(:,2) = std(CursorPathsByTrial.HC_Reward_Targ64{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ64{j}(:,2:2:end),2))
            
            MeanCursorPath.Targ65(:,1) = mean(CursorPathsByTrial.HC_Reward_Targ65{j}(:,1:2:end),2);
            MeanCursorPath.Targ65(:,2) = mean(CursorPathsByTrial.HC_Reward_Targ65{j}(:,2:2:end),2);
            MeanCursorPath.Targ65_STE(:,1) = std(CursorPathsByTrial.HC_Reward_Targ65{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ65{j}(:,1:2:end),2))
            MeanCursorPath.Targ65_STE(:,2) = std(CursorPathsByTrial.HC_Reward_Targ65{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ65{j}(:,2:2:end),2))
            
            MeanCursorPath.Targ66(:,1) = mean(CursorPathsByTrial.HC_Reward_Targ66{j}(:,1:2:end),2);
            MeanCursorPath.Targ66(:,2) = mean(CursorPathsByTrial.HC_Reward_Targ66{j}(:,2:2:end),2);
            MeanCursorPath.Targ66_STE(:,1) = std(CursorPathsByTrial.HC_Reward_Targ66{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ66{j}(:,1:2:end),2))
            MeanCursorPath.Targ66_STE(:,2) = std(CursorPathsByTrial.HC_Reward_Targ66{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ66{j}(:,2:2:end),2))
            
            MeanCursorPath.Targ67(:,1) = mean(CursorPathsByTrial.HC_Reward_Targ67{j}(:,1:2:end),2);
            MeanCursorPath.Targ67(:,2) = mean(CursorPathsByTrial.HC_Reward_Targ67{j}(:,2:2:end),2);
            MeanCursorPath.Targ67_STE(:,1) = std(CursorPathsByTrial.HC_Reward_Targ67{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ67{j}(:,1:2:end),2))
            MeanCursorPath.Targ67_STE(:,2) = std(CursorPathsByTrial.HC_Reward_Targ67{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.HC_Reward_Targ67{j}(:,2:2:end),2))
            
            Yoffset = abs(mean(CursorPaths(:,2)));
            errorbarxy(MeanCursorPath.Targ64(:,1),MeanCursorPath.Targ64(:,2)+ Yoffset,...
                MeanCursorPath.Targ64_STE(:,1), MeanCursorPath.Targ64_STE(:,2),...%lower error bounds
                [],[],'k-','b') % Colors
            hold on
            errorbarxy(MeanCursorPath.Targ65(:,1),MeanCursorPath.Targ65(:,2)+ Yoffset,...
                MeanCursorPath.Targ65_STE(:,1), MeanCursorPath.Targ65_STE(:,2),...
                [],[],'k-','b')
            hold on
            errorbarxy(MeanCursorPath.Targ66(:,1),MeanCursorPath.Targ66(:,2)+ Yoffset,...
                MeanCursorPath.Targ66_STE(:,1), MeanCursorPath.Targ66_STE(:,2),...
                [],[],'k-','b')
            hold on
            errorbarxy(MeanCursorPath.Targ67(:,1),MeanCursorPath.Targ67(:,2)+ Yoffset,...
                MeanCursorPath.Targ67_STE(:,1), MeanCursorPath.Targ67_STE(:,2),...
                [],[],'k-','b')
            
            %                 plot(MeanCursorPath.Targ64(:,1),MeanCursorPath.Targ64(:,2)+ abs(mean(CursorPaths(:,2))))
            %                 plot(MeanCursorPath.Targ65(:,1),MeanCursorPath.Targ65(:,2)+ abs(mean(CursorPaths(:,2))),'LineWidth',3.0,'Color','b')
            %                 plot(MeanCursorPath.Targ66(:,1),MeanCursorPath.Targ66(:,2)+ abs(mean(CursorPaths(:,2))),'LineWidth',3.0,'Color','b')
            %                 plot(MeanCursorPath.Targ67(:,1),MeanCursorPath.Targ67(:,2)+ abs(mean(CursorPaths(:,2))),'LineWidth',3.0,'Color','b')
            %
            clear MeanCursorPath CursorPathXY
            %             for i = 1:sum(cellfun(@isempty,CursorPathsByTrial.HC_MO(j,:))==0) % Iterate over # of trials
            %                 if ~isempty(CursorPathsByTrial.HC_MO{j,i})
            %                         figure(2)
            %                         subplot(Rows,4,k)
            % %                         plot(CursorPathsByTrial.HC_MO{j,i}(:,1), ...
            % %                              CursorPathsByTrial.HC_MO{j,i}(:,2) + abs(mean(CursorPaths(:,2))))
            %                 end
            %             end
            
        else % Plot BC trjactories (one subplot at a time)
            if isfield(CursorPathsByTrial,'BC_Reward_Targ64') && isempty(CursorPathsByTrial.BC_Reward_Targ64{j}) == 0
                % Since BC_Reward_Targ** is arranged by [xpos ypos] the
                % number of trials = 1/2 the number of columns in each cell                
                for i = 1: size(CursorPathsByTrial.BC_Reward_Targ64{j},2)/2
                    
                    figure(3)
                    subplot(Rows,4,k)
                    %                     plot(CursorPathsByTrial.BC_Reward{j,i}(:,1),CursorPathsByTrial.BC_Reward{j,i}(:,2))
                    if size(CursorPathsByTrial.BC_Reward_Targ64{j},2) > 2
                        MeanCursorPath.Targ64(:,1) = mean(CursorPathsByTrial.BC_Reward_Targ64{j}(:,1:2:end),2);
                        MeanCursorPath.Targ64(:,2) = mean(CursorPathsByTrial.BC_Reward_Targ64{j}(:,2:2:end),2);
                        MeanCursorPath.Targ64_STE(:,1) = std(CursorPathsByTrial.BC_Reward_Targ64{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ64{j}(:,1:2:end),2));
                        MeanCursorPath.Targ64_STE(:,2) = std(CursorPathsByTrial.BC_Reward_Targ64{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ64{j}(:,2:2:end),2));
                    else
                        MeanCursorPath.Targ64(:,1) = CursorPathsByTrial.BC_Reward_Targ64{j}(:,1);
                        MeanCursorPath.Targ64(:,2) = CursorPathsByTrial.BC_Reward_Targ64{j}(:,2);
                        MeanCursorPath.Targ64_STE(:,1) = zeros(size(CursorPathsByTrial.BC_Reward_Targ64{j},1),1);
                        MeanCursorPath.Targ64_STE(:,2) = zeros(size(CursorPathsByTrial.BC_Reward_Targ64{j},1),1);
                    end
                    plot(CursorPathsByTrial.BC_Reward_Targ64{j}(:,(i-1)*2+1),CursorPathsByTrial.BC_Reward_Targ64{j}(:,i*2),'Color','g')
                    hold on
                end
            end
            if isfield(CursorPathsByTrial,'BC_Reward_Targ65') && isempty(CursorPathsByTrial.BC_Reward_Targ65{j}) == 0
                for i = 1:size(CursorPathsByTrial.BC_Reward_Targ65{j},2)/2
                    if size(CursorPathsByTrial.BC_Reward_Targ65{j},2) > 2
                        MeanCursorPath.Targ65(:,1) = mean(CursorPathsByTrial.BC_Reward_Targ65{j}(:,1:2:end),2);
                        MeanCursorPath.Targ65(:,2) = mean(CursorPathsByTrial.BC_Reward_Targ65{j}(:,2:2:end),2);
                        MeanCursorPath.Targ65_STE(:,1) = std(CursorPathsByTrial.BC_Reward_Targ65{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ65{j}(:,1:2:end),2))
                        MeanCursorPath.Targ65_STE(:,2) = std(CursorPathsByTrial.BC_Reward_Targ65{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ65{j}(:,2:2:end),2))
                    else
                        MeanCursorPath.Targ65(:,1) = CursorPathsByTrial.BC_Reward_Targ65{j}(:,1);
                        MeanCursorPath.Targ65(:,2) = CursorPathsByTrial.BC_Reward_Targ65{j}(:,2);
                        MeanCursorPath.Targ65_STE(:,1) = zeros(size(CursorPathsByTrial.BC_Reward_Targ65{j},1),1);
                        MeanCursorPath.Targ65_STE(:,2) = zeros(size(CursorPathsByTrial.BC_Reward_Targ65{j},1),1);
                    end
                    plot(CursorPathsByTrial.BC_Reward_Targ65{j}(:,(i-1)*2+1),CursorPathsByTrial.BC_Reward_Targ65{j}(:,i*2),'Color','r')
                    hold on
                end
            end
            
            if isfield(CursorPathsByTrial,'BC_Reward_Targ66') && isempty(CursorPathsByTrial.BC_Reward_Targ66{j}) == 0
                for i = 1:size(CursorPathsByTrial.BC_Reward_Targ66{j},2)/2
                    if size(CursorPathsByTrial.BC_Reward_Targ66{j},2) > 2
                        MeanCursorPath.Targ66(:,1) = mean(CursorPathsByTrial.BC_Reward_Targ66{j}(:,1:2:end),2);
                        MeanCursorPath.Targ66(:,2) = mean(CursorPathsByTrial.BC_Reward_Targ66{j}(:,2:2:end),2);
                        MeanCursorPath.Targ66_STE(:,1) = std(CursorPathsByTrial.BC_Reward_Targ66{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ66{j}(:,1:2:end),2))
                        MeanCursorPath.Targ66_STE(:,2) = std(CursorPathsByTrial.BC_Reward_Targ66{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ66{j}(:,2:2:end),2))
                    else
                        MeanCursorPath.Targ66(:,1) = CursorPathsByTrial.BC_Reward_Targ66{j}(:,1);
                        MeanCursorPath.Targ66(:,2) = CursorPathsByTrial.BC_Reward_Targ66{j}(:,2);
                        MeanCursorPath.Targ66_STE(:,1) = zeros(size(CursorPathsByTrial.BC_Reward_Targ66{j},1),1);
                        MeanCursorPath.Targ66_STE(:,2) = zeros(size(CursorPathsByTrial.BC_Reward_Targ66{j},1),1);
                    end
                    plot(CursorPathsByTrial.BC_Reward_Targ66{j}(:,(i-1)*2+1),CursorPathsByTrial.BC_Reward_Targ66{j}(:,i*2),'Color','y')
                    hold on
                end
            end
            
            
            if isfield(CursorPathsByTrial,'BC_Reward_Targ67') && isempty(CursorPathsByTrial.BC_Reward_Targ67{j}) == 0
                for i = 1:size(CursorPathsByTrial.BC_Reward_Targ67{j},2)/2
                    if size(CursorPathsByTrial.BC_Reward_Targ67{j},2) > 2                        
                        MeanCursorPath.Targ67(:,1) = mean(CursorPathsByTrial.BC_Reward_Targ67{j}(:,1:2:end),2);
                        MeanCursorPath.Targ67(:,2) = mean(CursorPathsByTrial.BC_Reward_Targ67{j}(:,2:2:end),2);
                        MeanCursorPath.Targ67_STE(:,1) = std(CursorPathsByTrial.BC_Reward_Targ67{j}(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ67{j}(:,1:2:end),2))
                        MeanCursorPath.Targ67_STE(:,2) = std(CursorPathsByTrial.BC_Reward_Targ67{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ67{j}(:,2:2:end),2))
                    else
                        MeanCursorPath.Targ67(:,1) = CursorPathsByTrial.BC_Reward_Targ67{j}(:,1);
                        MeanCursorPath.Targ67(:,2) = CursorPathsByTrial.BC_Reward_Targ67{j}(:,2);
                        MeanCursorPath.Targ67_STE(:,1) = zeros(size(CursorPathsByTrial.BC_Reward_Targ67{j},1),1);
                        MeanCursorPath.Targ67_STE(:,2) = zeros(size(CursorPathsByTrial.BC_Reward_Targ67{j},1),1);
                    end
                    plot(CursorPathsByTrial.BC_Reward_Targ67{j}(:,(i-1)*2+1),CursorPathsByTrial.BC_Reward_Targ67{j}(:,i*2),'Color','m')
                    hold on
                end
            end                        
            
            if exist('H','var')
                
                sprecontmp = Trials{ControlCh,j}.RangeSp * abs(cos(0:.1:2*pi));
                gam3recontmp = Trials{ControlCh,j}.RangePB_G3 * abs(cos(0:.1:2*pi));
                gam2recontmp = Trials{ControlCh,j}.RangePB_G2 * abs(cos(0:.1:2*pi));
                gam0recontmp = Trials{ControlCh,j}.RangePB_G0 * abs(cos(0:.1:2*pi));
                
                if size(H,1) == 2
                    if H(1,1) ~= 0
                        XYrecon(:,1) = gam0recontmp(1:end-1)*H(1,1);
                        
                        XYrecon(:,2) = gam2recontmp(2:end)*H(2,2);
                    else
                        XYrecon(:,1) = gam0recontmp(1:end-1)*H(1,2);
                        
                        XYrecon(:,2) = gam2recontmp(2:end)*H(2,1);
                    end
                else
                    if H(1,1) ~= 0
                        XYrecon(:,1) = sprecontmp(5:end-5)*H(5,1)+ sprecontmp(4:end-6)*H(4,1)+ sprecontmp(3:end-7)*H(3,1)...
                            +sprecontmp(2:end-8)*H(2,1)+sprecontmp(1:end-9)*H(1,1);
                        
                        XYrecon(:,2) = (gam3recontmp(10:end)*H(10,2)+gam3recontmp(9:end-1)*H(9,2)+...
                            gam3recontmp(8:end-2)*H(8,2)+gam3recontmp(7:end-3)*H(7,2)+gam3recontmp(6:end-4)*H(6,2));
                    else
                        XYrecon(:,2) = sprecontmp(5:end-5)*H(5,2)+ sprecontmp(4:end-6)*H(4,2)+ sprecontmp(3:end-7)*H(3,2)...
                            +sprecontmp(2:end-8)*H(2,2)+sprecontmp(1:end-9)*H(1,2);
                        
                        XYrecon(:,1) = (gam3recontmp(10:end)*H(10,1)+gam3recontmp(9:end-1)*H(9,1)+...
                            gam3recontmp(8:end-2)*H(8,1)+gam3recontmp(7:end-3)*H(7,1)+gam3recontmp(6:end-4)*H(6,1));
                    end
                end
                % Integrate from velocity to position
                XYpos(:,1) = cumsum(XYrecon(:,1)*.05);
                XYpos(:,2) = cumsum(XYrecon(:,2)*.05);
                plot(XYpos(:,1),XYpos(:,2),'LineWidth',3.0,'Color','m')
                
                hold on
            end
            
            ah = findobj(gca,'TickDirMode','auto')
            set(ah,'Box','off')
            set(ah,'TickLength',[0,0])
            hold on
            if isfield(MeanCursorPath,'Targ64')
                errorbarxy(MeanCursorPath.Targ64(:,1),MeanCursorPath.Targ64(:,2),...
                    MeanCursorPath.Targ64_STE(:,1), MeanCursorPath.Targ64_STE(:,2),...%lower error bounds
                    [],[],'k-','k') % Colors
                hold on
            end
            if isfield(MeanCursorPath,'Targ65')
                errorbarxy(MeanCursorPath.Targ65(:,1),MeanCursorPath.Targ65(:,2),...
                    MeanCursorPath.Targ65_STE(:,1), MeanCursorPath.Targ65_STE(:,2),...
                    [],[],'k-','k')
                hold on
            end
            if isfield(MeanCursorPath,'Targ66')
                errorbarxy(MeanCursorPath.Targ66(:,1),MeanCursorPath.Targ66(:,2),...
                    MeanCursorPath.Targ66_STE(:,1), MeanCursorPath.Targ66_STE(:,2),...%lower error bounds
                    [],[],'k-','k') % Colors
                hold on
            end
            if isfield(MeanCursorPath,'Targ67')
                errorbarxy(MeanCursorPath.Targ67(:,1),MeanCursorPath.Targ67(:,2),...
                    MeanCursorPath.Targ67_STE(:,1), MeanCursorPath.Targ67_STE(:,2),...
                    [],[],'k-','k')
                hold on
            end
            %% Make last subplot with mean trajectories over all files
            if j == BC_I(end)
                %% Draw targets for last subplot
                figure(3)
                subplot(Rows,4,k+1)
                
                h = fill([Center,Center,-1*Center,-1*Center],[Center,-1*Center,-1*Center,Center],'r');
                % TC = target coordinates
                hold on
                for i = 1:size(TC,1)
                    h = fill([TC(i,1),TC(i,1),TC(i,3),TC(i,3)],[TC(i,2),TC(i,4),TC(i,4),TC(i,2)],'r');
                    
%                     set(h,'FaceAlpha',.3)
                    xlim([-15 15])
                    ylim([-15 15])
                end
                if j ==1
                    xlabel('X cursor position')
                    ylabel('Y cursor position')
                end
                
                title('Mean Cursor Tracjectory over all trials')
                
                BC_Reward_Targ64_MAT = cell2mat(CursorPathsByTrial.BC_Reward_Targ64');
                MeanCursorPath.Targ64(:,1) = mean(BC_Reward_Targ64_MAT(:,1:2:end),2);
                MeanCursorPath.Targ64(:,2) = mean(BC_Reward_Targ64_MAT(:,2:2:end),2);
                MeanCursorPath.Targ64_STE(:,1) = std(BC_Reward_Targ64_MAT(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ64{j}(:,1:2:end),2))
                MeanCursorPath.Targ64_STE(:,2) = std(BC_Reward_Targ64_MAT(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ64{j}(:,2:2:end),2))
                
                BC_Reward_Targ65_MAT = cell2mat(CursorPathsByTrial.BC_Reward_Targ65');
                MeanCursorPath.Targ65(:,1) = mean(BC_Reward_Targ65_MAT(:,1:2:end),2);
                MeanCursorPath.Targ65(:,2) = mean(BC_Reward_Targ65_MAT(:,2:2:end),2);
                MeanCursorPath.Targ65_STE(:,1) = std(BC_Reward_Targ65_MAT(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ65{j}(:,1:2:end),2))
                MeanCursorPath.Targ65_STE(:,2) = std(BC_Reward_Targ65_MAT(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ65{j}(:,2:2:end),2))
                
                if isfield(CursorPathsByTrial,'BC_Reward_Targ66')
                    BC_Reward_Targ66_MAT = cell2mat(CursorPathsByTrial.BC_Reward_Targ66');
                    MeanCursorPath.Targ66(:,1) = mean(BC_Reward_Targ66_MAT(:,1:2:end),2);
                    MeanCursorPath.Targ66(:,2) = mean(BC_Reward_Targ66_MAT(:,2:2:end),2);
                    MeanCursorPath.Targ66_STE(:,1) = std(BC_Reward_Targ66_MAT(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ66{j}(:,1:2:end),2))
                    MeanCursorPath.Targ66_STE(:,2) = std(CursorPathsByTrial.BC_Reward_Targ66{j}(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ66{j}(:,2:2:end),2))
                end
                if isfield(CursorPathsByTrial,'BC_Reward_Targ67')
                    BC_Reward_Targ67_MAT = cell2mat(CursorPathsByTrial.BC_Reward_Targ67');
                    MeanCursorPath.Targ67(:,1) = mean(BC_Reward_Targ67_MAT(:,1:2:end),2);
                    MeanCursorPath.Targ67(:,2) = mean(BC_Reward_Targ67_MAT(:,2:2:end),2);
                    MeanCursorPath.Targ67_STE(:,1) = std(BC_Reward_Targ67_MAT(:,1:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ67{j}(:,1:2:end),2))
                    MeanCursorPath.Targ67_STE(:,2) = std(BC_Reward_Targ67_MAT(:,2:2:end),0,2)./sqrt(size(CursorPathsByTrial.BC_Reward_Targ67{j}(:,2:2:end),2))
                end
                
                errorbarxy(MeanCursorPath.Targ64(:,1),MeanCursorPath.Targ64(:,2),...
                    MeanCursorPath.Targ64_STE(:,1), MeanCursorPath.Targ64_STE(:,2),...%lower error bounds
                    [],[],'k-','b') % Colors
                hold on
                errorbarxy(MeanCursorPath.Targ65(:,1),MeanCursorPath.Targ65(:,2),...
                    MeanCursorPath.Targ65_STE(:,1), MeanCursorPath.Targ65_STE(:,2),...
                    [],[],'k-','b')
                hold on
                if isfield(CursorPathsByTrial,'BC_Reward_Targ66')
                    errorbarxy(MeanCursorPath.Targ66(:,1),MeanCursorPath.Targ66(:,2),...
                        MeanCursorPath.Targ66_STE(:,1), MeanCursorPath.Targ66_STE(:,2),...%lower error bounds
                        [],[],'k-','b') % Colors
                    hold on
                end
                if isfield(CursorPathsByTrial,'BC_Reward_Targ67')
                    errorbarxy(MeanCursorPath.Targ67(:,1),MeanCursorPath.Targ67(:,2),...
                        MeanCursorPath.Targ67_STE(:,1), MeanCursorPath.Targ67_STE(:,2),...
                        [],[],'k-','b')
                    hold on
                end
            end
            
            
            clear MeanCursorPath CursorPathXY
            %             for i = 1:sum(cellfun(@isempty,CursorPathsByTrial.BC_MO(j,:))==0)
            %                 if ~isempty(CursorPathsByTrial.BC_MO{j,i})
            %                     figure(2)
            %                     subplot(Rows,4,k)
            % %                     plot(CursorPathsByTrial.BC_MO{j,i}(:,1), CursorPathsByTrial.BC_MO{j,i}(:,2))
            %
            %                     CursorPathXY = cell2mat(CursorPathsByTrial.BC_Reward{j,k});
            %                     MeanCursorPath(:,1) = mean(CursorPathXY(:,1:2:end),2);
            %                     MeanCursorPath(:,2) = mean(CursorPathXY(:,2:2:end),2);
            %
            %
            %                     plot(MeanCursorPath(:,1),MeanCursorPath(:,2),'LineWidth',3.0,'Color','g')
            %                     clear MeanCursorPath CursorPathXY
            %                 end
            %
            %             end
            %             TrialLength(TrialLength(:,1)==0,:) = [];
            %             [TrialLengths] = sortrows([TrialLength],2);
            %             for i = 1:3:length(TrialLengths)
            %                 if ~isempty(CursorPathsByTrial{i})
            %                     plot(CursorPathsByTrial{i}(:,1),CursorPathsByTrial{i}(:,2))
            %                 end
            %             end
        end
        k = k + 1;
        clear TrialLength TrialLengths CursorPaths TC
    end
end

%% Plot velocity traces and overlay them with dotted movement onset lines
if 0
    Fnum = 17;
    Chnum = 39;
    VelocityTrace = [];
    for i = 1 :length(Trials{Chnum,Fnum}.Vel_MO)
        
        VelocityTrace = [VelocityTrace; sqrt(Trials{Chnum,Fnum}.Vel_MO{:,i}(:,2).^2 + Trials{Chnum,Fnum}.Vel_MO{:,i}(:,3).^2)];
        MOpoints(1,i) = 40+80*(i-1);
        
    end
    
    figure
    plot(repmat(MOpoints,length(min(VelocityTrace)-1:max(VelocityTrace)+1),1),repmat((min(VelocityTrace)-1:max(VelocityTrace)+1)',1,length(MOpoints)),'r--')
    hold on
    plot(VelocityTrace)
    
    xlabel('Time(s)')
    ylabel('Velocity')
end