function [PDm,  = emgpds(bdf)

% emgpds.m
% Calculates STA based PDS in emgspace from bdf

% $Id: $

List=unit_list(bdf);
List = List(List(:,2)~=0 & List(:,2) ~=255,:);

nEmgs = size(bdf.emg.data,2) - 1;

timebefore= .25;
timeafter=.25;
stas = zeros(nEmgs, bdf.emg.emgfreq*timebefore+timeafter);
t = bdf.emg.data(:,1);

for i=1:length(List)
    
    sprintf('Now running unit %g of %g', i,length(List));
    
    u= get_unit(bdf, List(i,1), List(i,2));
    
    for emg_id = 1:nEmgs
        disp(emg_id);
        tmp_emg = bdf.emg.data(:,emg_id+1);
        tmp_emg = tmp_emg ./ var(tmp_emg);
        tmp_emg = smooth(abs(tmp_emg), 201);

        tmp_sta = STAsl(u, [t tmp_emg], timebefore, timeafter);
        stas(emg_id,:) = tmp_sta(:,2) - repmat(mean(tmp_sta(:,2)), length(tmp_sta(:,2)), 1);
        tsta = tmp_sta(:,1);
    end

    n = sqrt(sum(stas.^2));
    opt_delay = find(n==max(n), 1, 'first');
    opt_delay_t = tsta(opt_delay);
    PDm= zeros(nEmgs+2,length(List));
    PDm(1,i)= List(i,1);
    PDm(2,i)= List(i,2);
    PDm(3:end,i) = stas(:, opt_delay);
    PDm(3:end,i) = PDm(3:end,i)./ sqrt(sum(PDm(3:end,i).^2));
end


