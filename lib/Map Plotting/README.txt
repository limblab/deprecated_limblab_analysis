created by Brian Dekleva 2013-10-1 v0

-------------------------------------
----- ARRAYMAP.M --------------------
-------------------------------------

ArrayMap.m will return the spatial channel information on the array according to the monkey's listed mapfile. If a warning is given, the monkey's array information is not listed in Mapfile_repo.m. Simply add the information to Mapfile_repo.m according to the existing format. The function uses monkey name and implant area to open the correct mapfile and parse the information.

Example:
		
>> ArrayMap('Mihili','PMd')

ans =

     0    88    78    68    58    48    38    28    18     0
    96    87    77    67    57    47    37    27    17     8
    95    86    76    66    56    46    36    26    16     7
    94    85    75    65    55    45    35    25    15     6
    93    84    74    64    54    44    34    24    14     5
    92    83    73    63    53    43    33    23    13     4
    91    82    72    62    52    42    32    22    12     3
    90    81    71    61    51    41    31    21    11     2
    89    80    70    60    50    40    30    20    10     1
     0    79    69    59    49    39    29    19     9     0

-------------------------------------
----- ARRAYMAPPLOT.M ----------------
-------------------------------------

ArrayMapPlot.m will plot 1 or 2 metrics spatially on the array. The first metric will be plotted as marker size and the second as marker color. See help for more information. [map1, map2] = ArrayMapPlot(...) will also return the specified metrics corresponding to each electrode location.

Example:

>> [map1, map2] = ArrayMapPlot(...)

map1 = 

         0    1.1000    0.8000    6.4000    0.9000    4.1000    4.9000    5.7000    3.2000         0
    3.7000    3.0000    1.0000    3.5000    2.3000    2.3000    7.5000    9.5000    9.7000    5.6000
    4.4000    0.3000    3.8000    6.3000    0.9000    3.5000    3.7000    7.6000    1.4000    1.2000
    5.3000    6.3000    1.5000    4.5000    4.9000    9.9000    3.6000    7.8000    4.0000   10.1000
    5.6000    9.7000    7.7000    5.0000   10.1000    1.2000    5.5000    6.0000    0.8000    4.1000
    4.9000    5.6000    0.5000    9.7000    3.7000    0.9000    6.9000    5.7000    9.0000    9.2000
    7.0000    9.9000    9.4000    9.1000    0.9000    1.8000    6.9000    9.1000    2.7000    0.2000
    1.5000    0.2000    9.7000    4.5000    0.4000    4.8000    4.7000    5.9000    9.5000    3.4000
    6.5000    2.9000    0.6000    6.4000    3.0000    8.6000    1.1000    0.5000    3.4000    8.6000
         0    5.4000    4.9000    6.8000    5.7000    5.5000    8.7000    3.7000    5.4000         0

map2 = 

m2 =

     0     3     1     2     2     1     2     2     2     0
     1     2     2     2     2     2     2     2     1     2
     1     2     2     3     1     2     2     1     1     2
     2     2     3     2     3     1     2     3     1     2
     1     1     2     2     1     2     2     1     2     3
     1     1     1     2     3     2     1     1     2     1
     3     2     2     2     2     1     1     2     1     1
     3     2     2     2     1     3     1     3     2     2
     3     3     1     2     1     2     2     3     3     2
     0     3     2     1     1     2     1     2     2     0


-------------------------------------
----- MAPFILE_REPO.M ----------------
-------------------------------------

Mapfile_repo.m contains the list of array serial numbers corresponding to monkey name and implant location. If ArrayMap.m or ArrayMapPlot.m return errors, check Mapfile_repo.m to ensure that the desired array information is included. If not, add information in the form: MONKEY_NAME.IMPLANT_AREA = 'serial_number'.