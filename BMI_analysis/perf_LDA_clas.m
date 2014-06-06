function [states,Coeffs] = perf_LDA_clas(spikes,bin_length,vel,vel_thresh)

window = 0.500; % in seconds (for spike averaging)
window_bins = floor(window/bin_length); % calculate # of bins in window

observations = DuplicateAndShift(spikes,window_bins); % build training set
group = vel > vel_thresh; % assign training classes
bootstrapped = 0;

if ~bootstrapped
    [a,b,c,d,coeff0] = classify(observations(1,:),observations,group,'linear',[0.7 0.3]); % calculate coefficients for posture state
    coeff0 = coeff0(1,2);
    [a,b,c,d,coeff1] = classify(observations(1,:),observations,group,'linear',[0.3 0.7]); % calculate coefficients for movement state
    coeff1 = coeff1(1,2);
else
    num_cycles = 100;
    coeff0 = {};
    coeff1 = {};
    [~,~,~,~,coeff_all] = classify(observations(1,:),observations,group,'linear',[0.7 0.3]); % calculate coefficients for posture state

    for i=1:num_cycles
        disp(['LDA cycle: ' num2str(i) ' of ' num2str(num_cycles)])
        new_group = int32(group);
        remove_idx = randperm(size(new_group,1));
        new_group(remove_idx(1:floor(.4*size(observations,1)))) = nan;
        [~,~,~,~,coeff0{i}] = classify(observations(1,:),observations,new_group,'linear',[0.7 0.3]); % calculate coefficients for posture state
        [~,~,~,~,coeff1{i}] = classify(observations(1,:),observations,new_group,'linear',[0.3 0.7]); % calculate coefficients for posture state
    end
    coeff0_mean = []; 
    const0_mean = [];
    coeff1_mean = []; 
    const1_mean = [];
    figure; 
    hold on; 
    for i=1:num_cycles
        plot(coeff0{i}(1,2).linear) 
        coeff0_mean(:,end+1) = coeff0{i}(1,2).linear; 
        const0_mean(end+1) = coeff0{i}(1,2).const;
        coeff1_mean(:,end+1) = coeff1{i}(1,2).linear; 
        const1_mean(end+1) = coeff1{i}(1,2).const;
    end
    coeff0_mean = mean(coeff0_mean,2);
    const0_mean = mean(const0_mean);
    coeff1_mean = mean(coeff1_mean,2);
    const1_mean = mean(const1_mean);

    coeff0 = coeff0{1}(1,2);
    coeff0.linear = coeff0_mean;
    coeff0.const = const0_mean;
    coeff1 = coeff1{1}(1,2);
    coeff1.linear = coeff1_mean;
    coeff1.const = const1_mean;

    plot(coeff0_mean,'r')
    plot(coeff_all(1,2).linear,'k')
end

Coeffs = {coeff0,coeff1};

states = zeros(size(spikes,1),1); % initialize states

for x = 2:size(observations,1)
    if states(x-1) == 0
        states(x) = 0 >= observations(x,:)*coeff0.linear + coeff0.const; % predict states following posture state
    else
        states(x) = 0 >= observations(x,:)*coeff1.linear + coeff1.const; % predict states following movement state
    end
end