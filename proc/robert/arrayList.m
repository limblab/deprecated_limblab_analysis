function txtOut=arrayList(numIn)

breaks=find(diff(numIn)>1);
txtOut=['[', num2str(numIn(1))];
% if breaks(1)==numel(2)
%     txtOut(end)=[];
% end
for n=1:numel(breaks)
    txtOut=[txtOut, ':', num2str(numIn(breaks(n))), ...
        ',', num2str(numIn(breaks(n)+1))];                                  %#ok<*AGROW>
end
txtOut=[txtOut, ':', num2str(numIn(end)), ']'];

return



