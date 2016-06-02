% force load comparison

no_load_file = '../../../data_cache/Force/tiki_rw_029.mat';
load_file = '../../../data_cache/Force/tiki_rw_030.mat';

tr = 50;

if 0
    load(no_load_file);
    bdf_n = bdf;

    load(load_file);
    bdf_c = bdf;
    clear bdf;
end

%
% No load
%%%%%%%%%%%%%%%%%%%%%%%%%
forcex = bdf_n.force(:,2);
forcey = bdf_n.force(:,3);
forcex = forcex - mean(forcex);
forcey = forcey - mean(forcey);

s = sqrt(bdf_n.acc(:,2).^2 + bdf_n.acc(:,3).^2);
d = atan2(bdf_n.acc(:,3), bdf_n.acc(:,2));
d = d/pi*180;
Fs = sqrt(forcex.^2 + forcey.^2);
Fd = atan2(forcey, forcex);
Fd = Fd/pi*180;
%f = s > prctile(s,tr) & Fs > prctile(Fs,tr);
f = Fs > prctile(Fs,tr);

Nn = hist3([Fd(f) d(f)], {-175:10:175, -175:10:175});
Nn = Nn ./ repmat(sum(Nn, 2), 1, 36);

figure;
%pcolor(-175:10:175, -175:10:175, Nn);
pcolor([Nn Nn;Nn Nn]);
caxis([0 .20]);


%
% Load
%%%%%%%%%%%%%%%%%%%%%%%%
forcex = bdf_c.force(:,2);
forcey = bdf_c.force(:,3);
forcex = forcex - mean(forcex);
forcey = forcey - mean(forcey);

s = sqrt(bdf_c.acc(:,2).^2 + bdf_c.acc(:,3).^2);
d = atan2(bdf_c.acc(:,3), bdf_c.acc(:,2));
d = d/pi*180;
Fs = sqrt(forcex.^2 + forcey.^2);
Fd = atan2(forcey, forcex);
Fd = Fd/pi*180;
%f = s > prctile(s,tr) & Fs > prctile(Fs,tr);
f = Fs > prctile(Fs,tr);

Nl = hist3([Fd(f) d(f)], {-175:10:175, -175:10:175});
Nl = Nl ./ repmat(sum(Nl, 2), 1, 36);

figure;
%pcolor(-175:10:175, -175:10:175, Nl);
pcolor([Nl Nl;Nl Nl]);
caxis([0 .20]);
