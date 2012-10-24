function [g]=get_ml_fit(dirs,num_reaches,number_reaches)

    optifun = @(data) nllik(dirs,num_reaches,number_reaches,data);
    g = fminsearch(optifun, [.45 .4 .05 90]);
    
    function nl = nllik(dirs, x, n, th)
        %implements a cost function, such that the cost is inverseley
        %proportional to the sum magnitude of the pdf's for each data point
        %where pdf's are generated based on the binomial theorem
        a = th(1); b = th(2); c = th(3); d = th(4);
        y = a + b*erf(c*(dirs-d));   
        nl = -sum( log(binopdf(x,n,y)) );
    end
end