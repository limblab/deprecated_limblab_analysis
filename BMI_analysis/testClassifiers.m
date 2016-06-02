function [states,statemethods,classifiers] = testClassifiers(modelData,testData,varargin)
% [states,statemethods,classifiers] = testClassifiers(modelData,testData,varargin)
%
% MODELDATA and TESTDATA must have same number of units!
%
% MODELDATA is the binnedData file containing the classifiers.
% TESTDATA is the binnedData file to classify.
% VARARGIN contains numbers (1-5) of classifiers to use.
% If VARARGIN is empty, use all classifiers.
% STATES and STATEMETHODS will contain classifier output in these columns
% (which are also identifiers for them in VARARGIN):
%   1 - velocity threshold
%   2 - perfect Bayes
%   3 - peak Bayes
%   4 - perfect LDA
%   5 - peak LDA

    vel_thresh = 0;
    perf_bayes = 0;
    peak_bayes = 0;
    perf_LDA = 0;
    peak_LDA = 0;

    if nargin == 1
        vel_thresh = 1;
        perf_bayes = 1;
        peak_bayes = 1;
        perf_LDA = 1;
        peak_LDA = 1;
    else
        for x = 1:length(varargin)
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
                

    binsize = round(1000*(testData.timeframe(2)-testData.timeframe(1)))/1000;
    vel_magn = testData.velocbin(:,3);
    
    % 1- Classify states according to a velocity threshold:
    if vel_thresh
        classifiers{1} = modelData.classifiers{1};
        states(:,1) = vel_magn >= classifiers{1};
        statemethods(1,1:10) = 'Vel thresh';
    end
    
    % 2- Classify states according to naive Bayesian using all datapoints
    if perf_bayes
        classifiers{2} = modelData.classifiers{2};
        states(:,2) = test_perf_bayes_clas(testData.spikeratedata,binsize,classifiers{2});
        statemethods(2,1:14) = 'Complete Bayes';
    end
    
    % 3- Classify states according to naive Bayesian using mean velocities
    if peak_bayes
        classifiers{3} = modelData.classifiers{3};
        states(:,3) = test_peak_bayes_clas(testData.spikeratedata,binsize,classifiers{3});
        statemethods(3,1:10) = 'Peak Bayes';
    end
    
    % 4- Classify states according to Linear Discriminant Analysis using all datapoints
    if perf_LDA
        classifiers{4} = modelData.classifiers{4};
        states(:,4) = test_perf_LDA_clas(testData.spikeratedata,binsize,classifiers{4});
        statemethods(4,1:12) = 'Complete LDA';
    end
    
    % 5- Classify states according to Linear Discriminant Analysis using mean velocities
    if peak_LDA
        classifiers{5} = modelData.classifiers{5};
        states(:,5) = test_peak_LDA_clas(testData.spikeratedata,binsize,classifiers{5});
        statemethods(5,1:8) = 'Peak LDA';
    end
    
end