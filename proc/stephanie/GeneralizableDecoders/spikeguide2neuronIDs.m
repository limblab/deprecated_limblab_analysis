function neuronIDs = spikeguide2neuronIDs(spikeguide)
    
    numberinputs = size(spikeguide,1);
    neuronIDs = zeros(numberinputs,2);
    
    for k=1:numberinputs
        temp=deblank(spikeguide(k,:));
        I = findstr(temp, 'u');
        neuronIDs(k,1)=str2double(temp(1,3:(I-1)));
        neuronIDs(k,2)=str2double(temp(1,(I+1):size(temp,2)));
        clear temp I
    end
end