function z=test_arrayfun()
%test apply to slices
x=[1 2; 3 4; 5 6];

z(1,:,:)=x;
z(2,:,:)=2*x;
z(3,:,:)=3*x;
z(4,:,:)=4*x;

z=apply_to_slices(@tempfun, z);


end
function out=tempfun(input)
    out=[1 2 ; 3 4];
end
