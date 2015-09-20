

function fig_fr_change_hist( change_neural_activity, fig_title, varargin )


if nargin == 3
    switch varargin{1}
        case 'none'
            hist_axis   = -100:2:100; % could be made a parameter
            xlbl        = 'frequency change (Hz)';
        case 'norm'
            hist_axis   = -10:0.1:10;
            xlbl        = 'norm. frequency change';
    end
else
    hist_axis           = -100:2:100; % could be made a parameter
    xlbl                = 'frequency change (Hz)';
end


[hist_data, bin_centres] = hist(change_neural_activity,hist_axis);

% test if the distribution has zero mean

% figure
figure,bar(bin_centres,hist_data,1)
set(gca,'FontSize',14), set(gca,'TickDir','out')
xlabel(xlbl),ylabel('counts')
title(fig_title,'Interpreter','none')
% all this for the X-axis
xlm(1) = hist_axis(find(hist_data>0,1));
xlm(2) = hist_axis(find(hist_data>0,1,'last'));
if xlbl(1:4) == 'norm'
    xlm(1) = sign(xlm(1))*ceil(abs(xlm(1)));
    xlm(2) = sign(xlm(2))*ceil(abs(xlm(2)));
else
    xlm(1) = sign(xlm(1))*ceil(abs(xlm(1))/10)*10;
    xlm(2) = sign(xlm(2))*ceil(abs(xlm(2))/10)*10;
end
xlim(xlm)
