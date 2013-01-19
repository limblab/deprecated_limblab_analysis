function Hnew = removefreqband(bandNum, H, featind, bestc, bestf)

FreqBand_Index = [];

for i = 1:length(bandnum)
    FreqBand_Index = [FreqBand_Index bandNum:6:576];
end

FreqBand_Index = FreqBand_Index';

featind_bychan = sortrows([featind' bestc' bestf'],[2 3]);
[c, ic, id] = intersect(featind_bychan(:,1), FreqBand_Index);
Hnew = H;

for i = 1:length(ic)
    Hnew((ic(i)-1)*10+1:ic(i)*10,:) = 0;
end


end