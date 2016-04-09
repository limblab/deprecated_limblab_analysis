function obsNoise = get_obs_noise(ampst,stdF)

[numstim,nmusc] = size(ampst);
obsNoiseT = nan(numstim,nmusc);
ampNoise = nan(numstim,nmusc);
for ii = 1:nmusc
    % Sort amps for given muscle in ascending order
    TF = ~isnan(ampst(:,ii));
    b1 = unique(ampst(TF,ii), 'first');

    for jj = 1:length(b1)
        ind = find(ampst(:,ii)==b1(jj));
        if ~isempty(ind)
            TFi = ~isnan(stdF(ind,ii));
            obsNoiseT(jj,ii) = sum(stdF(ind(TFi),ii))/length(ind(TFi));
            ampNoise(jj,ii) = ampst(ind(1),ii);
        end
    end
end
% Sort in ascending order
[ampNoise,IX] = sort(ampNoise);
for j = 1:size(IX,2)
    obsNoiseT(:,j) = obsNoiseT(IX(:,j),j); 
end
obsNoise.noise = obsNoiseT;
obsNoise.amps = ampNoise;