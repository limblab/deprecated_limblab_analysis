function subs = array_activity_map(spike_list, monkey_name)
%Takes data binned in "bin_spikes" and maps it onto a matrix that has pin
%numbers placed in matrix indices according to physical connection with
%array; returns a matrix of subscripts

map = create_array_map(monkey_name);
pin_map   = map(:,1);
array_map = map(:,2);

array_list = zeros(length(array_map),2);

array_list(:,1) = array_map; %array_map numbers correspond to *physical location* in Utah array
array_list(:,2) = pin_map;   %pin_map numbers correspond to channels as recorded in bdf struct

sorted_list = sortrows(array_list,1); %100 x 2 matrix linking channel numbers to electrode position, sorted with electrode position going in ascending order

map_matrix = zeros(10,10); %holds channel numbers located in associated electrode [physical] positions

%As a 10x10 matrix, the 100 values from column 2 of sorted_list
%correspond with transposed positions when placed with single-value
%indexing (as in: position 11 of map_matrix is row 1, column 2) and can
%thus be directly inputed and then transposed (though that step is not
%entirely necessary, as all channels will be appropriately lined up with
%each other
for i = 1:length(array_map)
    map_matrix(i) = sorted_list(i,2);
end
map_matrix = map_matrix';


%Now that the mapping matrix has been created, we create a matrix of
%dimension "num_units" x 2 containing the row and column subscript of each
%unit within the mapping matrix
num_units = size(  spike_list, 1 ); %number of units that are on
subs      = zeros( num_units,  2 );

for i = 1 : num_units
    [subs(i,1), subs(i,2)] = find( map_matrix == spike_list(i) );
end



