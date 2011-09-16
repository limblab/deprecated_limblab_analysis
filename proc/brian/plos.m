% plos.m

% Create data table
files = {'Arthur_S1_018.mat', 'mini_bumps_005-6.mat', ...
    'tiki_rw_006.mat', 'Tiki_S1_b_005.mat', 'Pedro_S1_011'};    
%files = {'Arthur_S1_018.mat'};    
prefix = '../../../data_cache/';

letters = {'A', 'M', 'T1', 'T2', 'P'};

ul = cell(1,5);
pd = cell(1,5);
rt = cell(1,5);
fs = cell(1,5);
an = cell(1,5);

tic;
for fno = 1:length(files)
    disp(['  ---   ' files{fno} '   ---   ']);
    load([prefix files{fno}]);
    ult = unit_list(bdf);
    ul{fno} = [repmat(fno,length(ult),1) ult];
    [pd{fno}, rt{fno}, fs{fno}, an{fno}] = co_bump_timing_final(bdf,[],letters{fno});
    clear('bdf');
end
toc

%% Get speed profiles
sp = cell(1,5);

speed_traces = cell(5,4);

tic;
for fno = 1:length(files)
    disp(['  ---   ' files{fno} '   ---   ']);
    load([prefix files{fno}]);    
    [mp,vp,ma,va] = co_bump_speed_profile(bdf,[]);
    figure; hold on;
    plot(mp(:,1), mp(:,2), 'k-', mp(:,1), mp(:,2)+sqrt(vp(:,2)), 'k--', mp(:,1), mp(:,2)-sqrt(vp(:,2)), 'k--')
    plot(ma(:,1), ma(:,2), 'r-', ma(:,1), ma(:,2)+sqrt(va(:,2)), 'r--', ma(:,1), ma(:,2)-sqrt(va(:,2)), 'r--')
    title(files{fno});
    clear('bdf');
    speed_traces{fno,1} = mp;
    speed_traces{fno,2} = vp;
    speed_traces{fno,3} = ma;
    speed_traces{fno,4} = va;
end
toc

p_speed = [speed_traces{1,1}(126,2) speed_traces{2,1}(126,2) speed_traces{3,1}(126,2) speed_traces{4,1}(126,2) speed_traces{5,1}(126,2)];
a_speed = [speed_traces{1,3}(126,2) speed_traces{2,3}(126,2) speed_traces{3,3}(126,2) speed_traces{4,3}(126,2) speed_traces{5,3}(126,2)];
[h,p,ci,stats]=ttest2(a_speed,p_speed)
a_speed2 = [speed_traces{1,3}(76,2) speed_traces{2,3}(76,2) speed_traces{3,3}(76,2) speed_traces{4,3}(76,2) speed_traces{5,3}(76,2)];
p_speed2 = [speed_traces{1,1}(76,2) speed_traces{2,1}(76,2) speed_traces{3,1}(76,2) speed_traces{4,1}(76,2) speed_traces{5,1}(76,2)];
[h,p,ci,stats]=ttest2(a_speed2,p_speed2)

%% Process data table

