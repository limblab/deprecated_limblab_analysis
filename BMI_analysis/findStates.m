function [states,statemethods,Classifiers] = findStates(binnedData)

    binsize = round(1000*(binnedData.timeframe(2)-binnedData.timeframe(1)))/1000;
    vel_magn = binnedData.velocbin(:,3);
    
    
    % 1- Classify states according to a velocity threshold:
    Classifiers{1} = 8; %cm/sec
    states(:,1) = vel_magn >= Classifiers{1};
    statemethods(1,1:10) = 'Vel thresh';
    
%     % x- Classify states according to a Global Firing Rate threshold:
%     states(:,2) = GFR_clas(spikeratedata,binsize);
%     statemethods(x,1:10) = 'GFR thresh';
    
    % 2- Classify states according to naive Bayesian using all datapoints for training
    [states(:,2), Classifiers{2}]= perf_bayes_clas(binnedData.spikeratedata,binsize,vel_magn,Classifiers{1});
    statemethods(2,1:14) = 'Complete Bayes';
    
    % 3- Classify states according to naive Bayesian using velocity peaks for training
    [states(:,3), Classifiers{3}]= peak_bayes_clas(binnedData.spikeratedata,binsize,vel_magn);
    statemethods(3,1:10) = 'Peak Bayes';
    
    % 4- Classify states according to Linear Discriminant Analysis using velocity peaks for training
    [states(:,4), Classifiers{4}] = perf_LDA_clas(binnedData.spikeratedata,binsize,vel_magn,Classifiers{1});
    statemethods(4,1:12) = 'Complete LDA';
    
    % 5- Classify states according to Linear Discriminant Analysis using velocity peaks for training
    [states(:,5), Classifiers{5}] = peak_LDA_clas(binnedData.spikeratedata,binsize,vel_magn);
    statemethods(5,1:8) = 'Peak LDA';
    
end