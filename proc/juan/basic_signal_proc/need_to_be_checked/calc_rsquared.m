%
% calculate R2. Input vars can be matrices of dimensions time by variables
%

function r_squared = calc_rsquared( y_array, y_hat_array )

nbr_vars                = size(y_array,2);
r_squared               = zeros(nbr_vars,1);

% transpose matrices so that time is in dimension 1
if size(y_array,2) > size(y_array,1)
    y_array             = y_array';
    y_hat_array         = y_hat_array';
end

% do
for i = 1:nbr_vars
    % assign vars
    y                   = y_array(:,i);
    y_hat               = y_hat_array(:,i);
    
    % calculate total sum of squares
    mean_y              = mean(y);
    SS_tot              = sum((y-mean_y*ones(length(y),1)).^2);

    % calculate residual sum of squares
    SS_res              = sum((y-y_hat).^2);

    % find coeff of determination
    r_squared(i)        = 1 - SS_res/SS_tot;
end