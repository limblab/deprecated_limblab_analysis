function[COMPS, ts_ISI, D_wave, lda_proj] = KS_p(session,conf)

% This function uses empirical p-value computations to find multi-day
% stable neurons. 
%
% session is a struct containing all pertinent information from each
% session (spiking activity, wave shape, etc.) See Add_session.m for how to
% create this variable

%% Calculate Empirical Test Statistics

% Define functions used for distance calculations
alphafunc = @(xA,xB,a) norm(a*xA - xB)^2;
d1 = @(xA,xB,a) norm(a*xA - xB)/norm(xB);
d2 = @(a) abs(log(a));

% Define variables
alldays = vertcat(session{:});
num_days = length(alldays);
sort_inds = cell(length(alldays),1);

prev_l = 0; % Do terrible i++ indexing...
for i = 1:num_days   % Loop through each day 
    l = length(alldays(i).bdf.units);
    
    % Find the day's unit indices (channel, unit)
    dayids = vertcat(alldays(i).bdf.units.id);
    sort_inds{i}.inds = find(ismember(dayids(:,2),1:10));
    sort_inds{i}.ch_un = dayids(sort_inds{i}.inds);
    
    for j = 1:l % Loop through all of the day's neurons
        % Parse ID, timestamps, and wave shape
        UNITS(j+prev_l).id = alldays(i).bdf.units(j).id;
        UNITS(j+prev_l).ts = alldays(i).bdf.units(j).ts;
        UNITS(j+prev_l).wave = alldays(i).bdf.units(j).wave;
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
    WAVE{i} = UNITS(sorted(i)).wave(1,:);
    
end

IDS = vertcat(UNITS(sorted).id);

% Initialize empty arrays
ts_ISI = [];
D_wave.non = [];
D_wave.put = [];
for i = 1:length(sorted)-1 % Take a neuron
    for j = i+1:length(sorted) % Pair it with another 
        if IDS(j,1)~=IDS(i,1) % If they're not on the same electrode...
           
            %%%% Add to NON-MATCH set %%%%%
            
            % Perform Kolmogorov-Smirnov goodness-of-fit test on the ISIs
            [~,~,k] = kstest2(ISI{i},ISI{j});
            ts_ISI = [ts_ISI k];
    
            fprintf('%d\n',length(ts_ISI));
            
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

for i = 1:num_days % Loop through days
    
    % Initialize
    COMPS{i}.chan = zeros(length(sort_inds{i}.inds),num_days);
    COMPS{i}.inds = zeros(length(sort_inds{i}.inds),num_days);
    
    for j = 1:length(sort_inds{i}.inds) % find ID of unit in day i
        
        % Compile isi/wave information
        index = sort_inds{i}.inds(j);
        chan = sort_inds{i}.ch_un(j,1);
        ISI_1 = diff(alldays(i).bdf.units(index).ts);
        ISI_1 = ISI_1(ISI_1 < 1);
        WAVE_1 = alldays(i).bdf.units(index).wave(1,:);
        
         
        for k = find(1:num_days ~= i) % Look at other days
            % Find units on the same channel    
            same_chan = find(sort_inds{k}.ch_un(:,1) == chan);
            for l = 1:length(same_chan) % For all units on the same electrode
                
                % Compile their isi/wave information
                index2 = sort_inds{k}.inds(same_chan(l));
                sorted_list_ind = find(sort_inds{k}.inds == index2);
                
                ISI_2 = diff(alldays(k).bdf.units(index2).ts);
                ISI_2 = ISI_2(ISI_2 < 1);
                WAVE_2 = alldays(k).bdf.units(index2).wave(1,:);
         
                % Perform KS goodness-of-fit on isi shapes
                [~,~,kSTAT] = kstest2(ISI_1,ISI_2);

                xA = WAVE_1; xB = WAVE_2;

                % Perform optimization to minimize distance between wave
                % shapes. Save both distance metrics.
                alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
                dist_w = [d1(xA,xB,alpha) d2(alpha)];
                
                % Find projection onto line in distance space
                lda_dist = dist_w*coeff(1,2).linear;
                
                % Find p value for ISI using KS statistic
                p_isi = interp1(sortrows(ts_ISI),1:length(ts_ISI),kSTAT)./length(ts_ISI);
                % Find p value for wave shape using linear projection
                p_wave = interp1(sortrows(lda_proj),1:length(lda_proj),...
                    lda_dist,[],'extrap')./length(lda_proj);
            
                % If the combined p value is within specified confidence level 
                if p_isi*p_wave < conf
                    
                    % Link the two as matched neurons
                    COMPS{i}.chan(j,k) = alldays(k).bdf.units(index2).id(1) + ...
                        0.1*alldays(k).bdf.units(index2).id(2);
                    COMPS{i}.inds(j,k) = sorted_list_ind;
                end
            end
        end
    end
end

end


