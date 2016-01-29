
function S = ml_fit(x,y,tc_func_name,prob_model_name)

min_x_diff=min(diff(unique(x)));
min_y=min(y);
max_y=max(y);
spread=max_y-min_y;
switch lower(tc_func_name)
   case 'constant'
       p0 = mean(y);
   case 'linear'
       p0 = [mean(y) 1];
   case 'gaussian'
       p0 = [mean(y) spread mean(x) min_x_diff];
   case 'circular_gaussian_360'
       p0 = [mean(y) spread 180 90];
   case 'circular_gaussian_180'
       p0 = [mean(y) spread 90 20];
   case 'direction_selective_circular_gaussian'
       p0 = [mean(y) spread 90 20 mean(y)];
   case 'positivecosine'
       p0 = [mean(y) spread pi 1];
   otherwise
       error(['The TC function ',tc_func_name,' is not recognized']);
end

[params,fval] = fminsearch(@fitTCmle,p0,[],x,y,tc_func_name,prob_model_name);

S=[];
for i=1:length(params)
    S = setfield(S,['P' num2str(i)],params(i));
end
S.log_llhd = -fval;


function obj = fitTCmle(params,x,y,tc_func_name,prob_model_name)

yhat = getTCval(x,tc_func_name,params);

switch lower(prob_model_name)
   case {'poiss','poisson'}
        obj = -sum(log(yhat).*y - yhat);
   case 'add_normal'
        obj = sum((y-yhat).^2);
   otherwise
       error([' The probability model ',prob_model_name,' is not recognized']);
end

switch lower(tc_func_name)
   case 'circular_gaussian_360'
       p0 = [mean(y) spread 180 90];
   case 'circular_gaussian_180'
       if params(1)<0, obj=Inf; end
       if params(2)<0, obj=Inf; end
       if params(4)<0, obj=Inf; end
   case 'direction_selective_circular_gaussian'
        if params(1)<0, obj=Inf; end       
        if params(2)<0, obj=Inf; end
        if params(5)<0, obj=Inf; end
        if params(4)<0, obj=Inf; end
    otherwise
end