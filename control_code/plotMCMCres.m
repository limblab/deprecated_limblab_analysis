
function plotMCMCres(S,x1,x,y,tc_func_name)

cla
plot(x,y+randn(size(x))/20,'.k');
hold on

if iscell(S)
    cmap = lines(length(S));
    for i=1:length(S)
        plotMCMCres_single(S{i},x1,tc_func_name{i},cmap(i,:));
    end
else
    plotMCMCres_single(S,x1,tc_func_name,'r');
end
hold off
axis tight

function plotMCMCres_single(S,x1,tc_func_name,col)
    y2=zeros(length(S.P1),length(x1));
    for i=1:length(S.P1)
        y2(i,:)=getTCval(x1,tc_func_name,[S.P1(i) S.P2(i) S.P3(i) S.P4(i)])';
%         plot(x1,y2,'Color',col,'FaceAlpha',(S.log_llhd(i)-min(S.log_llhd))./(max(S.log_llhd)-min(S.log_llhd)));
    end
    plot(x1,y2,'Color',col);
    hold on
    y1=getTCval(x1,tc_func_name,[S.P1_median S.P2_median S.P3_median S.P4_median]);
    plot(x1,y1,'Color',col,'linewidth',2);