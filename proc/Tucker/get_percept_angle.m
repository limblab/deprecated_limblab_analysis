function percept_angle=get_percept_angle(bump_ang,bump_mag,stim_ang,stim_mag)
    %computes the apparent angle of a bump percept given the actual bump angle
    %and magnitude and the stimulus driven angle and magnitude
    
    percept_component_x=(bump_mag*sin(bump_ang)+stim_mag*sin(stim_ang));
    percept_component_y=(bump_mag*cos(bump_ang)+stim_mag*cos(stim_ang));
    percept_angle=atan2(percept_component_x/percept_component_y);

end