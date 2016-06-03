%script to test staircase
close all
%general parameters
num_tests=1000;
limit_trials=50;
forward_step=5;
reverse_step=15;
%sigmoid definition
minimum=1;
    maximum=0;
    center=70;
    steepness=.05;
sig_params=[minimum,maximum,center,steepness];
    
%assume center @90deg and initialize 4 staircase values for each tail:


session_length=zeros(1,num_tests);
for i=1:num_tests
    trials_since_converge=0;
    staircase_angle=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 180 180 180 180 180 180 180 180 180 180 180 180 180 180 180 180];
    staircase_limit=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 180 180 180 180 180 180 180 180 180 180 180 180 180 180 180 180];
    flag=0;
    j=0;
    while trials_since_converge<limit_trials
        %choose staircase
        staircase=ceil(32*rand);
        %get the odds of responding CW for that angle
        response_ratio=sigmoid(sig_params,staircase_angle(staircase));
        %incriment the staircase
        trials_since_converge=trials_since_converge+1;
        if staircase<17
            if rand>response_ratio
                staircase_angle(staircase)=staircase_angle(staircase)-reverse_step;
            else
                staircase_angle(staircase)=staircase_angle(staircase)+forward_step;
                if staircase_angle(staircase)>staircase_limit(staircase)
                    staircase_limit(staircase)=staircase_angle(staircase);
                    if flag==1
                        trials_since_converge=0;
                        flag=0;
                    else
                        flag=1;
                    end
                end
            end
        else
            if rand<response_ratio
                staircase_angle(staircase)=staircase_angle(staircase)+reverse_step;
            else
                staircase_angle(staircase)=staircase_angle(staircase)-forward_step;
                if staircase_angle(staircase)<staircase_limit(staircase)
                    staircase_limit(staircase)=staircase_angle(staircase);
                    if flag==1
                        trials_since_converge=0;
                        flag=0;
                    else
                        flag=1;
                    end
                end
            end
        end
        j=j+1;
    end    
    session_length(i)=j;
end
avg=mean(session_length)
low=min(session_length)
high=max(session_length)
variance=var(session_length)

