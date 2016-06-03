function plot_3waves_quick(t, Y1, Y2, Y3, labelt, labely1, labely2, labely3, fign);
% Plots two waves as a function of time.

f_clear_figure(fign);
subplot(3,1,1);
plot(t,Y1);
hold on;
ylabel(labely1); 
subplot(3,1,2); 
plot(t,Y2);
ylabel(labely2); 
subplot(3,1,3); 
plot(t,Y3);
ylabel(labely3); 
xlabel(labelt); 
