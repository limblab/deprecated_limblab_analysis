root_dir = 'F:\';
dataSummary;

doFiles = sessionList( ismember(sessionList(:,1),{'Mihili'}) & strcmpi(sessionList(:,3),'FF') & strcmpi(sessionList(:,4),'CO'),:);

d = cell(1,7);

for iFile = 1:size(doFiles,1)
    [t,c] = loadResults(root_dir,doFiles(iFile,:),'tuning',{'tuning','classes'},'M1','movement','regression','onpeak');
    for i = 1:7
        d{i} = [d{i}; sqrt(t(i).vels(:,1).^2 + t(i).vels(:,2).^2)];
    end
end

figure;
hold all;
for i = 1:7    
    plot(i,mean(d{i}),'ko');
    plot([i i],[mean(d{i}) - std(d{i})./sqrt(length(d{i})), mean(d{i}) + std(d{i})./sqrt(length(d{i}))],'k-');
end
set(gca,'Box','off','TickDir','out','FontSize',14,'XLim',[0 8]);



var(cell2mat(sResults(:,1)))
var([cell2mat(sResults(:,5)); cell2mat(sResults(:,6)); cell2mat(sResults(:,7))])

figure;
hold all;
[f,x] = hist((cell2mat(sResults(:,1))),0:1:120);
plot(0:1:120,cumsum(f)/sum(f))
[f,x] = hist([cell2mat(sResults(:,5)); cell2mat(sResults(:,6)); cell2mat(sResults(:,7))],0:1:120);
plot(0:1:120,cumsum(f)/sum(f))
set(gca,'XLim',[0 80])