function commonIntersection=intersect_regex(matchPattern)

% syntax commonIntersection=intersect_regex(matchPattern)


S=evalin('caller','whos');

S(cellfun(@isempty,regexp({S.name},matchPattern)))=[];

for n=1:length(S)
    allMatchVars{n}=evalin('caller',S(n).name);
end
temp=cellfun(@(x) reshape(x,numel(x),[]),allMatchVars,'UniformOutput',0);
commonIntersection=unique(cat(1,temp{:}));
