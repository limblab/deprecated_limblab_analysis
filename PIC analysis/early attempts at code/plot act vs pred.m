 figure
   hold on
   
   
   subplot(1,2,1)
     hold on
     plot(actual_avg(:,1),within_avg(:,1),'r.');
     plot(actual_avg(:,1),across_avg(:,1),'b.');
     
     p=polyfit(actual_avg(:,1),within_avg(:,1),1);
     
     
     plot([-5:5],[-5:5],'k');
     axis([-6 6 -6 6])
     xlabel('actual avg x');
     ylabel('pred avg x');
  
     
     
     subplot(1,2,2)
     hold on
     plot(actual_avg(:,2),within_avg(:,2),'r.');
     plot(actual_avg(:,2),across_avg(:,2),'b.');
     plot([-5:5],[-5:5],'k');
     axis([-6 6 -6 6])
     xlabel('actual avg y');
     ylabel('pred avg y');