function plotIsometricForce(trialTable,force,markSuccess)
% Plots force traces and marks trials and catch trials
% filename: string to file
% trialType: 'CT', 'HC', or 'BC'... right now HC and BC are same
% markSuccess: boolean to mark only successful trials

if nargin < 3
    markSuccess = false;
end

% Only use the successful trials
if markSuccess
    trialTable = trialTable(trialTable(:,9)==82,:);
end

startTimes = trialTable(:,1);
endTimes = trialTable(:,8);

t = force.data(:,1);
x = force.data(:,2);
y = force.data(:,3);

figure;
% Plot the forces in x and y
subplot1(2,1);
subplot1(1);
hold all

% Add markers for trials
%   If trialType is CT, mark CTs. otherwise, just plot box
for ind = 1:length(startTimes)
    if trialTable(ind,11) == 1
        fc = [0.2 .6 .8]; % face color during catch trial
    elseif trialTable(ind,11) == 2
        fc = [0.8 .6 .2]; % face color during catch trial
    else
        fc = [0.6 0.6 0.6]; % normal face color
    end
    rectangle('Position',[startTimes(ind) -500 endTimes(ind)-startTimes(ind) 1000], 'FaceColor',fc,'EdgeColor','none');
end

plot(t,x,'LineWidth',2);
axis('tight');

subplot1(2);
hold all

% Add markers for trials
%   If trialType is CT, mark CTs. otherwise, just plot box
for ind = 1:length(startTimes)
    if trialTable(ind,11) == 1
        fc = [0.2 .6 .8]; % face color during catch trial
    elseif trialTable(ind,11) == 2
        fc = [0.8 .6 .2]; % face color during catch trial
    else
        fc = [0.6 0.6 0.6]; % normal face color
    end
    rectangle('Position',[startTimes(ind) -500 endTimes(ind)-startTimes(ind) 1000], 'FaceColor',fc,'EdgeColor','none');
end
plot(t,y,'LineWidth',2);
axis('tight');

end