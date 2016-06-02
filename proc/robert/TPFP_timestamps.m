function [TP,FP]=TPFP_timestamps(TS1,TS2)

% syntax [TP,FP]=TPFP_timestamps(TS1,TS2);
%
% 

for n=1:length(TS1)
    [~,ind]=min(abs(TS1(n)-TS2));
    differences(n)=TS1(n)-TS2(ind);
end

threshold_plus=mean(differences)+std(differences);
threshold_minus=mean(differences)-std(differences);
TP=nnz(differences>threshold_minus & differences<threshold_plus);
FP=(length(TS2)-TP)/length(differences);
TP=TP/length(differences);
% disp('done')
figure, stem(differences)


