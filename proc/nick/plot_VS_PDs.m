figure
clear PD_means
for x = 1:length(PDs)
    PD_means(x) = mean(PDs{x}(:,1));
end
plot(0,PD_means,'x')