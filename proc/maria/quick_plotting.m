sq = [zeros(1, 50) ones(1, 50)];
color1 = [12 100 133]/255; %stance
color2 = [191 29 41]/255; %swing
color3 = [125 58 145]/255; %dual

o1 = [234 103 52]/255; 
o2 = [175 79 45]/255; 
o3 = [123 56 30]/255; 

% plot(sq, 'color', color1, 'linewidth', 4);
% set(gca, 'fontsize', 24);
% xlabel('% of step cycle');
% ylabel('normalized current');
% highVL = emg_array{3}; 
% normVL = emg_array{2}*.8; 
%medVL = emg_array{2}; 

hold on;
xvals = linspace(0, 100, length(emg_array{2}));
plot(xvals, highVL, 'color', o1, 'linewidth', 4);
plot(xvals, medVL, 'color', o2, 'linewidth', 4);
plot(xvals, normVL, 'color', o3, 'linewidth', 4);
set(gca, 'fontsize', 24);
xlabel('% of step cycle');
ylabel('normalized current');
NumTicks = 6;
ax = gca;
L = get(ax,'YLim');
set(ax,'YTick',linspace(L(1),L(2),NumTicks));
set(ax, 'YTickLabel', {'0', '0.2', '0.4', '0.6', '0.8', '1.0'});

%plotting the average emgs with error bars
% for i=[2 8]
% colors = color3;
% figure;  hold on;
% xvals = linspace(0, 100, length(emg_array{i}));
%
% %do fill
% y1 = std_array{i}(1:length(emg_array{i}))+emg_array{i};
% y2 = emg_array{i}-std_array{i}(1:length(emg_array{i}));
% Y = [y1 fliplr(y2)];
% X = [xvals fliplr(xvals)];
% h = fill(X, Y, colors);
% set(h, 'facealpha', .2);
%
% %plot lines
% plot(xvals, emg_array{i}, 'color', colors, 'linewidth', 4);
% plot(xvals, y1, 'color', colors, 'linewidth', 1);
% plot(xvals, y2, 'color', colors, 'linewidth', 1);
%
% set(gca, 'fontsize', 36);
% xlabel('% of step cycle');
% ylabel('normalized current');
% ylim([0 1]);
% disp(legendinfo{i});
% end


%plotting the raw emgs
% figure;
% hold on;
% animal = 2;
% mus = 8; %1:length(musc_names);
% for i=mus
%     if goodChannelsWithBaselines(animal, i)
%         steps = [rawCycleData{animal,1}(:, i); rawCycleData{animal,2}(:, i); rawCycleData{animal,3}(:, i)];
%         xvals = length(steps)/5000;
%         plot(xvals, steps, 'color', color2);
%         set(gca, 'fontsize', 28);
%         xlabel('Time (s)');
%         ylabel('EMG Amplitude');
%     else
%         disp('bad animal')
%     end
% end


box off;