function speed_vel_model(a,b,c)

idx = 0;
for x = -100:100
    for y = -100:100
        idx = idx + 1;
        temp(idx,1) = x;
        temp(idx,2) = y;
        tempZ(x+101,y+101) = a*x + b*y + c*sqrt(x^2 + y^2);
    end
end

figure;
surf(-100:100,-100:100,tempZ);
end
