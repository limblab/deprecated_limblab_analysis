function [pd, risetime, fs] = co_bump_timing_new(bdf, tt)
% Draw rasters for the different bump/reach directions sorted by active PD

amiw = [0 .25];  % active movement integration window
pmiw = [0 .125]; % passive movement integration window

fitopts = fitoptions('Method', 'NonlinearLeastSquares',...
    'Lower', [0 0 0], 'Upper', [Inf 2*pi Inf], ...
    'StartPoint', [1 pi 1]);
mdltmplt = fittype('a*cos(x-b)+c', 'options', fitopts);

% get eventsc
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

%h1 = figure;

%ul = unit_list(bdf);
ul = [13 1; 34 1; 95 1; 61 1]; % example set
%ul = [53 1];
%ul = [17 1];
%ul = [34 1; 88 1; 95 2];
%ul = [5 1];
%ul = [7 1];
%ul = [34 1; 88 1; 95 2; 13 1; 80 2];
%ul = [13 1];
%ul = [34 1];
%ul = [80 2];

%ul = [30 2; 35 1; 41 1;86 1];
%ul = [55 1];
%ul = [61 1];
ul = [13 1];

pd = zeros(size(ul,1),6);
risetime = zeros(size(ul,1),6);
fs = zeros(size(ul,1),2);
t = -.5:0.005:1;

% for loop (eventually)
for n = 1:size(ul,1)
    disp(n)
    chan = ul(n,1); unit = ul(n,2);
    table = cell(nTargets,1); all = cell(nTargets,1); count = cell(nTargets,1); indv_counts = cell(nTargets,1);
    figure; suptitle(sprintf('Passive: %d-%d', chan, unit));
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

    th = (2*pi*(0:nTargets-1)/nTargets)';
    mdl = fit(th, pas(:,1), mdltmplt);
    figure; errorbar(th*180/pi, pas(:,1), pas(:,2), 'ko');

    hold on;
    plot(-45:315, mdl((-45:315).*pi./180), 'k--');
    title(sprintf('Passive: %d-%d', chan, unit));

    % Save F statistic
    %out = g_anova(indv_counts);
    %fs(n,2) = out.F;
    
    %fs(n,2) = max(pas(:,1));
    fs(n,2) = max(pas(:,1)) - min(pas(:,1));

    try
        pdir = find(max(cell2mat(count)) == cell2mat(count),1);

        %figure(h1); 
        %h2 = subplot(5,2,2*(n-1)+1);
        %raster(get_unit(bdf, chan, unit), passive_onsets{pdir}, -.75, .75, h2);
        %axis([ -.5, .5, .5, length(passive_onsets{pdir})+.5]);
        
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
        %figure; hold on; plot(t,psbo(2,:),'k-'); plot(t,psbo(1,:),'b-'); plot(t,psbo(3,:),'b-'); 
        figure;
        shadedplot(t,psbo(1,:),psbo(3,:),[.5 .5 .5], [.5 .5 .5]);
        hold on;
        plot(t, psbo(2,:), 'k-');
        
        %stderr = sqrt(var(ps));%./sqrt(size(ps,1));
        %figure; hold on; plot(t,mean(ps),'k-'); plot(t,mean(ps)-stderr,'b-'); plot(t,mean(ps)+stderr,'b-'); 
        title(sprintf('Passive: %d-%d', chan, unit));

        figure;
%        [beta, ci] = onset_fit(table{pdir});
        [beta, ci] = onset_fit(ps);
        prise = [ci(1,1) beta(1) ci(1,2)];        
    catch
        prise = [NaN NaN NaN];
    end

    table = cell(nTargets,1);
    all = cell(nTargets,1);
    figure; suptitle(sprintf('Active: %d-%d', chan, unit));
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

    th = (2*pi*(0:nTargets-1)/nTargets)';
    mdl = fit(th, act(:,1), mdltmplt);
    figure; errorbar(th*180/pi, act(:,1), act(:,2), 'ko');
    hold on;
    plot(-45:315, mdl((-45:315).*pi./180), 'k--');
    title(sprintf('Active: %d-%d', chan, unit));

    % Save F statistic
    %out = g_anova(indv_counts);
    %fs(n,1) = out.F;
    
    %fs(n,1) = max(act(:,1));
    fs(n,1) = max(act(:,1)) - min(act(:,1));

    try
        pdir = find(max(cell2mat(count)) == cell2mat(count),1);

        
        %figure(h1); 
        %h2 = subplot(5,2,2*(n-1)+2);
        %raster(get_unit(bdf, chan, unit), active_onsets{pdir}, -.75, .75, h2);
        %axis([ -.5, .5, .5, length(active_onsets{pdir})+.5]);
        
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
        %figure; hold on; plot(t,asbo(2,:),'k-'); plot(t,asbo(1,:),'b-'); plot(t,asbo(3,:),'b-'); 
        figure;
        shadedplot(t,asbo(1,:),asbo(3,:),[.5 .5 .5], [.5 .5 .5]);
        hold on;
        plot(t, asbo(2,:), 'k-');

        title(sprintf('Active: %d-%d', chan, unit));

        figure;
        %[beta, ci] = onset_fit(table{pdir});        
        [beta, ci] = onset_fit(as);
        arise = [ci(1,1) beta(1) ci(1,2)];
    catch
        arise = [NaN NaN NaN];
    end

    pd(n,:) = [atune ptune];
    risetime(n,:) = [arise prise];

    %close all;

    %try
    %    figure; hist(ariseb, -1:.005:1);
    %    figure; hist(priseb, -1:.005:1);
    %end
end

f = pd(:,2) > pd(:,1);
pd(f,2) = pd(f,2) - 2*pi;
f = pd(:,3) < pd(:,1);
pd(f,3) = pd(f,3) - 2*pi;

f = pd(:,5) > pd(:,4);
pd(f,5) = pd(f,5) - 2*pi;
f = pd(:,6) < pd(:,4);
pd(f,6) = pd(f,4) - 2*pi;
