function[COMPS, ts_ISI, D_wave, lda_proj] = KS_p(data,conf)
% KS_p  Run empirical KS test to check for stability of neurons
%
%   This function uses empirical p-value computations to find multi-day
% stable neurons.
%
% INPUTS:
%   data: (struct) Matt's proprietary data struct
%   conf: (double) confidence level (e.g. 0.95)
%
% OUTPUTS:
%   COMPS: somewhat unintuitive description of which neuron matched which
%   ts_ISI: emprical test statistic distribution
%   D_wave: distance distribution for waveforms
%   lda_proj: projection with LDA from distance space
%
% NOTES:
%

%% Calculate Empirical Test Statistics

% Define functions used for distance calculations
alphafunc = @(xA,xB,a) norm(a*xA - xB)^2;
d1 = @(xA,xB,a) norm(a*xA - xB)/norm(xB);
d2 = @(a) abs(log(a));

if ~iscell(data)
    error('nofiles');
end

% session is cell array of my data structs
num_days = length(data);

% Define variables
num_days = length(data);
sort_inds = cell(length(data),1);

prev_l = 0; % Do terrible i++ indexing...
for i = 1:num_days   % Loop through each day
    dayids = data{i}.unit_guide;
    
    l = size(dayids,1);
    
    % Find the day's unit indices (channel, unit)
    sort_inds{i}.inds = find(ismember(dayids(:,2),1:10));
    sort_inds{i}.ch_un = dayids(sort_inds{i}.inds,:);
    
    for j = 1:l % Loop through all of the units
        % Parse ID, timestamps, and wave shape
        UNITS(j+prev_l).id = dayids(j,:);
        UNITS(j+prev_l).ts = data{i}.units.(['elec' num2str(dayids(j,1))]).(['unit' num2str(dayids(j,2))]).ts;
        UNITS(j+prev_l).wave = mean(data{i}.units.(['elec' num2str(dayids(j,1))]).(['unit' num2str(dayids(j,2))]).wf,2);
    end
    prev_l = prev_l + l; % increment counter
end


% Combine all unit IDs
ids = vertcat(UNITS.id);
sorted = find(ismember(ids(:,2),1:5));

for i  = 1:length(sorted) % Loop through units from ALL days
    
    % Find ISI, waveshape --> Store
    isi = diff(UNITS(sorted(i)).ts);
    ISI{i} = isi(isi < 1);
    WAVE{i} = UNITS(sorted(i)).wave;
    
end

IDS = vertcat(UNITS(sorted).id);

disp('Building empirical test distribution...')
% Initialize empty arrays
ts_ISI = [];
D_wave.non = [];
D_wave.put = [];
for i = 1:length(sorted)-1 % Take a neuron
    for j = i+1:length(sorted) % Pair it with another
        if IDS(j,1)~=IDS(i,1) % If they're not on the same electrode...
            
            %%%% Add to NON-MATCH set %%%%%
            if ~isempty(ISI{i}) && ~isempty(ISI{j})
                % Perform Kolmogorov-Smirnov goodness-of-fit test on the ISIs
                [~,~,k] = kstest2(ISI{i},ISI{j});
                ts_ISI = [ts_ISI k];
            end
            
            %             fprintf('%d\n',length(ts_ISI));
            
            % Take wave shape
            xA = WAVE{i};
            xB = WAVE{j};
            
            % Find optimal gain such that the distance between wave shapes
            % is minimized
            alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
            % Calculate distance metrics for wave shape (non-match set)
            D_wave.non = [D_wave.non ; d1(xA,xB,alpha) d2(alpha)];
        else
            %%%% Add to PUTATIVE MATCH set %%%%%
            xA = WAVE{i};
            xB = WAVE{j};
            
            alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
            % Calculate distance metrics (putative match set)
            D_wave.put = [D_wave.put ; d1(xA,xB,alpha) d2(alpha)];
        end
    end
end

% Perform LDA on space containing wave-shape distance metrics
[~,~,~,~, coeff] = classify([],[D_wave.non ; D_wave.put],...
    [zeros(length(D_wave.non),1) ; ones(length(D_wave.put),1)]);

