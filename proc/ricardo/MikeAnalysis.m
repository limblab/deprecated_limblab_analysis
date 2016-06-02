fit_func = 'a+b/(1+exp(x*c+d))';
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
        h_temp = plot(sigmoid_fit,'r');
        pause
    end
end
        