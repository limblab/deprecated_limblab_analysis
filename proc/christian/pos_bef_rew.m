rew_trials = find(tt(:,end)==double('R'));
num_rew = length(rew_trials);

time_window = 0.5;
SR = bdf.pos(2,1)-bdf.pos(1,1);

numbin = round(time_window/SR);

pos_bef_rew = zeros(numbin,2,num_rew);

for i=1:num_rew
    pos_bef_rew(:,:,i) = bdf.pos(find(bdf.pos(:,1)<=tt(rew_trials(i),9),numbin,'last'),2:end); 
end

