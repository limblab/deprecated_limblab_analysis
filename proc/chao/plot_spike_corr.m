
c = get_spikes_corr(binnedData.spikeratedata,binnedData.cursorposbin,20);
ymax = max(max(max(c{:})));
figure;
for n = 1:96
    hold off;
    plot(c{1}(:,n),'b');
    hold on;
    plot(c{2}(:,n),'g');
    ylim([0 ymax]);
    title(sprintf('neuron %d',n));
    legend('force x','force y');
    pause;
end