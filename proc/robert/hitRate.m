function hr=hitRate(bdf)

% syntax hr=hitRate(out_struct)
%
% 


% exclude info before the first and after the last trial
first_trial_start=find(bdf.words(:,2)==18,1,'first');
if first_trial_start~=1
    bdf.words(1:(first_trial_start-1),:)=[];
end
% success (32) | abort (33) | fail (34)
last_trial_end=find(bdf.words(:,2)==32 | bdf.words(:,2)==33 | bdf.words(:,2)==34,1,'last');  
if last_trial_end < size(bdf.words,1)
    bdf.words((last_trial_end+1):end,:)=[];
end

fprintf(1,'number of rewards was %d.\n',sum(bdf.words(:,2)==32))
fprintf(1,'number of trials was %d.\n',sum(bdf.words(:,2)==18))
fprintf(1,'number of aborts was %d.\n',sum(bdf.words(:,2)==33))
fprintf(1,'rewards/min: %.4f\n',sum(bdf.words(:,2)==32)/diff(bdf.words([1 end],1))*60)

hr=sum(bdf.words(:,2)==32)/sum(bdf.words(:,2)==18);
