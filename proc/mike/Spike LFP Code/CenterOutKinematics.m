FirstTrialInds=find(out_struct.words(:,2)==17);
j = 1;
for i = 1:length(FirstTrialInds)-1
    
    if out_struct.words(FirstTrialInds(i+1)-1,2) ~= 32
        continue
    else
        TimeStart = vpa(out_struct.words(FirstTrialInds(i),1),3);
        TimeEnd = vpa(out_struct.words(FirstTrialInds(i+1)-1,1),3);
        
        TrialStartIndex = round((TimeStart - 1)/.05);
        TrialEndIndex = round((TimeEnd - 1)/.05);
        
        if TrialEndIndex > length(out_struct.pos);
            continue
        else
        TrialPath{j} = out_struct.pos(TrialStartIndex:TrialEndIndex,:);
        end
        
        clear Time* TrialStartIndex TrialEndIndex
        
        if round(out_struct.targets.corners(i,2)) == 8
            plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'b')
        else
            plot(TrialPath{j}(:,2),TrialPath{j}(:,3),'k')
        end
        
        hold on
        j = j+1;
        
        
    end
end

h = fill([-2,-2,2,2],[12,8,8,12],'r')
set(h,'FaceAlpha',.3)
j = fill([8,8,12,12],[2,-2,-2,2],'r')
set(j,'FaceAlpha',.3)
m = fill([2,2,-2,-2],[2,-2,-2,2],'r')
set(m,'FaceAlpha',.3)

axis square
set(gca,'xlim',[-15,15])
set(gca,'ylim',[-12,12])

    
    
    