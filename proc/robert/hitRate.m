function hr=hitRate(bdf)

% syntax hr=hitRate(out_struct)
%
% 


% exclude info before the first and after the last trial
first_trial_start=find(bdf.words(:,2)==18,1,'first');
if first_trial_start~=1
    bdf.words(1:(first_trial_start-1),:)=[];
end
last_trial_end=find(bdf.words(:,2)==32,1,'last');
if last_trial_end < size(bdf.words,1)
    bdf.words((last_trial_end+1):end,:)=[];
end

hr=sum(bdf.words(:,2)==32)/sum(bdf.words(:,2)==18);
