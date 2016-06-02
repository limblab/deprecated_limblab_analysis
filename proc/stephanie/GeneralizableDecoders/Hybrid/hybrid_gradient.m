function grad_out = hybrid_gradient(x,flag,scale,Yvector,TotalX)
% movement flag = 0 | iso flag = 1
    scale_vec=(flag+(1-flag)*scale).^2;
    scaled_Y = scale_vec.*Yvector;
    scaled_X = repmat(scale_vec,1,size(TotalX,2)).*TotalX;
    grad_out = -2*scaled_Y'*scaled_X+2*x'*scaled_X'*scaled_X;
end