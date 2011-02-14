
morefiles = true;
Stats = {};

while morefiles
    plotflag = 1;
    datapath = 'C:\Monkey\Jaco\Data\BDFStructs\';
    NewStats = bd_fes_exp(datapath,plotflag);
    if isempty(NewStats)
        break;
    else
        Stats = [Stats;NewStats];
    end
end

    


