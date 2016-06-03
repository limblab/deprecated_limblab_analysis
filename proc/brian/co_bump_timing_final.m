function [pd, risetime, fs, an] = co_bump_timing_final(bdf, tt, prefix)
% Draw rasters for the different bump/reach directions sorted by active PD

amiw = [0 .250]; % active movement integration window
pmiw = [0 .125]; % passive movement integration window

fitopts = fitoptions('Method', 'NonlinearLeastSquares',...
    'Lower', [0 0 0], 'Upper', [Inf 2*pi Inf], ...
    'StartPoint', [1 pi 1]);
mdltmplt = fittype('a*cos(x-b)+c', 'options', fitopts);

% get eventsc
if nargin < 3
    prefix = [];
end

if isempty(prefix)
    prefix = 'X';
end

if nargin < 2
    tt = [];
end

if isempty(tt)
    tt = co_trial_table(bdf);
end

nTargets = max(tt(:,5)) + 1;

active_onsets = cell(nTargets,1);
passive_onsets = cell(nTargets,1);
for dir = 0:nTargets-1
    active_onsets{dir+1} = tt( tt(:,10)==double('R') & tt(:,5)==dir & tt(:,2) == -1 , 8);
    passive_onsets{dir+1} = tt( tt(:,3)==double('H') & tt(:,2)==dir, 4);
end

ul = unit_list(bdf);
%ul = [25 1];

pd = zeros(size(ul,1),6);
risetime = zeros(size(ul,1),6);
fs = zeros(size(ul,1),5);
an = zeros(size(ul,1), 4*nTargets);
t = -.5:0.005:1;

