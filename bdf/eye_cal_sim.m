function eye_cal_sim
%So, the basic idea is to take our raw eye data, correlate that with known
%screen positions, and find the necessary transformation vectors that give
%us a calibration.
%Form of equation we are looking at (presumably):
% [ POG_x  POG_y  ] = 
%    [ eye_x  eye_y  ]*| a  b |  +  [ translate_x  translate_y ]
%                      | c  d |
%...where POG_x/_y are coordinates of gaze on screen, eye_x/_y represent
%the vector between the pupil location and corneal reflection location,
% [a b; c d] is the transformation matrix (part 1 of what we want to
% determine) and translate_x/_y is the offset vector (part 2 of what we
% want to determine)

%Start specific: deal with the individual cases of the different target
%locations

%At some point: from existing data, look at gaze position activity compared
%to what's going on in the behavior (how long does he look at the center
%square while holding the cursor there? does his gaze follow the cursor or
%jump straight to one of the outer targets? at what point in the behavior
%routine can we be sure he is looking at the outer targets - or any
%specific target/location, for that matter?). Also: plot gaze position
%compared to cursor position.