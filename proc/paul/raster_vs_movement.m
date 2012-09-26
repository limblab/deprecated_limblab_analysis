% this is VERY quick and dirty

clear all; close all;clc;
%50ms bin is standard
load sortedunits_MrT_09252012.mat;
load kin_MrT_09252012.mat;

numunits = length(sortedunits);
numtrials = size(kin.ts,1);
totsmall = length(find(kin.feedback==0.5));

for ui=1:numunits
    figure;
    numsmall=0;
    numlarge=0;
    for ti=1:numtrials
        temp = find(~isnan(kin.ts(ti,:)));
        trange = kin.ts(ti,temp);
        
        spikerange=find(sortedunits(ui).ts>=trange(1) & sortedunits(ui).ts<=trange(end));
        if kin.feedback(ti)==0.5
            clr = 'r.';
            numsmall=numsmall+1;
            con=numsmall;
        elseif kin.feedback(ti)==3.5
            clr = 'b.';
            numlarge=numlarge+1;
            con=totsmall+numlarge;
        end
        if ~isempty(spikerange)
            plot(sortedunits(ui).ts(spikerange)-trange(1),con,clr);
            hold on;
        end
    end
end