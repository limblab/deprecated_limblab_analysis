function name=machineName

if ispc
    [status,result]=dos('ipconfig /all');
    if status==0
        nCharPerLine = diff([0 find(result == char(10)) numel(result)]);
        cellData = strtrim(mat2cell(result,1,nCharPerLine));
        nameLine=find(cellfun(@isempty,regexpi(cellData,'(?<=Host Name.*: ).*'))==0, 1);
        if ~isempty(nameLine)
            name=regexpi(cellData{nameLine},'(?<=Host Name.*: ).*','match','once');
        else
            error('ipconfig /all was not able to resolve the machine name')
        end
    else
        error('ipconfig /all was not able to resolve the machine name')
    end
elseif ismac
    [status,result]=unix('scutil --get ComputerName');
    if status==0
        name=result;
    else
        name='';
    end
end

name(regexp(name,sprintf('\n')))='';
