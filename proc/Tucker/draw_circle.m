function draw_circle(H,ctr,r,c)
    %draws a circle on figure H that has center at ctr=[x,y], radius r, and
    %color c
    
    %make vectors containing border of polygon:
    ang=[0:.01*pi:2*pi];
    x=r*cos(ang);
    y=r*sin(ang);
    figure(H)
    fill(x+ctr(1),y+ctr(2),c)

end