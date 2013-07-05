% linear regression of activity onto joints in the style of Bosco and
% Poppele 2000

% do joint regression for each cell  

for i=1:length(neurons)
    
    % do linear regression individually for each
    ac = activity_con(i,:)';
    au = activity_unc(i,:)';
    
    bias_term = ones(length(joint_angles_con),1);
    
    hip_term_con = [bias_term joint_angles_con(:,1)]\ac;
    hip_term_unc = [bias_term joint_angles_unc(:,1)]\au;
    
    knee_term_con = [bias_term joint_angles_con(:,2)]\ac;
    knee_term_unc = [bias_term joint_angles_unc(:,2)]\au;
    
    ankle_term_con = [bias_term joint_angles_con(:,1)]\ac;
    ankle_term_unc = [bias_term joint_angles_unc(:,1)]\au;
    
    % make plots
    figure(1234)
    
    % plot constrained-unconstrained firing comparison
    subplot(4,3,2)
    plot(activity_unc(i,:),activity_con(i,:),'.', activity_unc(i,:), activity_unc(i,:), '-')
    title(['Neuron ' num2str(i)])
    
    % plot constrained-unconstrained angle comparison
    subplot(4,3,6)
    plot(joint_angles_unc(:,1), joint_angles_con(:,1), '.', joint_angles_unc(:,1), joint_angles_unc(:,1), '-')
    
    subplot(4,3,9)
    plot(joint_angles_unc(:,2), joint_angles_con(:,2), '.', joint_angles_unc(:,2), joint_angles_unc(:,2), '-')
    
    subplot(4,3,12)
    plot(joint_angles_unc(:,3), joint_angles_con(:,3), '.', joint_angles_unc(:,3), joint_angles_unc(:,3), '-')
    
    % plot unconstrained stuff
    subplot(4,3,4)
    plot(joint_angles_unc(:,1),au,'.', joint_angles_unc(:,1),[bias_term joint_angles_unc(:,1)]*hip_term_unc,'-')
    
    subplot(4,3,7)
    plot(joint_angles_unc(:,2),au,'.', joint_angles_unc(:,2),[bias_term joint_angles_unc(:,2)]*knee_term_unc,'-')
    
    subplot(4,3,10)
    plot(joint_angles_unc(:,3),au,'.', joint_angles_unc(:,3),[bias_term joint_angles_unc(:,3)]*ankle_term_unc,'-')
    
    % plot constrained stuff
    subplot(4,3,5)
    plot(joint_angles_con(:,1),ac,'.', joint_angles_con(:,1),[bias_term joint_angles_con(:,1)]*hip_term_con,'-')
    
    subplot(4,3,8)
    plot(joint_angles_con(:,2),ac,'.', joint_angles_con(:,2),[bias_term joint_angles_con(:,2)]*knee_term_con,'-')
    
    subplot(4,3,11)
    plot(joint_angles_con(:,3),ac,'.', joint_angles_con(:,3),[bias_term joint_angles_con(:,3)]*ankle_term_con,'-')
    
    % plot change in endpoint preferred direction
    subplot(4,3,1)
    rose(ycpd(i)-yupd(i),360)
    
    % plot VAF for unconstrained/constrained
    subplot(4,3,3)
    plot(VAF_unc(i),VAF_con(i),'.')
    axis([0 1 0 1])
    grid on
    
    waitforbuttonpress;
end