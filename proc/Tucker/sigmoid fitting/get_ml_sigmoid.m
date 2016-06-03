function [phat,varargout]=get_ml_sigmoid(data)
    %takes in a bdf from the bumpdirection task which has been extended
    %with the .tt and .tt_hdr fields, and computes the maximum likelihood
    %sigmoidal expression for that data. The sigmoidal function fit is the
    %full form function with main and stim effect terms. The cost function 
    %for this sigmoid is found in logpdf_sigmoid_fit.m. 
%     min_val=0.95;
%     max_val=0.05;
%     ctr_point=90;
%     steepness=0.1;
%     start(1,:)=[min_val,max_val,ctr_point,steepness];
%     %set parameter ranges:

%     %linear constraint, sum of min and max parameters is less than 1

% 
% 
    tmp=sort(unique(data(:,1)));
    angles=tmp(tmp<180  &  0<tmp);
    for i=1:length(angles)
        N_tot(i)=sum(data(:,1)==angles(i));%trials at the current angle 
        N_primary(i)=sum(data(:,1)==angles(i) & data(:,2)==1);%trials at the current angle and to the primary target
    end
    p=N_primary./N_tot;

    %estimate min val:
    min_val=max(p) ;
    %estimate max val:
    max_val=min(p);
    %build vectors of initial guesses:
    diff_p=min_val-max_val;
    min_val=min_val+diff_p*[-.1 0 .1];
    min_val(min_val>=1)=.99;
    min_val(min_val<=0)=.01;
    max_val=max_val+diff_p*[-.1 0 .1];
    max_val(max_val>=1)=.99;
    max_val(max_val<=0)=.01;
    %estimate center point of the sigmoid:
    ctr_p=min_val-diff_p*[.4 .5 .6];
    ctr_p(ctr_p>=1)=.99;
    ctr_p(ctr_p<=0)=.01;
    
    pts=angles(abs(p-diff_p*.5)<.1);
    if ~isempty(pts);
        ctr_point=mean(pts)+[-15 0 15];
    else
        ctr_point=[75 90 105];
    end
    %estimate steepness:
    steepness=[0.1 0.2];
%     start(2,:)=[min_val,max_val,ctr_point,steepness];
%     goodness_start(1)=logpdf_sigmoid2(data,start(1,:));
%     goodness_start(2)=logpdf_sigmoid2(data,start(2,:));
%     [~,best_start]=min(goodness_start);
%     
%     start(3,:)=lsqcurvefit(@sigmoid,start(best_start,:),angles,p');
%     
%     goodness_start(3)=logpdf_sigmoid2(data,start(3,:));
%     
%     [~,best_start]=min(goodness_start);
%     phat2=phat2;
% 
%     if(phat3(1)>1)
%         phat3(1)=.99;
%     end
%     if((phat3(1)+phat3(2))>1)
%         phat3(2)=0;
%     end
%     if(phat3(3)<0)
%         phat3(3)=.01;
%     end
%     if((phat3(3)+phat3(4))<0)
%         phat3(4)=.01;
%     end

    %set the function handle for the logpdf of the sigmoid to fit
    logpdf=@(params) logpdf_sigmoid_fit2(data,params);
    
    %set up a multistart solver object:
    phat_min=[0 0 0 0];
    phat_max=[1 1 180 .5];
    a=[1 1 0 0];
    b=1;
    %problem=createOptimProblem('fmincon','objective',logpdf,'x0',[.9 .1 90 .1],'Aineq',a,'bineq',b,'lb',phat_min,'ub',phat_max);
    problem=createOptimProblem('fmincon','objective',logpdf,'x0',[.9 .1 90 .1],'lb',phat_min,'ub',phat_max);
    ms=MultiStart('StartPointsToRun','bounds','MaxTime',600,'UseParallel','always');
    %build custom set of start points:
    startpoints=zeros(length(min_val)*length(max_val)*1:length(ctr_point)*length(steepness),4);
    n=1;
    for i=1:length(min_val)
        for j=1:length(max_val)
            for k=1:length(ctr_p)
                for m=1:length(steepness)
                    startpoints(n,:)=[min_val(i) max_val(j) ctr_point(k) steepness(m)];
                    n=n+1;
                end
            end
        end
    end
    cs=CustomStartPointSet(startpoints);
    % [phat,pci] = mle(data,'logpdf',logpdf,'start',start);
    %phat=fminsearch(logpdf,phat3,optimset('MaxIter',10000,'MaxFunEvals',100000));
    %phat=fmincon(logpdf,start(best_start,:),a,b,[],[],phat_min,phat_max);
    %phat=fminsearch(logpdf,start);
    phat=run(ms,problem,cs);
    if nargout>1
        varargout{1}=logpdf_sigmoid2(data,phat);
    end

end