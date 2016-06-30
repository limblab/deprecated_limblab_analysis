function [electrode_pin,map] = electrode_pin_mapping(monkey_array)

switch monkey_array
    case 'Chips'
        electrodes = [0, 79, 69, 59,49,39,29,19,9,0; 89, 80 70 60 50 40 30 20 10 1; 90 81 71 61 51 41 31 21 11 2;91 82 72 62 52 42 32 22 12 3; ...
            92 83 73 63 53 43 33 23 13 4; 93 84 74 64 54 44 34 24 14 5; 94 85 75 65 55 45 35 25 15 6; 95 86 76 66 56 46 36 26 16 7; ...
             96 87 77 67 57 47 37 27 17 8; 0 88 78 68 58 48 38 28 18 0];
     case 'Tiki_2'
        electrodes = [93 94 75 85 86 87 77 66 76 67 58 78 68 69 59 49 92 95 96 97 98 88 99 89 90 79 80 10,... 
            60 50 40 30 83 100 63 53 43 44 33 34 24 35 25 26 27 28 29 19 84 74 64 54 55 45 46 65 56 47 57,...
            36 37 38 48 39 81 71 61 51 41 31 21 11 2 3 4 15 16 17 8 20 82 72 62 52 42 32 22 12 23 13 14 5,...
            6 7 18 9]';

end

order = [1:2:31 2:2:32 33:2:63 34:2:64 65:2:95 66:2:96]';
[a b] = sort(order);

pin_electrode = [[1:96]' electrodes(b)];
[a b] = sort(pin_electrode(:,2));
electrode_pin = [pin_electrode(b,2) pin_electrode(b,1)];

array_pins = zeros(100,1);
array_pins(electrode_pin(:,1)) = electrode_pin(:,2);
array_pins = reshape(array_pins,10,10)';
array_pins = array_pins(end:-1:1,:);

map = array_pins; % array from the top