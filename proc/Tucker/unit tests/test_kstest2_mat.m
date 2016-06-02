%script to test kstest2_mat

x=randn(100000,3000);
y=randn(100000,3000)+.01;
tic
[H, pValue, KSstatistic] = kstest2_mat(x, y, .05);
toc
sum(H)
