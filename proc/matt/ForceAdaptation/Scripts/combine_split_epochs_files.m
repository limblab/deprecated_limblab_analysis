clear;
clc;

d1 = load('F:\MrT\Processed\2013-08-21\CO_FF_AD1_2013-08-21.mat');
d2 = load('F:\MrT\Processed\2013-08-21\CO_FF_AD2_2013-08-21.mat');
dt = 0.001;

%    1: Start time
%    2: Target ID                 -- -1 for none
%`   3: Target angle (rad)
%    4-7: Target location (ULx ULy LRx LRy) NOTE: THIS IS BROKEN AND JUST RETURNS [-1 -1 -1 -1] FOR NOW
%    8: OT on time
%    9: Go cue
%    10: Movement start time
%    11: Peak speed time
%    12: Movement end time
%    13: Trial End time
%    14: Reward or not

t1 = d1.cont.t(end);

d2.cont.t = d2.cont.t + t1 - 1 + dt;
d2.movement_table(:,2:end) = d2.movement_table(:,2:end) + t1 - 1 + dt;
d2.trial_table(:,[1,8,9,10,11,12,13]) = d2.trial_table(:,[1,8,9,10,11,12,13]) + t1 - 1 + dt;
for i = 1:length(d2.M1.units)
    d2.M1.units(i).ts = d2.M1.units(i).ts + t1 - 1 + dt;
end
for i = 1:length(d2.PMd.units)
    d2.PMd.units(i).ts = d2.PMd.units(i).ts + t1 - 1 + dt;
end

d.params = d1.params;
d.meta = d1.meta; d.meta.epoch = 'AD';
d.trial_table = [d1.trial_table; d2.trial_table];
d.movement_table = [d1.movement_table; d2.movement_table];
d.movement_centers = [d1.movement_centers; d2.movement_centers];
d.cont.t = [d1.cont.t; d2.cont.t];
d.cont.force = [d1.cont.force; d2.cont.force];
d.cont.pos = [d1.cont.pos; d2.cont.pos];
d.cont.vel = [d1.cont.vel; d2.cont.vel];
d.cont.acc = [d1.cont.acc; d2.cont.acc];

badUnits = checkUnitGuides(d1.M1.sg,d2.M1.sg);
sg = setdiff(d1.M1.sg, badUnits, 'rows');

for i = 1:length(d1.M1.units)
    idx1 = d1.M1.sg(:,1)==sg(i,1) & d1.M1.sg(:,2)==sg(i,2);
    idx2 = d2.M1.sg(:,1)==sg(i,1) & d2.M1.sg(:,2)==sg(i,2);
    
    u(i).id = d1.M1.units(idx1).id;
    u(i).wf = [d1.M1.units(idx1).wf,d2.M1.units(idx2).wf];
    u(i).ts = [d1.M1.units(idx1).ts, d2.M1.units(idx2).ts];
    u(i).ns = d1.M1.units(idx1).ns + d2.M1.units(idx2).ns;
    u(i).p2p = d1.M1.units(idx1).p2p;
    u(i).misi = d1.M1.units(idx1).misi;
    u(i).mfr = d1.M1.units(idx1).mfr;
    u(i).offline_sorter_channel = d1.M1.units(idx1).offline_sorter_channel;
end
d.M1.units = u;
d.M1.sg = sg;

badUnits = checkUnitGuides(d1.PMd.sg,d2.PMd.sg);
sg = setdiff(d1.PMd.sg, badUnits, 'rows');

clear u;
for i = 1:length(sg)
    
    idx1 = d1.PMd.sg(:,1)==sg(i,1) & d1.PMd.sg(:,2)==sg(i,2);
    idx2 = d2.PMd.sg(:,1)==sg(i,1) & d2.PMd.sg(:,2)==sg(i,2);
    
    u(i).id = d1.PMd.units(idx1).id;
    u(i).wf = [d1.PMd.units(idx1).wf,d2.PMd.units(idx2).wf];
    u(i).ts = [d1.PMd.units(idx1).ts, d2.PMd.units(idx2).ts];
    u(i).ns = d1.PMd.units(idx1).ns + d2.PMd.units(idx2).ns;
    u(i).p2p = d1.PMd.units(idx1).p2p;
    u(i).misi = d1.PMd.units(idx1).misi;
    u(i).mfr = d1.PMd.units(idx1).mfr;
    u(i).offline_sorter_channel = d1.PMd.units(idx1).offline_sorter_channel;
end
d.PMd.units = u;
d.PMd.sg = sg;

save('F:\MrT\Processed\2013-08-21\CO_FF_AD_2013-08-21.mat','-struct','d');