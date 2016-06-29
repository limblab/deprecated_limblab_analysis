function [overlap] = check_overlap(ci1,ci2)
%checks overlap between confidence intervals

overlap = (ci1(1)>ci2(1) && ci1(1)<ci2(2)) || (ci1(2)>ci2(1) && ci1(2)<ci2(2));

end