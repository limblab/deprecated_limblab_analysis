plot_all = 0;

fit_func = '2/(1+exp(x*c+d))-1';
f_sigmoid = fittype(fit_func,'independent','x');

jnd = zeros(8,5);
a = [];
for i_dir=1:8
    for i_mag=1:5
        a = [a ; [(i_dir-1)*5+i_mag (i_dir-1)*5+i_mag+40]];
        x_data = [Alldata((i_dir-1)*5+i_mag).value Alldata((i_dir-1)*5+i_mag+40).value];
        y_data = [Alldata((i_dir-1)*5+i_mag).resp Alldata((i_dir-1)*5+i_mag+40).resp];
        
        sigmoid_fit = fit(x_data',y_data',f_sigmoid);   
        x_vector = [-5:.01:5];
        [sig_der sig_der2] = differentiate(sigmoid_fit,x_vector);
        [temp max_idx] = max(sig_der2);
        [temp min_idx] = min(sig_der2);
        jnd(i_dir,i_mag) = abs((x_vector(max_idx)-x_vector(min_idx))/2);
        
        if plot_all
            figure
            plot(x_data,y_data,'.')
            hold on
            h_temp = plot(sigmoid_fit,'r');
            plot(x_vector,sig_der2/max(sig_der2),'.k')
            xlim([min(x_data) max(x_data)])
            ylim([-1 1])
            title(['JND = ' num2str(jnd(i_dir,i_mag))])
        end
%         pause
    end
    
end
Dir= [0:45:315];
Mag= [2:2:10];

figure
plot(Mag,mean(jnd)*180/pi)
xlabel('Magnitude')
ylabel('JND')
title('Mean JND across directions')

figure
plot(Dir,(mean(jnd,2)*180/pi))
xlabel('Direction')
ylabel('JND')
title('Mean JND across magnitudes')

colors = colormap('jet');
figure; 
colors_temp = colors(1:round(length(colors)/size(jnd,2)):end,:);
for k=1:size(jnd,2)
    temp = polar([Dir Dir(1)]*pi/180,[jnd(:,k); jnd(1,k)]'*180/pi);
    set(temp,'Color',colors_temp(k,:))
    hold on
end
legend(num2str(Mag'))
title('JND by direction and magnitude')

figure;
colors_temp = colors(1:round(length(colors)/size(jnd,1)):end,:);
for k=1:size(jnd,1)
    plot(Mag,jnd(k,:)*180/pi,'Color',colors_temp(k,:))
    hold on
end
xlabel('Magnitude')
ylabel('JND')
legend(num2str(Dir'))