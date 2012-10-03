function h = un1d_plotKinematics(kin)

numMoves = size(kin.pos_x,1);
    figure;

for mi=1:numMoves
   prange = [1:find(isnan(kin.pos_x(mi,:))==1,1,'first')];
   [pks, locs] = findpeaks(kin.speed(mi,prange),'MINPEAKDISTANCE',300);
   [pks2, locs2] = findpeaks(-kin.speed(mi,prange),'MINPEAKDISTANCE',300);
   subplot(211);
   plot(kin.pos_x(mi,prange),kin.pos_y(mi,prange));
   hold on;
   plot(kin.pos_x_end(mi),kin.pos_y_end(mi),'gs');
   plot(kin.pos_x_go(mi),kin.pos_y_go(mi),'gs');
%    plot(kin.pos_x_cloud(mi),kin.pos_y_cloud(mi),'bo');
   
   plot(kin.pos_x(mi,locs),kin.pos_y(mi,locs),'bo');
   plot(kin.pos_x(mi,locs2),kin.pos_y(mi,locs2),'ro');   
   hold off;
   axis([-10 10 -2 15]);
   title(['Position trace ' num2str(kin.visualShift(mi)) ' - fb - '  num2str(kin.cloudVar(mi))]);
   subplot(212);
   
   plot(kin.speed(mi,prange));
   hold on;

   plot(locs,kin.speed(mi,locs),'bo');
   plot(locs2,kin.speed(mi,locs2),'ro');   
   hold off;
   title('Speed trace');
   pause;
end

return;