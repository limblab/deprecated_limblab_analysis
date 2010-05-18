function map = create_array_map(monkey_name)
%SUB-FUNCTION OF 'array_activity_map'
%function is called with form "create_array_map(monkey_name);" ex:
%"create_array_may('thor')"


%I input pin/electrode numbers in this order because it was much easier
%for me to type them in this order while looking at the Excel table than in
%actual order (in table, are laid out divided by headstage with each having 
%a column of the odd numbers of that third of the pins and a column of even 
%numbers of that third of the pins); I went for ease of input over ease of
%programming because ease of input made me significantly more sure that I
%was not making mistakes while typing in the numbers, and it made it
%significantly easier to check for mistakes after finishing.
pin_map   = [1  3  5  7  9  11 13 15 17 19 21 23 25 27 29 31 ... %bank 1
             2  4  6  8  10 12 14 16 18 20 22 24 26 28 30 32 ...
             33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 ... %bank 2
             34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 ...
             65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 ... %bank 3
             66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 ...
             0 0 0 0 ];


%Array ID#1025-0398; Left hemisphere (implanted 4.27.10)
fidel_map = [93 94 75 85 86 87 77 66 76 67 58 78 68 69 59 49 ... %pins 1-31 odd
             92 95 96 97 98 88 99 89 90 79 80 70 60 10 40 30 ... %pins 2-32 even
             83 73 63 53 43 44 33 34 24 35 25 26 27 28 29 19 ... %pins 33-63 odd
             84 74 64 54 55 45 46 65 56 47 57 36 37 38 48 39 ... %pins 34-64 even
             81 71 61 51 41 31 21 11 2  3  4  15 16 17 8  20 ... %pins 65-95 odd
             82 72 62 52 42 32 22 12 23 1  14 5  6  7  18 9  ... %pins 66-96 even
             13 50 91 100]; %gnd/ref electrodes
         
%Array ID#1025-0300
theo_map  = [93 91 75 85 86 87 77 66 76 67 58 78 68  69 59 49 ... %pins 1-31 odd
             92 95 96 97 98 88 99 89 90 79 80 70 60  50 40 30 ... %pins 2-32 even
             83 73 63 53 43 44 33 34 24 35 25 26 100 28 29 19 ... %pins 33-63 odd
             84 74 64 54 55 45 46 65 56 47 57 36 37  38 48 39 ... %pins 34-64 even
             81 71 61 51 41 31 21 11 2  3  4  15 16  17 8  20 ... %pins 65-95 odd
             82 72 62 52 42 32 22 12 23 13 14 5  6   7  18 9  ... %pins 66-96 even
             1  10 27 94]; %gnd/ref electrodes
         
%Array ID#1025-0302
thor_map  = [93 94 75 85 86 87 77 66 76 67 58 78  68 69 59 49 ... %pins 1-31 odd
             92 95 96 97 98 88 99 89 90 79 80 100 60 50 40 30 ... %pins 2-32 even
             83 73 63 53 43 44 33 34 24 35 25 26  27 28 29 19 ... %pins 33-63 odd
             84 74 64 54 55 45 46 65 56 47 57 36  37 38 48 39 ... %pins 34-64 even
             81 71 61 51 41 31 21 11 1  3  4  15  16 17 8  20 ... %pins 65-95 odd
             82 72 62 52 42 32 22 12 23 13 14 5   6  91 18 10 ... %pins 66-96 even
             2  7  9  70 ]; %gnd/ref electrodes

%Array ID#1024-0393; Right hemisphere - S1
tiki1_map = [93 94 75 85 86 87 77 66 76 67 58 78 68 69 59 49 ... %pins 1-31 odd
             92 95 96 97 98 88 99 89 90 79 80 70 60 50 40 30 ... %pins 2-32 even
             83 73 63 53 43 44 33 34 24 35 25 26 27 28 29 19 ... %pins 33-63 odd
             84 74 64 54 55 45 46 65 56 47 57 39 37 38 48 39 ... %pins 34-64 even
             81 71 61 51 41 31 21 11 2  3  4  15 16 17 8  20 ... %pins 65-95 odd
             82 72 62 52 42 32 22 12 23 13 14 5  6  7  18 9  ... %pins 66-96 even
             1  10 91 100 ]; %gnd/ref electrodes

%Array ID#1024-0350; Left hemisphere - S1 (implanted 4.15.10)
tiki2_map = [93 94  75 85 86 87 77 66 76 67 58 78 68 69 59 49 ... %pins 1-31 odd
             92 95  96 97 98 88 99 89 90 79 80 10 60 50 40 30 ... %pins 2-32 even
             83 100 63 53 43 44 33 34 24 35 25 26 27 28 29 19 ... %pins 33-63 odd
             84 74  64 54 55 45 46 65 56 47 57 36 37 38 48 39 ... %pins 34-64 even
             81 71  61 51 41 31 21 11 2  3  4  15 16 17 8  20 ... %pins 65-95 odd
             82 72  62 52 42 32 22 12 23 13 14 5  6  7  18 9  ... %pins 66-96 even
             1  70  73 91]; %gnd/ref electrodes

% If a number is not given on end of 'monkey_name' (i.e. only 'tiki', not
% 'tiki1'), the first map in this list with the matching name will be
% returned (as in the argument 'tiki' will return 'tiki1_map')
if strncmpi( monkey_name, 'thor_map', length(monkey_name) )
    map = [pin_map' thor_map'];
elseif strncmpi( monkey_name, 'tiki1_map', length(monkey_name) )
    map = [pin_map' tiki1_map'];
elseif strncmpi( monkey_name, 'tiki2_map', length(monkey_name) )
    map = [pin_map' tiki2_map'];
elseif strncmpi( monkey_name, 'theo_map', length(monkey_name) ) || strncmpi( monkey_name, 'thelonius', length(monkey_name) )
    map = [pin_map' theo_map'];
elseif strncmpi( monkey_name, 'fidel_map', length(monkey_name) )
    map = [pin_map' fidel_map'];
else
    disp('Warning: No array found for given monkey.')
end


