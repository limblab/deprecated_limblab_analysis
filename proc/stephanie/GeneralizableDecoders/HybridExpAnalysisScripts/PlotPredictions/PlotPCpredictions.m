function PlotPCpredictions(Actual_PC, Within_PC, Hybrid_PC, Across_PC, WithinVAF,HybridVAF,AcrossVAF,save,foldername, filename)

if nargin < 8
    save=0;
end


% Plot predictions of movement data----------------------------------------
%--------------------------------------------------------------------------
linewidth = 1.5;
x = (0:0.05:length(Actual_PC)*.05-0.05)';
figure;hold on;
plot(x,Actual_PC,'k','LineWidth', linewidth)
plot(x,Within_PC,'b','LineWidth', linewidth)
plot(x,Hybrid_PC,'g','LineWidth', linewidth)
plot(x,Across_PC,'r','LineWidth', linewidth)
title(filename)
legend('Actual',strcat('Within | vaf=',num2str(WithinVAF)),strcat('Hybrid | vaf=',num2str(HybridVAF)),strcat('Across | vaf=',num2str(AcrossVAF)))
MillerFigure;

% Save figure
if save == 1
    SaveFigure(foldername, filename)
end


 

 
 end