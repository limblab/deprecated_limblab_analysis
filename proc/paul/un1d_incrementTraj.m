function h = un1d_incrementTraj(traj)

numMoves = size(traj.pos_x,1);
    figure;

for mi=1:numMoves
   prange = [1:find(isnan(traj.pos_x(mi,:))==1,1,'first')];

   subplot(211);
   plot(traj.pos_x(mi,prange),traj.pos_y(mi,prange));
   hold on;
   plot(traj.pos_x_comp(mi),traj.pos_y_comp(mi),'rs');
   plot(traj.pos_x_go(mi),traj.pos_y_go(mi),'rs');
   plot(traj.pos_x_mid(mi),traj.pos_y_mid(mi),'bo');
   hold off;
   axis([-10 10 -2 15]);
   title(['Position trace ' num2str(traj.shifts(mi)) ' - fb - '  num2str(traj.feedback(mi))]);
   subplot(212);
   sp = smooth(sqrt(traj.vel_x(mi,prange).^2+traj.vel_y(mi,prange).^2),50);
   dsp = diff(sp);
   zr=[];
   for j=1:length(dsp)-1
    if (sign(dsp(j))~=sign(dsp(j+1)))||(dsp(j)==0)
       zr = [j zr];
    end
   end
   plot(sp);
   hold on; plot(zr,sp(zr),'bo'); hold off;
   title('Speed trace');
   pause;
end

return;