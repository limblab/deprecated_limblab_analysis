ControlCh = 73
k = 1

HC_I = [1:6];
BC_I = [17:26];

Rows = ceil(nnz(~cellfun(@isempty,Trials(ControlCh,[HC_I(1):HC_I(end) BC_I(1):BC_I(end)])))/4);

figure
for j = [1 3 17] %17:26]
    CursorPaths = [];
    figure
    if isfield(Trials{ControlCh,j},'Path_MO')
%         subplot(Rows,4,k)   
        if j <= 6
            h = fill([8.9,8.9,11.1,11.1],[1.108,-1.0920,-1.0920,1.08],'r');
            set(h,'FaceAlpha',.3)
            hold on
            p = fill([-1.08,-1.08,1.1159,1.1159],[-8.9,-11.1,-11.1,-8.9],'r');
            set(p,'FaceAlpha',.3)
            m = fill([-11.1,-11.1,-8.9,-8.9],[1.0761,-1.1239,-1.1239,1.0761],'r');
            set(m,'FaceAlpha',.3) 
            n = fill([-1.1,-1.1,1.1,1.1],[11.1,8.9,8.9,11.1],'r');
            set(n,'FaceAlpha',.3)           
            q = fill([1.1,1.1,-1.1,-1.1],[1.1,-1.1,-1.1,1.1],'r');
            set(q,'FaceAlpha',.3)
%             axis square
        elseif j >= 17 && j <= 26
            h = fill([-2,-2,2,2],[9,5,5,9],'r');
            set(h,'FaceAlpha',.3)
            hold on
            p = fill([9,9,5,5],[2,-2,-2,2],'r');
            set(p,'FaceAlpha',.3)
            m = fill([2,2,-2,-2],[2,-2,-2,2],'r');
            set(m,'FaceAlpha',.3)
            xlim([-12 12])
            ylim([-12 12 ])
%             axis square
        end
        if j ==1
            xlabel('X cursor position')
            ylabel('Y cursor position')
        end
        for i = 1:length(Trials{ControlCh,j}.Path_Whole)
            if ~isempty(Trials{ControlCh,j}.Path_Whole{i})
                if j < HC_I(end) 
                    CursorPaths = [CursorPaths; Trials{ControlCh,j}.Path_Whole{i}(:,2),Trials{ControlCh,j}.Path_Whole{i}(:,3)];
                    CursorPathsByTrial_HC{j,i} = Trials{ControlCh,j}.Path_Whole{i}(:,2:3);
                elseif length(Trials{ControlCh,j}.Path_Whole{i}) < 50
                    plot(Trials{ControlCh,j}.Path_Whole{i}(:,2),Trials{ControlCh,j}.Path_Whole{i}(:,3))
                    TrialLength(i,:) = [i length(Trials{ControlCh,j}.Path_Whole{i}(:,2))];
                    CursorPathsByTrial{i} = Trials{ControlCh,j}.Path_Whole{i}(:,2:3);
                end
            end
        end
        if j < HC_I(end)
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
        clear TrialLength TrialLengths CursorPathsByTrial CursorPaths CursorPathsByTrial_HC 
    end
end