fit_func = '2/(1+exp(x*c+d))-1';
f_sigmoid = fittype(fit_func,'independent','x');

for i_dir=1:8
    for i_mag=1:5
        [(i_dir-1)*5+i_mag (i_dir-1)*5+i_mag+40]
        x_data = [Alldata((i_dir-1)+i_mag).value Alldata((i_dir-1)+i_mag+40).value];
        y_data = [Alldata((i_dir-1)+i_mag).resp Alldata((i_dir-1)+i_mag+40).resp];
        figure
        plot(x_data,y_data,'.')
        hold on
        sigmoid_fit = fit(x_data',y_data',f_sigmoid);   
        x_vector = [-5:.01:5];
        [sig_der sig_der2] = differentiate(sigmoid_fit,x_vector);
        [temp max_idx] = max(sig_der2);
        [temp min_idx] = min(sig_der2);
        jnd(i_dir,i_mag) = abs(x_vector(max_idx)-x_vector(min_idx));
        h_temp = plot(sigmoid_fit,'r');
        hold on
%         plot(x_vector,sig_der2/max(sig_der2),'.k')
        xlim([min(x_data) max(x_data)])
%         ylim([-1 1])
%         pause
    end
end
        