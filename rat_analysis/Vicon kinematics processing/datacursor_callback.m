function txt = datacursor_callback(empt,event)

line_hndl = get(event,'Target');
parent = get(line_hndl,'Parent');
kids = get(parent,'Children');
ind = find(kids == line_hndl);
set(kids,'LineWidth',.5);
set(kids(ind),'LineWidth',2);

nelem = length(kids);
txt = {['index #: ' num2str(nelem - ind +1)]};
