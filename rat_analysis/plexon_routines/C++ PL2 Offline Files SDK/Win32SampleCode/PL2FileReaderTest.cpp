// PL2FileReaderTest.cpp : Defines the entry point for the console application.
//

#include <iostream>
#include <time.h>
#include <vector>
#include "PL2FileReader.h"

// we specify here that we want the linker to include PL2FileReader.lib
#pragma comment(lib, "..\\Bin\\Win32\\PL2FileReader.lib")

// to run the executable after Debug build (.\Debug\PLFileReaderTest.exe), 
// copy PLFileReader.dll from ..\Bin\Win32 to .\Debug

using namespace std;

void Usage()
{
    printf( "PL2FileReaderTest Usage:\n\n" ) ;
    printf( "PL2FileReaderTest <filename>\n" ) ;
}

void PrintFileHeader( PL2FileInfo& info );
void PrintSpikeChannelHeaders( int fileHandle, PL2FileInfo& fileInfo );
void PrintAnalogChannelHeaders( int fileHandle, PL2FileInfo& fileInfo );
void PrintDigitalChannelHeaders( int fileHandle, PL2FileInfo& fileInfo );
void PrintSampleOfFirstSpikeChannelWithData( int fileHandle, PL2FileInfo& fileInfo );
void PrintSampleOfFirstAnalogChannelWithData( int fileHandle, PL2FileInfo& fileInfo );
void PrintSampleOfFirstDigitalChannelWithData( int fileHandle, PL2FileInfo& fileInfo );
void PrintSampleOfStartStopChannel( int fileHandle, PL2FileInfo& fileInfo );


int main( int argc, char* argv[] )
{
    if ( argc < 2 ) {
        Usage();
        return -1;
    }

    char error[1024];
    int fileHandle = 0;

    // try to open the file specified in command line
    if ( !PL2_OpenFile( argv[1], &fileHandle ) ) {
        PL2_GetLastError( error, 1024 );
        cout << "failed to open file '" << argv[1] << "': " << error << endl;
        return -1;
    }

    if ( fileHandle <= 0 ) {
        cout << "invalid file handle" << endl;
   }

    PL2FileInfo info;
    if ( !PL2_GetFileInfo( fileHandle, &info ) ) {
        char error[1024];
        PL2_GetLastError( error, 1024 );
        cout << "unable to get file info: " << error << endl;
    }

    PrintFileHeader( info );
    PrintSpikeChannelHeaders( fileHandle, info );
    PrintAnalogChannelHeaders( fileHandle, info );
    PrintDigitalChannelHeaders( fileHandle, info );
    PrintSampleOfFirstSpikeChannelWithData( fileHandle, info );
    PrintSampleOfFirstAnalogChannelWithData( fileHandle, info );
    PrintSampleOfFirstDigitalChannelWithData( fileHandle, info );
    PrintSampleOfStartStopChannel( fileHandle, info );

    return 0;
}

void PrintFileHeader( PL2FileInfo& info )
{
    printf( "Comment: '%s'\n", info.m_CreatorComment );
    printf( "Creator: '%s', version '%s'\n", info.m_CreatorSoftwareName, info.m_CreatorSoftwareVersion );
    printf( "Time: %s", asctime( &info.m_CreatorDateTime ) );
    printf( "Timestamp Frequency: %f\n", info.m_TimestampFrequency );
    printf( "Spike channels: %d\n", info.m_TotalNumberOfSpikeChannels );
    printf( "Analog channels: %d\n", info.m_TotalNumberOfAnalogChannels );
    printf( "Digital channels: %d\n", info.m_NumberOfDigitalChannels );
}

