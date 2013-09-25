
model='posvel';
ul = unit_list(bdf,0)
pds = 0;
errs = 0;
moddepth = 0;


[b, dev, stats] = glm_kin(bdf, ul(1,1), ul(1,2), 0, model); %#ok<ASGLU>
bv = [b(4) b(5)]; % glm weights on x and y velocity
dbv = [stats.se(4) stats.se(5)];
J = [-bv(2)/(bv(1)^2+bv(2)^2); bv(1)/(bv(1)^2+bv(2)^2)];
moddepth = norm(bv,2);
pds = atan2(bv(2), bv(1));
errs = dbv*J;
moddepth = sqrt(bv(1).^2 + bv(2).^2); 