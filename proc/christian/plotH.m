function NormW = plotH(H,numlags,subplot_flag)
%this function plots the weights in H using imagesc for each
% column of H in different figures, or subplot if the flag is set
% the weigths are all normalized between -1 and 1, and returned
% as array

Nin  = size(H,1)/numlags;
Nout = size(H,2);

NormW = zeros(Nin,numlags,Nout);

if subplot_flag
    figure;
end

for o = 1:Nout
    for i = 1:Nin
        firstbin = 1+(i-1)*numlags;
        H_i = H(firstbin:firstbin+numlags-1,o);
        max_i = max(abs(H_i));
        NormW(i,:,o) = H_i/max_i;
    end
    if subplot_flag
        subplot(1,Nout,o);
    else
        figure;
    end
    imagesc(NormW(:,:,o));
    colorbar;
end