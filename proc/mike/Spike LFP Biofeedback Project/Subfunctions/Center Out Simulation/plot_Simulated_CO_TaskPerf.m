AllTTT = cell([1 size(Task,1)]);
AllPL = cell([1 size(Task,1)]);
Success = [];
SuccessTimes = [];
SuccessTTT = cell([1 size(Task,1)]);
SuccessPL = cell([1 size(Task,1)]);
Fail = [];
FailTimes = [];
FailTTT = cell([1 size(Task,1)]);
FailPL = cell([1 size(Task,1)]);
Abort = [];
AbortTimes = [];
Incomplete = [];
IncompleteTTT = cell([1 size(Task,1)]);
IncompletePL = cell([1 size(Task,1)]);

for ci = 1:size(Task,1) % Index across correlations
    for it = 1:size(Task,2) % Index across iterations
        for fi = 1:size(Task,3) % Index across files
            Success(ci,it,fi) = [Task{ci,it,fi}.Success];           
%             SuccessTimes = [SuccessTimes Task{ci,it,fi}.SuccessTimes];
            Fail(ci,it,fi) = [Task{ci,it,fi}.Fail];
%             FailTimes = [Success Task{ci,it,fi}.Success];
            Abort(ci,it,fi) = [Task{ci,it,fi}.Abort];
