success_mean = [114 68 0 80 58 0 51 11 0 0 85 52 0 53 30]/10;
hybrid_success_mean = [114 0 0 80 0 0 51 0 0 0 85 0 0 53 0]/10;
standard_success_mean = [0 68 0 0 58 0 0 11 0 0 0 52 0 0 30]/10;

success_std = [26 27 0 24 21 0 14 4 0 0 32 11 0 18 18]/10;

fail_mean = [1 3 0 29 14 0 2 1 0 0 3 1 0 23 15]/10;
hybrid_fail_mean = [1 0 0 29 0 0 2 0 0 0 3 0 0 23 0]/10;
standard_fail_mean = [0 3 0 0 14 0 0 1 0 0 0 1 0 0 15]/10;

fail_std = [1 2 0 7 3 0 1 1 0 0 4 1 0 7 5]/10;

figure;
bar(hybrid_success_mean,1,'b')
hold on
bar(standard_success_mean,1,'r')
errorbar(1:length(success_std),success_mean,success_std,'.k')
axis([0 16 0 15])
title('Online BMI Performance')
xlabel('Monkey M')
ylabel('Targets Acquired / min')
legend('Hybrid Decoder', 'Standard Decoder')

figure;
bar(hybrid_success_mean,1,'b')
hold on
bar(standard_success_mean,1,'r')
errorbar(1:length(success_std),success_mean,success_std,'.k')
bar(hybrid_fail_mean,1,'c')
bar(standard_fail_mean,1,'m')
errorbar(1:length(fail_std),fail_mean,fail_std,'.w')
axis([0 16 0 15])
title('Online BMI Performance')
xlabel('Monkey M')
ylabel('Targets Acquired / min')
legend('Hybrid Decoder (success)', 'Standard Decoder (success)', '', 'Hybrid Decoder (fail)', 'Standard Decoder (fail)')
