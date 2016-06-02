function array_build(mapfile,X)
%mapfile cmp file 
%X : 2 columns one first column with electrode name as in cerebus, and  

% correspond=convertMAP2MAT(char(mapfile));
correspond = mapfile;

for j=1:10
    for i=1: 10
        arrays(10-(i-1),10-(j-1))=i+(10*(j-1));
     end
end;

effects=-1*ones(10,10);



    for i=1: length(X) 
        col=10-correspond(find(correspond(:,3)==X(1)),1);
        row=10-correspond(find(correspond(:,3)==X(1)),2);
        effects(row,col)=X(i,2);

    end
    
     
    

figure; imagesc(effects);hold;
for j=1:10
    for i=1: 10
       
        text(i,j,int2str(correspond(find(correspond(:,4)==arrays(j,i)),3)));
       
    end
end;
colorbar
colormap(gray)
set(gca,'XTick',[],'XTicklabel',[],'YTick',[],'YTicklabel',[])
% xlabel('lateral');
% ylabel('anterior')
end