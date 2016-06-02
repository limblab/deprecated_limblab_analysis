function PSE=getPSE(params)
    %gets the point of subjective equality (PSE) for a sigmoid defined by
    %the parameter set params
    minimum=params(1);
    maximum=params(2);
    center=params(3);
    steepness=params(4);
    
    PSE=    center  -   log(    (maximum-minimum)/(0.5-minimum)  -   1    )   /   steepness;
    if ~isreal(PSE)
        PSE=180;
    end
    return
end