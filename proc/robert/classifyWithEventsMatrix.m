function [classResults,trueTestDataGrouping,tprate]=classifyWithEventsMatrix(t,x,eventsMatrix,trainInds,testInds,eventTags)

% Inputs
%   t
%   x
%   eventsMatrix
%   trainInds
%   testInds
%   eventTags               such as {'force','no force'}
%
% fp is poorly named.
% a full eventMatrix is 
%
% [startForce stopForce startPinch stopPinch startRelease stopRelease]
%

if ~nargin, return, end
%#ok<*AGROW>


% if it's only 2 columns, then the 'movement' times are just going to
% be the complement of the force times.  Leave out the times before the
% first trial and the times after the last trial.  Also leave out the
% times immediately following what will be the testing trial, since
% that will be part of the testing data also.  In the diagram below,
% t1, t2, etc represent times in the eventMatrix.  (1), (2), etc show
% what regions belong to what trials
%
%                (1)       (1)
%           t1 <----> t2  ====>
%     (1)        (2)       (2)
%    ====>  t3 <----> t4  ====>
%     (2)        (3)       (3)
%    ====>  t5 <----> t6  ====>
%
% single dash regions are in 1 class, double-dash (equals signs) regions
% are in the other class.  For simplicity within the loop,
% convert this to a 4-column matrix that looks like the following:
%
%           t1 <----> t2    t2 <====> t3
%           t3 <----> t4    t4 <====> t5
%           t5 <----> t6    t6 <====> t7
%
% then, the code can execute the same as it would if we were handing in >2
% classes
%

% consider adding an exterior class, or a NULL class, whatever is passed in
% via eventsMatrix.  This might be good from a design standpoint, because
% in the BMI case every point must be classified as something or other.

if size(eventsMatrix,2)==2
    lastTrialpostWindowWidth=mean(eventsMatrix(2:end,1)- ...
        eventsMatrix(1:end-1,2));
    eventsMatrix=[eventsMatrix, eventsMatrix(:,2), ...
        [eventsMatrix(2:end,1); (eventsMatrix(end,2)+lastTrialpostWindowWidth)]];
end

% trainingData is what is handed in.  cl_trainingData is what will be
% aggregated/labelled for the classifier.  If the states are a binary such
% as force/no force, then all of trainingData will be used, and it's just 
% an exercise in labelling.  But if multiple windows are specified, 
% then not all of trainingData will be used, and we're back to aggregation.
x=rowBoat(x);
cl_trainingData=[];
groupingData={};
trainInds_logical=false(size(t));
trainInds_logical(trainInds)=true;
for n=1:size(eventsMatrix,1)
    for m=2:2:size(eventsMatrix,2)
        eventTimes=(t>=eventsMatrix(n,m-1) & ...
            t<=eventsMatrix(n,m) & trainInds_logical);
        % only put data from this trial into cl_trainingData if it is also
        % from the designated training data.  The current approach allows
        % for partial inclusion of windows from the eventsMatrix.  This
        % results in a richer training data set, but raises the possibility
        % of slight overlap around the edges of the trainInds/testInds
        % boundaries.  For a more conservative approach, exclude the
        % current window if it is not completely contained within trainInds
        if ~nnz(eventTimes)
            continue
        end
        % if we get to this point, we're in the trainging data area, so go
        % ahead and include the data into cl_trainingData
        cl_trainingData=[cl_trainingData; x(eventTimes,:)];
        groupingData((size(groupingData,1)+1): ...
            (size(groupingData,1)+nnz(eventTimes)),1)= ...
            repmat(eventTags(m/2),nnz(eventTimes),1);
    end
end
% now, the testing data.  For the online BMI case, there can be no points
% that are outside the available classes.  Every time point has to belong
% to some class.  
% For the offline case, we can choose to only pick data that are part of our
% windows, and make the classifier accuracy about whether the tested data
% point was assigned to the correct window.

% the question is whether we should revamp this so that there is always a
% NULL class.  Previously, this was being done explicitly in the case of
% force/no force.  The proposed change is to make this general.  In other
% words, regardless of the number of classes handed in (it could be only
% one, e.g. 'force'), there will be one more class added on, that being the
% NULL or 'none of the above' class.  That one will always be an option.
% This may have implications for the online BMI case, as times that are
% identified as NULL class might indicate transition, or a pause, or
% something else.  If it's a discontinuous transition or a pause, though,
% it should probably be accompanied by an instruction sent to the robot to
% slow down, or integrate instructions for another control cycle, or
% something.


% for a pure classifier test, I only tested data that I knew was part of
% some window, and the classifier was only responsible for assigning which
% window that was.  For the within-predictions code implementation, the
% testing data will ALWAYS have to include all points, because the
% information output by the classifier will be used to tell calling
% function which continuous decoder to use, to make predictions.  
% For the force/no force state classifier, the two statements are
% equivalent and all data is used anyway.  So, during ititial testing it's
% wise to stick to this case. 

% if testing is going to include all data, then this loop is only used 
% for labelling
trueTestDataGrouping={};
trueTestDataTimes=[];
cl_testingData=x(testInds,:);
testingInds_logical=false(size(t));
testingInds_logical(testInds)=true;
eventTimes_all=false(size(t));
for n=1:size(eventsMatrix,1)    
    for m=2:2:size(eventsMatrix,2)
        eventTimes=(t>=eventsMatrix(n,m-1) & ...
            t<=eventsMatrix(n,m) & testingInds_logical);
        if ~nnz(eventTimes)
            continue
        end
        eventTimes_all=(eventTimes_all | eventTimes);
        trueTestDataTimes=[trueTestDataTimes; rowBoat(t(eventTimes))];
        trueTestDataGrouping((size(trueTestDataGrouping,1)+1): ...
            (size(trueTestDataGrouping,1)+nnz(eventTimes)),1)= ...
            repmat(eventTags(m/2),nnz(eventTimes),1);
    end    
end
% for any case other than 1 class (which supplies its own default),
% something will need to be put in here that picks up any unclaimed time
% points in the testing data  Those will be placed in the default or 
% NULL category.
if nnz(eventTimes_all)~=numel(testInds)
    % pick up stragglers, assign them to NULL.  Use trueTestDataTimes to
    % sort?
    stragglers=(~eventTimes_all & testingInds_logical);
    [trueTestDataTimes,sortInd]=sort([trueTestDataTimes; ...
        rowBoat(t(stragglers))]);
    tmp=[trueTestDataGrouping; repmat(eventTags(end),nnz(stragglers),1)];
    trueTestDataGrouping=tmp(sortInd);
end

% note that a lot of this can be circumvented if the outer (calling)
% function assigns a default continuous decoder to use.  Then, when a NULL
% state is encountered, the combined decoder just falls back on its default
% member.  

classResults= ...
    classify(cl_testingData,cl_trainingData,groupingData,'linear');
% compare classResults to trueTestDataGrouping to get accuracy.
tprate=nnz(strcmp(classResults,trueTestDataGrouping))/numel(classResults);
