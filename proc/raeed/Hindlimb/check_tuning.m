function p = check_tuning(activity)

%check using 1 way ANOVA (as in Bosco and Poppele 1996 J. Neurophys)
p = zeros(size(activity,1),1);

for i = 1:length(activity)
    p(i) = anova1(activity(i,:)',[],'off');
end