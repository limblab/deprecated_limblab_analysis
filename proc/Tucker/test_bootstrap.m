function [stats,raw_out,raw_in]=test_bootstrap()

    data=rand(1000,2);
    [stats,raw_out,raw_in]=bootstrap_with_stats(@testfun,data,[],100,500,true,.9);

end

function out=testfun(matrix)
    out=mean(matrix);
end