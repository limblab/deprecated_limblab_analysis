function pds = batch_glm_pds(bdf)

ul = unit_list(bdf);
pds = zeros(length(ul),1);

th = 1:360;
th = th*2*pi/360;
vel_test = [50.*cos(th') 50.*sin(th')];
speed = sqrt(vel_test(:,1).^2 + vel_test(:,2).^2);
test_params = [zeros(length(vel_test),2) vel_test speed];

tic;
for i = 1:length(ul)
    et = toc;
    disp(sprintf('ET: %f (%d of %d)', et, i, length(ul)));
    b = glm_kin(bdf, ul(i,1), ul(i,2), 0, 'posvel');
    fr = glmval(b, test_params, 'log');    
    pd = th(find(fr==max(fr),1));
    pds(i,:) = pd;
end


