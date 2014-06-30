function [cost_out,grad_out] = hybrid_cost(x,flag,scale,Yvector,TotalX)
    scale_vec=(flag+(1-flag)*scale).^2;
    scaled_Y = scale_vec.*Yvector;
    scaled_X = repmat(scale_vec,1,size(TotalX,2)).*TotalX;
    grad_out = -2*scaled_Y'*scaled_X+2*x'*(scaled_X'*scaled_X);
    
    cost_out = ((scale_vec.*(Yvector-TotalX*x))'*(scale_vec.*(Yvector-TotalX*x)));
end