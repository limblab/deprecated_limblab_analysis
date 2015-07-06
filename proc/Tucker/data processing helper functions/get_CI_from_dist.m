function CI=get_CI_from_dist(dist,CI_range)
    %gets the CI specified in CI range from the data in dist.
    %dist should be a row vector, or row matrix, 
    %and CI_range should be the fractional CI, i.e. 95% should be given as .95
    numpts=length(dist);
    if numpts<100;
        warning('GET_CI_FROM_DIST:SMALLSAMPLE',strcat('The given distribution only has ', num2str(numpts) ,' samples. The estimation of CI may be inaccurate due to poor sampling of the distribution.'))
    end
    low=ceil(numpts*(1-CI_range)/2);
    high=floor(numpts*(1+CI_range)/2);
    
    dist=sort(dist);
    CI=squeeze([dist(low,:,:);dist(high,:,:)]);
   
end