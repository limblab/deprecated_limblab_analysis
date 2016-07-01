function PolarSetup
% This function creates a polar plot background with radius of 1 and minimal/no labels
% It also has a circle at r=0.5 and dashed lines along the 8 paths to each target

figure;
colorvector = [.5 .5 .5];
lineH = polar([0 pi], [1 1], '--'); % Horizontal 
set( findobj(lineH, 'Type', 'line'),'Color', colorvector);
hold on;
%------------------------------------------------------------------
lineH = polar([pi/2 pi+pi/2], [1 1],'--'); % Vertical
set( findobj(lineH, 'Type', 'line'),'Color', colorvector);
%------------------------------------------------------------------
lineH = polar([(pi/4) pi+(pi/4)], [1 1],'--');
set( findobj(lineH, 'Type', 'line'),'Color', colorvector);
%------------------------------------------------------------------
lineH = polar([(pi/4)*3 pi+(pi/4)*3], [1 1],'--');
set( findobj(lineH, 'Type', 'line'),'Color', colorvector);
%------------------------------------------------------------------
% Draw circle at r=0.5
circle([0 0],.5,[.7 .7 .7],1)

% Delete text
polartext = (findall(gcf,'type','text'));
delete(polartext(1:12)); 
polartext(14).String = '  0.5';
polartext(14).Position = [0.0849 0.5041 0];
delete(polartext(15:end))

%Delete extraneous lines
lines = findall(gcf,'type','line');
delete(lines(6:end,:))


 end