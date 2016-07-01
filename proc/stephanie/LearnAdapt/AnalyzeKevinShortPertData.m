% AnalyzeKevinShortPertData

tic
BaseFolder = 'Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\Kevin\ShorterPerturbationDays_Kevin\';
FileName = {'ShortPert_Kevin_040215_ref','ShortPert_Kevin_040315_rot',...
    'ShortPert_Kevin_040615_ref', 'ShortPert_Kevin_040715_rot','ShortPert_Kevin_041015_rot',...
    'ShortPert_Kevin_041515_ref','ShortPert_Kevin_041615_rot','ShortPert_Kevin_041715_rot'...
    'ShortPert_Kevin_042015_ref','ShortPert_Kevin_042315_ref'};

 Normal1PercentSuccess = -1*ones(1,length(FileName)); Normal2PercentSuccess = -1*ones(1,length(FileName)); Normal3PercentSuccess = -1*ones(1,length(FileName));
Rotated1PercentSuccess = -1*ones(1,length(FileName)); Rotated2PercentSuccess = -1*ones(1,length(FileName)); Rotated3PercentSuccess = -1*ones(1,length(FileName));
Reflected1PercentSuccess = -1*ones(1,length(FileName)); Reflected2PercentSuccess = -1*ones(1,length(FileName)); Reflected3PercentSuccess = -1*ones(1,length(FileName));

for i = 1:length(FileName)
    load(strcat(BaseFolder,FileName{i}))
    currentFile = FileName{i};
   date =  FileName{i}(17:22);
   
   [~, ~, ~, ~, TrialsStructNormal1] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_normal1']));
   Normal1PercentSuccess(i) = ComputeSessionSuccess(TrialsStructNormal1);
    [~, ~, ~, ~, TrialsStructNormal2] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_normal2']));
   Normal2PercentSuccess(i) = ComputeSessionSuccess(TrialsStructNormal2);
      [~, ~, ~, ~, TrialsStructNormal3] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_normal3']));
   Normal3PercentSuccess(i) = ComputeSessionSuccess(TrialsStructNormal3);
   
   if (FileName{i}(end-2:end)) == 'ref'
       [~, ~, ~, ~, TrialsStructReflected1] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_reflected1']));
       Reflected1PercentSuccess(i) = ComputeSessionSuccess(TrialsStructReflected1);
       [~, ~, ~, ~, TrialsStructReflected2] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_reflected2']));
       Reflected2PercentSuccess(i) = ComputeSessionSuccess(TrialsStructReflected2);
       [~, ~, ~, ~, TrialsStructReflected3] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_reflected3']));
       Reflected3PercentSuccess(i) = ComputeSessionSuccess(TrialsStructReflected3);
       
   else if (FileName{i}(end-2:end)) == 'rot'
           [~, ~, ~, ~, TrialsStructRotated1] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_rotated1']));
           Rotated1PercentSuccess(i) = ComputeSessionSuccess(TrialsStructRotated1);
           [~, ~, ~, ~, TrialsStructRotated2] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_rotated2']));
           Rotated2PercentSuccess(i) = ComputeSessionSuccess(TrialsStructRotated2);
           [~, ~, ~, ~, TrialsStructRotated3] = ComputeTaskTimeMetrics(eval(['out_struct_' date '_rotated3']));
           Rotated3PercentSuccess(i) = ComputeSessionSuccess(TrialsStructRotated3);
       end
   end
   
   
   clearvars -except  Normal1PercentSuccess Normal2PercentSuccess Normal3PercentSuccess ...
   Rotated1PercentSuccess Rotated2PercentSuccess Rotated3PercentSuccess  ...
   Reflected1PercentSuccess Reflected2PercentSuccess Reflected3PercentSuccess ...
    BaseFolder FileName
   
   
end

