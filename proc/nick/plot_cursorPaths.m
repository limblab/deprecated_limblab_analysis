% trials = [10 13 60 26 3 23 29 15 12 11 5 2 24 19 4 28]; % Mini Hybrid 984
trials = [5 10 1 28 3 30 20 8 35 4 16 39 18 11 27 9]; % Mini Standard 985
colors = ['r' 'g' 'b' 'k' 'r' 'g' 'b' 'k' 'r' 'g' 'b' 'k' 'r' 'g' 'b' 'k'];
figure;
rectangle('position',[-0.75 -0.75 1.5 1.5]);
for x = 1:16
    rectangle('position', [cos(2*pi*(x)/16)*8-0.75 sin(2*pi*(x)/16)*8-0.75 1.5 1.5]);
end
for x = 1:length(trials)
    startindex = find(binnedData.timeframe*10 == floor(binnedData.trialtable(trials(x),5)*10));
    endindex = find(binnedData.timeframe*10 == floor(binnedData.trialtable(trials(x),9)*10));
    hold on;
    plot(binnedData.cursorposbin(startindex:endindex,1),binnedData.cursorposbin(startindex:endindex,2),colors(x));
end
axis([-12 12 -12 12])
