function cost = wrist_length_obj(d,input)

%wrist_length_obj.m is a cost function used by adj_dist_fiduc.m. It calculates
%the distance between the new distal arm fiducial point (dictated by input
%value d) and returns a cost, representing the efficacy of chosen value 'd'
%in minimizing the change in length (between new distal fiducial and
%handle)

h = input(:,[1 2]);
w = input(:,[3 4]);
m = input(:,[5 6]);
    %separate input coordinate matrix into component coordinates

wrist_vec = (w-m);
wrist_length = sqrt(wrist_vec(:,1).^2 + wrist_vec(:,2).^2);
wrist_length = repmat(wrist_length, 1, 2);
l = h - m - ((w - m)./wrist_length).*(wrist_length+d);
l = sqrt(l(:,1).^2 + l(:,2).^2);
    %Calculate l, which represents the distance between the adjusted distal
    %fiducial and the handle

l_hat = mean(l);

cost = sum((l-l_hat).^2);
   