%%  read in all the Vicon files for this animal

allstim = read_vicon_filelist(OPTS.DATASET(3),OPTS);

%% set up video recording
vidwrite = VideoWriter('treadstep.avi'); 
open(vidwrite); 

%%
p = allstim{2}; %index = which trial in this set we should use
ind = [3 2 1 4 5 6];
frame_ind = 400:3:700;

[h, F] = animate_stick(p.x(frame_ind,ind),p.y(frame_ind,ind),p.z(frame_ind,ind),p.frames);

for fr = 1:length(F)
    writeVideo(vidwrite, F(fr)); 
end
close(vidwrite); 

