function ang = find_angle(v1,v2)
DEBUG = 0;

v3 = v2-v1;
nvectors = size(v1,1);
for ii = 1:nvectors    
    u1 = [1 0];
    u2 = [0 1];    
    ang1 = atan2((v1(ii,:)*u2'),v1(ii,:)*u1');
    ang2 = atan2((v2(ii,:)*u2'),v2(ii,:)*u1');
    ang(ii) = ang1 - ang2;
    
    if DEBUG
        plot([0 v1(ii,1) 0 v2(ii,1)],[0 v1(ii,2) 0 v2(ii,2)]);
%         plot([v1(ii,1) v2(ii,1)], [v1(ii,2) v2(ii,2)])
        title([ang1 ang2 ang(ii)]')
        axis('equal')
        pause(.1)
    end
    
end

c1 = cos(ang);
s1 = sin(ang);
ang = atan2(s1,c1)*180/pi;