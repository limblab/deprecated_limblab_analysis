function plotH(H,fillen,chan)
%this function plots the weights in H using imagesc for the specified
%channel (muscle, force, etc.)

Ninputs = size(H,1)/fillen;
Hmod = zeros(Ninputs,fillen);

for i = 1:Ninputs
    H_i = 1+(i-1)*fillen;
    Hmod(i,:) = H(H_i:H_i+fillen-1,chan);
end

figure; imagesc(Hmod);
end