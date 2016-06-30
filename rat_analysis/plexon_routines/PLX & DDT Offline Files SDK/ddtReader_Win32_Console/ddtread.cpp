/////////////////////////////////////////////////////////////////////
//
//  ddtread.cpp - sample code for reading DDT files
//
//  (c) 1998-2006 Plexon, Inc., Dallas, Texas
//  www.plexoninc.com 
//
/////////////////////////////////////////////////////////////////////

#include <windows.h>
#include <stdio.h>

#include "../Plexon.h"


// The maximum number of sample scans that will be displayed.
// Typical files will of course be much longer than this, so only
// the first MAX_SAMPLES values will be displayed.
#define MAX_SAMPLES (200)

// A channel gain of 255 indicates that the channel was not recorded
#define DISABLED_CHANNEL (255)


FILE *fp;
DigFileHeader fileHeader; // File header structure -- see Plexon.h
fpos_t pos;

// Change this from 0 to 1 in order to dump the actual voltages
// at the recording site, as opposed to the raw sample values.
int iDumpActualVoltages = 0;


// Print out help to the console if the user does not specify a DDT file to read
void Usage ()
{
	printf ("\n\nddtread Version 2.1 Usage:\n\n");
	printf ("> ddtread <filename>\n");
	printf ("\n");
	printf ("Example:\n\n");
	printf ("> ddtread ..\\SampleData\\test1.ddt\n");
	exit (1);
}

// Main routine
void main(int argc, char *argv[])
{
	// Print out help to the console if the user does not specify a DDT file to read
	if (argc <= 1)
	{
		Usage();
	}

	// Open the specified DDT file
	fp = fopen(argv[1], "rb");
	if (fp == 0)
	{
		printf("Cannot open DDT file (%s).", argv[1]);
		exit(1);
	}

	// Read the file header
	fread(&fileHeader, sizeof(fileHeader), 1, fp);

	// Dump the header
	
	printf("Date created %d/%d/%d %d:%d:%d\n", 
		fileHeader.Month,
		fileHeader.Day,
		fileHeader.Year,
		fileHeader.Hour,
		fileHeader.Minute,
		fileHeader.Second);
	printf("Version %d\n", fileHeader.Version);
	if (strlen(fileHeader.Comment))
	  printf("Comment %s\n", fileHeader.Comment);
	// Note that fileHeader.NChannels is the number of channels actually
	// recorded in the file, not the total number of channels in the device.
	// The maximum number of recorded channels in a DDT file is 64.
	printf("Number of recorded channels %d\n", fileHeader.NChannels);
	printf("Frequency %.3f Hz\n", fileHeader.Freq);
	printf("Preamp gain %d\n", fileHeader.Gain);
	
	if (fileHeader.Version >= 101) 
	{
	  // 12 or 16 bits per sample, depending on the device
		printf("Bits per sample %d\n", fileHeader.BitsPerSample);
	}
	else // Version 100
	{
		printf("Bits per sample 12 (assumed by default)\n");
		fileHeader.BitsPerSample = 12;
	}

  // Calculate scaling factor to convert raw sample values (12 or 16 bits) to
  // equivalent voltage (in millivolts), not including gain.
  float fScaleRawSampleValueToVoltage;
	if (fileHeader.Version >= 103)
	{
		printf("Max magnitude %d mV\n", fileHeader.MaxMagnitudeMV);
    if (fileHeader.BitsPerSample == 12)
      fScaleRawSampleValueToVoltage = fileHeader.MaxMagnitudeMV/2048.0f;
    else // 16 bit samples
      fScaleRawSampleValueToVoltage = fileHeader.MaxMagnitudeMV/32768.0f;
	}
	
	printf("\n");
	
	// If some channels were disabled, or their "to DDT" entry in Recorder's
	// parameter grid was "no", their samples will not be recorded in the file.
	// This is indicated by the corresponding ChannelGain entry being set to 255.  
	// We build an iChannelMap array here which contains a list of the channel
	// numbers for the channels actually recorded; this will be used later to 
	// access the gains for each channel.
  int iChannelMap[64]; 
	if (fileHeader.Version >= 102)
	{
    int iNumRecordedChans = 0;
		for (int iChannel = 0; iChannel < 64; iChannel++)
		{
		  if (fileHeader.ChannelGain[iChannel] == DISABLED_CHANNEL) 
		    printf("Channel %d not recorded\n", iChannel+1);
		  else
		  {
			  printf("Channel %d gain is %d\n", iChannel+1, fileHeader.ChannelGain[iChannel]);
			  iChannelMap[iNumRecordedChans++] = iChannel; // Add to channel map
			}
		}
	}

	printf("\n");
		
	
	// The header has been dumped -- now dump the sample times and values.
	
	// Each recorded scan consists of the sample values for one sample time,
	// for only the enabled channels.  Timestamps are not recorded; the timestamp
	// for each scan of samples is implicitly one sample time after the preceding
	// scan (e.g. 25 microseconds at 40 kHz sampling rate).
	
	printf("   Time (sec)");
  for (int iChannel = 0; iChannel < 64; iChannel++)
	{
	  if (fileHeader.ChannelGain[iChannel] != DISABLED_CHANNEL) 
	  {
		  char buffer [32];
		  sprintf(buffer, "CH %d", iChannel+1); // 1-based, as shown in Recorder
		  printf("%7s", buffer);
		}
	}
	printf ("\n");

	// Allocate a buffer to hold the channel samples for one scan (i.e. sample time)
	short* buf = new short[fileHeader.NChannels];
	
	// Seek to the beginning of data
	fseek(fp, fileHeader.DataOffset, SEEK_SET);
	
	for (int iSample = 0; ; iSample++)
	{
		// Read the values 
		fread(buf, sizeof(short), fileHeader.NChannels, fp);

		// Convert to seconds
		double seconds = (double) iSample / (double) fileHeader.Freq;
		printf("%12.6lf ", seconds);

		// Print the the data for all of the channel for the current time stamp
		// as raw sample values (12 or 16 bits)
		for (int iChannel = 0; iChannel < fileHeader.NChannels; iChannel++)
		{
			printf(" %6d", buf[iChannel]);
		}
		printf("\n");

    if (iDumpActualVoltages)
    {
      // If we have the preamp gain and the per-channel gain,
      // then also print the sample values as voltages at the recording site.
      // Note that the printing of these values will not be aligned with the 
      // printing of the raw sample values; this code is provided more as an
      // illustration of how to decode the true voltage at the recording site 
      // from the raw sample values in the file.
      if (fileHeader.Version >= 102)
      {
        float fPreampGain = (float)fileHeader.Gain; 
  		  for (int iChannel = 0; iChannel < fileHeader.NChannels; iChannel++)
	  	  {
	  	    int iTrueChannel = iChannelMap[iChannel];
	  	    float fTotalGain = fPreampGain*fileHeader.ChannelGain[iTrueChannel];
          float fVolts = ((float)buf[iChannel]*fScaleRawSampleValueToVoltage) / fTotalGain;
          if (iChannel == 0)
            printf("      (%.3f", fVolts);
          else
            printf(" %.3f", fVolts);
        }
  		  printf(")\n");
		  }
    }

		// Uncomment the Sleep(500) in order to pause briefly after dumping each scan of samples
    //Sleep(500);		 

		// Quit reading when a maximum number of samples reached.  
		// Note that real applications typically read all of the samples.
		if ((iSample+1) >= MAX_SAMPLES)
		{
			printf ("Only the first %d samples were extracted.\n", MAX_SAMPLES);
			break;
		}
	}

	delete []buf;
	fclose(fp);
}

