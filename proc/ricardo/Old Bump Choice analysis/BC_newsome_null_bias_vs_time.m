function h = BC_newsome_null_bias_vs_time(bump_table,stim_table,stim_pd)

lin_fit = 'a+b*x';
f_linear = fittype(lin_fit,'independent','x');
bump_directions = unique(bump_table(:,6));
bump_directions = [bump_directions(bump_directions==stim_pd) bump_directions(bump_directions~=stim_pd)];

h = figure;

bump_target_1 = bump_table(bump_table(:,7)==0,[1 3 6]);
bump_target_1(bump_target_1(:,2)==32 & bump_target_1(:,3)==bump_directions(1),4)=1;
bump_target_1(bump_target_1(:,2)==34 & bump_target_1(:,3)==bump_directions(2),4)=1;

stim_target_1 = stim_table(stim_table(:,7)==0,[1 3 6]);
stim_target_1(stim_target_1(:,2)==32 & stim_target_1(:,3)==bump_directions(1),4)=1;
stim_target_1(stim_target_1(:,2)==34 & stim_target_1(:,3)==bump_directions(2),4)=1;

bump_target_1_fit = fit(bump_target_1(:,1),bump_target_1(:,4),f_linear);
stim_target_1_fit = fit(stim_target_1(:,1),stim_target_1(:,4),f_linear);

plot(bump_target_1_fit,'r'); 
hold on; 
plot(stim_target_1_fit,'b'); 
plot(bump_target_1(:,1),bump_target_1(:,4),'.r'); 
plot(stim_target_1(:,1),stim_target_1(:,4),'.b');
legend('0N bump','0N bump + Stim','Location','SouthEast')
xlabel('time (s)')
ylabel('P moving to target 1')
