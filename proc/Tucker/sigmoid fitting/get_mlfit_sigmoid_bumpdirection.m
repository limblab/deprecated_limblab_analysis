function phat=get_mlfit_sigmoid_bumpdirection(bdf,mask)
    %takes in a bdf from the bumpdirection task which has been extended
    %with the .tt and .tt_hdr fields, and computes the maximum likelihood
    %sigmoidal expression for that data. The sigmoidal function fit is the
    %full form function with main and stim effect terms. The cost function 
    %for this sigmoid is found in logpdf_sigmoid_fit.m. the mask input
    %allows the user to specifically force certain parameters to zero. The
    %mask [1 0 1 0 1 0 1 0] could be used to force a fit without any of the
    %stim parameters
    min_val=0.9;
    min_val_stim=0;
    max_val=0.1;
    max_val_stim=0;
    ctr_point=90;
    ctr_point_stim=0;
    steepness=0.2;
    steepness_stim=0;

    start=[min_val,min_val_stim,max_val,max_val_stim,ctr_point,ctr_point_stim,steepness,steepness_stim];
    mask=[1 1 1 1 1 1 1 1];

    %get the data vector from the bdf
    data(:,1)=bdf.tt(:,bdf.tt_hdr.bump_angle);%angles
    data(:,2)=bdf.tt(:,bdf.tt_hdr.stim_trial);%stim condition

    data(:,3)=( bdf.tt(:,bdf.tt_hdr.trial_result)==2 & 90 <= bdf.tt(:,bdf.tt_hdr.bump_angle) &  bdf.tt(:,bdf.tt_hdr.bump_angle)<= 270 |...
            bdf.tt(:,bdf.tt_hdr.trial_result)==0 & -90 <= bdf.tt(:,bdf.tt_hdr.bump_angle) & bdf.tt(:,bdf.tt_hdr.bump_angle) <= 90 |...
            bdf.tt(:,bdf.tt_hdr.trial_result)==0 & 270 <= bdf.tt(:,bdf.tt_hdr.bump_angle) & bdf.tt(:,bdf.tt_hdr.bump_angle) <= 360  );%was the reach to the primary target or not

    tmp=sort(unique(data(:,1)));
    angles=tmp(tmp<180  &  15<tmp);
    for i=1:length(angles)
        N_tot(i)=sum(data(:,1)==angles(i) & data(:,2)==0);%trials at the current angle with no stim
        N_tot_stim(i)=sum(data(:,1)==angles(i) & data(:,2)==1);%trials at the current angle with stim
        N_primary(i)=sum(data(:,1)==angles(i) & data(:,2)==0 & data(:,3)==1);%trials at the current angle with no stim and to the primary target
        N_primary_stim(i)=sum(data(:,1)==angles(i) & data(:,2)==1 & data(:,3)==1);%trials at the current angle with stim and to the primary target
    end
    p_nostim=N_primary./N_tot;
    p_stim=N_primary_stim./N_tot_stim;

    phat2=lsqcurvefit(@sigmoid_stim,start,[angles,zeros(length(angles),1);angles,ones(length(angles),1)],[p_nostim';p_stim']);
    phat3=phat2;

    if(phat3(1)>1)
        phat3(1)=.99;
    end
    if((phat3(1)+phat3(2))>1)
        phat3(2)=0;
    end
    if(phat3(3)<0)
        phat3(3)=.01;
    end
    if((phat3(3)+phat3(4))<0)
        phat3(4)=.01;
    end

    %set the function handle for the logpdf of the sigmoid to fit
    logpdf=@(params) logpdf_sigmoid_fit(data,mask,params);

    % [phat,pci] = mle(data,'logpdf',logpdf,'start',start);
    phat=fminsearch(logpdf,phat3,optimset('MaxIter',10000,'MaxFunEvals',100000));
    %phat=fminsearch(logpdf,start);

    disp(strcat('Max Liklihood model, 1/likelihood : ', num2str(logpdf_sigmoid(data,mask,phat))))

end