Normal1means = mean(Normal1PercentSuccess); Normal1std = std(Normal1PercentSuccess); Normal1ste = Normal1std/sqrt(length(Normal1PercentSuccess));
Normal2means = mean(Normal2PercentSuccess); Normal2std = std(Normal2PercentSuccess); Normal2ste = Normal1std/sqrt(length(Normal2PercentSuccess));
Normal3means = mean(Normal3PercentSuccess); Normal3std = std(Normal3PercentSuccess); Normal3ste = Normal1std/sqrt(length(Normal3PercentSuccess));

Reflected1PercentSuccess(find(Reflected1PercentSuccess==-1)) = [];
Reflected2PercentSuccess(find(Reflected2PercentSuccess==-1)) = [];
Reflected3PercentSuccess(find(Reflected3PercentSuccess==-1)) = [];
Reflected1means = mean(Reflected1PercentSuccess); Reflected1std = std(Reflected1PercentSuccess); Reflected1ste = Reflected1std/sqrt(length(Reflected1PercentSuccess));
Reflected2means = mean(Reflected2PercentSuccess); Reflected2std = std(Reflected2PercentSuccess); Reflected2ste = Reflected1std/sqrt(length(Reflected2PercentSuccess));
Reflected3means = mean(Reflected3PercentSuccess); Reflected3std = std(Reflected3PercentSuccess);  Reflected3ste = Reflected1std/sqrt(length(Reflected3PercentSuccess));

Rotated1PercentSuccess(find(Rotated1PercentSuccess==-1)) = [];
Rotated2PercentSuccess(find(Rotated2PercentSuccess==-1)) = [];
Rotated3PercentSuccess(find(Rotated3PercentSuccess==-1)) = [];
Rotated1means = mean(Rotated1PercentSuccess); Rotated1std = std(Rotated1PercentSuccess); Rotated1ste =  Rotated1std/sqrt(length(Rotated1PercentSuccess)); 
Rotated2means = mean(Rotated2PercentSuccess); Rotated2std = std(Rotated2PercentSuccess); Rotated2ste =  Rotated2std/sqrt(length(Rotated2PercentSuccess)); 
Rotated3means = mean(Rotated3PercentSuccess); Rotated3std = std(Rotated3PercentSuccess); Rotated3ste =  Rotated3std/sqrt(length(Rotated3PercentSuccess)); 
toc

figure; hold on;
MarkerSize = 35; LineWidth = 3;
ylim([0 1]); xlim([0.5 3.5])
rectangle('Position',[1.5 0.01 1 1], 'FaceColor',[.95 .95 .95],'EdgeColor','none')
for n = 1:3
h(1)=plot(n,eval(['Normal' num2str(n) 'means']),'k.','MarkerSize',MarkerSize,'DisplayName','Normal')
plot([n n], [eval(['Normal' num2str(n) 'means']) - eval(['Normal' num2str(n) 'ste']) (eval(['Normal' num2str(n) 'means']) + eval(['Normal' num2str(n) 'ste']))],'k-','LineWidth',LineWidth)
end
 
for n = 1:3
h(2)=plot(n,eval(['Rotated' num2str(n) 'means']),'g.','MarkerSize',MarkerSize,'DisplayName','Rotated')
plot([n n], [eval(['Rotated' num2str(n) 'means']) - eval(['Rotated' num2str(n) 'ste']) (eval(['Rotated' num2str(n) 'means']) + eval(['Rotated' num2str(n) 'ste']))],'g-','LineWidth',LineWidth)
end

for n = 1:3
h(3)=plot(n,eval(['Reflected' num2str(n) 'means']),'r.','MarkerSize',MarkerSize,'DisplayName','Reflected')
plot([n n], [eval(['Reflected' num2str(n) 'means']) - eval(['Reflected' num2str(n) 'ste']) (eval(['Reflected' num2str(n) 'means']) + eval(['Reflected' num2str(n) 'ste']))],'r-','LineWidth',LineWidth)
end
legend(h(1:3))
MillerFigure;set(gca,'XTick',[1 2 3])




