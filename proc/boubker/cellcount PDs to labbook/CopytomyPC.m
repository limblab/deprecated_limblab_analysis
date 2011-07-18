clear;clc; 
root='Pedro_2011-07-13_BC_002';
bdf=get_cerebus_data(['Z:\Miller\Pedro_4C2\S1 Array\Raw\',root,'.nev']);
save(['\\tsclient\C\Users\Boubker\Documents\s1\Pedro_4C2\S1 array\processed\',root,'.mat'],'bdf');
copyfile(['Z:\Miller\Pedro_4C2\S1 Array\Raw\',root,'.nev'],['\\tsclient\C\Users\Boubker\Documents\s1\Pedro_4C2\S1 array\raw\',root,'.nev']);