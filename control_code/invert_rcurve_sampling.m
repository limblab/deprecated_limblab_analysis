function x = invert_rcurve_sampling(f,S)

p1 = S.P1_median;
p2 = S.P2_median;
p3 = S.P3_median;
p4 = S.P4_median;
y = f;
x = -(1/p4)*log((p2/(y-p1))-1)+p3;
if ~isreal(x)
    x = 0;
end

