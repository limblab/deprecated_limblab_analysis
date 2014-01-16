function L=get_sigmoid_liklihood(data,params,fhandle)
    %returns the liklihood of data given a sigmoid function
    testpoints=unique(data(:,1));
    L_points=zeros(size(testpoints));
    %get the probabilities for each point in the sigmoid
    p=fhandle(params,testpoints);
    for i=1:length(testpoints)
        choices=data(:,1)==testpoints(i);
        n       =sum(   data(  choices,   2 )   )
        n_tot   =sum(   choices                 )
        L_points=nchoosek(n_tot,n)*(p(i)^n)*((1-p(i))^(n_tot-n));
    end
    
    L=prod(L_points);
end