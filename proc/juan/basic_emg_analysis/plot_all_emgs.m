% 
% plot all EMGs in a BDF struct
%

function plot_all_emgs( bdf_struct, varargin )

nbr_bdfs                = length(bdf_struct);

if nargin == 3
    switch varargin{1}
        case 'time'
            t_int       = varargin{2};
        case 'emgs'
            chs         = varargin{2};
    end
end

if ~exist('chs','var')
    chs                 = 1:length(bdf_struct(1).emg.emgnames);
end

% get number of EMGs
nbr_emgs                = length(chs);


for e = 1:nbr_emgs
    figure('units','normalized','outerposition',[0 0 1 1])
    for b = 1:nbr_bdfs
        subplot(nbr_bdfs,1,b)
        plot(bdf_struct(b).emg.data(:,1),bdf_struct(1).emg.data(:,chs(e)+1))
        legend(bdf_struct(b).emg.emgnames(e));
        set(gca,'TickDir','out'),set(gca,'FontSize',14);
        
        if exist('t_int','var'), xlim(t_int); end
        if b == nbr_bdfs, xlabel('time (s)'); end
    end
end