function predVar = StateMean(PredData,PredStates)

%ActData    = [BinnedData.cursorposbin BinnedData.velocbin];
%PredData   = AllPred.preddatabin;
%PredStates = AllPred.states;

numstates = max( range(PredStates)+1);
numclass  = size(PredStates,2);

% predStateVar = cell(1,numclass);
% actStateVar  = cell(1,numclass);
predVar = cell(numstates,numclass);
% actVar  = cell(numstates,numclass);

% for state = 1:numstates
%     for class = 1:numclass
%         predStateVar{class}(state,:)= std(PredData{1,class}(PredStates(:,class)==state-1,:));
% %          actStateVar{class}(state,:)= std(ActData(PredStates(:,class)==state-1,:));
%     end
% end

StateChange = abs(diff(PredStates));
numchanges  = sum(StateChange);
numbins     = size(PredStates,1);

%this code assumes 2 states:
for class = 1:numclass
   
    numrest = ceil(numchanges(class)/2)+1;
    nummvt  = ceil(numchanges(class)/2)+1;
   
    predVar{1,class} = zeros(numrest,size(PredData,2));
    predVar{2,class} = zeros(nummvt,size(PredData,2));
    
    rest_counter = 0;
    mvt_counter  = 0;
    nextstart = 1;
    
    while nextstart
            
        state = PredStates(nextstart,class);
        
        start = nextstart;
        if nextstart == numbins
            stop = nextstart;
            nextstart = [];
        else
            nextstart = nextstart+find(StateChange(nextstart:end,class),1,'first');
            if ~isempty(nextstart)
                stop = nextstart-1;
            else
                stop = numbins;
            end
        end
            
        if ~state
            rest_counter = rest_counter+1;
             predVar{state+1,class}(rest_counter,:) = mean(PredData(start:stop,:));            
%             predVar{state+1,class}(rest_counter,:) = std(PredData(1,class}(start:stop,:));
%             actVar{state+1,class}(rest_counter,:) = std(ActData(start:stop,:));
        else
            mvt_counter  =  mvt_counter+1;
            predVar{state+1,class}(mvt_counter,:) = mean(PredData(start:stop,:));
%             predVar{state+1,class}(mvt_counter,:) = std(PredData(1,class}(start:stop,:));            
%             actVar{state+1,class}(mvt_counter,:) = std(ActData(start:stop,:));
        end
    end
    
    predVar{1,class} = predVar{1,class}(1:rest_counter,:);
    predVar{2,class} = predVar{2,class}(1:mvt_counter,:);
%     actVar {1,class} =  actVar{1,class}(1:rest_counter,:);
%     actVar {2,class} =  actVar{2,class}(1:mvt_counter,:);
    
end
% 
% actStateVarNotes  = 'actStateVar is the stdev of the actual velocities signals (x,y and magn) for each state (row1=state0, row2=state2) each cell is a different classification method';
% predStateVarNotes = 'predStateVar is the stdev of the predicted velocities signals (x,y and magn) for each state (row1=state0, row2=state2) each cell is a different classification method';
% actVarNotes = 'actVar is the stdev measure of actual signals for each epoch of each state. Each row of the cell array is a different state, each column a classification method.';
% predVarNotes = 'predVar is the stdev measure of predicted signals for each epoch of each state. Each row of the cell array is a different state, each column a classification method.';
%     
% SDVar = {'actStateVar ',actStateVar   ; 'actSateVarNotes ',actStateVarNotes   ;...
%          'predStateVar ',predStateVar ; 'predStateVarNotes ',predStateVarNotes;...
%          'actVar ',actVar             ; 'actVarNotes ',actVarNotes            ;...
%          'predVar ',predVar           ; 'predVarNotes ',predVarNotes};