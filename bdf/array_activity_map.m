function subs = array_activity_map(spike_list, monkey_name)
%Takes data binned in "bin_spikes" and maps it onto a matrix that has pin
%numbers placed in matrix indices according to physical connection with
%array; returns a matrix of subscripts

%Structure of 'map' --> [ pin_map   array_map ]   ...where 'pin_map' is a
%column of the pin/channel numbers and 'array_map' is a column of the
%corresponding electrode numbers
map = create_array_map(monkey_name);

%100 x 2 matrix linking channel numbers to electrode position, sorted
%according to ascending electrode position
sorted_list = sortrows(map,2);

map_matrix = zeros(10,10); %holds channel numbers located in associated electrode [physical] positions

%As a 10x10 matrix, the 100 values from column 1 of sorted_list
%correspond with transposed positions when placed with single-value
%indexing (as in: position 11 of map_matrix is row 1, column 2) and can
%thus be directly inputed and then transposed (though that step is not
%entirely necessary, as all channels will be appropriately lined up with
%each other)
for i = 1:size(map,1)%length(array_map)
    map_matrix(i) = sorted_list(i,1);
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

