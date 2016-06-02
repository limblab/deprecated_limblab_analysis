figure
clear PD_means
for x = 1:length(PDs)
    PD_means(x) = circ_mean(PDs{x}(:,1));
end
plot(0,PD_means,'x')
axis([-1 1 -3.15 3.15])