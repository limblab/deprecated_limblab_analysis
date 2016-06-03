function bool = cursorInSquareTarget(cursorH,rectH)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
bool = false;

d = get(rectH,'Position');
cursor_x =  get(cursorH,'XData');
cursor_y =  get(cursorH,'YData');
px=d(1);
py=d(2);
wid = d(3);
het = d(4);

up_y = het+py;
dn_y = py;
up_x = wid+px;
dn_x = px;

if ((cursor_x>=dn_x)&&(cursor_x <= up_x)) && ...
       ((cursor_y>=dn_y)&&(cursor_y<=up_y))
    bool = true;
end
end