% Find projections of non-match data onto linear term of boundary equation
lda_proj = D_wave.non*coeff(1,2).linear;

%% Compare Units
COMPS = cell(num_days,1);
disp('Comparing units...')
for i = 1:num_days % Loop through days
    
    % Initialize
    COMPS{i}.chan = zeros(length(sort_inds{i}.inds),num_days);
    COMPS{i}.inds = zeros(length(sort_inds{i}.inds),num_days);
    COMPS{i}.p_isi = zeros(length(sort_inds{i}.inds),num_days);
    COMPS{i}.p_wave = zeros(length(sort_inds{i}.inds),num_days);
    
    for j = 1:length(sort_inds{i}.inds) % find ID of unit in day i
        
        % Compile isi/wave information
        chan = sort_inds{i}.ch_un(j,1);
        unit = sort_inds{i}.ch_un(j,2);
        ISI_1 = diff(data{i}.units.(['elec' num2str(chan)]).(['unit' num2str(unit)]).ts);
        ISI_1 = ISI_1(ISI_1 < 1);
        WAVE_1 = mean(data{i}.units.(['elec' num2str(chan)]).(['unit' num2str(unit)]).wf,2);
        
        COMPS{i}.chan(j,i) = data{i}.units.(['elec' num2str(chan)]).(['unit' num2str(unit)]).id(1) + 0.1*data{i}.units.(['elec' num2str(chan)]).(['unit' num2str(unit)]).id(2);
        
        for k = find(1:num_days ~= i) % Look at other days
            % Find units on the same channel
            same_chan = find(sort_inds{k}.ch_un(:,1) == chan);
            for l = 1:length(same_chan) % For all units on the same electrode
                
                % Compile their isi/wave information
                index2 = sort_inds{k}.inds(same_chan(l));
                sorted_list_ind = find(sort_inds{k}.inds == index2);
                chan2 = sort_inds{k}.ch_un(same_chan(l),1);
                unit2 = sort_inds{k}.ch_un(same_chan(l),2);
                
                ISI_2 = diff(data{k}.units.(['elec' num2str(chan2)]).(['unit' num2str(unit2)]).ts);
                ISI_2 = ISI_2(ISI_2 < 1);
                WAVE_2 = mean(data{k}.units.(['elec' num2str(chan2)]).(['unit' num2str(unit2)]).wf,2);
                
                % Perform KS goodness-of-fit on isi shapes
                if ~isempty(ISI_1) && ~isempty(ISI_2)
                    [~,~,kSTAT] = kstest2(ISI_1,ISI_2);
                else
                    kSTAT = 1;
                end
                
                xA = WAVE_1; xB = WAVE_2;
                
                % Perform optimization to minimize distance between wave
                % shapes. Save both distance metrics.
                alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
                dist_w = [d1(xA,xB,alpha) d2(alpha)];
                
                % Find projection onto line in distance space
                lda_dist = dist_w*coeff(1,2).linear;
                
                % Find p value for ISI using KS statistic
                p_isi = interp1(sortrows(ts_ISI'),1:length(ts_ISI),kSTAT,'linear')./length(ts_ISI);
                if isnan(p_isi)
                    p_isi = interp1(sortrows(ts_ISI'),1:length(ts_ISI),kSTAT,'linear','extrap')./length(ts_ISI);
                end
                
                % Find p value for wave shape using linear projection
                p_wave = interp1(sortrows(lda_proj),1:length(lda_proj),...
                    lda_dist,'linear','extrap')./length(lda_proj);
                
                % If the combined p value is within specified confidence level
                if p_isi*p_wave < conf % p_isi < conf && p_wave < conf
                    % Link the two as matched neurons
                    COMPS{i}.chan(j,k) = chan2 + 0.1*unit2;
                    COMPS{i}.inds(j,k) = sorted_list_ind;
                    COMPS{i}.p_isi(j,k) = p_isi;
                    COMPS{i}.p_wave(j,k) = p_wave;
                elseif chan==chan2 && unit==unit2
                    COMPS{i}.p_isi(j,k) = p_isi;
                    COMPS{i}.p_wave(j,k) = p_wave;
                end
                
            end
        end
        
    end
    COMPS{i}.sg = dayids;
end

end


