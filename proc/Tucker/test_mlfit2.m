% same as test_mlfit but operates on angles between 180 and 360.
%script to test ML fits

%[...] = mle(data,'logpdf',logpdf,'logsf',logsf,'start',start,...) returns 
%MLEs for the parameters of the distribution defined by the log probability
%density and log survival functions logpdf and logsf. logpdf and logsf are 
%function handles created using the @ sign. They accept as inputs a vector 
%data and one or more individual distribution parameters, and return 
%vectors of logged probability density values and logged survival function 
%values, respectively. This form is sometimes more robust to the choice of 
%starting point than using pdf and cdf functions. If the 'censoring' name/
%value pair is not present, you can omit the 'logsf' name/value pair. start
%is a vector containing initial values for the distribution's parameters.


%set the starting vector from which to search for the maximum likelihood
%estimate for the parameters of our sigmoid. Note that the *_stim
%parameters are deviations from the main parameters and should be close to
%zero
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
angles=tmp(tmp<350  &  190<tmp);
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



figure
plot(angles,sigmoid_stim(phat,[angles, zeros(length(angles),1)]),'b')
hold on
plot(angles,sigmoid_stim(phat2,[angles, zeros(length(angles),1)]),'g')
plot(angles,p_nostim,'bx')
figure
plot(angles,sigmoid_stim(phat,[angles, ones(length(angles),1)]),'r')
hold on
plot(angles,sigmoid_stim(phat2,[angles, ones(length(angles),1)]),'g')
plot(angles,p_stim,'rx')

disp(strcat('Max Liklihood model, 1/likelihood : ', num2str(logpdf_sigmoid(data,mask,phat))))
disp(strcat('Least Squares model, 1/likelihood : ', num2str(logpdf_sigmoid(data,mask,phat2))))