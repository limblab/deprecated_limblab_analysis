function L=get_sigmoid_liklihood2(data,params,fhandle)
    %returns the liklihood of data given a sigmoid function data has
    %format:  [angle, num primary, num total]
    testpoints=unique(data(:,1));
    L_points=zeros(size(testpoints));
    %get the probabilities for each point in the sigmoid
    p=fhandle(params,testpoints);
    
    for i=1:length(testpoints)
        choices= data(:,1)==testpoints(i);
        n       =sum(   data(   choices,    2 ) );
        n_tot   =sum(   data(   choices,    3 ) );               
        L_points(i)=nchoosek(n_tot,n)*(p(i)^n)*((1-p(i))^(n_tot-n));
        %L_points(i)=binopdf(n,n_tot,p(i));
    end
    if min(p)<0
        L=eps;
    elseif max(p)>1
        L=eps;
    else
        L=prod(L_points);
    end
end