%             AbortTimes = [Success Task{ci,it,fi}.Success];
            Incomplete(ci,it,fi) = [Task{ci,it,fi}.Incomplete];
            
            if isfield(Task{ci,it,fi},'Success_TTT')
                AllTTT{1,ci} = [AllTTT{1,ci}; Task{ci,it,fi}.Success_TTT'];
                AllPL{1,ci} = [AllPL{1,ci}; Task{ci,it,fi}.Success_PL'];
                SuccessTTT{1,ci} = [SuccessTTT{1,ci}; Task{ci,it,fi}.Success_TTT']; 
                SuccessPL{1,ci} = [SuccessPL{1,ci}; Task{ci,it,fi}.Success_PL'];                 
            end
            
            if isfield(Task{ci,it,fi},'Fail_TTT')
                AllTTT{1,ci} = [AllTTT{1,ci}; Task{ci,it,fi}.Fail_TTT'];
                AllPL{1,ci} = [AllPL{1,ci}; Task{ci,it,fi}.Fail_PL'];
                FailTTT{1,ci} = [FailTTT{1,ci}; Task{ci,it,fi}.Fail_TTT']; 
                FailPL{1,ci} = [FailPL{1,ci}; Task{ci,it,fi}.Fail_PL']; 
            end   
            
            if isfield(Task{ci,it,fi},'Incomplete_TTT')
                AllTTT{1,ci} = [AllTTT{1,ci}; Task{ci,it,fi}.Incomplete_TTT'];
                AllPL{1,ci} = [AllPL{1,ci}; Task{ci,it,fi}.Incomplete_PL'];
                IncompleteTTT{1,ci} = [IncompleteTTT(1,ci); Task{ci,it,fi}.Incomplete_TTT']; 
                IncompletePL{1,ci} = [IncompletePL(1,ci); Task{ci,it,fi}.Incomplete_PL']; 
            end
        end
    end
end

meanAllTTT_MAT = cellfun(@mean,AllTTT);
meanAllTTT_MAT = flip([flip(meanAllTTT_MAT(1:10)) meanAllTTT_MAT(11:20)]);
stdAllTTT_MAT = cellfun(@std,AllTTT)./sqrt(sum(cellfun(@length,AllTTT)));
stdAllTTT_MAT = flip([flip(stdAllTTT_MAT(1:10)) stdAllTTT_MAT(11:20)]);
figure
shadedErrorBar([-1:.1:-.1 .1:.1:1],meanAllTTT_MAT,stdAllTTT_MAT)
title('Time to Target Over All Simulated Correlations')
ylabel('TTT')
xlabel('Percent change to signal')

meanAllPL_MAT = cellfun(@mean,AllPL);
meanAllPL_MAT = flip([flip(meanAllPL_MAT(1:10)) meanAllPL_MAT(11:20)]);
stdAllPL_MAT = cellfun(@std,AllPL)./sqrt(sum(cellfun(@length,AllPL)));
stdAllPL_MAT = flip([flip(stdAllPL_MAT(1:10)) stdAllPL_MAT(11:20)]);
figure
shadedErrorBar([-1:.1:-.1 .1:.1:1],meanAllPL_MAT,stdAllPL_MAT)
title('Path Length Over All Simulated Correlations')
ylabel('PL')
xlabel('Percent change to signal')

meanSuccessTTT_MAT = cellfun(@mean,SuccessTTT);
meanSuccessTTT_MAT = flip([flip(meanSuccessTTT_MAT(1:11)); meanSuccessTTT_MAT(13:22)]);
stdSuccessTTT_MAT = cellfun(@std,SuccessTTT)./sqrt(sum(cellfun(@length,SuccessTTT)));
stdSuccessTTT_MAT = flip([flip(stdSuccessTTT_MAT(1:11)); stdSuccessTTT_MAT(13:22)]);
shadedErrorBar(-1:.1:1,meanSuccessTTT_MAT,stdSuccessTTT_MAT)

meanSuccessPL_MAT = cellfun(@mean,SuccessPL);
meanSuccessPL_MAT = flip([flip(meanSuccessPL_MAT(1:11)); meanSuccessPL_MAT(13:22)]);
stdSuccessPL_MAT = cellfun(@std,SuccessPL)./sqrt(sum(cellfun(@length,SuccessPL)));
stdSuccessPL_MAT = flip([flip(stdSuccessPL_MAT(1:11)); stdSuccessPL_MAT(13:22)]);
shadedErrorBar(-1:.1:1,meanSuccessPL_MAT,stdSuccessPL_MAT)

meanFailTTT_MAT = mean(mean(FailTTT,2),3);
meanFailTTT_MAT = flip([flip(meanFailTTT_MAT(1:11)); meanFailTTT_MAT(13:22)]);
stdFailTTT_MAT = std(std(FailTTT,0,2),0,3);
stdFailTTT_MAT = flip([flip(stdFailTTT_MAT(1:11)); stdFailTTT_MAT(13:22)]);
figure
shadedErrorBar(-1:.1:1,meanFailTTT_MAT,stdFailTTT_MAT)

meanFailPL_MAT = mean(mean(FailPL,2),3);
meanFailPL_MAT = flip([flip(meanFailPL_MAT(1:11)); meanFailPL_MAT(13:22)]);
stdFailPL_MAT = std(std(FailPL,0,2),0,3);
stdFailPL_MAT = flip([flip(stdFailPL_MAT(1:11)); stdFailPL_MAT(13:22)]);
figure
shadedErrorBar(-1:.1:1,meanFailPL_MAT,stdFailPL_MAT)

meanIncomplete_MAT = mean(mean(Incomplete,2),3);
meanIncomplete_MAT = flip([flip(meanIncomplete_MAT(1:11)); meanIncomplete_MAT(13:22)]);
stdIncomplete_MAT = std(std(Incomplete,0,2),0,3);
stdIncomplete_MAT = flip([flip(stdIncomplete_MAT(1:11)); stdIncomplete_MAT(13:22)]);
figure
shadedErrorBar(-1:.1:1,meanIncomplete_MAT,stdIncomplete_MAT)

meanAbort_MAT = mean(mean(Abort,2),3);
meanAbort_MAT = flip([flip(meanAbort_MAT(1:11)); meanAbort_MAT(13:22)]);
stdAbort_MAT = std(std(Abort,0,2),0,3);
stdAbort_MAT = flip([flip(stdAbort_MAT(1:11)); stdAbort_MAT(13:22)]);
figure
shadedErrorBar(-1:.1:1,meanAbort_MAT,stdAbort_MAT)
