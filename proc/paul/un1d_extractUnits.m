function sortedunits =  un1d_extractUnits(bdf)
% this is very quick and dirty

numunits=size(bdf.units,2);

sorted_ids=[];
for ui=1:numunits
   unit_id(ui,:)=bdf.units(ui).id;
   if unit_id(ui,2)~=0 & unit_id(ui,2)~=255
       sorted_ids=[sorted_ids ui];
   end
end
   figure;
   count=1;
for suidx=sorted_ids
   sortedunits(count).ts = bdf.units(suidx).ts;
   count=count+1;
end

return;