function [subs, audio_subs] = array_activity_map(spike_list, monkey_name, sound_chan)
%SUB-FUNCTION OF 'array_movie'
%Returns a matrix of subscripts correlating each unit's channel
%number to its electrode position

%Structure of 'implant_map': [ pin_map   array_map ], where 'pin_map' is a
%column of the pin/channel numbers and 'array_map' is a column of the
%corresponding electrode numbers
implant_map = create_array_map(monkey_name);

%100 x 2 matrix linking channel numbers to electrode position, sorted
%according to ascending electrode position
sorted_list = sortrows( implant_map, 2 );

map_matrix = zeros(10,10); %holds channel numbers located in associated electrode [physical] positions

%As a 10x10 matrix, the 100 values from column 1 of 'sorted_list'
%correspond with transposed positions when placed with single-value
%indexing (as in: position 11 of map_matrix is row 1, column 2) and can
%thus be directly inputed and then transposed (though that step is not
%entirely necessary, as all channels will be appropriately lined up with
%each other)
for i = 1:length(implant_map)
    map_matrix(i) = sorted_list(i,1);
end
map_matrix = map_matrix'; %Not a necessary step, but puts electrode 1 in top left and electrode 10 in top right 
                          %(instead of bottom left) of matrix. That is, it
                          %maps pin number into electrode position with
                          %electrode number increasing from left to right


%Now that the mapping matrix has been created, we create a matrix of
%dimension 'num_units' x 2 containing the row and column subscript of each
%unit within the mapping matrix
num_units = length( spike_list ); %number of active units
subs      = zeros(  num_units, 2 );

for i = 1 : num_units
    [subs(i,1), subs(i,2)] = find( map_matrix == spike_list(i) );
end

%Get the subscripted location of the channel specified by 'sound_chan'
if ( sound_chan == 0 )
    audio_subs = 0;
else
    [audio_subs(1), audio_subs(2)] = find( map_matrix == sound_chan );
end






