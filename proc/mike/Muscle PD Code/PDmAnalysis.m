randPDm= randn(100,8)

randPDm = randPDm./repmat(sqrt(sum(randPDm.^2,2)),1,8)

[IDX1,C,sumd1] = kmeans(emgPC,1);
[IDX2,C,sumd2] = kmeans(emgPC,2);
[IDX3,C,sumd3] = kmeans(emgPC,3);
[IDX4,C,sumd4] = kmeans(emgPC,4);
[IDX5,C,sumd5] = kmeans(emgPC,5);
[IDX6,C,sumd6] = kmeans(emgPC,6);
[IDX7,C,sumd7] = kmeans(emgPC,7);

k= [1 2 3 4 5 6 7];

sumsqerror= [sumd1 sum(sumd2) sum(sumd3) sum(sumd4) sum(sumd5) sum(sumd6) sum(sumd7)];

figure(4)
plot(k,sumsqerror)

[COEFF,SCORE] = princomp(pronePDm(:,5:15));

PC = pronePDm(:,5:15)*COEFF;

centroid = C*COEFF;

figure(5)
plot(PC(:,1),PC(:,2), 'ob');
hold on
plot(centroid(1,1),centroid(1,2),'or')
plot(centroid(2,1),centroid(2,2),'og')

[pronepd_diff_DE]= pd_electrode_map(pronePDm);

figure(6)
hist(pronepd_diff_DE*(180/pi),[0:5:360]);