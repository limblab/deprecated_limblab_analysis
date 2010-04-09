function big_image = expand_image(image, width, height)
%Input format: expand_image( [2 dimensional matrix], scalar, scalar)
%Return: [2 dimensional matrix] of size "width x height"

%takes a matrix output by accumarray (specifically in the 'array_movie'
%function) and replicates each value into a block of copies of that value
%within the matrix (so 1 pixel becomes 50 pixels, or whatever, according to
%specified width and height). For 'image' matrix of dimension "m x n",
%'width' must be > n, and 'height' must be > m. Width and heigh are pixel
%dimensions of desired final image size.

%Ex:  [1 0 0                [1 1 0 0 0 0
%      0 1 0    becomes:     1 1 0 0 0 0
%      0 0 1]                0 0 1 1 0 0
%                            0 0 1 1 0 0
%                            0 0 0 0 1 1
%                            0 0 0 0 1 1]

x            = length( image(1,:) );  %number of columns in 'image' matrix
y            = length( image(:,1) );  %number of rows in 'image' matrix
x_gain       = floor( width/x );      %number of times each value will be replicated in the horizontal direction
y_gain       = floor( height/y );     %number of times each value will be replicated in the vertical direction

%Run through 'image' matrix and replicate values across the rows and down
%the columns... value at image(i,j) becomes:
%big_image( [y_gain*(i-1)+1]:y_gain*i , [x_gain*(j-1)+1]:x_gain*j )
for i = 1 : y %this loop takes you through the rows (i = 1 --> row 1)
    for j = 1 : x %this loop takes you through the columns (j = 1 --> col 1)
        init_x = x_gain*(j-1) + 1; 
        term_x = x_gain*j;            %set beginning and end of expansion intervals
        init_y = y_gain*(i-1) + 1;
        term_y = y_gain*i;
        
        big_image(init_y:term_y, init_x:term_x) = image(i,j);
    end
end

