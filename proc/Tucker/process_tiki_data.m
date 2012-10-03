%script to take CO bdf's, break into bump and movement segments

%make tdf additions to bdf object
make_tdf
%generate chopped tdf objects
tdf_bump=get_sub_trials(bdf, [bdf.tt(:,2),(bdf.tt(:,2)+1)] );
tdf_move=get_sub_trials(bdf, [bdf.tt(:,3),bdf.tt(:,4)] );
% compute glm_kin type output for chopped files
glm_force();
glm_kin();

