
function s = getDateFname(acc)

if nargin<1, acc=3; end
if acc>6
    disp('Sorry, only goes up to second-accuracy...')
    acc=6;
end

v = clock;
v(1)=v(1)-2000;
v(6) = round(v(6));
s = num2str(v(1:acc),'%02i');