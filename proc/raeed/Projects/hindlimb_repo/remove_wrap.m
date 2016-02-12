function unwrapped_angles = remove_wrap(angles)
% REMOVE_WRAP removes wrapping caused by subtraction or addition

unwrapped_angles = angles;
while(sum(unwrapped_angles>pi)>0)
    unwrapped_angles(unwrapped_angles>pi) =  unwrapped_angles(unwrapped_angles>pi)-2*pi;
end
while(sum(unwrapped_angles<-pi)>0)
    unwrapped_angles(unwrapped_angles<-pi) =  unwrapped_angles(unwrapped_angles<-pi)+2*pi;
end