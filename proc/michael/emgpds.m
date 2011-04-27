% emgpds.m
% Calculates STA based PDS in emgspace from bdf

% $Id: $

unit_id = 3;

nEmgs = size(bdf.emg.data,2) - 1;

stas = zeros(nEmgs, 10001);
t = bdf.emg.data(:,1);

for emg_id = 1:nEmgs
    disp(emg_id);
    tmp_emg = bdf.emg.data(:,emg_id+1);
    tmp_emg = tmp_emg ./ var(tmp_emg);
    tmp_emg = smooth(abs(tmp_emg), 201);
    
    tmp_sta = STA(bdf.units(unit_id).ts, [t tmp_emg], 2.5, 2.5);
    stas(emg_id,:) = tmp_sta(:,2) - repmat(mean(tmp_sta(:,2)), length(tmp_sta(:,2)), 1);
    tsta = tmp_sta(:,1);
end

n = sqrt(sum(stas.^2));
opt_delay = find(n==max(n), 1, 'first');
opt_delay_t = tsta(opt_delay);

PDm = stas(:, opt_delay);
PDm = PDm ./ sqrt(sum(PDm.^2));

