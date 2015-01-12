function TSS=trueSkillStatistic(trueGroups,predGroups)

% syntax TSS=trueSkillStatistic(trueGroups,predGroups);
%
% also known as the Pierce Skill Score, this is a quantity for
% evaluating classifier data.  It takes into account the frequency
% with which classes are predicted.  For example, if class A is
% predicted correctly 90% of the time, we might be tempted to think
% that is a great classifier.  But if 90% of the elements in 
% trueGroups belong to A, then the classifier can just 
% predict A 100% of the time (i.e. massive bias) and still 
% get a 90% success rate.  The TSS, on the other hand, would 
% be 0(?) for such a case.
%
% Right now, this is only implemented for 2-class arrangements.
%
%           INPUTS
%                       trueGroups  - data labelled with actual
%                                     correct labels
%                       predGroups  - output of the classifier
%           OUTPUTS
%                       TSS         - the True Skill Statistic

u_trueGroups=unique(trueGroups);
classPop=zeros(size(u_trueGroups));
if iscell(trueGroups)
    for n=1:numel(u_trueGroups)
        classPop(n)=nnz(strcmp(u_trueGroups{n},trueGroups));
    end
    % group1 should always be the majority group
    [~,ind]=max(classPop);
    was1=strcmp(trueGroups,u_trueGroups{ind});
    says1=strcmp(predGroups,u_trueGroups{ind});
else
    for n=1:numel(u_trueGroups)
        classPop(n)=nnz(u_trueGroups(n)==trueGroups);
    end
    % group1 should always be the majority group
    [~,ind]=max(classPop);
    was1=trueGroups==u_trueGroups(ind);
    says1=predGroups==u_trueGroups(ind);    
end

a=nnz(was1 & says1);
b=nnz(~was1 & says1);
c=nnz(was1 & ~says1);
d=nnz(~was1 & ~says1);
TSS=(a*d - b*c)/((a+c) * (b+d));
