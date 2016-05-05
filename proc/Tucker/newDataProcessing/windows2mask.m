function mask=windows2mask(time,windows)
    %windows2mask gets a logical index vector by applying time windows to a
    %vector of timestamps.
    %mask=windows2mask(time,windows)
    %time is a column vector of timestamps. Time is not required to be
    %   sorted for this function
    %windows is a column matrix [tStart1,tEnd1; tStart2,tEnd2; tStart3,
    %   tEnd3; ... ]. The first column has the start time of each window,
    %   and the second column has the end time of each window.
    %the output of windows2mask is a single column vector of 0/1 logical
    %values that serves as a mask for the given windows. Mask will be 1
    %where the values of time fall within any of the given windows, and 0
    %otherwise.     
    
    if size(windows,2)~=2
        error('windows2mask:windowsNotColumnMatrix','the aray of windows must be a column matrix with the first column containing the start of each window, and the scond column containing the end of each window')
    end
    if isrow(time)
        error('windows2mask:timeNotColumnVector','the time input to windows2mask must be a column vector')
    end
    %% compose the matrixes we will use for comparison:
    %each column of testTime is a replicate of the input time. we will
    %compare each column to one pair of low and high windows so that the
    %resulting column is a logical mask for that window
    testTime=repmat(time,1,size(windows,1));
    %compose matrixes of the high and low windows so that we have matrices
    %of the same size, where each column contains the same value replicated
    %once for each point in time. This allows a single comparison operation
    %to compare all elements in time without looping
    lowWindow=repmat(windows(:,1)',numel(time),1);
    highWindow=repmat(windows(:,2)',numel(time),1);
    %get our final mask:
    %the logical operation generates a matrix where each column is the mask
    %   for a single time window.
    %summing, converts this to a single column vector
    %casting as logical converts points that might have occurred in
    %   multiple windows and thus summed to >1, back to true for the final
    %   mask
    mask=logical(sum((testTime>=lowWindow & testTime<=highWindow),2));
    
end