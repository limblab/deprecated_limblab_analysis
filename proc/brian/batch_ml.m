% Batch ML to find differences

%good_units = out(~isnan(out(:,3)), :);
%good_units = sortrows(good_units, -3);
good_units = mis;
num_units = size(good_units,1);

%ml_fits = zeros(num_units, 8); % [chan unit baseline pos_x pos_y pd pd_gain speed_gain]
ml_fits = zeros(num_units, 9); % [chan unit mi_lag mi_peak baseline pd pd_gain speed_gain L]
%ml_fits = zeros(num_units, 8); % [chan unit mi_lag mi_peak baseline x y L]

tic;
for i = 1:num_units        
    et = toc;
    disp(sprintf('%d of %d\tET: %f', i, num_units, et));
    
    if isnan(good_units(i,3))
        ml_fits(i,:) = [good_units(i,1:4) NaN NaN NaN NaN NaN];
        %ml_fits(i,:) = [good_units(i,1:4) NaN NaN NaN NaN];
        continue;
    end

    [L, alpha, success] = fit_model(bdf, good_units(i,1), good_units(i,2), good_units(i,3));
    
    if success ~= 1
        warning('BatchML:NonConv', 'cell %d-%d did not converge.', good_units(i,1), good_units(i,2));
        ml_fits(i,:) = [good_units(i,1:4) NaN NaN NaN NaN L];
        continue;
    end
    
    rth = [atan2(alpha(3),alpha(2)) sqrt(alpha(2)^2+alpha(3)^2)];
    ml_fits(i,:) = [good_units(i,1:4) alpha(1) rth alpha(4) L];
    %ml_fits(i,:) = [good_units(i,1:4) alpha(1:3) L];
end