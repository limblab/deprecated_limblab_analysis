%Fix trial table for horizontal task
%Numbers the targets 1-6 going left to right on the screen

for i=1:length(binnedData.trialtable)
    switch binnedData.trialtable(i,2)
        case -10
            binnedData.trialtable(i,10)=1;
        case -8
            binnedData.trialtable(i,10)=2;
        case -6
            binnedData.trialtable(i,10)=3;
        case 4
            binnedData.trialtable(i,10)=4;
        case 6
            binnedData.trialtable(i,10)=5;
        case 8
            binnedData.trialtable(i,10)=6;
    end
end