FirstTrialInds=find(out_struct.words(:,2)==17);
j = 1;
for i = 1:length(FirstTrialInds)
    
    if out_struct.words(FirstTrialInds(i+1)-1,2) ~= 32
        continue
    else
        TimeStart = vpa(out_struct.words(FirstTrialInds(i),1),3)
        TimeEnd = vpa(out_struct.words(FirstTrialInds(i+1)-1,1),3)
        
        TrialStartIndex = (TimeStart - 1)/.05
        TrialEndIndex = (TimeEnd - 1)/.05
        
        TrialPath{j} = out_struct.pos(TrialStartIndex:TrialEndIndex,:)
        
        clear Time* TrialStartIndex TrialEndIndex
        
        if out_struct.targets.corners(i,2) == -3
            plot(TrialPath{i}(:,2),TrialPath{i}(:,3),'b')
        else
            plot(TrialPath{i}(:,2),TrialPath{i}(:,3),'gr')
        end
        
        hold on
        j = j+1;
        
        
    end
end

fill([-3,-3,3,3],[13,7,7,13],'r')
set(gco,'FaceAlpha',.3)
fill([7,7,13,13],[3,-3,-3,3],'r')
set(gco,'FaceAlpha',.3)
fill([3,3,-3,-3],[3,-3,-3,3],'r')
set(gco,'FaceAlpha',.3)
    
    
    
    