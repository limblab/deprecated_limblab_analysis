function alpha = get_familywise_errors(ref, N_test, N_test_obs)
    %returns the family wise error rate for a vector of proportions drawn
    %from a reference population 
    %input is a reference vector of proportions and a matched vector of 
    %test proportions. Individual error rates will be assessed with the
    %binomial theorem and combined to form an estimate of the family wise
    %error rate
    %input is avector of rates from the reference family: ref
    %a vector of 'success' counts from the test observations: N_test
    %a vector of total observation counts from the test set: N_test_obs
    
    
    %get the point-wise alpha values
    for i=1:length(ref)
        alpha_points(i) = binopdf(N_test(i),N_test_obs(i),ref(i));
    end
    
    %combine the point wise alpha values into a single family-wise error
    %rate
    alpha=1-prod(1-alpha_points);
    
end