% all_likelihoods.m

units = out(~isnan(out(:,3)), :);

likelihoods = zeros(size(units,1), 4);
for i = 1:size(units,1)
    % formula is: lambda = m + k*sp*cos(th-th_p) + p*sp
    m = units(i,5);
    th_p = out(i,6);
    k = units(i,7);
    p = units(i,8);
    
    sp = sqrt(bdf.vel(:,2).^2 + bdf.vel(:,2).^2)';
    th = atan2(bdf.vel(:,3), bdf.vel(:,2))';
    
    lambda = m + k*sp.*cos(th-thp) + p*sp;
    %lambda = lambda - (mean(lambda)-m);
    
    L_m = spike_train_log_likelihood(s, lambda);
    L_n = spike_train_log_likelihood(s, repmat(m,size(s)));
    
    likelihoods(i,:) = [units(i,1), units(i,2), L_m, L_n];
end

