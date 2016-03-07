%%  read in all the Vicon files for this animal

allstim = read_vicon_filelist(OPTS.DATASET(2),OPTS);

%%
p = allstim{3};
ind = [3 2 1 4 5 6];
frame_ind = 350:5:500;

animate_stick(p.x(frame_ind,ind),p.y(frame_ind,ind),p.z(frame_ind,ind),p.frames);

