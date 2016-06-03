%script to test staircase
close all
%general parameters
num_trials=1000;
limit_trials=50;
forward_step=2;
reverse_step=6;
%sigmoid definition
minimum=1;
    maximum=0;
    center=70;
    steepness=.05;
sig_params=[minimum,maximum,center,steepness];
    
%assume center @90deg and initialize 4 staircase values for each tail:

staircase_angle=[0 0 0 0 180 180 180 180];

for i=1:num_trials
    %choose staircase
    staircase=ceil(8*rand);
    %get the odds of responding CW for that angle
    response_ratio=sigmoid(sig_params,staircase_angle(staircase));
    %incriment the staircase
    if staircase<5
        if rand>response_ratio
            staircase_angle(staircase)=staircase_angle(staircase)-reverse_step;
        else
            staircase_angle(staircase)=staircase_angle(staircase)+forward_step;
        end
    else
        if rand<response_ratio
            staircase_angle(staircase)=staircase_angle(staircase)+reverse_step;
        else
            staircase_angle(staircase)=staircase_angle(staircase)-forward_step;
        end
    end
    staircase_log(:,i)=staircase_angle;     
            
end

plot(staircase_log(1,:),'r')
hold on
plot(staircase_log(2,:),'b')
plot(staircase_log(3,:),'g')
plot(staircase_log(4,:),'k')

figure
plot(staircase_log(5,:),'r')
hold on
plot(staircase_log(6,:),'b')
plot(staircase_log(7,:),'g')
plot(staircase_log(8,:),'k')

