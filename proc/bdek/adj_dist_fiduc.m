function[d,table] = adj_dist_fiduc(input)

% adj_dist_fiduc.m takes as input a matrix of fiducial coordinates and returns
% a matrix of coordinates in which the distal arm fiducial has been
% replaced with an approximation of the coordinates representing the actual
% point of rotation of the wrist.  

f = @(x) wrist_length_obj(x,input); 
    %anonymous function using wrist_length_obj, a cost function.

d = fminunc(f, 30);
    %finds the value of d, which represents the distance away from the
    %distal fiducial (on the same line as the centroids of the distal and
    %medial fiducials) that minimizes the change in distance between the
    %handle and the new distal fiducial P, where P = distal_fiducial + d.
    
h = input(:,[1 2]);
w = input(:,[3 4]);
m = input(:,[5 6]);
    %separates coordinates for handle, distal arm fiducial and medial arm
    %fiducial
    
wrist_vec = (w-m);
wrist_length = sqrt(wrist_vec(:,1).^2 + wrist_vec(:,2).^2);
wrist_length = repmat(wrist_length,1, 2);
p = m + ((w - m)./wrist_length).*(wrist_length+d);
    %uses the calculated value of d to reconstruct the coordinate matrix,
    %substituting the new distal arm fiduciary coordinates. 
table = [h p m];