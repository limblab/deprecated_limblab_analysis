%Plot EMGs and PSD

foldername = 'Y:\user_folders\Stephanie\Data Analysis\ContextDependence\Jango\04-29-14\EMGs\EMGpsds\';
Fs = 2000;
spectrumvar = spectrum.welch;
xindex = 2000:120000;
forceX =  out_struct.force.data(xindex,2) - mean(out_struct.force.data(xindex,2));
forceY =  out_struct.force.data(xindex,3) - mean(out_struct.force.data(xindex,3));
names = char(out_struct.emg.emgnames(:));

   for i = 2:length(out_struct.emg.data(1,:))
       
       figure
       h(1) = subplot(2,1,1);
       plot(out_struct.emg.data(xindex,1),out_struct.emg.data(xindex,i),'k')
       title(names(i-1,:))
       set(gca,'TickDir','out')
       box off
       h(2) = subplot(2,1,2);
       maxY = max(out_struct.emg.data(xindex,i));
       minY =  min(out_struct.emg.data(xindex,i));
       set(h(1),'YLim',[minY-(maxY/8) maxY+(maxY/8)])
       plot(out_struct.force.data(xindex,1),forceX,'b')
       hold on
       plot(out_struct.force.data(xindex,1),forceY,'g')
       xlabel('Time (seconds)')
       set(gca,'TickDir','out')
       box off
       
       saveas(gcf, strcat(foldername, names(i-1,:),'.fig'))
       saveas(gcf, strcat(foldername, '', names(i-1,:),'.eps'))
       saveas(gcf, strcat(foldername, '', names(i-1,:),'.jpg'))
       close
       
       x = out_struct.emg.data(:,i);
       psd(spectrumvar,x,'Fs',Fs);
       figure
       k(1) = subplot(2,1,1);
       psd(spectrumvar,x,'Fs',Fs);
       set(gca,'TickDir','out')
       box off
       
       k(4) = subplot(2,1,2);
       psd(spectrumvar,x,'Fs',Fs);
       xlim([0 0.1])
       set(gca,'TickDir','out')
       box off
       
       saveas(gcf, strcat(foldername, names(i-1,:), '_psd', '.fig'))
       saveas(gcf, strcat(foldername,  names(i-1,:), '_psd','.eps'))
       saveas(gcf, strcat(foldername, names(i-1,:), '_psd', '.jpg'))
       close
       
   end
