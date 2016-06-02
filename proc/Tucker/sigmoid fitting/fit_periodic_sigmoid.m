function params=fit_periodic_sigmoid(data)
    %returns a vector containing the parameters of fit for a periodic
    %sigmoid of form:
    %y=minimum+(maximum-minimum)./(1+exp(-steepness*cos(x-center)))
%     minimum=params(1);
%     maximum=params(2);
%     center=params(3);
%     steepness=params(4);
    %data should be of the format [angle;choice] where choice is a boolean
    %0 or 1

    
    %initialize parameter vector
    params0=[0 1 0 2];
    optifun=@(P) inv_liklihood(P,data);
    params=fminsearch(optifun,params0);
    function il=inv_liklihood(params,data)
        L=get_sigmoid_liklihood(data,params,@sigmoid_periodic);
        il=1/L;
    end

end