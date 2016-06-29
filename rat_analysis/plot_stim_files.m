stim_file = '20160621_020.mat';
load(stim_file);

colors = {[204 0 0], [255 125 37], [153 84 255],  [106 212 0], [0 102 51], [0 171 205], [0 0 153], [102 0 159], [64 64 64], [255 51 153], [253 203 0]};
figure(1); hold on;

for i=1:size(ds_means, 2)
    plot(emg_array{i}, 'color', colors{i}/255, 'linewidth', 3);
end

legend(legendinfo);


disp(['Slowdown: ' num2str(slowdown_factor)]); 
disp(['Number of steps: ' num2str(repeats)]); 
% musc_names = {'GS', 'Gmed', 'LG', 'VL', 'BFa',...
%     'BFpr', 'BFpc', 'TA', 'RF', 'VM', 'AM', ...
%     'SM', 'GRr', 'GRc', 'ST'};
% 

if length(amp_adjust)>1
    disp([legendinfo.' num2cell(amp_adjust(1:length(muscles))).'])
else
disp(musc_names(muscles)); 
disp(amp_adjust);
end


