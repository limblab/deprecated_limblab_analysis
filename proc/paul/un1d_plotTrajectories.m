function h = un1d_plotTrajectories(traj, x_off, y_off)

numMoves = size(traj.pos_x,1);

for mi=1:numMoves
   prange = [1:find(isnan(traj.pos_x(mi,:))==1,1,'first')];
   
   figure(1);
   subplot(211);
   plot(traj.pos_x(mi,prange)-x_off,traj.pos_y(mi,prange)-y_off);
   axis square;
   title(['Position trace ' num2str(traj.shifts(mi)) ' - fb - '  num2str(traj.feedback(mi))]);
   subplot(212);
   sp = smooth(sqrt(traj.vel_x(mi,prange).^2+traj.vel_y(mi,prange).^2),5);
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