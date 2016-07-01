function [ PercentSuccess firstBinarySuccess lastBinarySuccess] = ComputeTotalSuccessOverTime_trialbasis(TrialsStruct, TrialsPerEpoch);



binarySuccess = TrialsStruct.TrialsFull(:,1); 
binarySuccess(binarySuccess==82)=1; binarySuccess(binarySuccess==70)=0;
counter = 1;
for i = 1:floor(length(TrialsStruct.TrialsFull(:,1))/TrialsPerEpoch)  % or change floor to ceil
    if counter+TrialsPerEpoch-1 <= length(TrialsStruct.TrialsFull(:,1))
        IndicesInEpoch = counter:counter+TrialsPerEpoch-1;
    else
        IndicesInEpoch = counter:length(TrialsStruct.TrialsFull(:,1));
    end
    NumTrialsInEpoch = length(IndicesInEpoch);
    SuccessesInEpoch = length(find(TrialsStruct.TrialsFull(IndicesInEpoch,1)==82));
    PercentSuccess(i) = SuccessesInEpoch/NumTrialsInEpoch;
    counter = counter+TrialsPerEpoch;
    if i==1
        firstBinarySuccess = binarySuccess(IndicesInEpoch);
    end
    if i == floor(length(TrialsStruct.TrialsFull(:,1))/TrialsPerEpoch)
        lastBinarySuccess = binarySuccess(IndicesInEpoch);
    end
    
end


end


 
