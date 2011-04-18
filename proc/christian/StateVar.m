numstates = max( range(AllPred.states)+1);
numclass  = size(AllPred.states,2);

predStateVar = cell(1,numclass);
actStateVar  = cell(1,numclass);
predVar = cell(numstates,numclass);
actVar  = cell(numstates,numclass);

%actVelData = Chewie001_002.velocbin(1:24000,:);
%actVelData = Chewie001_002.velocbin(1:24000,:);

for state = 1:numstates
    for class = 1:numclass
        predStateVar{class}(state,:)= std(AllPred.preddatabin{1,class}(AllPred.states(:,class)==state-1,:));
         actStateVar{class}(state,:)= std(actVelData(AllPred.states(:,class)==state-1,:));
    end
end

StateChange = [abs(diff(AllPred.states));ones(1,size(AllPred.states,2))];
numchanges = sum(StateChange);

%this code assumes 2 states:
for class = 1:numclass
   
    numrest = ceil(numchanges(class)/2);
    nummvt  = ceil(numchanges(class)/2);
    firstState = AllPred.states(1,class);
   
    predVar{1,class} = zeros(numrest,size(actVelData,2));
    predVar{2,class} = zeros(nummvt,size(actVelData,2));
    
    nextstart = 1;
    rest_counter = 0;
    mvt_counter  = 0;
    
    while nextstart
        state = AllPred.states(nextstart,class);

        
        start = nextstart;
        nextstart = nextChange+find(StateChange(nextChange+1:end,class),1,'first')+1;
        if ~isempty(nextstart)
            stop = nextstart-1;
        else
            stop = length(AllPred.timeframe);
        end
        
        if ~state
            rest_counter = rest_counter+1;
            predVar{state+1,class}(rest_counter,:) = std(AllPred.preddatabin{1,class}(start:stop,:));
            actVar{state+1,class}(rest_counter,:) = std(actVelData(start:stop,:));
        else
            mvt_counter  =  mvt_counter+1;
            predVar{state+1,class}(mvt_counter,:) = std(AllPred.preddatabin{1,class}(start:stop,:));
            actVar{state+1,class}(mvt_counter,:) = std(actVelData(start:stop,:));
        end
       
    end
end
    