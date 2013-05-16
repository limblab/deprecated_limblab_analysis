function UF_bump_mag_test()
% %% Bump magnitude test (remove when done)
% figure
% subplot(211)
% hold on
% for iBumpMag = 1:length(bump_magnitudes)
%     plot(t_axis,UF_struct.x_force_rot_bump(bump_mag_indexes{iBumpMag},:)','Color',UF_struct.colors_bump_mag(iBumpMag,:))
% end
% xlabel('t (s)')
% ylabel('F (N)')
% title('Force parallel to bump')
% xlim([t_axis(1) t_axis(end)])
% subplot(212)
% hold on
% for iBumpMag = 1:length(bump_magnitudes)
%     mean_bump_mag(iBumpMag) = mean(mean(UF_struct.x_force_rot_bump(bump_mag_indexes{iBumpMag},find(t_axis>.05 & t_axis<UF_struct.bump_duration))));
%     plot(bump_magnitudes(iBumpMag),mean_bump_mag(iBumpMag),...
%         '.','Color',UF_struct.colors_bump_mag(iBumpMag,:),'MarkerSize',15)
% end
% plot(bump_magnitudes,mean_bump_mag)
% xlabel('Commanded force (N)')
% ylabel('Mean bump force (N)')
% 
% % Bump magnitude test (remove when done)
% figure
% subplot(211)
% hold on
% for iBiasForce = 1:length(bias_force_directions)   
%     for iBumpMag = 1:length(bump_magnitudes)
%         idx = intersect(bias_indexes{iBiasForce},bump_mag_indexes{iBumpMag});
%         idx = intersect(idx,bump_indexes{4});
%         if iBiasForce == 1
%             plot(t_axis,mean(UF_struct.x_force_rot_bump(idx,:)),'Color',UF_struct.colors_bump_mag(iBumpMag,:)) 
%         else
%             plot(t_axis,mean(UF_struct.x_force_rot_bump(idx,:)),'Color',UF_struct.colors_bump_mag(iBumpMag,:),'LineStyle','--')  
%         end
%     end
% end
% xlabel('t (s)')
% ylabel('F (N)')
% title('Force parallel to bump')
% xlim([t_axis(1) t_axis(end)])
% subplot(212)
% hold on
% for iBumpMag = 1:length(bump_magnitudes)
%     mean_bump_mag(iBumpMag) = mean(mean(UF_struct.x_force_rot_bump(bump_mag_indexes{iBumpMag},find(t_axis>.05 & t_axis<UF_struct.bump_duration))));
%     plot(bump_magnitudes(iBumpMag),mean_bump_mag(iBumpMag),...
%         '.','Color',UF_struct.colors_bump_mag(iBumpMag,:),'MarkerSize',15)
% end
% plot(bump_magnitudes,mean_bump_mag)
% xlabel('Commanded force (N)')
% ylabel('Mean bump force (N)')