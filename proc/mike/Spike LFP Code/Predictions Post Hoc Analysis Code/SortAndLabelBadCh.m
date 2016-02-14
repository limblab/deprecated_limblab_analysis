for i = 1:length(bestc)

    if sum(badChannels == bestc(i)) == 1
        BadChIndex(i) = 2;
    else
        BadChIndex(i) = 1;
    end
end

r2_X_SingleUnitsFirstFileDec1_HC = [r2_X_SingleUnitsFirstFileDec1_HC BadChIndex'];
r2_Y_SingleUnitsFirstFileDec1_HC = [r2_Y_SingleUnitsFirstFileDec1_HC BadChIndex'];

r2_X_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_X_SingleUnitsFirstFileDec1_HC,[size(r2_X_SingleUnitsFirstFileDec1_HC,2)-1 size(r2_X_SingleUnitsFirstFileDec1_HC,2) -1 ]);
r2_Y_SingleUnitsFirstFileDec1_HCSorted = sortrows(r2_Y_SingleUnitsFirstFileDec1_HC,[size(r2_Y_SingleUnitsFirstFileDec1_HC,2)-1 size(r2_X_SingleUnitsFirstFileDec1_HC,2) -1 ]);

r2_X_SingleUnitsFirstFileDec1_HCSortedbadchremov = r2_X_SingleUnitsFirstFileDec1_HCSorted;
r2_Y_SingleUnitsFirstFileDec1_HCSortedbadchremov = r2_Y_SingleUnitsFirstFileDec1_HCSorted;
j = 1;

for i = 1:length(bestc)-1

    if r2_X_SingleUnitsFirstFileDec1_HCSorted(i,171) == r2_X_SingleUnitsFirstFileDec1_HCSorted(i+1,171)
        continue
    else
        r2_X_badchIndex(j) = i;
        j = j+1;
    end
end

badchIndex = repmat(r2_X_badchIndex,2,1);
badchIndex = reshape(badchIndex,[4 6]);

badchIndex2 = repmat([0 169],1,12);
badchIndex2 = reshape(badchIndex2,[4 6]);

for k = 1:size(badchIndex,2)
    h(k) = fill(badchIndex2(:,k),badchIndex(:,k),'r')
    set(h(k),'FaceAlpha',.3)
end
