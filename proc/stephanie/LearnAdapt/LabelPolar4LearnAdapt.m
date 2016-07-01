function LabelPolar4LearnAdapt(MetricStruct)
%This function puts target labels and trial numbers on the polar pluts for
%the Learn adapt experiment

% Input: MetricStruct should be a struct that contains metrics for the
% targets separately. IE: MetricStruct.Target1, MetricStruct.Target2

%Delete all present labels
polartext = (findall(gcf,'type','text'));
%delete(polartext(1:12))
xlims = get(gca,'xlim');
radius = xlims(2)+xlims(2)/8;
text(radius,0,strcat(['n=' num2str(length(MetricStruct.Target1))]))
text(radius/sqrt(2),radius/sqrt(2),strcat(['n=' num2str(length(MetricStruct.Target2))]))
text(-radius/12,radius,strcat(['n=' num2str(length(MetricStruct.Target3))]))
text(-radius/sqrt(2)-xlims(2)/4,radius/sqrt(2),strcat(['n=' num2str(length(MetricStruct.Target4))]))
text(-radius-xlims(2)/4,0,strcat(['n=' num2str(length(MetricStruct.Target5))]))
text(-radius/sqrt(2)-xlims(2)/4,-radius/sqrt(2),strcat(['n=' num2str(length(MetricStruct.Target6))]))
text(0,-radius,strcat(['n=' num2str(length(MetricStruct.Target7))]))
text(radius/sqrt(2),-radius/sqrt(2),strcat(['n=' num2str(length(MetricStruct.Target8))]))

end
