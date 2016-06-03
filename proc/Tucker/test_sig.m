angles3=1:180;

for i=1:length(angles3)
temp(i)=1/(1+exp(-(angles3(i)-90)*.1));
end

plot(temp)