
musc_names = {'gluteus max', 'gluteus med', 'gastroc', 'vastus lat', 'biceps fem A',...
    'biceps fem PR', 'biceps fem PC', 'tib ant', 'rect fem', 'vastus med', 'adduct mag', ...
    'semimemb', 'gracilis R', 'gracilis C', 'semitend'};

%and good channels (1 is good, 0 is bad)
goodChannelsWithBaselines =  [ 1 ,  0 ,  0 , 0 , 1 , 1 ,  1 ,  0 , 1 , 1 , 0 , 0 , 1 , 1 , 1 ;...
0 ,  1 ,  1 , 1 , 1 , 1 ,  1 ,  1 , 1 , 1 , 0 , 1 , 0 , 1 , 0 ;...
1 ,  0 ,  1 , 1 , 1 , 0 ,  1 ,  1 , 1 , 1 , 0 , 0 , 1 , 1 , 0 ;...
1 ,  0 ,  1 , 0 , 1 , 1 ,  1 ,  1 , 0 , 0 , 0 , 0 , 0 , 1 , 1 ;...
1 ,  1 ,  1 , 0 , 1 , 1 ,  1 ,  1 , 1 , 0 , 0 , 1 , 1 , 1 , 0 ;...
1 ,  1 ,  0 , 1 , 1 , 1 ,  1 ,  1 , 1 , 0 , 0 , 1 , 0 , 1 , 0 ;...
1 ,  0 ,  1 , 1 , 1 , 1 ,  1 ,  1 , 1 , 1 , 0 , 1 , 0 , 1 , 1 ;...
1 ,  0 ,  1 , 1 , 0 , 1 ,  1 ,  1 , 1 , 1 , 0 , 0 , 1 , 1 , 1 ];


animal = 2; 
muscle = 3; 
n = 4; 
Wn = 30/(5000/2); %butter parameters (30 Hz)

if ~goodChannelsWithBaselines(animal, muscle)
    error('This is a bad channel, try a different muscle/animal.')
end
% 
% lp_matrix = filter_emgs(animal, muscle, n, Wn);
% 
% 
% %figure('Name', ['Muscle ' num2str(muscle)]);
% %hold on;
% 
% avgall = mean(lp_matrix);
% 
% 
% conv_fact = 1/125; %update at 40 hz; 5000/125 = 40
% x = 1/5000:1/5000:length(avgall)/5000; %time variable (sampling at 5000hz)
% xq = 1/5000/conv_fact:1/5000/conv_fact:length(avgall)/5000; %new time variables - now an array of len
% downsamp = interp1(x, avgall, xq);
% 
% %e = std(lp_matrix);
% %errorbar(x, avgall, e);
% %plot(x, avgall, 'k', 'linewidth', 3);
% 
% lp_2 = filter_emgs(3, 3, n, Wn); 
% avg2 = mean(lp_2); 
% x2 = 1/5000:1/5000:length(avg2)/5000;
% %plot(x2, avg2, 'b', 'linewidth', 2); 
% 
% %plot(xq, downsamp, 'linewidth', 2)
% %saveas(gcf, ['Animal' num2str(animal) 'Muscle' num2str(muscle) '.png']); 

%PLOT MUSCLE, all good channels
figure('Name', ['Muscle 8 - TA']);
hold on;

muscle = 8; 
%conv_fact = 40/5000; %update at 40 hz

for i=1:8 %there are 8 animals total
    if goodChannelsWithBaselines(i, muscle)
        lp_matrix = filter_emgs(i, muscle, n, Wn); 
        avgall = mean(lp_matrix); 
        x = 1/5000:1/5000:length(avgall)/5000; 
        plot(x, avgall, 'linewidth', 2); 
    end
end