void PrintSpikeChannelHeaders( int fileHandle, PL2FileInfo& fileInfo )
{
    printf( "\nSpike Channels\nName       Source Channel Wflength Unsorted   Unit a   Unit b   Unit c\n" );
    for ( int channelIndex = 0; channelIndex < ( int )fileInfo.m_TotalNumberOfSpikeChannels; ++channelIndex ) {
        PL2SpikeChannelInfo channel;
        if ( !PL2_GetSpikeChannelInfo( fileHandle, channelIndex, &channel ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get spike channel info: " << error << endl;
            continue;
        }
        printf( "%-10s %6d %7d %8d", channel.m_Name, channel.m_Source, channel.m_Channel, channel.m_SamplesPerSpike );
        for ( unsigned char unit = 0; unit < 4; ++unit ) {
            printf( " %8I64d", channel.m_UnitCounts[ unit ] );
        }
        printf( "\n" );
    }
}

void PrintAnalogChannelHeaders( int fileHandle, PL2FileInfo& fileInfo )
{
    printf( "\nAnalog Channels\nName       Source Channel SampleRate        Count\n" );
    for ( int channelIndex = 0; channelIndex < ( int )fileInfo.m_TotalNumberOfAnalogChannels; ++channelIndex ) {
        PL2AnalogChannelInfo channel;
        if ( !PL2_GetAnalogChannelInfo( fileHandle, channelIndex, &channel ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get analog channel info: " << error << endl;
            continue;
        }
        printf( "%-10s %6d %7d %10.2f %12I64d\n", channel.m_Name,
                channel.m_Source,
                channel.m_Channel,
                channel.m_SamplesPerSecond,
                channel.m_NumberOfValues );
    }
}

void PrintDigitalChannelHeaders( int fileHandle, PL2FileInfo& fileInfo )
{
    printf( "\nDigital Channels\nName       Source Channel      Count\n" );
    for ( int channelIndex = 0; channelIndex < ( int )fileInfo.m_NumberOfDigitalChannels; ++channelIndex ) {
        PL2DigitalChannelInfo channel;
        if ( !PL2_GetDigitalChannelInfo( fileHandle, channelIndex, &channel ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get digital channel info: " << error << endl;
            continue;
        }
        printf( "%-10s %6d %7d %10I64d\n", channel.m_Name,
                channel.m_Source,
                channel.m_Channel,
                channel.m_NumberOfEvents );
    }
}

void PrintSampleOfFirstSpikeChannelWithData( int fileHandle, PL2FileInfo& fileInfo )
{
    for ( int channelIndex = 0; channelIndex < ( int )fileInfo.m_TotalNumberOfSpikeChannels; ++channelIndex ) {
        PL2SpikeChannelInfo channelInfo;
        if ( !PL2_GetSpikeChannelInfo( fileHandle, channelIndex, &channelInfo ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get spike channel info: " << error << endl;
            continue;
        }
        if ( channelInfo.m_NumberOfSpikes == 0 ) {
            continue;
        }
        unsigned long long numSpikesReturned = 0;
        long long* spikeTimestamps = new long long[( size_t )channelInfo.m_NumberOfSpikes ];
        unsigned short* units = new unsigned short[( size_t )channelInfo.m_NumberOfSpikes ];
        short* values = new short[( size_t )channelInfo.m_NumberOfSpikes * channelInfo.m_SamplesPerSpike];

        if ( !PL2_GetSpikeChannelData( fileHandle, channelIndex, &numSpikesReturned,
                                       spikeTimestamps, units, values ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get spike channel data: " << error << endl;
            delete []spikeTimestamps;
            delete []units;
            delete []values;
            continue;
        }

        printf( "\nSpike channel: %s\n", channelInfo.m_Name );

        for ( int spike = 0; spike < min( 2, ( int )numSpikesReturned ); ++spike ) {
            printf( "Spike %d: Unit: %d, Timestamp(sec):%10.6f,  Waveform(mV): ["
                    , spike, units[spike], spikeTimestamps[spike] / fileInfo.m_TimestampFrequency );
            for ( int wfValueIndex = 0; wfValueIndex < min( 2, ( int )channelInfo.m_SamplesPerSpike ); ++wfValueIndex ) {
                printf( " %12.6f,", values[spike * channelInfo.m_SamplesPerSpike + wfValueIndex]*channelInfo.m_CoeffToConvertToUnits * 1000 );
            }
            printf( " ...]\n" );
        }
        printf( "\n" );

        delete []spikeTimestamps;
        delete []units;
        delete []values;
        return;
    }
}

void PrintSampleOfFirstAnalogChannelWithData( int fileHandle, PL2FileInfo& fileInfo )
{
    for ( int channelIndex = 0; channelIndex < ( int )fileInfo.m_TotalNumberOfAnalogChannels; ++channelIndex ) {
        PL2AnalogChannelInfo channelInfo;
        if ( !PL2_GetAnalogChannelInfo( fileHandle, channelIndex, &channelInfo ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get analog channel info: " << error << endl;
            continue;
        }

        if ( channelInfo.m_NumberOfValues == 0 ) {
            continue;
        }

        unsigned long long numFragmentsReturned = 0;
        unsigned long long numDataPointsReturned = 0;
        long long* fragmentTimestamps = new long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        unsigned long long* fragmentCounts = new unsigned long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        short* values = new short[( size_t )channelInfo.m_NumberOfValues];

        if ( !PL2_GetAnalogChannelData( fileHandle, channelIndex, &numFragmentsReturned, &numDataPointsReturned
                                        , fragmentTimestamps, fragmentCounts, values ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get analog channel data: " << error << endl;
            delete []fragmentTimestamps;
            delete []fragmentCounts;
            delete []values;
            continue;
        }

        printf( "\nAnalog channel: %s, Number of fragments: %d\n", channelInfo.m_Name, ( int )numFragmentsReturned );
        double step = 1.0 / channelInfo.m_SamplesPerSecond;
        // print first few timestamps and values
        // if the first fragment count is more than 4 data points
        if ( numDataPointsReturned >= 4 && fragmentCounts[0] >= 4 ) {
            printf( "Timestamp (sec)   Value (mV)\n" );
            double step = 1.0 / channelInfo.m_SamplesPerSecond;
            double fragmentTimestampInSeconds = fragmentTimestamps[0] / fileInfo.m_TimestampFrequency;
            for ( size_t valueIndex = 0; valueIndex < 4; ++valueIndex ) {
                double dataPointTimestampInSeconds = fragmentTimestampInSeconds + step * valueIndex;
                double valueInMilliVolts = values[valueIndex]*channelInfo.m_CoeffToConvertToUnits * 1000;
                printf( "%15.6f %12.6f\n", dataPointTimestampInSeconds, valueInMilliVolts );
            }
        }
        printf( "...\n" );
        delete []fragmentTimestamps;
        delete []fragmentCounts;
        delete []values;
        return;
    }
}


void PrintSampleOfFirstDigitalChannelWithData( int fileHandle, PL2FileInfo& fileInfo )
{
    for ( int channelIndex = 0; channelIndex < ( int )fileInfo.m_NumberOfDigitalChannels; ++channelIndex ) {
        PL2DigitalChannelInfo channelInfo;
        if ( !PL2_GetDigitalChannelInfo( fileHandle, channelIndex, &channelInfo ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get digital channel info: " << error << endl;
            continue;
        }

        if ( channelInfo.m_NumberOfEvents == 0 ) {
            continue;
        }

        unsigned long long numEventsReturned = 0;
        long long* eventTimestamps = new long long[( size_t )channelInfo.m_NumberOfEvents ];
        unsigned short* eventValues = new unsigned short[( size_t )channelInfo.m_NumberOfEvents];

        if ( !PL2_GetDigitalChannelData( fileHandle, channelIndex, &numEventsReturned,
                                         eventTimestamps, eventValues ) ) {
            char error[1024];
            PL2_GetLastError( error, 1024 );
            cout << "unable to get digital channel data: " << error << endl;
            delete []eventTimestamps;
            delete []eventValues;
            continue;
        }

        printf( "\nDigital channel: %s\n", channelInfo.m_Name );
        printf( "Timestamp (sec)   Value\n" );
        // print first few timestamps and values
        for ( int valueIndex = 0; valueIndex < min( 4, ( int )numEventsReturned ); ++valueIndex ) {
            printf( "%15.6f   %05x\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency, eventValues[valueIndex] );
        }
        if ( numEventsReturned > 4 ) {
            printf( "...\n" );
        }
        delete []eventTimestamps;
        delete []eventValues;
        return;
    }
}

void PrintSampleOfStartStopChannel( int fileHandle, PL2FileInfo& fileInfo )
{
    unsigned long long numberOfStartStopEvents = 0;
    if ( !PL2_GetStartStopChannelInfo( fileHandle, &numberOfStartStopEvents ) ) {
        char error[1024];
        PL2_GetLastError( error, 1024 );
        cout << "unable to get start/stop channel info: " << error << endl;
        return;
    }

    if ( numberOfStartStopEvents == 0 ) {
        return;
    }

    unsigned long long numEventsReturned = 0;
    long long* eventTimestamps = new long long[( size_t )numberOfStartStopEvents];
    unsigned short* eventValues = new unsigned short[( size_t )numberOfStartStopEvents];

    if ( !PL2_GetStartStopChannelData( fileHandle, &numEventsReturned, eventTimestamps, eventValues ) ) {
        char error[1024];
        PL2_GetLastError( error, 1024 );
        cout << "unable to get start/stop channel data: " << error << endl;
        delete []eventTimestamps;
        delete []eventValues;
        return;
    }

    printf( "\nStart/stop channel\n" );
    printf( "Timestamp (sec)   Value\n" );
    const char* valueNames[] = { "STOP", "START", "PAUSE", "RESUME"};

    // print first few timestamps and values
    for ( int valueIndex = 0; valueIndex < min( 4, ( int )numEventsReturned ); ++valueIndex ) {
        if ( eventValues[valueIndex] < 4 ) {
            printf( "%15.6f   %05x  %s\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency,
                    eventValues[valueIndex],  valueNames[eventValues[valueIndex]] );
        } else {
            printf( "%15.6f   %05x (invalid event value)\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency,
                    eventValues[valueIndex] );
        }
    }
    if ( numEventsReturned > 4 ) {
        printf( "...\n" );
    }

    delete []eventTimestamps;
    delete []eventValues;
}
