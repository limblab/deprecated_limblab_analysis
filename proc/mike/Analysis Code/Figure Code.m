figure
plot(abs(All_R2_HC_Decoders(1:7,1:3,1))','-r')
hold on;
plot(abs(All_R2_BC_HC_Decoders(1:7,1:3,2))','-b')
All_R2_BC_HC_Decoders(8,:,:) = mean(abs(All_R2_BC_HC_Decoders(1:7,:,:)));
errorbar(mean(All_R2_BC_HC_Decoders(8,1:3,:),3),mean(std(All_R2_BC_HC_Decoders(1:7,1:3,:)),3)/sqrt(9),'bl')
plot(abs(All_R2_BC_HC_Decoders(1,1:3,1))','-g')
plot(abs(All_R2_BC_HC_Decoders(1,1:3,2))','-y')

handles = [gco];
handles = [handles gco];

legend(handles,'X Velocity','Y Velocity')
ylabel('R^2')

set(gca,'XTick',1:4)
set(gca,'XTickLabel',{'Before','During','After'})

title('Correlation between LFP (HC decoder) and Spike (online Decoder) pred vel before, during and after Spike BC')