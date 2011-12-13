function Outputs = predMIMOCE1(Inputs,H,numlags)

[numpts,Nin]=size(Inputs);
[rowH,Nout]=size(H);

Outputs = zeros(numpts,Nout);

if Nin ~= rowH
    %Inputs may have to be duplicated and shifted according to numlags
    %For long files, this creates huge arrays and Matlab runs out of memory
    %So let's do it for segments of 5k bins maximum
    maxSeg = min(5000,numpts);
     
    %first loop is different, no spike history
    InputSeg = DuplicateAndShift(Inputs(1:maxSeg,:),numlags);
    
    %Predictions for first segment
    Outputs(1:maxSeg,:) = InputSeg*H;
    
    %loop one more time in the likely case that numpts is not an exact
    %multiple of maxSeg, to predict the last bit of data
    NoRem = ~logical(rem(numpts,maxSeg));
        
    for i = 1:floor(numpts/maxSeg)-NoRem
        startbin = i*maxSeg+1; 
        endbin   = min(numpts,startbin+maxSeg-1);
        
        %account for spike history (start-numlag index)
        InputSeg = DuplicateAndShift(Inputs(startbin-(numlags-1):endbin,:),numlags);
        
        %Make predictions
        Outputs(startbin:endbin,:) = InputSeg(numlags:end,:)*H;
    end
else
    Outputs = Inputs*H;
end
% %discard the first numlags-1 points because they are garbage:
% Outputs = Outputs(numlags:end,:);