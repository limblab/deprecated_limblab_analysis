function emg_onset_timing(bdf, tt)
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

sbp = 1;
earliest = ones(1,9);
for emg_id = [9:11 13:18]
    disp(bdf.raw.analog.channels{emg_id})

    % Extract Data
    adfreq = bdf.raw.analog.adfreq(emg_id);
    emg_t = bdf.raw.analog.ts{emg_id} + (1:length(bdf.raw.analog.data{emg_id})) / adfreq;
    emg_data = interp1(emg_t, bdf.raw.analog.data{emg_id}, bdf.vel(:,1));
    gscale = sqrt(var(emg_data));
    
    % Filter EMG
    [b,a] = butter(6, 2/adfreq, 'high');
    emg_data = filter(b,a,emg_data);
    emg_data = abs(emg_data);
    [b,a] = butter(6, 30/adfreq, 'low');
    emg_data = filter(b,a,emg_data);

    % Get trial
    acti = zeros(nTargets,6251);
    ed = ones(1, nTargets);
    %figure; hold on;
    for direction = 1:nTargets
        avd = zeros(6251,1);
        count = 0;

        for trial = 2:length(active_onsets{direction});
            onset = active_onsets{direction}(trial);
            if isnan(onset)
                continue;
            end
            start = find(bdf.vel(:,1) > onset - 1.5, 1);
            stop = find(bdf.vel(:,1) > onset + 1, 1);
            t = emg_t(start:stop);
            d = emg_data(start:stop);

            % Average emgs
            %d = cumsum(d - mean(d(1:2500)));
            avd = avd + d;
            count = count + 1;
        end

        trs = avd/count;
        %plot(-1.5:(1/2500):1, trs);
        acti(direction,:) = trs;
        thr = mean(trs(1:1250)) + 2*sqrt(var(trs(1:1250)));
        f = find(trs>thr,1,'first');
        if ~isempty(f)
            ed(direction) = f;
        end
    end
    
    %title(bdf.raw.analog.channels{emg_id});
    
    acti = sqrt(var(acti));
    acti = acti ./ sqrt(var(emg_data));
    t = -1.5:(1/2500):1;
    ths = acti - mean(acti(1:1250));
    ths = cumsum(ths);
    thr = mean(ths(1251:2500)) + 2*sqrt(var(ths(1251:2500)));
    
    f = find(ths>thr,1,'first');
    if ~isempty(f)
        earliest(sbp) = t(f);
    end
    
    subplot(3,3,sbp), plot(t, acti, 'k-');
    title(bdf.raw.analog.channels{emg_id});
        
    sbp=sbp+1;
end

disp(earliest)





