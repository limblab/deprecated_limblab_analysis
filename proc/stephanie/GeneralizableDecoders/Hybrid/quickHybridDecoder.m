function [H] = quickHybridDecoder(HybridFinal)

Y = HybridFinal.emgdatabin;
X = HybridFinal.spikeratedata;

% This flag tells you if you are in a stretch of iso or wm data
flag = HybridFinal.taskflag;


for i = 1:length(HybridFinal.emgdatabin(1,:))
    % Scale is a ratio dictated in the makeHybrid script
    scale = HybridFinal.scale(i);
    scale_vec=(flag+(1-flag)*scale).^2;
    scaled_X = repmat(scale_vec,1,size(X,2)).*X;
    scaled_Y = repmat(scale_vec,1,size(Y,2)).*Y;
    
    Hnew=filMIMO4(scaled_X,scaled_Y ,10,1,1);
    H(:,i) = Hnew(:,i);
end
 