fss = cell2mat(fs');
pds = cell2mat(pd');
rts = cell2mat(rt');
uls = cell2mat(ul');
%anv = cell2mat(an');

fa = pds(:,3) - pds(:,2) < pi/2;
fp = pds(:,6) - pds(:,5) < pi/2;

fb = fa & fp;
fa = fa & ~fb;
fp = fp & ~fb;
fn = ~fp & ~fa & ~fb;

% Firing rate comparison plot
figure;
%plot(fss(fa,2), fss(fa,4), 'r.', fss(fp,2), fss(fp,4), 'b.', fss(fb,2), fss(fb,4), 'k.', fss(fn,2), fss(fn,4), 'g.')
plot(fss(fa,2), fss(fa,4), 'bo', fss(fp,2), fss(fp,4), 'bo', fss(fb,2), fss(fb,4), 'bo', fss(fn,2), fss(fn,4), 'go')
axis square;
axis([0 35 0 35]);

gph = gca;
set(gph, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Arial');

% PD comparison plot
fpd = pds(fb,:);
figure; hold on;
for id = 1:length(fpd)
    %A = [sqrt(fpd(id,3)-fpd(id,2)), 0; 0, sqrt(fpd(id,6)-fpd(id,5))];
    A = [fpd(id,3)-fpd(id,2), 0; 0, fpd(id,6)-fpd(id,5)];
    C = [fpd(id,1) fpd(id,4)];
    ellipse_plot(A, C);
end

gph = gca;
set(gph, 'Box', 'off', 'XGrid', 'off', 'YGrid', 'off', 'ZGrid', 'off');
set(gph, 'TickDir', 'out', 'FontName', 'Arial');

% Timing plot
ft = rts(:,3)-rts(:,1) < .3 & rts(:,6)-rts(:,4) < .3;
%rtd = rts(fb & ~isnan(rts(:,1)) & ft, :);
rtd = rts(~isnan(rts(:,1)) & ft & rts(:,2) ~= -.495 & rts(:,5) ~= -.495, :);
figure; hold on;
for id = 1:length(rtd)
    A = [(rtd(id,3)-rtd(id,1)), 0; 0, (rtd(id,6)-rtd(id,4))];
    C = [rtd(id,2) rtd(id,5)];
    ellipse_plot(A, C);
end

%plot(rts(fb,2), rts(fb,4), 'k.');

gph = gca;
set(gph, 'Box', 'off', 'XGrid', 'off', 'YGrid', 'off', 'ZGrid', 'off');
set(gph, 'TickDir', 'out', 'FontName', 'Arial');
axis square;

%% Find erronious points
poi = [-0.2530  0.3438;     % OK
       -0.3419 -0.0269;     % remove
       -0.2233 -0.04075;    % remove
       -0.0031 -0.0248;     % OK
        0.0755 -0.0201;     % OK
        0.1270 -0.0639;     % remove - sharp peak, but alg got wrong one
       -0.3114 -0.3523;     % remove - no response
       -0.2234 -0.3855;     % remove
        0.0098 -0.4341;     % remove
        0.1297 -0.3438;     % remove
        0.1369 -0.3499];    % remove


rtsf = rts;
rtsf(isnan(rtsf)) = 1e7;
for i = 1:length(poi)
    point = poi(i,:);
    deltas = rtsf(:,[2 5]) - repmat(point,length(rtsf),1);
    deltas = sqrt(deltas(:,1).^2 + deltas(:,2).^2);
    idx = find(deltas == min(deltas));
    disp(sprintf('%s:\t%d-%d\t% 0.4f % 0.4f', letters{uls(idx,1)}, uls(idx,2), uls(idx,3), ...
        point(1), point(2)));
    filename = sprintf('tmp/%s_%d-%d.fig',letters{uls(idx,1)}, uls(idx,2), uls(idx,3));
    open(filename);
end

%% Eliminate bad histogram points

pt = rts(:,6)-rts(:,4) < .3;
at = rts(:,3)-rts(:,1) < .3;
pooi = rts(:,5)<0 & pt & ~at;

% passive
for idx = 1:length(pooi)
    if pooi(idx)
        disp(sprintf('%s:\t%d-%d\t% 0.4f', letters{uls(idx,1)}, uls(idx,2), uls(idx,3), rts(idx,5)));
        filename = sprintf('tmp/%s_%d-%d.fig',letters{uls(idx,1)}, uls(idx,2), uls(idx,3));
        open(filename);
    end
end

input('press return to continue');
 
% active
aooi = rts(:,2)<0 & rts(:,2)>-.495 & ~isnan(rts(:,2)) & ~pt & at;
for idx = 1:length(aooi)
    if aooi(idx)
        disp(sprintf('%s:\t%d-%d\t% 0.4f', letters{uls(idx,1)}, uls(idx,2), uls(idx,3), rts(idx,2)));
        filename = sprintf('tmp/%s_%d-%d.fig',letters{uls(idx,1)}, uls(idx,2), uls(idx,3));
        open(filename);
    end
end

%% Actual removal

reject_both = [ -0.3419 -0.0269;     % remove
                -0.2233 -0.04075;    % remove
                 0.1270 -0.0639;     % remove - sharp peak, but alg got wrong one
                -0.3114 -0.3523;     % remove - no response
                -0.2234 -0.3855;     % remove
                 0.0098 -0.4341;     % remove
                 0.1297 -0.3438;     % remove
                 0.1369 -0.3499];    % remove

rtsf = rts;
rtsf(isnan(rtsf)) = 1e7;
rjb = []; % reject both
for i = 1:length(reject_both)
    point = reject_both(i,:);
    deltas = rtsf(:,[2 5]) - repmat(point,length(rtsf),1);
    deltas = sqrt(deltas(:,1).^2 + deltas(:,2).^2);
    idx = find(deltas == min(deltas));
    rjb = [rjb, idx];
end
rjb = sort(rjb);

reject_active = [2 37 1; 2 49 1; 2 53 1; 2 57 1; 3 3 1; 4 5 1; 4 92 1; 5 10 1];
rja = [];
for i = 1:length(reject_active)
    ln = reject_active(i,:);
    idx = find(sum(uls == repmat(ln,length(uls),1),2)==3);
    rja = [rja, idx];
end
rja = sort(rja);

rjp = find( (rts(:,5)<0 & rts(:,5)>-.495 & pt & ~at) );

reject = zeros(length(uls),1);
reject(rjb) = 1;
reject(rja) = 1;
reject(rjp) = 1;
reject(abs(rts(:,5))>.49 | abs(rts(:,2))>.49) = 1; % eliminate boundry conditions

figure;
ab = hist(rts( at & pt & ~reject , 2), -.5125:.025:.525); % active both
ao = hist(rts( at & ~pt & ~reject , 2), -.5125:.025:.525); % active only
bar(-.5125:.025:.525, [ab' ao'], 'stacked');

figure;
pb = hist(rts( at & pt & ~reject , 5), -.5125:.025:.525);  % passive both
po = hist(rts( ~at & pt & ~reject , 5), -.5125:.025:.525); % passive only
bar(-.5125:.025:.525, [pb' po'], 'stacked');


%% DW's requested analysis

% Plot PD vs onset time
figure;
subplot(2,2,1), plot(rts(ft,2), pds(ft,1)*180/pi, 'k.'); axis square;
xlabel('active rt'); ylabel('active pd'); axis([-.5 .5 0 360]);
subplot(2,2,2), plot(rts(ft,5), pds(ft,1)*180/pi, 'k.'); axis square;
xlabel('passive rt'); ylabel('active pd'); axis([-.5 .5 0 360]);
subplot(2,2,3), plot(rts(ft,2), pds(ft,4)*180/pi, 'k.'); axis square;
xlabel('active rt'); ylabel('passive pd'); axis([-.5 .5 0 360]);
subplot(2,2,4), plot(rts(ft,5), pds(ft,4)*180/pi, 'k.'); axis square;
xlabel('passive rt'); ylabel('passive pd'); axis([-.5 .5 0 360]);

% See if onset timing or active/passive response differs by location on
% array


% Are PD distributions uniform of all three cell types

figure;
subplot(3,2,1), hist(mod(pds(fa,2),2*pi)*180/pi, 5:10:355);
subplot(3,2,2), hist(mod(pds(fa,4),2*pi)*180/pi, 5:10:355);
subplot(3,2,3), hist(mod(pds(fp,2),2*pi)*180/pi, 5:10:355);
subplot(3,2,4), hist(mod(pds(fp,4),2*pi)*180/pi, 5:10:355);
subplot(3,2,5), hist(mod(pds(fb,2),2*pi)*180/pi, 5:10:355);
subplot(3,2,6), hist(mod(pds(fb,4),2*pi)*180/pi, 5:10:355);


