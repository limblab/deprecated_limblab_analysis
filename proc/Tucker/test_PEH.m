
close all
ul=unit_list(Multi_unit_bdf,1);

%get_event_times
word_ctr_hold = hex2dec('a0');
event_times = Multi_unit_bdf.words( bitand(hex2dec('f0'),Multi_unit_bdf.words(:,2)) == word_ctr_hold, 1);%hex2dec('f0') is a bitwise mask for the leading bit

for(i=1:10)
    chan=ul(i,1);
    unit_num=ul(i,2);
    fig_list(i)=make_PEH(Multi_unit_bdf,event_times,[500,1000],[chan,unit_num],33,1);
    figure(fig_list(i));
    title(strcat('histogram for unit ',num2str(i)))
end