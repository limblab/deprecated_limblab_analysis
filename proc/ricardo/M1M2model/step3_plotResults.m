%% This scripts plots the results of an M1-M2 simulation
% It replicates Figures 6 and 8 from the article.
%
%
% Author:  Jasper Schuurmans
% Contact: jasper@schuurmans.cc
%% Initialize
clear
load analyzedResults

fs      = 12;  % Fontsize
lw      = 1;   % Linewidth
ms      = 6;   % Markersize

%% Plot M1 and M2 for all conditions (line charts)

figure
%set(gcf,'paperpositionmode','auto')

% M1
subplot(1,2,1)

% Plot lines
lines = {'k-o', 'k--v', 'k-.s'};
Xoffset = 0.09;
for jj = 1:length(amplitudes)
    plot(velocities + (jj-length(amplitudes)/2) * Xoffset, M1(:,jj), lines{jj}, 'linewidth', lw, 'markerfacecolor', 'k', 'markersize', ms);
    hold on
end

% Axes properties
set(gca, 'fontsize', fs, 'linewidth', lw, 'box', 'off')
ylim([0.5 3.5])
xlim([1 5.5])
axis square

% Tick labels
xlab = cell(size(velocities));
for ii = 1:length(amplitudes)
    xlab{ii} = num2str(velocities(ii));
end

set(gca, 'xtick', velocities, 'xticklabel', xlab, 'ytick', 0:0.5:3.5)
ylabel('Normalized M1')
xlabel('Stretch velocity [rad/s]')

% Legend
leg = cell(size(amplitudes));
for jj = 1:length(amplitudes)
    leg{jj} = [num2str(amplitudes(jj), '%1.2f'), ' rad'];
end
%legend(leg, 'location', 'north', 'orientation', 'horizontal')
legend(leg, 'location', 'southeast')
legend('boxoff')

%% M2
subplot(1,2,2)

% Plot lines
lines = {'k-o', 'k--v', 'k-.s'};
Xoffset = 0.09;
for jj = 1:length(amplitudes)
    plot(velocities + (jj-length(amplitudes)/2) * Xoffset, M2(:,jj), lines{jj}, 'linewidth', lw, 'markerfacecolor', 'k', 'markersize', ms);
    hold on
end

% Axes properties
set(gca, 'fontsize', fs, 'linewidth', lw, 'box', 'off')
ylim([0.5 3.5])
xlim([1 5.5])
axis square

% Tick labels
xlab = cell(size(velocities));
for ii = 1:length(amplitudes)
    xlab{ii} = num2str(velocities(ii));
end

set(gca, 'xtick', velocities, 'xticklabel', xlab, 'ytick', 0:0.5:3.5)
ylabel('Normalized M1')
xlabel('Stretch velocity [rad/s]')

%% Plot spike map
figure

% Choose velocity and amplitude to plot for
velIdx = 4;
ampIdx = 2;

% Time window
window = [-0.080, 0.150];
idx = (time<=window(2)) & (time >= window(1));

% Retrieve spikes
S = out{velIdx,ampIdx}.nrn.Sdetail; %#ok<USENS>

% Stretch
subplot(4,1,1)
set(gca, 'fontsize', fs)
plot(time(idx), ramp{velIdx,ampIdx}.pos(idx), 'k-','linewidth',lw) %#ok<USENS>
xlim(window);
ylim([-0.05, 0.2])
ylabel('Angle [rad]')
set(gca, 'linewidth', lw)
box off
set(gca, 'xticklabel', [], 'linewidth', 2)

% Ia rate
subplot(4,1,2)
set(gca, 'fontsize', fs)
Iaidx = (time<=window(2)+inputs.Iadelay) & (time >= window(1)+inputs.Iadelay);
plot(time(idx), out{velIdx,ampIdx}.inputs.rIa(Iaidx), 'k-','linewidth',lw)
xlim(window);
ylabel('Ia rate [sp/s]')
set(gca, 'linewidth', lw)
box off
set(gca, 'xticklabel', [], 'linewidth', 2)

% Motoneuron spikes
subplot(4,1,3);
set(gca, 'fontsize', fs)
h = plotsync(time(idx), S(idx,:), 'k');
set(get(h,'children'),'markersize',ms)
xlim(window);
ylim([0, pool.N])
set(gca,'ytick',[0 300])
ylabel('Neuron #')
box off
set(gca, 'xticklabel', [], 'linewidth', lw)

% Average number of spikes
subplot(4,1,4);
set(gca, 'fontsize', fs)
plot(time(idx), sum(S(idx,:), 2), 'k', 'linewidth', lw); hold on
xlabel('Time [s]')
ylabel('Pool output [-]')
box off
set(gca, 'linewidth', lw, 'ytick', [0 40 80])
xlim(window);