for n = 1:size(ul,1)
    disp(n)
    chan = ul(n,1); unit = ul(n,2);
    table = cell(nTargets,1); all = cell(nTargets,1); count = cell(nTargets,1); indv_counts = cell(nTargets,1);
    for dir = 1:nTargets
        h = subplot(nTargets,1,dir);
        [table{dir}, all{dir}] = raster(get_unit(bdf, chan, unit), passive_onsets{dir}, -.75, 1.25, h);
        indv_counts{dir} = table_to_vector(raster(get_unit(bdf, chan, unit), passive_onsets{dir}, pmiw(1), pmiw(2), -1));
        count{dir} = sum(indv_counts{dir});
        axis([ -.5, 1, .5, length(passive_onsets{dir})+.5]);
    end
    res = bootstrap(@vector_sum_pd, indv_counts, 'all', 1000);
    ptune = cprctile(res(:,1),[50 5 95]);

    pas = zeros(nTargets,2);
    for i = 1:nTargets
        pas(i,1) = mean(indv_counts{i}) ./ (pmiw(2)-pmiw(1));
        pas(i,2) = sqrt(var(indv_counts{i}));% / sqrt(length(indv_counts{i}));
    end
    
    out = g_anova(indv_counts);
    %anva(n,1) = out.p;
    
    th = (2*pi*(0:nTargets-1)/nTargets)';
    mdl = fit(th, pas(:,1), mdltmplt);

    % depth of modulation
    aa = cell2mat(all);
    fs(n,1) = sum(aa<0 & aa>-.5)*2/length(cell2mat(passive_onsets)); % baseline
    %fs(n,2) = max(pas(:,1)) - min(pas(:,1));
    fs(n,2) = max(pas(:,1)) - fs(n,1);
    fs(n,3) = mdl.a;
    
    for i = 1:nTargets
        an(n,i+0) = pois_test(sum(aa<0 & aa>-.5), .5*length(cell2mat(passive_onsets)), sum(indv_counts{i}), (pmiw(2)-pmiw(1))*length(indv_counts{i}));
        an(n,i+nTargets) = pois_test(sum(indv_counts{i}), (pmiw(2)-pmiw(1))*length(indv_counts{i}),sum(aa<0 & aa>-.5), .5*length(cell2mat(passive_onsets)));
    end

    try
        pdir = find(max(cell2mat(count)) == cell2mat(count),1);

        ps = zeros(length(table{pdir}), length(t));
        for trial = 1:length(table{pdir})
            for spike = table{pdir}{trial}'
                %ps(trial,:) = ps(trial,:) + exp( - (t-spike).^2 / (2*.03.^2) )./sqrt(2*pi*.03^2);         
                ps(trial,:) = ps(trial,:) + ((t-spike)>0) .* (t-spike) .* exp( -(t-spike) ./ .03 ) ./ .03^2;
            end
        end

        f = @(r) mean(r(ceil(size(r,1)*rand(1,size(r,1))),:));
        psb = [];
        for i = 1:1000
            psb = [psb; f(ps)];
        end

        psbo = prctile(psb, [5 50 95]);

        h=figure;
        shadedplot(t,psbo(1,:),psbo(3,:),[.5 .5 .5], [.5 .5 .5]);
        hold on;
        plot(t, psbo(2,:), 'k-');
        title(sprintf('Passive: %d-%d', chan, unit));
        saveas(h, sprintf('tmp/%s_%d-%d.fig',prefix, chan, unit), 'fig');
        close all;
        
        [beta, ci] = onset_fit(ps);
        prise = [ci(1,1) beta(1) ci(1,2)];
    catch
        prise = [NaN NaN NaN];
    end

    table = cell(nTargets,1);
    all = cell(nTargets,1);
    for dir = 1:nTargets
        h = subplot(nTargets,1,dir);
        [table{dir}, all{dir}] = raster(get_unit(bdf, chan, unit), active_onsets{dir}, -.75, 1.25, h);
        indv_counts{dir} = table_to_vector(raster(get_unit(bdf, chan, unit), active_onsets{dir}, amiw(1), amiw(2), -1));
        count{dir} = sum(indv_counts{dir});
        axis([ -.5, 1, .5, length(active_onsets{dir})+.5]);
    end
    res = bootstrap(@vector_sum_pd, indv_counts, 'all', 1000);
    atune = cprctile(res(:,1),[50 5 95]);
    
    act = zeros(nTargets,2);
    for i = 1:nTargets
        act(i,1) = mean(indv_counts{i}) ./ (amiw(2)-amiw(1));
        act(i,2) = sqrt(var(indv_counts{i}));% / sqrt(length(indv_counts{i}));
    end

    %out = g_anova(indv_counts);
    %anva(n,2) = out.p;
    
    
    
    th = (2*pi*(0:nTargets-1)/nTargets)';
    mdl = fit(th, act(:,1), mdltmplt);

    % depth of modulation
    %fs(n,4) = max(act(:,1)) - min(act(:,1));
    fs(n,4) = max(act(:,1)) - fs(n,1);
    fs(n,5) = mdl.a;
    
    for i = 1:nTargets
        an(n,i+2*nTargets) = pois_test(sum(aa<0 & aa>-.5), .5*length(cell2mat(passive_onsets)), sum(indv_counts{i}), (pmiw(2)-pmiw(1))*length(indv_counts{i}));
        an(n,i+3*nTargets) = pois_test(sum(indv_counts{i}), (pmiw(2)-pmiw(1))*length(indv_counts{i}),sum(aa<0 & aa>-.5), .5*length(cell2mat(passive_onsets)));
    end

    try
        pdir = find(max(cell2mat(count)) == cell2mat(count),1);

        as = zeros(length(table{pdir}), length(t));
        for trial = 1:length(table{pdir})
            for spike = table{pdir}{trial}'
                %as(trial,:) = as(trial,:) + exp( - (t-spike).^2 / (2*.03.^2) )./sqrt(2*pi*.03^2);
                as(trial,:) = as(trial,:) + ((t-spike)>0) .* (t-spike) .* exp( -(t-spike) ./ .03 ) ./ .03^2;
            end
        end

        f = @(r) mean(r(ceil(size(r,1)*rand(1,size(r,1))),:));
        asb = [];
        for i = 1:1000
            asb = [asb; f(as)];
        end

        asbo = prctile(asb, [5 50 95]);

        [beta, ci] = onset_fit(as);
        arise = [ci(1,1) beta(1) ci(1,2)];
    catch
        arise = [NaN NaN NaN];
    end

    pd(n,:) = [atune ptune];
    risetime(n,:) = [arise prise];

%     try
%        figure; hist(ariseb, -1:.005:1);
%        figure; hist(priseb, -1:.005:1);
%     end
end

f = pd(:,2) > pd(:,1);
pd(f,2) = pd(f,2) - 2*pi;
f = pd(:,3) < pd(:,1);
pd(f,3) = pd(f,3) - 2*pi;

f = pd(:,5) > pd(:,4);
pd(f,5) = pd(f,5) - 2*pi;
f = pd(:,6) < pd(:,4);
pd(f,6) = pd(f,4) - 2*pi;




