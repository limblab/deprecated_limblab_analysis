
%Rename files

D = dir(Y:\User_folders\Stephanie\Data Analysis\LearnAdapt\Kevin\LongerPerturbationDays_Kevin')
for i = 3:length(D)
    currentname = D(i).name;
    cutstrings = strsplit(currentname,'Kevin');
    movefile(currentname,char(strcat('Jango',cutstrings(2))));
end