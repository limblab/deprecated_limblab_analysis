% Plot muscle lengths versus joint angles

for i = 1:length(muscles)
    figure
    for j = 1:3 %number of joints
        subplot(3,1,j)
        plot(joint_angles_unc(:,j),muscle_lengths_unc(:,i),'go',joint_angles_con(:,j),muscle_lengths_con(:,i),'ro')
    end
end