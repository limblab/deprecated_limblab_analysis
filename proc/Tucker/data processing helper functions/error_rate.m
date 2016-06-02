function [h]=error_rate(tt,tt_hdr,stimcodes)
    %plots a bar chart of the error rate for each of the listed stim codes
 %exclude aborts and catch trials
    tt = tt( ( tt(:,tt_hdr.trial_result) ~= 1 & tt(:,tt_hdr.bump_mag) ~= 0  ) ,  :); 
    
    
    %get non stim trials
    tt_no_stim=tt(( tt(:,tt_hdr.stim_trial) ~= 1 ),  :);

    is_error_no_stim =(tt_no_stim(:,tt_hdr.trial_result)==2);%code 2 is fail, 0 is success, 1 is abort
    
    num_no_stim=length(tt_no_stim(:,1));
    
    R_no_stim=sum(is_error_no_stim)/num_no_stim;

    CI_no_stim=binoinv([0.05 0.95],num_no_stim,R_no_stim)

    h=figure;
    bar([R_no_stim, zeros(1,length(stimcodes))],'b');
    hold on;
    
    
    %find the stim conditions used

    
    
    for i=1:length(stimcodes)
        %get catch trials
        tt_stim=tt( ( tt(:,tt_hdr.stim_trial) == 1 & tt(:,tt_hdr.stim_code) == stimcodes(i)) ,  :);

        is_error_stim =(  tt_stim(:,tt_hdr.trial_result)==2  );

        num_stim=length(tt_stim(:,1));
        
        R_stim(i)=sum(is_error_stim)/num_stim;
        
        CI_stim=binoinv([0.05 0.95],num_stim,R_stim(i));
        e_lower(i+1)=R_stim(i)-CI_stim(1)/num_stim;
        e_upper(i+1)=-R_stim(i)+CI_stim(2)/num_stim;
        %compute the probability of observing this number of left reaches during
        %stim trials if the rate of left reaches is the same as in the nostim
        %condition
        P_dist(i)=binopdf(sum(is_error_stim),num_stim,R_no_stim);
        
        temp=zeros(1,length(stimcodes)+1);
        temp(i+1)=R_stim(i);
        bar(temp,'r')
        
    end
    
%     
%      bar([0, P_catch(1), 0, 0, 0],'r')
%      bar([0, 0, P_catch(2), 0, 0],'r') 
%      bar([0, 0, 0, P_catch(3), 0],'r')
%      bar([0, 0, 0, 0, P_catch(4)],'r')
    

    %legend('No-stim',strcat('5uA: p=',num2str(P_dist(1))),strcat('10uA: p=',num2str(P_dist(2))),strcat('15uA: p=',num2str(P_dist(3))),strcat('20uA: p=',num2str(P_dist(4))))
    %lower errorbars
    e_lower(1)=R_no_stim-CI_no_stim(1)/num_no_stim;
    %upper errorbars
    e_upper(1)=-R_no_stim+CI_no_stim(2)/num_no_stim;
    
    
    err_ind=1:(length(stimcodes)+1);
    probs=[R_no_stim,R_stim];
    
    errorbar(err_ind,probs,e_lower,e_upper,'k')
    
    title(['\fontsize{14}error rate by stim condition\newline' ...
        '\fontsize{10}error is 95% CI computed using matlabs binoinv function'])
    disp(strcat('Probability our stim trials are drawn from the same distribution as the no stim trials based on error rate: ',num2str(P_dist)))
 
end