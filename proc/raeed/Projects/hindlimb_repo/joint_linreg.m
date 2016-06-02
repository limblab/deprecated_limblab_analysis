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
    
    ankle_term_con = [bias_term joint_angles_con(:,3)]\ac;
    ankle_term_unc = [bias_term joint_angles_unc(:,3)]\au;
    
    % make plots
    figure(1234)
    
    % plot constrained-unconstrained firing comparison
    subplot(4,3,2)
    plot(activity_unc(i,:),activity_con(i,:),'.', activity_unc(i,:), activity_unc(i,:), '-')
    title(sprintf(['Neuron ' num2str(i) '\nConstrained vs. unconstrained neural activity']))
    xlabel 'Unconstrained'
    ylabel 'Constrained'
    
    % plot constrained-unconstrained angle comparison
    subplot(4,3,6)
    plot(joint_angles_unc(:,1), joint_angles_con(:,1), '.', joint_angles_unc(:,1), joint_angles_unc(:,1), '-')
    title 'Constrained versus unconstrained joint angles'
    ylabel 'Constrained'
    
    subplot(4,3,9)
    plot(joint_angles_unc(:,2), joint_angles_con(:,2), '.', joint_angles_unc(:,2), joint_angles_unc(:,2), '-')
    ylabel 'Constrained'
    
    subplot(4,3,12)
    plot(joint_angles_unc(:,3), joint_angles_con(:,3), '.', joint_angles_unc(:,3), joint_angles_unc(:,3), '-')
    xlabel 'Unconstrained'
    ylabel 'Constrained'
    
    % plot unconstrained stuff
    hip_unc_pred = [bias_term joint_angles_unc(:,1)]*hip_term_unc;
    hip_unc_VAF = calc_VAF(au,hip_unc_pred);
    subplot(4,3,4)
    plot(joint_angles_unc(:,1),au,'.', joint_angles_unc(:,1),hip_unc_pred,'-')
    title(sprintf(['Neural Activity versus unconstrained joint angle\n' 'VAF: ' num2str(hip_unc_VAF)]))
    ylabel(sprintf('Hip\nActivity'))
    
    knee_unc_pred = [bias_term joint_angles_unc(:,2)]*knee_term_unc;
    knee_unc_VAF = calc_VAF(au,knee_unc_pred);
    subplot(4,3,7)
    plot(joint_angles_unc(:,2),au,'.', joint_angles_unc(:,2),knee_unc_pred,'-')
    ylabel(sprintf('Knee\nActivity'))
    title(['VAF: ' num2str(knee_unc_VAF)])
    
    ankle_unc_pred = [bias_term joint_angles_unc(:,3)]*ankle_term_unc;
    ankle_unc_VAF = calc_VAF(au,ankle_unc_pred);
    subplot(4,3,10)
    plot(joint_angles_unc(:,3),au,'.', joint_angles_unc(:,3),ankle_unc_pred,'-')
    ylabel(sprintf('Ankle\nActivity'))
    xlabel 'Unconstrained Joint Angle'
    title(['VAF: ' num2str(ankle_unc_VAF)])
    
    % plot constrained stuff
    hip_con_pred = [bias_term joint_angles_con(:,1)]*hip_term_con;
    hip_con_VAF = calc_VAF(ac,hip_con_pred);
    subplot(4,3,5)
    plot(joint_angles_con(:,1),ac,'.', joint_angles_con(:,1),hip_con_pred,'-')
    title(sprintf(['Neural Activity versus constrained joint angle\n' 'VAF: ' num2str(hip_con_VAF)]))
    ylabel 'Activity'
    
    knee_con_pred = [bias_term joint_angles_con(:,2)]*knee_term_con;
    knee_con_VAF = calc_VAF(ac,knee_con_pred);
    subplot(4,3,8)
    plot(joint_angles_con(:,2),ac,'.', joint_angles_con(:,2),knee_con_pred,'-')
    ylabel 'Activity'
    title(['VAF: ' num2str(knee_con_VAF)])
    
    ankle_con_pred = [bias_term joint_angles_con(:,3)]*ankle_term_con;
    ankle_con_VAF = calc_VAF(ac,ankle_con_pred);
    subplot(4,3,11)
    plot(joint_angles_con(:,3),ac,'.', joint_angles_con(:,3),ankle_con_pred,'-')
    ylabel 'Activity'
    xlabel 'Constrained Joint Angle'
    title(['VAF: ' num2str(ankle_con_VAF)])
    
    % plot change in endpoint preferred direction
    subplot(4,3,1)
    rose(ycpd(i)-yupd(i),360)
    title(sprintf('Change in preferred direction\nfrom unconstrained to constrained'))
    
    % plot VAF for unconstrained/constrained
    subplot(4,3,3)
    plot(VAF_unc(i),VAF_con(i),'.')
    axis([0 1 0 1])
    grid on
    title(sprintf( 'VAF for Neuron (Cartesian Endpoint)\nConstrained vs. Unconstrained cases'))
    ylabel 'Constrained'
    xlabel 'Unconstrained'
    
    waitforbuttonpress;
end