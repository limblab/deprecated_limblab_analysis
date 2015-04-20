ControlCh = 52
k = 1

HC_I = [1:4];
BC_I = [5:9];

Rows = ceil(nnz(~cellfun(@isempty,Trials(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)])))/4);

for j = [HC_I(1):HC_I(end) BC_I(1):BC_I(end)] % 
    CursorPaths = [];
    if isfield(Trials{ControlCh,j},'Path_MO')
        subplot(Rows,4,k)
        TC = unique(Trials{ControlCh,j}.Targets.corners(:,2:5),'rows');
        Center = min(min(abs(TC)));
        h = fill([Center,Center,-1*Center,-1*Center],[Center,-1*Center,-1*Center,Center],'r');
        % TC = target coordinates
        hold on
        for i = 1:size(TC,1)
            h = fill([TC(i,1),TC(i,1),TC(i,3),TC(i,3)],[TC(i,2),TC(i,4),TC(i,4),TC(i,2)],'r');
            
            set(h,'FaceAlpha',.3)
            xlim([min(min(TC))-10 max(max(TC))+10])
            ylim([min(min(TC))-10 max(max(TC))+10])
        end
        if j ==1
            xlabel('X cursor position')
            ylabel('Y cursor position')
        end
        for i = 1:length(Trials{ControlCh,j}.Path_Whole)
            if ~isempty(Trials{ControlCh,j}.Path_Whole{i})
                if j <= HC_I(end) 
                    CursorPaths = [CursorPaths; Trials{ControlCh,j}.Path_Whole{i}(:,2),Trials{ControlCh,j}.Path_Whole{i}(:,3)];
                    CursorPathsByTrial_HC{j,i} = Trials{ControlCh,j}.Path_Whole{i}(:,2:3);
                else %if length(Trials{ControlCh,j}.Path_Whole{i}) < 50
                    plot(Trials{ControlCh,j}.Path_Whole{i}(:,2),Trials{ControlCh,j}.Path_Whole{i}(:,3))
                    TrialLength(i,:) = [i length(Trials{ControlCh,j}.Path_Whole{i}(:,2))];
                    CursorPathsByTrial{i} = Trials{ControlCh,j}.Path_Whole{i}(:,2:3);
                end
            end
        end
        if j <= HC_I(end)
                        for i = 1:size(CursorPathsByTrial_HC,2)
                            if ~isempty(CursorPathsByTrial_HC{j,i})
                                plot(CursorPathsByTrial_HC{j,i}(:,1), CursorPathsByTrial_HC{j,i}(:,2) + abs(mean(CursorPaths(:,2))))
                            end
                        end
        else
%             TrialLength(TrialLength(:,1)==0,:) = [];
%             [TrialLengths] = sortrows([TrialLength],2);
%             for i = 1:3:length(TrialLengths)
%                 if ~isempty(CursorPathsByTrial{i})
%                     plot(CursorPathsByTrial{i}(:,1),CursorPathsByTrial{i}(:,2))
%                 end
%             end
        end
        k = k + 1;
        clear TrialLength TrialLengths CursorPathsByTrial CursorPaths CursorPathsByTrial_HC TC
    end
end

%% Plot velocity traces and overlay them with dotted movement onset lines
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