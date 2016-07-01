  function PlotTargets(out_struct)
  % This function plots the 8 targets for the task in their correct
  % position. Gets target size information from the trialtable.
  
  
  % Extract target info from trial table and plot targets
  trialtable = GetFixTrialTable(out_struct,'learnadapt',0);
  colors = distinguishable_colors(9);
  [~, TgtInd] = unique(trialtable(:,10));
  figure; hold on; axis('square'); xlim([-14 14]); ylim([-14 14]);
  MillerFigure;
  rectangle('Position',[-2,-2,4,4],'EdgeColor',[0.7 0.7 0.7])
  for i=1:length(TgtInd)
      width = trialtable(TgtInd(i),4)-trialtable(TgtInd(i),2);
      height = trialtable(TgtInd(i),3)-trialtable(TgtInd(i),5);
      % Get lower left target coordinates
      LLx = trialtable(TgtInd(i),2); LLy = trialtable(TgtInd(i),5);
      %Plot target
      switch trialtable(TgtInd(i),10)
          case 1
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(1,:))
          case 2
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(2,:))
          case 3
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(3,:))
          case 4
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(4,:))
          case 5
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(5,:))
          case 6
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(6,:))
          case 7
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(7,:))
          case 8
              rectangle('Position',[LLx,LLy,width,height],'EdgeColor',colors(9,:))
              
      end
  end
  end
