function force = eval_sigmoid_sampling(S,xIN)

p1 = S.P1_median;
p2 = S.P2_median;
p3 = S.P3_median;
p4 = S.P4_median;

force = p1+p2*(1./(1+exp(-p4*(xIN-p3))));
force(xIN==0) = 0;