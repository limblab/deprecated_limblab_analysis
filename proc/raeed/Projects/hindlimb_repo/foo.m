figure
draw_bones;
axis equal;

length_history = [];

for i=-.50:.01:1
    angles = [0 0 i]+base_angles;
    get_mp;
    draw_bones;
    %drawnow
    
    get_lengths;
    length_history = [length_history; lengths];
end
