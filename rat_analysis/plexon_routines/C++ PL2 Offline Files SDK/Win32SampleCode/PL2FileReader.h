// Symbol PL2FILEREADER_EXPORTS should not be defined in any project
// that uses this DLL. This way any project whose source files include this file see
// PL2FILEREADER_API functions as being imported from a DLL.
#ifdef PL2FILEREADER_EXPORTS
#define PL2FILEREADER_API __declspec(dllexport)
#else
#define PL2FILEREADER_API __declspec(dllimport)
#endif


#include "PL2FileStructures.h"

#define PL_BLOCK_TYPE_SPIKE (1)
#define PL_BLOCK_TYPE_ANALOG (2)
#define PL_BLOCK_TYPE_DIGITAL_EVENT (3)
#define PL_BLOCK_TYPE_STARTSTOP_EVENT (4)

extern "C" {

    /*------- PL2_OpenFile ----------------------
    Purpose:
        Open specified pl2 file.

    Parameters:
        const char* filePath - full path of the file
        int* fileHandle - pointer to file handle

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    */
    PL2FILEREADER_API int PL2_OpenFile( const char* filePath, int* fileHandle );



    /*------- PL2_CloseFile ----------------------
    Purpose:
        Close specified pl2 file.

    Parameters:
        int fileHandle - file handle

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    // ...
    PL2_CloseFile( fileHandle );
    */
    PL2FILEREADER_API void PL2_CloseFile( int fileHandle );



    /* ------- PL2_CloseAllFiles ----------------------
    Purpose:
        Close all pl2 files that have been opened by the dll.

    */
    PL2FILEREADER_API void PL2_CloseAllFiles();



    /*------- PL2_GetLastError ----------------------
    Purpose:
        Retrieve description of the last error.

    Parameters:
        char* buffer - buffer for the error description
        int bufferSize - buffer size in bytes (should be no less than 32)

    Return Values:
        1 - function succeeded
        0 - function failed

    Sample Code:

    int fileHandle = 0;
    if ( ! PL2_OpenFile( "C:\\PlexonData\\test1.pl2", &fileHandle ) ) {
        char error[256];
        PL2_GetLastError( error, 256 );
        printf( "unable to open file. error=%s\n", error );
    }
    */
    PL2FILEREADER_API int PL2_GetLastError( char *buffer, int bufferSize );



    /*------- PL2_GetFileInfo ----------------------
    Purpose:
        Retrieve information about pl2 file.

    Parameters:
        int fileHandle - file handle
        PL2FileInfo* info - pointer to PL2FileInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    */
    PL2FILEREADER_API int PL2_GetFileInfo( int fileHandle, PL2FileInfo* info );



    /*------- PL2_GetAnalogChannelInfo ----------------------
    Purpose:
        Retrieve information about analog channel

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based analog channel index
        PL2AnalogChannelInfo* info - pointer to PL2AnalogChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // print all analog channel names
    for ( int i = 0; i < ( int )fileInfo.m_TotalNumberOfAnalogChannels; ++i ) {
        PL2AnalogChannelInfo channelInfo;
        PL2_GetAnalogChannelInfo( fileHandle, i, &channelInfo );
        printf( "Channel %d, name %s\n", i, channelInfo.m_Name );
    }
    */
    PL2FILEREADER_API int PL2_GetAnalogChannelInfo( int fileHandle, int zeroBasedChannelIndex, PL2AnalogChannelInfo* info );



    /*------- PL2_GetAnalogChannelInfoByName ----------------------
    Purpose:
       Retrieve information about analog channel

    Parameters:
        int fileHandle - file handle
        const char* channelName - analog channel name
        PL2AnalogChannelInfo* info - pointer to PL2AnalogChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

     int fileHandle = 0;
     PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
     // get information about channel "FP01"
     PL2AnalogChannelInfo channelInfo;
     PL2_GetAnalogChannelInfoByName( fileHandle, "FP01", &channelInfo );
     */
    PL2FILEREADER_API int PL2_GetAnalogChannelInfoByName( int fileHandle, const char* channelName, PL2AnalogChannelInfo* info );



    /*------- PL2_GetAnalogChannelInfoBySource ----------------------
    Purpose:
        Retrieve information about analog channel

    Parameters:
        int fileHandle - file handle
        int sourceId - numeric source ID
        int oneBasedChannelIndexInSource - one-based channel index within the source
        PL2AnalogChannelInfo* info - pointer to PL2AnalogChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    // get information about the first analog channel in source 7
    PL2AnalogChannelInfo channelInfo;
    PL2_GetAnalogChannelInfoBySource( fileHandle, 7, 1, &channelInfo );
    */
    PL2FILEREADER_API int PL2_GetAnalogChannelInfoBySource( int fileHandle, int sourceId, int oneBasedChannelIndexInSource, PL2AnalogChannelInfo* info );


    /*------- PL2_GetAnalogChannelData ----------------------
    Purpose:
        Retrieve analog channel data

        Analog data come in fragments. Each fragment has a timestamp
        and a number of a/d data points. The timestamp corresponds to
        the time of recording of the first a/d value in this fragment.

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based analog channel index
        unsigned long long* numFragmentsReturned - pointer to number of fragments
        unsigned long long* numDataPointsReturned - pointer to number of data points
        long long* fragmentTimestamps - pointer to an array of fragment timestamps
                    the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements

                    The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                    PL2FileInfo.m_TimestampFrequency

        long long* fragmentCounts - pointer to an array of fragment counts
                    the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements

        short* values - pointer to an array of raw a/d values
                   the array should have at least PL2AnalogChannelInfo.m_NumberOfValues elements

                   To convert raw values to Volts, multiply by PL2AnalogChannelInfo.m_CoeffToConvertToUnits

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the first analog channel
    int channelIndex = 0;
    PL2AnalogChannelInfo channelInfo;
    PL2_GetAnalogChannelInfo( fileHandle, channelIndex, &channelInfo );
    if ( channelInfo.m_NumberOfValues > 0 ) {
        unsigned long long numFragmentsReturned = 0;
        unsigned long long numDataPointsReturned = 0;
        long long* fragmentTimestamps = new long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        unsigned long long* fragmentCounts = new unsigned long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        short* values = new short[( size_t )channelInfo.m_NumberOfValues];

        PL2_GetAnalogChannelData( fileHandle, channelIndex, &numFragmentsReturned, &numDataPointsReturned
        , fragmentTimestamps, fragmentCounts, values );

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
        delete []fragmentTimestamps;
        delete []fragmentCounts;
        delete []values;
    }
     */
    PL2FILEREADER_API int PL2_GetAnalogChannelData(
        int fileHandle
        , int zeroBasedChannelIndex
        , unsigned long long* numFragmentsReturned
        , unsigned long long* numDataPointsReturned
        , long long* fragmentTimestamps
        , unsigned long long* fragmentCounts
        , short* values );


    
   /*------- PL2_GetAnalogChannelDataSubset ----------------------
    Purpose:
        Retrieve subset of analog channel data

        Analog data come in fragments. Each fragment has a timestamp
        and a number of a/d data points. The timestamp corresponds to
        the time of recording of the first a/d value in this fragment.

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based analog channel index
        unsigned long long zeroBasedStartValueIndex - zero-based index of the first value
        unsigned int numberOfValues - number of values to be read
        unsigned long long* numFragmentsReturned - pointer to number of fragments
        unsigned long long* numDataPointsReturned - pointer to number of data points
        long long* fragmentTimestamps - pointer to an array of fragment timestamps
                    the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements

                    The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                    PL2FileInfo.m_TimestampFrequency

        long long* fragmentCounts - pointer to an array of fragment counts
                    the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements

        short* values - pointer to an array of raw a/d values
                   the array should have at least numberOfValues elements

                   To convert raw values to Volts, multiply by PL2AnalogChannelInfo.m_CoeffToConvertToUnits

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    PL2_CloseAllFiles();
    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the first analog channel
    int channelIndex = 0;
    PL2AnalogChannelInfo channelInfo;
    PL2_GetAnalogChannelInfo( fileHandle, channelIndex, &channelInfo );
    if ( channelInfo.m_NumberOfValues > 0 ) {
        unsigned long long numFragmentsReturned = 0;
        unsigned long long numDataPointsReturned = 0;
        long long* fragmentTimestamps = new long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        unsigned long long* fragmentCounts = new unsigned long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        size_t indexOfFirstValue = 1000;
        size_t numberOfValues = 2000;
        short* values = new short[numberOfValues];

        PL2_GetAnalogChannelDataSubset( fileHandle, channelIndex, indexOfFirstValue, numberOfValues,  &numFragmentsReturned, &numDataPointsReturned
        , fragmentTimestamps, fragmentCounts, values );

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
        delete []fragmentTimestamps;
        delete []fragmentCounts;
        delete []values;
    }
    */ 
    PL2FILEREADER_API int PL2_GetAnalogChannelDataSubset(
        int fileHandle
        , int zeroBasedChannelIndex
        , unsigned long long zeroBasedStartValueIndex
        , unsigned int numberOfValues
        , unsigned long long* numFragmentsReturned
        , unsigned long long* numDataPointsReturned
        , long long* fragmentTimestamps
        , unsigned long long* fragmentCounts
        , short* values );



    /*------- PL2_GetAnalogChannelDataByName ----------------------
    Purpose:
        Retrieve analog channel data

        Analog data come in fragments. Each fragment has a timestamp
        and a number of a/d data points. The timestamp corresponds to
        the time of recording of the first a/d value in this fragment.

    Parameters:
    int fileHandle - file handle
    const char* channelName - analog channel name
    unsigned long long* numFragmentsReturned - pointer to number of fragments
    unsigned long long* numDataPointsReturned - pointer to number of data points
    long long* fragmentTimestamps - pointer to an array of fragment timestamps
                            the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements

                            The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                            PL2FileInfo.m_TimestampFrequency

    long long* fragmentCounts - pointer to an array of fragment counts
                            the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements


    short* values - pointer to an array of raw a/d values
                            the array should have at least PL2AnalogChannelInfo.m_NumberOfValues elements

                            To convert raw values to Volts, multiply by PL2AnalogChannelInfo.m_CoeffToConvertToUnits

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for analog channel "FP01"
    PL2AnalogChannelInfo channelInfo;
    PL2_GetAnalogChannelInfoByName( fileHandle, "FP01", &channelInfo );
    if ( channelInfo.m_NumberOfValues > 0 ) {
        unsigned long long numFragmentsReturned = 0;
        unsigned long long numDataPointsReturned = 0;
        long long* fragmentTimestamps = new long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        unsigned long long* fragmentCounts = new unsigned long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        short* values = new short[( size_t )channelInfo.m_NumberOfValues];

        PL2_GetAnalogChannelDataByName( fileHandle, "FP01", &numFragmentsReturned, &numDataPointsReturned
        , fragmentTimestamps, fragmentCounts, values );

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
        delete []fragmentTimestamps;
        delete []fragmentCounts;
        delete []values;
    }
    */
    PL2FILEREADER_API int PL2_GetAnalogChannelDataByName(
        int fileHandle
        , const char* channelName
        , unsigned long long* numFragmentsReturned
        , unsigned long long* numDataPointsReturned
        , long long* fragmentTimestamps
        , unsigned long long* fragmentCounts
        , short* values );



    /*------- PL2_GetAnalogChannelDataBySource ----------------------
    Purpose:
        Retrieve analog channel data

        Analog data come in fragments. Each fragment has a timestamp
        and a number of a/d data points. The timestamp corresponds to
        the time of recording of the first a/d value in this fragment.

    Parameters:
        int fileHandle - file handle
        int sourceId - numeric source ID
        int oneBasedChannelIndexInSource - one-based channel index within the source
        unsigned long long* numFragmentsReturned - pointer to number of fragments
        unsigned long long* numDataPointsReturned - pointer to number of data points
        long long* fragmentTimestamps - pointer to an array of fragment timestamps
                                the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements

                                The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                                PL2FileInfo.m_TimestampFrequency

        long long* fragmentCounts - pointer to an array of fragment counts
                                the array should have at least PL2AnalogChannelInfo.m_MaximumNumberOfFragments elements


        short* values - pointer to an array of raw A/D values
                                the array should have at least PL2AnalogChannelInfo.m_NumberOfValues elements

                                To convert raw values to Volts, multiply by PL2AnalogChannelInfo.m_CoeffToConvertToUnits

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the first analog channel from source 7
    PL2AnalogChannelInfo channelInfo;
    PL2_GetAnalogChannelInfoBySource( fileHandle, 7, 1, &channelInfo );
    if ( channelInfo.m_NumberOfValues > 0 ) {
        unsigned long long numFragmentsReturned = 0;
        unsigned long long numDataPointsReturned = 0;
        long long* fragmentTimestamps = new long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        unsigned long long* fragmentCounts = new unsigned long long[( size_t )channelInfo.m_MaximumNumberOfFragments ];
        short* values = new short[( size_t )channelInfo.m_NumberOfValues];

        PL2_GetAnalogChannelDataBySource( fileHandle, 7, 1, &numFragmentsReturned, &numDataPointsReturned
        , fragmentTimestamps, fragmentCounts, values );

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
        delete []fragmentTimestamps;
        delete []fragmentCounts;
        delete []values;
    }
    */
    PL2FILEREADER_API int PL2_GetAnalogChannelDataBySource(
        int fileHandle
        , int sourceId
        , int oneBasedChannelIndexInSource
        , unsigned long long* numFragmentsReturned
        , unsigned long long* numDataPointsReturned
        , long long* fragmentTimestamps
        , unsigned long long* fragmentCounts
        , short* values );

    
    
    /*------- PL2_GetSpikeChannelInfo ----------------------
    Purpose:
        Retrieve information about spike channel

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based spike channel index
        PL2SpikeChannelInfo* info - pointer to PL2SpikeChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // print all spike channel names
    for ( int i = 0; i < ( int )fileInfo.m_TotalNumberOfSpikeChannels; ++i ) {
        PL2SpikeChannelInfo channelInfo;
        PL2_GetSpikeChannelInfo( fileHandle, i, &channelInfo );
        printf( "Channel %d, name %s\n", i, channelInfo.m_Name );
    }
    */
    PL2FILEREADER_API int PL2_GetSpikeChannelInfo( int fileHandle, int zeroBasedChannelIndex, PL2SpikeChannelInfo* info );



    /*------- PL2_GetSpikeChannelInfoByName ----------------------
    Purpose:
        Retrieve information about spike channel

    Parameters:
        int fileHandle - file handle
        const char* channelName - spike channel name
        PL2SpikeChannelInfo* info - pointer to PL2SpikeChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    // get information about channel "SPK01"
    PL2SpikeChannelInfo channelInfo;
    PL2_GetSpikeChannelInfoByName( fileHandle, "SPK01", &channelInfo );
    */
    PL2FILEREADER_API int PL2_GetSpikeChannelInfoByName( int fileHandle, const char* channelName, PL2SpikeChannelInfo* info );



    /*------- PL2_GetSpikeChannelInfoBySource ----------------------
    Purpose:
        Retrieve information about spike channel

    Parameters:
        int fileHandle - file handle
        int sourceId - numeric source ID
        int oneBasedChannelIndexInSource - one-based channel index within the source
        PL2SpikeChannelInfo* info - pointer to PL2SpikeChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    // get information about the first channel of source 6
    PL2SpikeChannelInfo channelInfo;
    PL2_GetSpikeChannelInfoBySource( fileHandle, 6, 1, &channelInfo );
    */
    PL2FILEREADER_API int PL2_GetSpikeChannelInfoBySource( int fileHandle, int sourceId, int oneBasedChannelIndexInSource, PL2SpikeChannelInfo* info );

    
     
    /*------- PL2_GetSpikeChannelData ----------------------
    Purpose:
        Retrieve spike channel data

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based spike channel index
        unsigned long long* numSpikesReturned - pointer to number of spikes
        long long* spikeTimestamps - pointer to an array of spike timestamps
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes elements

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

    unsigned short* units - pointer to an array of unit values
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes elements

    short* values - pointer to an array of raw a/d spike waveform values
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes*PL2SpikeChannelInfo.m_SamplesPerSpike elements

                        To convert raw values to Volts, multiply by PL2SpikeChannelInfo.m_CoeffToConvertToUnits

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the first spike channel
    int channelIndex = 0;
    PL2SpikeChannelInfo channelInfo;
    PL2_GetSpikeChannelInfo( fileHandle, channelIndex, &channelInfo );
    if ( channelInfo.m_NumberOfSpikes > 0 ) {
        unsigned long long numSpikesReturned = 0;
        long long* spikeTimestamps = new long long[( size_t )channelInfo.m_NumberOfSpikes ];
        unsigned short* units = new unsigned short[( size_t )channelInfo.m_NumberOfSpikes ];
        short* values = new short[( size_t )channelInfo.m_NumberOfSpikes * channelInfo.m_SamplesPerSpike];

        PL2_GetSpikeChannelData( fileHandle, channelIndex, &numSpikesReturned,
        spikeTimestamps, units, values );
        // print data for the first 2 spikes
        for ( int spike = 0; spike < min( 2, ( int )numSpikesReturned ); ++spike ) {
            printf( "Spike %d: Unit: %d, Timestamp(sec):%10.6f,  Waveform(mV): ["
            , spike, units[spike], spikeTimestamps[spike] / fileInfo.m_TimestampFrequency );
            for ( int wfValueIndex = 0; wfValueIndex < min( 2, ( int )channelInfo.m_SamplesPerSpike ); ++wfValueIndex ) {
                printf( " %12.6f,", values[spike * channelInfo.m_SamplesPerSpike + wfValueIndex]*channelInfo.m_CoeffToConvertToUnits * 1000 );
            }
            printf( " ...]\n" );
        }
        delete []spikeTimestamps;
        delete []units;
        delete []values;
    }
     */   
    PL2FILEREADER_API int PL2_GetSpikeChannelData(
        int fileHandle
        , int zeroBasedChannelIndex
        , unsigned long long* numSpikesReturned
        , long long* spikeTimestamps
        , unsigned short* units
        , short* values );
    
    
    
    /*------- PL2_GetSpikeChannelDataByName ----------------------
    Purpose:
        Retrieve spike channel data

    Parameters:
        int fileHandle - file handle
        const char* channelName - channel name
        unsigned long long* numSpikesReturned - pointer to number of spikes
        long long* spikeTimestamps - pointer to an array of spike timestamps
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes elements

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

        unsigned short* units - pointer to an array of unit values
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes elements

        short* values - pointer to an array of raw a/d spike waveform values
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes*PL2SpikeChannelInfo.m_SamplesPerSpike elements

                        To convert raw values to Volts, multiply by PL2SpikeChannelInfo.m_CoeffToConvertToUnits

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the spike channel "SPK01"
    int channelIndex = 0;
    PL2SpikeChannelInfo channelInfo;
    PL2_GetSpikeChannelInfoByName( fileHandle, "SPK01", &channelInfo );
    if ( channelInfo.m_NumberOfSpikes > 0 ) {
        unsigned long long numSpikesReturned = 0;
        long long* spikeTimestamps = new long long[( size_t )channelInfo.m_NumberOfSpikes ];
        unsigned short* units = new unsigned short[( size_t )channelInfo.m_NumberOfSpikes ];
        short* values = new short[( size_t )channelInfo.m_NumberOfSpikes * channelInfo.m_SamplesPerSpike];

        PL2_GetSpikeChannelDataByName( fileHandle, "SPK01", &numSpikesReturned, spikeTimestamps, units, values );
        // print data for the first 2 spikes
        for ( int spike = 0; spike < min( 2, ( int )numSpikesReturned ); ++spike ) {
            printf( "Spike %d: Unit: %d, Timestamp(sec):%10.6f,  Waveform(mV): ["
            , spike, units[spike], spikeTimestamps[spike] / fileInfo.m_TimestampFrequency );
            for ( int wfValueIndex = 0; wfValueIndex < min( 2, ( int )channelInfo.m_SamplesPerSpike ); ++wfValueIndex ) {
                printf( " %12.6f,", values[spike * channelInfo.m_SamplesPerSpike + wfValueIndex]*channelInfo.m_CoeffToConvertToUnits * 1000 );
            }
            printf( " ...]\n" );
        }
        delete []spikeTimestamps;
        delete []units;
        delete []values;
    }
     */   
    PL2FILEREADER_API int PL2_GetSpikeChannelDataByName(
        int fileHandle
        , const char* channelName
        , unsigned long long* numSpikesReturned
        , long long* spikeTimestamps
        , unsigned short* units
        , short* values );
    
    
    
    /*------- PL2_GetSpikeChannelDataBySource ----------------------
    Purpose:
        Retrieve spike channel data

    Parameters:
        int fileHandle - file handle
        int sourceId - numeric source ID
        int oneBasedChannelIndexInSource - one-based channel index within the source
        unsigned long long* numSpikesReturned - pointer to number of spikes
        long long* spikeTimestamps - pointer to an array of spike timestamps
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes elements

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

        unsigned short* units - pointer to an array of unit values
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes elements

        short* values - pointer to an array of raw a/d spike waveform values
                        the array should have at least PL2SpikeChannelInfo.m_NumberOfSpikes*PL2SpikeChannelInfo.m_SamplesPerSpike elements

                        To convert raw values to Volts, multiply by PL2SpikeChannelInfo.m_CoeffToConvertToUnits

    Return Values:
    1 - function succeeded
    0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the first channel of source 6
    PL2SpikeChannelInfo channelInfo;
    PL2_GetSpikeChannelInfoBySource( fileHandle, 6, 1, &channelInfo );
    if ( channelInfo.m_NumberOfSpikes > 0 ) {
        unsigned long long numSpikesReturned = 0;
        long long* spikeTimestamps = new long long[( size_t )channelInfo.m_NumberOfSpikes ];
        unsigned short* units = new unsigned short[( size_t )channelInfo.m_NumberOfSpikes ];
        short* values = new short[( size_t )channelInfo.m_NumberOfSpikes * channelInfo.m_SamplesPerSpike];

        PL2_GetSpikeChannelDataBySource( fileHandle, 6, 1, &numSpikesReturned, spikeTimestamps, units, values );
        // print data for the first 2 spikes
        for ( int spike = 0; spike < min( 2, ( int )numSpikesReturned ); ++spike ) {
            printf( "Spike %d: Unit: %d, Timestamp(sec):%10.6f,  Waveform(mV): ["
            , spike, units[spike], spikeTimestamps[spike] / fileInfo.m_TimestampFrequency );
            for ( int wfValueIndex = 0; wfValueIndex < min( 2, ( int )channelInfo.m_SamplesPerSpike ); ++wfValueIndex ) {
                printf( " %12.6f,", values[spike * channelInfo.m_SamplesPerSpike + wfValueIndex]*channelInfo.m_CoeffToConvertToUnits * 1000 );
            }
            printf( " ...]\n" );
        }
        delete []spikeTimestamps;
        delete []units;
        delete []values;
    }
    */
    PL2FILEREADER_API int PL2_GetSpikeChannelDataBySource(
        int fileHandle
        , int sourceID
        , int oneBasedChannelIndexInSource
        , unsigned long long* numSpikesReturned
        , long long* spikeTimestamps
        , unsigned short* units
        , short* values );




    /*------- PL2_GetDigitalChannelInfo ----------------------
    Purpose:
        Retrieve information about digital channel

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based spike channel index
        PL2DigitalChannelInfo* info - pointer to PL2DigitalChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // print all spike channel names
    for ( int i = 0; i < ( int )fileInfo.m_NumberOfDigitalChannels; ++i ) {
        PL2DigitalChannelInfo channelInfo;
        PL2_GetDigitalChannelInfo( fileHandle, i, &channelInfo );
        printf( "Channel %d, name %s\n", i, channelInfo.m_Name );
    }
    */
    PL2FILEREADER_API int PL2_GetDigitalChannelInfo( int fileHandle, int zeroBasedChannelIndex, PL2DigitalChannelInfo* info );
 
    
    
    /*------- PL2_GetDigitalChannelInfoByName ----------------------
    Purpose:
        Retrieve information about digital channel

    Parameters:
        int fileHandle - file handle
        const char* channelName - channel name
        PL2DigitalChannelInfo* info - pointer to PL2DigitalChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    // get information about digital channel "EVT01"
    PL2DigitalChannelInfo channelInfo;
    PL2_GetDigitalChannelInfoByName( fileHandle, "EVT01", &channelInfo );
    */   
    PL2FILEREADER_API int PL2_GetDigitalChannelInfoByName( int fileHandle, const char* channelName, PL2DigitalChannelInfo* info );


    /*------- PL2_GetDigitalChannelInfoBySource ----------------------
    Purpose:
        Retrieve information about digital channel

    Parameters:
        int fileHandle - file handle
        int sourceId - numeric source ID
        int oneBasedChannelIndexInSource - one-based channel index within the source
        PL2DigitalChannelInfo* info - pointer to PL2DigitalChannelInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    // get information about the first digital channel in source 8
    PL2DigitalChannelInfo channelInfo;
    PL2_GetDigitalChannelInfoBySource( fileHandle, 8, 1, &channelInfo );
    */   
    PL2FILEREADER_API int PL2_GetDigitalChannelInfoBySource( int fileHandle, int sourceId, int oneBasedChannelIndexInSource, PL2DigitalChannelInfo* info );

    
  
    /*------- PL2_GetDigitalChannelData ----------------------
    Purpose:
        Retrieve digital channel data

    Parameters:
        int fileHandle - file handle
        int zeroBasedChannelIndex - zero-based digital channel index
        unsigned long long* numEventsReturned - pointer to number of events
        long long* eventTimestamps - pointer to an array of event timestamps
                        the array should have at least PL2DigitalChannelInfo.m_NumberOfEvents elements

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

        unsigned short* eventValues - pointer to an array of event values
                        the array should have at least PL2DigitalChannelInfo.m_NumberOfEvents elements

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for the first digital channel
    int channelIndex = 0;
    PL2DigitalChannelInfo channelInfo;
    PL2_GetDigitalChannelInfo( fileHandle, channelIndex, &channelInfo );
    if ( channelInfo.m_NumberOfEvents > 0 ) {
        unsigned long long numEventsReturned = 0;
        long long* eventTimestamps = new long long[( size_t )channelInfo.m_NumberOfEvents ];
        unsigned short* eventValues = new unsigned short[( size_t )channelInfo.m_NumberOfEvents];
        PL2_GetDigitalChannelData( fileHandle, channelIndex, &numEventsReturned, eventTimestamps, eventValues );
        printf( "Timestamp (sec)   Value\n" );
        // print first few timestamps and values
        for ( int valueIndex = 0; valueIndex < min( 4, ( int )numEventsReturned ); ++valueIndex ) {
            printf( "%15.6f   %05x\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency, eventValues[valueIndex] );
        }
        delete []eventTimestamps;
        delete []eventValues;
    }
    */
    PL2FILEREADER_API int PL2_GetDigitalChannelData(
        int fileHandle
        , int zeroBasedChannelIndex
        , unsigned long long* numEventsReturned
        , long long* eventTimestamps
        , unsigned short* eventValues );
    
    
    /*------- PL2_GetDigitalChannelDataByName ----------------------
    Purpose:
        Retrieve digital channel data

    Parameters:
        int fileHandle - file handle
        const char* eventName - event name
        unsigned long long* numEventsReturned - pointer to number of events
        long long* eventTimestamps - pointer to an array of event timestamps
                        the array should have at least PL2DigitalChannelInfo.m_NumberOfEvents elements

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

        unsigned short* eventValues - pointer to an array of event values
                        the array should have at least PL2DigitalChannelInfo.m_NumberOfEvents elements

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for digital channel "EVT01"
    int channelIndex = 0;
    PL2DigitalChannelInfo channelInfo;
    PL2_GetDigitalChannelInfoByName( fileHandle, "EVT01", &channelInfo );
    if ( channelInfo.m_NumberOfEvents > 0 ) {
        unsigned long long numEventsReturned = 0;
        long long* eventTimestamps = new long long[( size_t )channelInfo.m_NumberOfEvents ];
        unsigned short* eventValues = new unsigned short[( size_t )channelInfo.m_NumberOfEvents];
        PL2_GetDigitalChannelDataByName( fileHandle, "EVT01", &numEventsReturned, eventTimestamps, eventValues );
        printf( "Timestamp (sec)   Value\n" );
        // print first few timestamps and values
        for ( int valueIndex = 0; valueIndex < min( 4, ( int )numEventsReturned ); ++valueIndex ) {
            printf( "%15.6f   %05x\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency, eventValues[valueIndex] );
        }
        delete []eventTimestamps;
        delete []eventValues;
    }
    */  
    PL2FILEREADER_API int PL2_GetDigitalChannelDataByName(
        int fileHandle
        , const char* channelName
        , unsigned long long* numEventsReturned
        , long long* eventTimestamps
        , unsigned short* eventValues );
    
    
    
    /*------- PL2_GetDigitalChannelDataBySource ----------------------
    Purpose:
        Retrieve digital channel data

    Parameters:
        int fileHandle - file handle
        int sourceId - numeric source ID
        int oneBasedChannelIndexInSource - one-based channel index within the source
        unsigned long long* numEventsReturned - pointer to number of events
        long long* eventTimestamps - pointer to an array of event timestamps
                        the array should have at least PL2DigitalChannelInfo.m_NumberOfEvents elements

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

        unsigned short* eventValues - pointer to an array of event values
                        the array should have at least PL2DigitalChannelInfo.m_NumberOfEvents elements

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    // get data for first digital channel in source 8
    int channelIndex = 0;
    PL2DigitalChannelInfo channelInfo;
    PL2_GetDigitalChannelInfoBySource( fileHandle, 8, 1, &channelInfo );
    if ( channelInfo.m_NumberOfEvents > 0 ) {
        unsigned long long numEventsReturned = 0;
        long long* eventTimestamps = new long long[( size_t )channelInfo.m_NumberOfEvents ];
        unsigned short* eventValues = new unsigned short[( size_t )channelInfo.m_NumberOfEvents];
        PL2_GetDigitalChannelDataBySource( fileHandle, 8, 1, &numEventsReturned, eventTimestamps, eventValues );
        printf( "Timestamp (sec)   Value\n" );
        // print first few timestamps and values
        for ( int valueIndex = 0; valueIndex < min( 4, ( int )numEventsReturned ); ++valueIndex ) {
            printf( "%15.6f   %05x\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency, eventValues[valueIndex] );
        }
        delete []eventTimestamps;
        delete []eventValues;
    }
    */  
    PL2FILEREADER_API int PL2_GetDigitalChannelDataBySource(
        int fileHandle
        , int sourceID
        , int oneBasedChannelIndexInSource
        , unsigned long long* numEventsReturned
        , long long* eventTimestamps
        , unsigned short* eventValues );


    /*------- PL2_GetStartStopChannelInfo ----------------------
    Purpose:
        Retrieve information about start/stop channel

    Parameters:
        int fileHandle - file handle
        unsigned long long* numberOfStartStopEvents - pointer to the number of start/stop events

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    unsigned long long numberOfStartStopEvents = 0;
    PL2_GetStartStopChannelInfo( fileHandle, &numberOfStartStopEvents );
    */
    PL2FILEREADER_API int PL2_GetStartStopChannelInfo( int fileHandle, unsigned long long* numberOfStartStopEvents );

    

    /*------- PL2_GetStartStopChannelData ----------------------
    Purpose:
        Retrieve digital channel data

    Parameters:
        int fileHandle - file handle
        unsigned long long* numEventsReturned - pointer to number of events
        long long* eventTimestamps - pointer to an array of event timestamps
                        the array should have at least numberOfStartStopEvents elements 
                        where numberOfStartStopEvents is the value retrieved by calling
                        PL2_GetStartStopChannelInfo

                        The timestamps are returned in ticks. To convert timestamps to seconds, divide by
                        PL2FileInfo.m_TimestampFrequency

        unsigned short* eventValues - pointer to an array of event values
                        the array should have at least numberOfStartStopEvents elements

                        Event values are specified by this enum
                        enum RecordingStartStop { STOP = 0, START = 1, PAUSE = 2, RESUME = 3 };


    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:
    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    PL2FileInfo fileInfo;
    PL2_GetFileInfo( fileHandle, &fileInfo );
    unsigned long long numberOfStartStopEvents = 0;
    PL2_GetStartStopChannelInfo( fileHandle, &numberOfStartStopEvents );
    if ( numberOfStartStopEvents > 0 ) {
        unsigned long long numEventsReturned = 0;
        long long* eventTimestamps = new long long[( size_t )numberOfStartStopEvents];
        unsigned short* eventValues = new unsigned short[( size_t )numberOfStartStopEvents];

        PL2_GetStartStopChannelData( fileHandle, &numEventsReturned, eventTimestamps, eventValues );
        printf( "Timestamp (sec)   Value\n" );
        const char* valueNames[] = { "STOP", "START", "PAUSE", "RESUME"};
        // print first few timestamps and values
        for ( int valueIndex = 0; valueIndex < min( 4, ( int )numEventsReturned ); ++valueIndex ) {
            printf( "%15.6f   %05x  %s\n", eventTimestamps[valueIndex] / fileInfo.m_TimestampFrequency,
               eventValues[valueIndex],  valueNames[eventValues[valueIndex]] );
        }
        delete []eventTimestamps;
        delete []eventValues;
    }
    */
    PL2FILEREADER_API int PL2_GetStartStopChannelData(
        int fileHandle
        , unsigned long long* numEventsReturned
        , long long* eventTimestamps
        , unsigned short* eventValues );


    /*------- PL2_ReadFirstDataBlock ----------------------
    Purpose:
        Seek to the start of data in pl2 file and read first data block

    Parameters:
        int fileHandle - file handle

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

        int fileHandle = 0;
        PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
        PL2_ReadFirstDataBlock( fileHandle );
    */
    PL2FILEREADER_API int PL2_ReadFirstDataBlock( int fileHandle );


    /*------- PL2_ReadNextDataBlock ----------------------
    Purpose:
        Read next data block. PL2_ReadFirstDataBlock must be called before calling this method.

    Parameters:
        int fileHandle - file handle

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        // code for data block processing goes here
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */
    PL2FILEREADER_API int PL2_ReadNextDataBlock( int fileHandle );

    /*------- PL2_GetDataBlockInfo ----------------------
    Purpose:
        Retrieve information about current data block

    Parameters:
        int fileHandle - file handle
        PL2BlockInfo* info - pointer to PL2BlockInfo structure

    Return Values:
        1 - function succeeded
        0 - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ... 
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */
    PL2FILEREADER_API int PL2_GetDataBlockInfo( int fileHandle, PL2BlockInfo* info );

    
    /*------- PL2_GetSpikeDataBlockTimestamps ----------------------
    Purpose:
        Retrieve pointer to timestamps for a current data block (if data block is a spike data block)
        The number of timestamps is PL2BlockInfo.m_NumberOfItems

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_SPIKE ) {
            const long long* timestamps = PL2_GetSpikeDataBlockTimestamps( fileHandle );
            const unsigned short* units = PL2_GetSpikeDataBlockUnits( fileHandle );
            const short* waveforms = PL2_GetSpikeDataBlockWaveforms( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */    
    PL2FILEREADER_API const long long* PL2_GetSpikeDataBlockTimestamps( int fileHandle );


   /*------- PL2_GetSpikeDataBlockUnits ----------------------
    Purpose:
        Retrieve pointer to units for a current data block (if data block is a spike data block)
        The number of unit values is PL2BlockInfo.m_NumberOfItems

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_SPIKE ) {
            const long long* timestamps = PL2_GetSpikeDataBlockTimestamps( fileHandle );
            const unsigned short* units = PL2_GetSpikeDataBlockUnits( fileHandle );
            const short* waveforms = PL2_GetSpikeDataBlockWaveforms( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */    
    PL2FILEREADER_API const unsigned short* PL2_GetSpikeDataBlockUnits( int fileHandle );


   /*------- PL2_GetSpikeDataBlockWaveforms ----------------------
    Purpose:
        Retrieve pointer to waveforms for a current data block (if data block is a spike data block)
        The number of waveforms is PL2BlockInfo.m_NumberOfItems, 
        each waveform contains PL2SpikeChannelInfo.m_SamplesPerSpike values.
        So the total number of values is (PL2BlockInfo.m_NumberOfItems * PL2SpikeChannelInfo.m_SamplesPerSpike).

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_SPIKE ) {
            const long long* timestamps = PL2_GetSpikeDataBlockTimestamps( fileHandle );
            const unsigned short* units = PL2_GetSpikeDataBlockUnits( fileHandle );
            const short* waveforms = PL2_GetSpikeDataBlockWaveforms( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */    
    PL2FILEREADER_API const short* PL2_GetSpikeDataBlockWaveforms( int fileHandle );

    
    /*------- PL2_GetAnalogDataBlockTimestamp ----------------------
    Purpose:
        Retrieve timestamp of the first data point for a current data block (if data block is an analog data block)

    Parameters:
        int fileHandle - file handle

    Return Values:
        returns timestamp of the first data point in the analog data block

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_ANALOG ) {
            long long timestamp = PL2_GetAnalogDataBlockTimestamp( fileHandle );
            const short* values = PL2_GetAnalogDataBlockValues( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */    
    PL2FILEREADER_API long long PL2_GetAnalogDataBlockTimestamp( int fileHandle );
    
    /*------- PL2_GetAnalogDataBlockValues ----------------------
    Purpose:
        Retrieve pointer to values for a current data block (if data block is an analog data block)
        The number of values is PL2BlockInfo.m_NumberOfItems

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_ANALOG ) {
            long long timestamp = PL2_GetAnalogDataBlockTimestamp( fileHandle );
            const short* values = PL2_GetAnalogDataBlockValues( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */    
    PL2FILEREADER_API const short* PL2_GetAnalogDataBlockValues( int fileHandle );

   
    
    /*------- PL2_GetDigitalDataBlockTimestamps ----------------------
    Purpose:
        Retrieve pointer to timestamps for a current data block (if data block is a digital data block)
        The number of timestamps is PL2BlockInfo.m_NumberOfItems

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_DIGITAL_EVENT ) {
            const long long* timestamps = PL2_GetDigitalDataBlockTimestamps( fileHandle );
            const unsigned short* values = PL2_GetDigitalDataBlockValues( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */        
    PL2FILEREADER_API const long long* PL2_GetDigitalDataBlockTimestamps( int fileHandle );

    
    
    /*------- PL2_GetDigitalDataBlockValues ----------------------
    Purpose:
        Retrieve pointer to digital event values for a current data block (if data block is a digital data block)
        The number of values is PL2BlockInfo.m_NumberOfItems

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_DIGITAL_EVENT ) {
            const long long* timestamps = PL2_GetDigitalDataBlockTimestamps( fileHandle );
            const unsigned short* values = PL2_GetDigitalDataBlockValues( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */        
    PL2FILEREADER_API const unsigned short* PL2_GetDigitalDataBlockValues( int fileHandle );

    
    /*------- PL2_GetStartStopDataBlockTimestamps ----------------------
    Purpose:
        Retrieve pointer to timestamps for a current data block (if data block is a start/stop data block)
        The number of timestamps is PL2BlockInfo.m_NumberOfItems

    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_STARTSTOP_EVENT ) {
            const long long* timestamps = PL2_GetStartStopDataBlockTimestamps( fileHandle );
            const unsigned short* values = PL2_GetStartStopDataBlockValues( fileHandle );
            // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */       
    PL2FILEREADER_API const long long* PL2_GetStartStopDataBlockTimestamps( int fileHandle );
    
    
    /*------- PL2_GetStartStopDataBlockValues ----------------------
    Purpose:
        Retrieve pointer to start/stop event values for a current data block (if data block is a start/stop data block)
        The number of values is PL2BlockInfo.m_NumberOfItems
        The values are the following:
        #define PL2_STOP (0)
        #define PL2_START (1)
        #define PL2_PAUSE (2)
        #define PL2_RESUME (3)


    Parameters:
        int fileHandle - file handle

    Return Values:
        non-NULL - function succeeded
        NULL - function failed (use PL2_GetLastError() to retrieve error description)

    Sample Code:

    int fileHandle = 0;
    PL2_OpenFile( "C:\\PlexonData\\test.pl2", &fileHandle );
    int dataBlockIsOK = PL2_ReadFirstDataBlock( fileHandle );
    while ( dataBlockIsOK ) {
        PL2BlockInfo info;
        PL2_GetDataBlockInfo( fileHandle, &info );
        // process data block ...
        if (  info.m_BlockType == PL2_BLOCK_TYPE_STARTSTOP_EVENT ) {
            const long long* timestamps = PL2_GetStartStopDataBlockTimestamps( fileHandle );
            const unsigned short* values = PL2_GetStartStopDataBlockValues( fileHandle );
        // ...
        }
        dataBlockIsOK = PL2_ReadNextDataBlock( fileHandle )
    }
    */    
    PL2FILEREADER_API const unsigned short* PL2_GetStartStopDataBlockValues( int fileHandle );
};
