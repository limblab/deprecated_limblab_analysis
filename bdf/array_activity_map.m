function [subs, audio_subs] = array_activity_map(spike_list, monkey_name, sound_chan)
%SUB-FUNCTION OF 'array_movie'
%Returns a matrix of subscripts correlating each unit's channel
%number to its electrode position and the subscript of the requested
%channel to be output as audio

%Structure of 'implant_map': [ pin_map   array_map ], where 'pin_map' is a
%column of the pin/channel numbers and 'array_map' is a column of the
%corresponding electrode numbers
implant_map = create_array_map(monkey_name);

%100 x 2 matrix linking channel numbers to electrode position, sorted
%according to ascending electrode position
sorted_list = sortrows( implant_map, 2 );

%As a 10x10 matrix, the 100 values from column 1 of 'sorted_list'
%correspond with transposed positions when placed with single-value
%indexing (as in: position 11 of map_matrix is row 1, column 2) and can
%thus be directly inputed and then transposed (though that step is not
%entirely necessary, as all channels will be appropriately lined up with
%each other)
map_matrix = reshape( sorted_list(:,1), 10, 10 )';

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






