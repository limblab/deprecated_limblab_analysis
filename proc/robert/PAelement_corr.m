function allElementCorr=PAelement_corr(PA)

% all possible pairs of elements
combos=nchoosek(1:size(PA,1),2);

for n=1:size(PA,2)
    for k=1:size(combos,1)
        allElementCorr(n,k)=corr(squeeze(PA(combos(k,1),n,:)), ...
            squeeze(PA(combos(k,2),n,:)));
    end
end

%%
Cbox=zeros(size(PA,1));
for n=1:size(allElementCorr,1)
    for k=1:size(combos,1)
        Cbox(combos(k,1),combos(k,2))=Cbox(combos(k,1),combos(k,2))+allElementCorr(n,k); 
    end
end
Cbox=Cbox./size(allElementCorr,1);
for k=1:size(PA,1)
    Cbox(k,k)=1.0;
end
figure, imagesc(Cbox)








%%
% interaction between spectral power bands.  
% already seen that there's not much correlation between pairs of bins,
% except with immediate neighbors.  Only at the low end of the spectrum
% does this not hold true; say below maybe around 30 Hz.  

% could the correlation between neighboring bins be the result of some kind
% of bleed from one power bin to the next?  Something caused by windowing,
% or the nature of using the FFT to separate frequencies.  I'm thinking
% about the imperfect dropoff of real filters.  
% could use BPF to separate frequencies, calculate the power that way.
% Then, see if the pattern of correlations is the same.  
% the question is: what is a reasonable spectral binning scheme?

% or is the question something else.  Does force change more slowly than
% kinematics?  No, not really.  Does isometric force differ from movement
% in some important way?  Only in the sense that movement is not required.
% The neural signals are then shown to be encoding muscle activity and not
% just position.  But that's old news.  

% how do the different frequency bands interact?  Do they interact?  Can we
% detect something like beta suppresion at movement onset in a continuous
% movement task?  Is there something in this that shows averaging to be
% unwise?  