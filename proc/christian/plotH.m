function plotH(H,fillen,channels)
%this function plots the weights in H using imagesc for the specified
%channels (muscle, force, etc.)

Ninputs = size(H,1)/fillen;
Hmod = zeros(Ninputs,fillen);
    
for c = 1:length(channels)
    chan = channels(c);

    for i = 1:Ninputs
        H_i = 1+(i-1)*fillen;
        Hmod(i,:) = H(H_i:H_i+fillen-1,chan);
    end

    figure; imagesc(Hmod);

end