/////////////////////////////////////////////////////////////////////
// plxvtdecoder.c - sample functionality for decoding VT data from PLX files.

#include <stdio.h>
#include "vt_interpret.h"


#define MAX_SPIKE_CHANNELS   (128)
#define MAX_EVENT_CHANNELS   (512)
#define MAX_SLOW_CHANNELS    (256)

#define MAX_SAMPLES_PER_WAVEFORM (256)

// Open PLX file
FILE* fp = 0;

// PLX File header structure
PL_FileHeader fileHeader;

// PLX Spike Channel headers
PL_ChanHeader spikeChannels[MAX_SPIKE_CHANNELS];

// PLX Event Channel headers
PL_EventHeader eventChannels[MAX_EVENT_CHANNELS];

// PLX Slow A/D Channel headers
PL_SlowChannelHeader slowChannels[MAX_SLOW_CHANNELS];

// position in file where data begins
int data_start = 0;

void    Scan()
{
	PL_DataBlockHeader dataBlock;
	short buf[MAX_SAMPLES_PER_WAVEFORM];    // used for data skipping

    VT_Data data;   // decoded VT data

    VT_Acc  acc;    // accumulator of VT data
    VT_Acc_Init( &acc );

    unsigned __int64 acceptable_delay = (unsigned __int64)( fileHeader.ADFrequency / 105.0 + 0.5 );

	// Seek to the beginning of the data blocks in the PLX file
	fseek( fp, data_start, SEEK_SET );

	// Rip through the rest of the file
    for(;;)
    {
		// Read the next data block header.
		if( fread( &dataBlock, sizeof(dataBlock), 1, fp ) != 1 )    break;
        
        // reject all non-strobed events
        if( dataBlock.Type != PL_ExtEventType || dataBlock.Channel != PL_StrobedExtChannel ) {
            // skip samples
            if( dataBlock.NumberOfWaveforms > 0 || dataBlock.NumberOfWordsInWaveform > 0 ) {
			    int nbuf = dataBlock.NumberOfWaveforms * dataBlock.NumberOfWordsInWaveform;
			    if( fread( buf, nbuf * sizeof(short), 1, fp ) != 1) break;
            }
            continue;
        }

        // extract VT data and add it to the accumulator
        VT_Data_Init( &data, &dataBlock );
        bool accepted = VT_Acc_Accept( &acc, &data, acceptable_delay );

        if( !accepted ) {
            // => data was rejected
            if( VT_Acc_Mode( &acc ) != UNKNOWN ) {
                // print valid VT data
                VT_Acc_Print( &acc );
            }
            // reset the accumulator
            VT_Acc_Clear( &acc );
            // add VT data to it
            VT_Acc_Accept( &acc, &data, acceptable_delay );
        }
	}

    // check the accumulator if it contains a valid combination
    if( VT_Acc_Mode( &acc ) != UNKNOWN ) {
        // print valid VT data
        VT_Acc_Print( &acc );
    }
}

// Print out help to the console if the user does not specify a PLX file to read
void Usage()
{
	printf( "\n\nplxVTdecoder Version 1.0 Usage:\n\n" );
	printf( "> plxVTdecoder <filename>\n" );
	printf( "\n" );
	printf( "Example:\n\n" );
	printf( "> plxVTdecoder ..\\SampleData\\CM_Quickstart.plx\n" );
	exit(1);
}

// Main routine
void main( int argc, char *argv[] )
{
	// Print out help to the console if the user does not specify a PLX file to read
	if( argc <= 1 ) Usage();

	// Open the specified PLX file.
	fp = fopen( argv[1], "rb" );
	if( fp == 0 ){
		printf( "Cannot open PLX file (%s).", argv[1] );
		exit(1);
	}

	// Read the file header
	fread( &fileHeader, sizeof(fileHeader), 1, fp );

	// Read the spike channel headers
	if( fileHeader.NumDSPChannels > 0 )
		fread( spikeChannels, fileHeader.NumDSPChannels * sizeof(PL_ChanHeader), 1, fp );

	// Read the event channel headers
	if( fileHeader.NumEventChannels > 0 )
		fread( eventChannels, fileHeader.NumEventChannels * sizeof(PL_EventHeader), 1, fp );

	// Read the slow A/D channel headers
	if( fileHeader.NumSlowChannels )
		fread( slowChannels, fileHeader.NumSlowChannels * sizeof(PL_SlowChannelHeader), 1, fp );

	// save the position in the PLX file where data block begin
	data_start = sizeof(fileHeader) + fileHeader.NumDSPChannels * sizeof(PL_ChanHeader)
						+ fileHeader.NumEventChannels * sizeof(PL_EventHeader)
						+ fileHeader.NumSlowChannels * sizeof(PL_SlowChannelHeader);

    // scan all blocks for VT data
    Scan();

	fclose(fp);
}
