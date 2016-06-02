function rowVector=rowBoat(inputVector)

% syntax rowVector=rowBoat(inputVector);
%
% makes inputVector into a row vector regardless
% of what its dimensionality was before.  
% inputVector is 1-D.

if size(inputVector,2)>size(inputVector,1)
    rowVector=inputVector';
else
    rowVector=inputVector;
end