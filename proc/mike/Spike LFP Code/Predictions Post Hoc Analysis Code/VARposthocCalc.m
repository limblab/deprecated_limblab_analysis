AllVAF = cat(2,VAFcalc{:})

AllVAF = [AllVAF  r2_X_SingleUnitsSorted(:,2) bestf];

AllVAF_sorted = sortrows(AllVAF ,[size(AllVAF ,2) -(size(AllVAF ,2)-1)]);

AllVAF_sorted_LMP = AllVAF_sorted(1:32,1:end-2)./repmat(AllVAF_sorted(1:32,1),1,size(AllVAF_sorted,2)-2);

bandi = [32 65 70 91 116];

AllVAF_sorted_avg(1,:) = mean(AllVAF_sorted(1:10,:))/mean(AllVAF_sorted(1:10,1));
AllVAF_sorted_avg(2,:) = mean(AllVAF_sorted(bandi(1)+1:bandi(1)+11,:))/mean(AllVAF_sorted(bandi(1)+1:bandi(1)+11,1));
AllVAF_sorted_avg(3,:) = mean(AllVAF_sorted(bandi(2)+1:bandi(2)+11,:))/mean(AllVAF_sorted(bandi(2)+1:bandi(2)+11,1));
AllVAF_sorted_avg(4,:) = mean(AllVAF_sorted(bandi(3)+1:bandi(3)+5,:))/mean(AllVAF_sorted(bandi(3)+1:bandi(3)+11,1));
AllVAF_sorted_avg(5,:) = mean(AllVAF_sorted(bandi(4)+1:bandi(4)+11,:))/mean(AllVAF_sorted(bandi(4)+1:bandi(4)+11,1));
AllVAF_sorted_avg(6,:) = mean(AllVAF_sorted(bandi(5)+1:bandi(5)+11,:))/mean(AllVAF_sorted(bandi(5)+1:bandi(5)+11,1));

AllVAF_sorted_avg(isnan(AllVAF_sorted_avg) == 1) = 0;

% AllVAF_EML(:,1) = mean(AllVAF_sorted_avg(:,1:5),2);
% %AllVAF_EML_SE(:,1) = std(AllVAF_sorted_avg(:,1:5),2)/sqrt(5);
% 
% AllVAF_EML(:,2) = mean(AllVAF_sorted_avg(:,6:11),2);
% %AllVAF_EML_SE(:,2) = std(AllVAF_sorted_avg(:,6:11),2)/sqrt(6);
% 
% AllVAF_EML(:,3) = mean(AllVAF_sorted_avg(:,12:17),2);
% %AllVAF_EML_SE(:,3) = std(AllVAF_sorted_avg(:,12:17),2)/sqrt(6);

