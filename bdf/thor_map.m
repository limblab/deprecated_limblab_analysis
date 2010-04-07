function output = thor_map(spike_list)


%Putting electrode position into channel number matrix (that is, array_map(1,1) is
%channel/pin #1 and maps to electrode position #93, array_map(1,2) is pin #2 and electrode position #92, etc.)
array_map = [93 92 94 95 75 96 85 97 86 98;... %pins 1-10
             87 88 77 99 66 89 76 90 67 79;... %pins 11-20
             58 80 78 100 68 60 69 50 59 40;...%pins 21-30
             49 30 83 84 73 74 63 64 53 54;... %pins 31-40
             43 55 44 45 33 46 34 65 24 56;... %pins 41-50
             35 47 25 57 26 36 27 37 28 38;... %pins 51-60
             29 48 19 39 81 82 71 72 61 62;... %pins 61-70
             51 52 41 42 31 32 21 22 11 12;... %pins 71-80
             1  23 3  13 4  14 15 5  16 6 ;... %pins 81-90
             17 91 8  18 20 10 0  0  0  0 ];   %pins 91-96, plus the four ground/reference electrodes (electrodes 2, 7, 9, 70)
 
%because single-value indexing increases as you go down a column instead of across a row...       
array_map = array_map';       
       
num_units = size(  spike_list, 1 ); %number of units
subs      = zeros( num_units,  2 );

%for each unit
for i=1:num_units
    pin       = spike_list(i);
    index     = array_map(pin);
    cell      = ind2sub( [10 10], index );
    subs(i)   = cell;
end

output = subs;