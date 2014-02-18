%Fix trial table for horizontal task
%Numbers the targets 1-6 going left to right on the screen

for i=1:length(binnedData.trialtable)
    switch binnedData.trialtable(i,2)
        case -11.5
            binnedData.trialtable(i,10)=1;
        case -9.5
            binnedData.trialtable(i,10)=2;
        case -6.5
            binnedData.trialtable(i,10)=3;
        case 3.5
            binnedData.trialtable(i,10)=4;
        case 6.5
            binnedData.trialtable(i,10)=5;
        case 8.5
            binnedData.trialtable(i,10)=6;
    end
end