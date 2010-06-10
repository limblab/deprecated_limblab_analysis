electrodes = [93 94 75 85 86 87 77 66 76 67 58 78 68 69 59 49 92 95 96 97 98 88 99 89 90 79 80 10,... 
    60 50 40 30 83 100 63 53 43 44 33 34 24 35 25 26 27 28 29 19 84 74 64 54 55 45 46 65 56 47 57,...
    36 37 38 48 39 81 71 61 51 41 31 21 11 2 3 4 15 16 17 8 20 82 72 62 52 42 32 22 12 23 13 14 5,...
    6 7 18 9]';

order = [1:2:31 2:2:32 33:2:63 34:2:64 65:2:95 66:2:96]';
[a b] = sort(order);

pin_electrode = [[1:96]' electrodes(b)];
[a b] = sort(pin_electrode(:,2));
electrode_pin = [pin_electrode(b,2) pin_electrode(b,1)];

array_electrodes = [1:100]';
array_pins = zeros(100,1);
array_pins(electrode_pin(:,1)) = electrode_pin(:,2);

array_electrodes = reshape(array_electrodes,10,10)';
array_pins = reshape(array_pins,10,10)';

array_electrodes = array_electrodes(end:-1:1,:);
array_pins = array_pins(end:-1:1,:);

map_tiki_b = array_pins;

% array_pins(electrode_pin(:,1)) = 