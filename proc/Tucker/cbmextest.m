function trialdata = cbmextest(cyclenum)

name = ['./test1/testdata' num2str(cyclenum) '.mat'];
try
    load(name, 'trialdata');
catch
    name = ['./test2/testdata', num2str(cyclenum-100), '.mat'];
    load(name, 'trialdata');
end
end
