function[COMPS, ts_ISI, D_wave, lda_proj] = KS_p(session,conf,varargin)

    % This function uses empirical p-value computations to find multi-day
    % stable neurons. 
    %
    % session is a struct containing all pertinent information from each
    % session (spiking activity, wave shape, etc.) See Add_session.m for how to
    % create this variable

    if ~isempty(varargin)
        opts=varargin{1};
    else
        opts=[];
    end
    if isfield(opts,'use_shape')
        use_shape=opts.use_shape;
    else
        use_shape=1;
    end
    if isfield(opts,'use_ISI')
        use_ISI=opts.use_ISI;
    else
        use_ISI=1;
    end
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
        m = length(alldays(i).bdf.units);

        % Find the day's unit indices (channel, unit)
        dayids = vertcat(alldays(i).bdf.units.id);
        sort_inds{i}.inds = find(ismember(dayids(:,2),1:10));
        sort_inds{i}.ch_un = dayids(sort_inds{i}.inds);

        for j = 1:m % Loop through all of the day's neurons
            % Parse ID, timestamps, and wave shape
            UNITS(j+prev_l).id = alldays(i).bdf.units(j).id;
            UNITS(j+prev_l).ts = alldays(i).bdf.units(j).ts;
            UNITS(j+prev_l).wave = alldays(i).bdf.units(j).wave;
        end
        prev_l = prev_l + m; % increment counter
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
    num_units=length(sorted)-1;
    for i = 1:num_units % Take a neuron
        fprintf('generating base comparison data for unit: %d out of: %d units\n',i,num_units)
        for j = i+1:length(sorted) % Pair it with another 
            if IDS(j,1)~=IDS(i,1) % If they're not on the same electrode...

                %%%% Add to NON-MATCH set %%%%%
                if use_ISI
                    % Perform Kolmogorov-Smirnov goodness-of-fit test on the ISIs
                    [~,~,k] = kstest2(ISI{i},ISI{j});
                    ts_ISI = [ts_ISI k];
                end
                %fprintf('%d\n',length(ts_ISI));
                if use_shape
                    % Take wave shape
                    xA = WAVE{i}; 
                    xB = WAVE{j};

                    % Find optimal gain such that the distance between wave shapes
                    % is minimized
                    alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
                    % Calculate distance metrics for wave shape (non-match set)
                    D_wave.non = [D_wave.non ; d1(xA,xB,alpha) d2(alpha)];
                end
            else
                %%%% Add to PUTATIVE MATCH set %%%%%     
                if use_shape
                    xA = WAVE{i}; 
                    xB = WAVE{j};

                    alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
                    % Calculate distance metrics (putative match set)
                    D_wave.put = [D_wave.put ; d1(xA,xB,alpha) d2(alpha)]; 
                end
            end
        end
    end
    % Perform LDA on space containing wave-shape distance metrics
    if use_shape
        [~,~,~,~, coeff] = classify([],[D_wave.non ; D_wave.put],...
            [zeros(length(D_wave.non),1) ; ones(length(D_wave.put),1)]);

        % Find projections of non-match data onto linear term of boundary equation
        lda_proj = D_wave.non*coeff(1,2).linear;
        lda_proj=sort(unique(lda_proj));
        numpts_lda=length(lda_proj);
    end
    %prep ISI variables:
    if use_ISI
        ts_ISI=sort(unique(ts_ISI));
        numpts_ts=length(ts_ISI);
    end
    %% Compare Units
    COMPS = cell(num_days,1);

    for i = 1:num_days % Loop through days
        % Initialize
        COMPS{i}.chan = zeros(length(sort_inds{i}.inds),num_days,2);
        COMPS{i}.inds = zeros(length(sort_inds{i}.inds),num_days);

        for j = 1:length(sort_inds{i}.inds) % find ID of unit in reference (base) day

            % Compile isi/wave information
            index = sort_inds{i}.inds(j);
            chan = sort_inds{i}.ch_un(j,1);
            if use_ISI
                ISI_1 = diff(alldays(i).bdf.units(index).ts);
                ISI_1 = ISI_1(ISI_1 < 1);
            end
            if use_shape
                WAVE_1 = alldays(i).bdf.units(index).wave(1,:);
            end
            % insert index and chan information into column for reference(base)
            % day
            COMPS{i}.chan(j,i,:) = alldays(i).bdf.units(sort_inds{i}.inds(j)).id;
            COMPS{i}.inds(j,i) = index; 
            for k = find(1:num_days ~= i) % Look at other days

                fprintf('comparing day:%d to day:%d \n',i,k)
                % Find units on the same channel    
                same_chan = find(sort_inds{k}.ch_un(:,1) == chan);
                for m = 1:length(same_chan) % For all units on the same electrode
                    index2 = sort_inds{k}.inds(same_chan(m));
                    if use_ISI
                        % Compile their isi information
                        ISI_2 = diff(alldays(k).bdf.units(index2).ts);
                        ISI_2 = ISI_2(ISI_2 < 1);
                        % Perform KS goodness-of-fit on isi shapes
                        [~,~,kSTAT] = kstest2(ISI_1,ISI_2);
                        % Find p value for ISI using KS statistic
                        p_isi = interp1(ts_ISI,1:numpts_ts,kSTAT)./numpts_ts;
                    end
                    if use_shape
                        % Compile their wave information
                        WAVE_2 = alldays(k).bdf.units(index2).wave(1,:);
                        xA = WAVE_1; xB = WAVE_2;

                        % Perform optimization to minimize distance between wave
                        % shapes. Save both distance metrics.
                        alpha = fminsearch(@(a) alphafunc(xA,xB,a),1);
                        dist_w = [d1(xA,xB,alpha) d2(alpha)];

                        % Find projection onto line in distance space
                        lda_dist = dist_w*coeff(1,2).linear;
                        % Find p value for wave shape using linear projection
                        p_wave = interp1(lda_proj,1:numpts_lda,lda_dist,[],'extrap')./numpts_lda;
                    end
                    %find the p value using the appropriate combination of ISI
                    %and shape
                    if use_shape && use_ISI
                        p=p_isi*p_wave;
                    elseif use_shape
                        p=p_wave;
                    elseif use_ISI
                        p=p_isi;
                    else
                        error('KS_p:NoComparisonStat','You have to allow either ISI or shape for comparisons')
                    end
                    % If the p value is within specified confidence level 
                    if p < conf
                        % Link the two as matched neurons
                        COMPS{i}.chan(j,k,:) = [alldays(k).bdf.units(index2).id(1) , ...
                                                alldays(k).bdf.units(index2).id(2)];
                        COMPS{i}.inds(j,k) = sort_inds{k}.inds(sort_inds{k}.inds == index2);
                    end
                end
            end
        end
    end
    %% check for duplicate matches

    for i=1:length(COMPS)
        chanlist=unique(COMPS{i}.inds(:,i));
        for k=1:length(chanlist)
            %find all the rows corresponding to the current inds id
            rowlist=find(COMPS{i}.inds(:,i)==chanlist(k));
            for j=find(1:size(COMPS{i}.chan,2)~=i)
                if length(unique(COMPS{i}.inds(rowlist,j)))~=length(rowlist)
                   warning('KS_p:duplicateMatches',['Duplicate matches found. Multiple units on day: ', num2str(i), ' match unit#: ',num2str(k) ,' on day: ',num2str(j)]) 
                   disp(['the suspect channel is #: ',num2str(COMPS{i}.chan(rowlist(1),i,1))])
                end
            end
        
        end
    end
end

