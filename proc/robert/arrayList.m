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


% n=2; k=1;
% while n<numel(numIn)
%     if numIn(n)==breaks(k)
%         txtOut=[txtOut, ' '];
%         n=breaks(k)+1;
%         k=k+1;
%     else
%         continue
%     end
% end



