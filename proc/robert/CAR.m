function outArray=CAR(inArray,rowColFlag)

% syntax outArray=CAR(inArray,rowColFlag)
%
%       INPUTS
%               inArray         - a 2D matrix
%               rowColFlag      - 1 for average down rows, 2 for 
%                                 average across columns
%
%       OUPUTS
%               outArray        - same as inArray, but CAR'red
%
% This function excludes, in turn, each row/col of inArray from the 
% common average.  As a rule of thumb, rowColFlag should usually be 
% along whichever dimension is not the time dimension.

% outArray=zeros(size(inArray));

for n=1:size(inArray,rowColFlag)
    CAbasis_ind=setdiff(1:size(inArray,rowColFlag),n);
    if rowColFlag==1
        CAbasis=inArray(CAbasis_ind,:);
        outArray(n,:)=inArray(n,:)-mean(CAbasis,1);
    else
        CAbasis=inArray(:,CAbasis_ind);
        outArray(:,n)=inArray(:,n)-mean(CAbasis,2);        
    end
end






