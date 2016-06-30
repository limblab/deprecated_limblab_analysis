function [selectivity] = selectivity( electrode,emgNumber )
%SELECTIVITY Summary of this function goes here
%   Detailed explanation goes here

if emgNumber == 7
    emgNumber = emgNumber-1;
end

%% Ensure that the PW isn't empty
if size(electrode.PW,1) == 1
    return
end

%% Sort the normalized data with respect to PW and find locations for which
%  the selectivity reaches 20%

tempData = [electrode.PW electrode.normalized(:,1:emgNumber-1)];
sortedData = sortrows(tempData);
threshold = sortedData(:,2:emgNumber)<=0.2;

%%  Allocate space for index of locations
allLoc = zeros(2,5);

%% Extract the specific locations - if a muclse doesn't reach 20%, a = 999
for i=1:emgNumber-1
    allLoc(1,i)=i;
    a = find(threshold(:,i)<=0,1,'first');
    
    if isempty(a) == 1
        a=999;
    end
    
    allLoc(2,i) = a;
end

allLoc=allLoc';
sorted = sortrows(allLoc,2);

t = sprintf('Selectivity for muscle \n');t1=sprintf('\n in percent is \n');

%% Defining muscles

muscles = char('FDS', 'FCR', 'FPB', 'OP' ,'FDP');

%% If only one muscle reaches 20% that givens muscles selectivity is choosen
if sorted(2,2)==999
    disp(t)
    disp(muscles(sorted(1,1),:))
    disp(t1)
    disp(max(sortedData(:,sorted(1,1)+1))*100)
    mscl = num2str(muscles(sorted(1,1),:));
    slctv = num2str(max(sortedData(:,sorted(1,1)+1))*100);
    selectivity = [mscl ' ' slctv '' '%'];
    return
end

disp(t)
disp(muscles(sorted(1,1),:))
disp(t1)
disp(sortedData(sorted(2,2)-1,sorted(1,1)+1)*100);
mscl = num2str(muscles(sorted(1,1),:));
slctv = num2str(sortedData(sorted(2,2)-1,sorted(1,1)+1)*100);
selectivity = [mscl ' ' slctv '' '%'];

end