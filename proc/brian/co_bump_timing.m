function [pd, risetime, fs] = co_bump_timing(bdf, tt)
% Draw rasters for the different bump/reach directions sorted by active PD

amiw = [0 .25];  %  active movement integration window
pmiw = [0 .125]; % passive movement integration window

fitopts = fitoptions('Method', 'NonlinearLeastSquares',...
    'Lower', [0 0 0], 'Upper', [Inf 2*pi Inf], ...
    'StartPoint', [1 pi 1]);
mdltmplt = fittype('a*cos(x-b)+c', 'options', fitopts);

% get eventsc
%tt = co_trial_table(bdf);

active_onsets = cell(4,1);
passive_onsets = cell(4,1);
for dir = 0:3
    active_onsets{dir+1} = tt( tt(:,10)==double('R') & tt(:,5)==dir & tt(:,2) == -1 , 8);
    passive_onsets{dir+1} = tt( tt(:,3)==double('H') & tt(:,2)==dir, 4);
end

ul = unit_list(bdf);
%ul = [13 1];
%ul = [80 2];

pd = zeros(size(ul,1),6);
risetime = zeros(size(ul,1),6);
fs = zeros(size(ul,1),2);
t = -.5:0.005:1;

% for loop (eventually)
for n = 1:size(ul,1)
    disp(n)
    chan = ul(n,1); unit = ul(n,2);
    table = cell(4,1); all = cell(4,1); count = cell(4,1); indv_counts = cell(4,1);
    figure; suptitle(sprintf('Passive: %d-%d', chan, unit));
    for dir = 1:4
        h = subplot(4,1,dir);
        [table{dir}, all{dir}] = raster(get_unit(bdf, chan, unit), passive_onsets{dir}, -.75, 1.25, h);
        indv_counts{dir} = table_to_vector(raster(get_unit(bdf, chan, unit), passive_onsets{dir}, pmiw(1), pmiw(2), -1));
        count{dir} = sum(indv_counts{dir});
        axis([ -.5, 1, .5, length(passive_onsets{dir})+.5]);
    end
    res = bootstrap(@vector_sum_pd, indv_counts, 'all', 1000);
    ptune = cprctile(res(:,1),[50 5 95]);

    pas = zeros(4,2);
    for i = 1:4
        pas(i,1) = mean(indv_counts{i}) ./ (pmiw(2)-pmiw(1));
        pas(i,2) = sqrt(var(indv_counts{i})) / sqrt(length(indv_counts{i}));
    end
        
    mdl = fit([0 0.5*pi pi 1.5*pi]', pas(:,1), mdltmplt);
    figure; errorbar([0 90 180 270], pas(:,1), pas(:,2), 'ko');
    hold on;
    plot(-45:315, mdl((-45:315).*pi./180), 'k--');
    title(sprintf('Passive: %d-%d', chan, unit));
    
    % Save F statistic
    %out = g_anova(indv_counts);
    %fs(n,2) = out.F;
    fs(n,2) = max(pas(:,1));

    try
        pdir = find(max(cell2mat(count)) == cell2mat(count),1);

        %ps = zeros(size(t));
        %for spike = all{pdir}'
        %    ps = ps + exp( - (t-spike).^2 / (2*.03.^2) );
        %end
        
        ps = zeros(length(table{pdir}), length(t));
        for trial = 1:length(table{pdir})
            for spike = table{pdir}{trial}'
                ps(trial,:) = ps(trial,:) + exp( - (t-spike).^2 / (2*.03.^2) );
            end
        end
        
        f = @(r) mean(r(ceil(size(r,1)*rand(1,size(r,1))),:));
        psb = [];
        for i = 1:1000
            psb = [psb; f(ps)];
        end
        
        psbo = prctile(psb, [2.5 50 97.5]);
        figure; hold on; plot(t,psbo(2,:),'k-'); plot(t,psbo(1,:),'b-'); plot(t,psbo(3,:),'b-'); 
        %stderr = sqrt(var(ps));%./sqrt(size(ps,1));
        %figure; hold on; plot(t,mean(ps),'k-'); plot(t,mean(ps)-stderr,'b-'); plot(t,mean(ps)+stderr,'b-'); 
        title(sprintf('Passive: %d-%d', chan, unit));
        priseb = zeros(1,size(psb,1));
        thr = mean(mean(psb(:,1:50))) + 2*sqrt(var(reshape(psb(:,1:50),1,[])));        
        for i = 1:1000
            %thr = (max(psb(i,:)) - mean(psb(i,1:50)))/2 + mean(psb(i,1:50));    
            priseb(i) = t(find(psb(i,:)<thr & t<t(psb(i,:)==max(psb(i,:))),1,'last')+1);
        end
        prise = prctile(priseb, [2.5 50 97.5]);
    catch
        prise = [NaN NaN NaN];
    end
    
    table = cell(4,1);
    all = cell(4,1);
    figure; suptitle(sprintf('Active: %d-%d', chan, unit));
    for dir = 1:4
        h = subplot(4,1,dir);
        [table{dir}, all{dir}] = raster(get_unit(bdf, chan, unit), active_onsets{dir}, -.75, 1.25, h);
        indv_counts{dir} = table_to_vector(raster(get_unit(bdf, chan, unit), active_onsets{dir}, amiw(1), amiw(2), -1));
        count{dir} = sum(indv_counts{dir});
        axis([ -.5, 1, .5, length(active_onsets{dir})+.5]);
    end
    res = bootstrap(@vector_sum_pd, indv_counts, 'all', 1000);
    atune = cprctile(res(:,1),[50 5 95]);

    act = zeros(4,2);
    for i = 1:4
        act(i,1) = mean(indv_counts{i}) ./ (amiw(2)-amiw(1));
        act(i,2) = sqrt(var(indv_counts{i})) / sqrt(length(indv_counts{i}));
    end
    
    mdl = fit([0 0.5*pi pi 1.5*pi]', act(:,1), mdltmplt);
    figure; errorbar([0 90 180 270], act(:,1), act(:,2), 'ko');
    hold on;
    plot(-45:315, mdl((-45:315).*pi./180), 'k--');
    title(sprintf('Active: %d-%d', chan, unit));
    
    % Save F statistic
    %out = g_anova(indv_counts);
    %fs(n,1) = out.F;
    fs(n,1) = max(act(:,1));
    
    try
        pdir = find(max(cell2mat(count)) == cell2mat(count));
        
        %as = hist(all{pdir}, t);
        %as = smooth(as,5);
        
        %as = zeros(size(t));
        %for spike = all{pdir}'
        %    as = as + exp( - (t-spike).^2 / (2*.03.^2) );
        %end
        
        
        %figure; plot(t,as); title(sprintf('Active: %d-%d', chan, unit));
        
        as = zeros(length(table{pdir}), length(t));
        for trial = 1:length(table{pdir})
            for spike = table{pdir}{trial}'
                as(trial,:) = as(trial,:) + exp( - (t-spike).^2 / (2*.03.^2) );
            end
        end

        f = @(r) mean(r(ceil(size(r,1)*rand(1,size(r,1))),:));
        asb = [];
        for i = 1:1000
            asb = [asb; f(as)];
        end
        
        asbo = prctile(asb, [5 50 95]);
        figure; hold on; plot(t,asbo(2,:),'k-'); plot(t,asbo(1,:),'b-'); plot(t,asbo(3,:),'b-'); 
        %stderr = sqrt(var(as));%./sqrt(size(as,1));
        %figure; hold on; plot(t,mean(as),'k-'); plot(t,mean(as)-stderr,'b-'); plot(t,mean(as)+stderr,'b-'); 
        title(sprintf('Active: %d-%d', chan, unit));
        
        ariseb = zeros(1,size(psb,1));
        thr = mean(mean(asb(:,1:50))) + 2*sqrt(var(reshape(asb(:,1:50),1,[])));
        for i = 1:1000
            %thr = (max(asb(i,:)) - mean(asb(i,1:50)))/2 + mean(asb(i,1:50));    
            %ariseb(i) = t(find(asb(i,:)<thr & t<t(asb(i,:)==max(asb(i,:))),1,'last')+1);
            ariseb(i) = t(find(asb(i,:)<thr & t<t(asb(i,:)==max(asb(i,:))),1,'last')+1);
        end        
        arise = prctile(ariseb, [2.5 50 97.5]);
    catch
        arise = [NaN NaN NaN];
    end
    
    pd(n,:) = [atune ptune];
    risetime(n,:) = [arise prise];
    
    close all;
    
    try
        figure; hist(ariseb, -1:.005:1);
        figure; hist(priseb, -1:.005:1);
    end
end

f = pd(:,2) > pd(:,1);
pd(f,2) = pd(f,2) - 2*pi;
f = pd(:,3) < pd(:,1);
pd(f,3) = pd(f,3) - 2*pi;

f = pd(:,5) > pd(:,4);
pd(f,5) = pd(f,5) - 2*pi;
f = pd(:,6) < pd(:,4);
pd(f,6) = pd(f,4) - 2*pi;
