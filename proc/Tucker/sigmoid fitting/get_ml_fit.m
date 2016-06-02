function [g]=get_ml_fit(dirs,num_left_reaches,number_reaches)
    %returns a maximum likelyhood fit for a psychometric curve to bump
    %choice data. 
    %Inputs are:
    %a vector of reach directions: dirs
    %a vector containing the number of leftward reaches at each bump direction
    %a vector containing the total number of reaches at each bump direction
    %outputs are a single vector containing the optimal parameters a,b,c
    %and d of the curve function:
    %y = a + b*erf(c*(x-d))
    %where y is the left-reaching rate, and x is the bump direction
    
    %generate a function handle which allows us to wrap the cost function
    %so that our optimization only optimizes the function parameters, and
    %ignores our input data vectors
    optifun = @(params) nllik(dirs,num_left_reaches,number_reaches,params);
    g = fminsearch(optifun, [.45 .4 .5 90]);
    
    function nl = nllik(dirs, x, n, th)
        %implements a cost function, such that the cost is inverseley
        %proportional to the sum magnitude of the pdf's for each data point
        %where pdf's are generated based on the binomial theorem
        a = th(1); b = th(2); c = th(3); d = th(4);
        y = a + b*erf(c*(dirs-d));   
        nl = -sum( log(binopdf(x,n,y)) );
    end
end