function [states,statemethods,classifiers] = findStates(binnedData,varargin)
% [states,statemethods,classifiers] = findStates(binnedData,varargin)
%
% BINNEDDATA is the binnedData file to classify.
% VARARGIN contains GT_THRESH followed by numbers (1-5) of classifiers to use.
% GT_THRESH is the velocity threshold used to define ground truth states, if
% less than or equal to zero use defaulth GT_THRESH.
% If VARARGIN is empty, use default GT_THRESH and all classifiers.
% STATES and STATEMETHODS will contain classifier output in these columns
% (which are also identifiers for them in VARARGIN):
%   1 - velocity threshold
%   2 - perfect Bayes
%   3 - peak Bayes
%   4 - perfect LDA
%   5 - peak LDA

    GT_thresh = 8; %cm/sec
    vel_thresh = 0;
    perf_bayes = 0;
    peak_bayes = 0;
    perf_LDA = 0;
    peak_LDA = 0;

    if nargin > 1 && varargin{1} > 0;
        GT_thresh = varargin{1}; %cm/sec
    end

    if nargin < 3
        vel_thresh = 1;
        perf_bayes = 1;
        peak_bayes = 1;
        perf_LDA = 1;
        peak_LDA = 1;
    else
        for x = 2:length(varargin)
            if varargin{x} == 1
                vel_thresh = 1;
            elseif varargin{x} == 2
                perf_bayes = 1;
            elseif varargin{x} == 3
                peak_bayes = 1;
            elseif varargin{x} == 4
                perf_LDA = 1;
            elseif varargin{x} == 5
                peak_LDA = 1;
            end
        end
    end
                

    binsize = round(1000*(binnedData.timeframe(2)-binnedData.timeframe(1)))/1000;
    vel_magn = binnedData.velocbin(:,3);
    
    % 1- Classify states according to a velocity threshold:
    if vel_thresh
        classifiers{1} = GT_thresh;
        states(:,1) = vel_magn >= classifiers{1};
        statemethods(1,1:10) = 'Vel thresh';
    end
    
    % 2- Classify states according to naive Bayesian using all datapoints for training
    if perf_bayes
        [states(:,2), classifiers{2}]= perf_bayes_clas(binnedData.spikeratedata,binsize,vel_magn,GT_thresh);
        statemethods(2,1:14) = 'Complete Bayes';
    end
    
    % 3- Classify states according to naive Bayesian using velocity peaks for training
    if peak_bayes
        [states(:,3), classifiers{3}]= peak_bayes_clas(binnedData.spikeratedata,binsize,vel_magn);
        statemethods(3,1:10) = 'Peak Bayes';
    end
    
    % 4- Classify states according to Linear Discriminant Analysis using all datapoints for training
    if perf_LDA
        [states(:,4), classifiers{4}] = perf_LDA_clas(binnedData.spikeratedata,binsize,vel_magn,GT_thresh);
        statemethods(4,1:12) = 'Complete LDA';
    end
    
    % 5- Classify states according to Linear Discriminant Analysis using velocity peaks for training
    if peak_LDA
        [states(:,5), classifiers{5}] = peak_LDA_clas(binnedData.spikeratedata,binsize,vel_magn);
        statemethods(5,1:8) = 'Peak LDA';
    end
        
%     % x- Classify states according to a Global Firing Rate threshold:
%     states(:,x) = GFR_clas(spikeratedata,binsize);
%     statemethods(x,1:10) = 'GFR thresh';
    
end