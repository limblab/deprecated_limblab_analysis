function PlotPCpredictions_Spring(Actual_PC, Within_PC, Hybrid_PC, AcrossI_PC, AcrossW_PC,WithinVAF,HybridVAF,AcrossIVAF,AcrossWVAF,save,foldername, filename)

if nargin < 10
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
plot(x,AcrossI_PC,'r','LineWidth', linewidth)
plot(x,AcrossW_PC,'r','LineWidth', linewidth)
title(filename)
legend('Actual',strcat('Within | vaf=',num2str(WithinVAF)),strcat('Hybrid | vaf=',num2str(HybridVAF)),strcat('I on S | vaf=',num2str(AcrossIVAF)),strcat('W on S | vaf=',num2str(AcrossWVAF)))
MillerFigure;

% Save figure
if save == 1
    SaveFigure(foldername, filename)
end


 

 
 end