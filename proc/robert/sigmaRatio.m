function SRreturn=sigmaRatio(plxPathIn,verbose)

units=get_waveforms_plx(plxPathIn,struct('verbose',verbose));

% some logic to decide where the cutoff to decide baseline should be, given
% the number of points pre-threshold, as well as the knowledge that the
% waveforms tend to be dipping down towards the thresholds for the last few
% points beforehand.  Example, with 8 points pre-threshold, generally only
% the first 5 can truly be considered to be 'baseline' points.

units(cellfun(@isempty,{units.id}))=[];

SRreturn=zeros(size(units));

for n=1:length(units)
    SRreturn(n)=abs(units(n).thresh)/ ...
        mean(abs(mean(units(n).waveforms(:,1:5),2))); 
end