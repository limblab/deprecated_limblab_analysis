function plot_robot_pos(bdf)
% Plot robot position, color coded with handle speed (black is low speed,
% red is high speed)

    % t = bdf.pos(:,1);
    pos_x = bdf.pos(:,2);
    pos_y = bdf.pos(:,3);

    vel_x = bdf.vel(:,2);
    vel_y = bdf.vel(:,3);

    speed = sqrt(vel_x.^2+vel_y.^2);
    
    speed_normer = mean(speed)+std(speed)*1.96;

    norm_speed = speed/speed_normer;

    colors = [min(norm_speed,1) zeros(length(norm_speed),2)];

    scatter(pos_x,pos_y,2,colors)

end