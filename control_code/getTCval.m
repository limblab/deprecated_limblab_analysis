function  y=getTCval(x,tc_func_name,params)
% getTCval get tuning curve value for a given TC type
%
% x                A vector of independent variable values
% tc_func_name     The name of the tuning curve function to use; one of
%                  'constant', 'linear', 'gaussian', 'circular_gaussian',
%                  'sigmoid'...
% params           A vector of parameter values (varies for each TC fn)

switch lower(tc_func_name)
   case 'constant'
        y = (x./x)*params(1);
   case 'linear'
        y = params(1) + params(2)*x;
   case 'gaussian'
        y = params(1) + params(2) * exp(-(x-params(3)).^2 ./ (2*params(4).^2));
   case 'circular_gaussian_360'
        y = cg(x,params(1),params(2),params(3),params(4),360);
   case 'circular_gaussian_180'
        y = cg(x,params(1),params(2),params(3),params(4),180);
   case 'direction_selective_circular_gaussian'
        y = cg_dir(x,params(1),params(2),params(3),params(4),params(5));
   case 'sigmoid'
        y= params(1) + params(2)*(1./(1+exp(-params(4)*(x-params(3)))));
   case 'rectifiedcosine'
        y = params(1) + params(2)*max(0, cos(params(4)*(x-params(3))));
   case 'positivecosine'
        y = max(0,params(1) + params(2)*cos(params(4)*(x-params(3))));
%         y = params(1) + params(2)*cos(params(4)*(x-params(3)));
   otherwise
       error(['The TC function ',tc_func_name,' is not recognized']);
end

function  y=cg(x,b,a,po,tw,P)
    if nargin==5, P=360; end
    y=zeros(size(x));
    for i=1:length(x(:))
        y(i)=b;
        for j=-4:4
            y(i)=y(i)+a*exp(-(x(i)-po-j*P)^2 / (2*tw^2));
        end
    end
    
function y=cg_dir(x,b,a1,po,tw,a2)
    y=b*ones(size(x));
    y=y+cg(x,0,a1,po,tw,360);
    y=y+cg(x,0,a2,po+180,tw,360);