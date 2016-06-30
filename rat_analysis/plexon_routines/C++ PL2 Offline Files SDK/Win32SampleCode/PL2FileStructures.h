#pragma once

// this header is needed for tm structure
#include <wchar.h>


#pragma pack( push, 8 )

struct PL2FileInfo {
    PL2FileInfo() { memset( this, 0, sizeof( *this ) ); }

    // file comment
    char m_CreatorComment[256];
    // software name
    char m_CreatorSoftwareName[64];
    // software version
    char m_CreatorSoftwareVersion[16];
    // file creation date and time (local time)
    tm m_CreatorDateTime;
    int m_CreatorDateTimeMilliseconds;
    // timestamp frequency in Hertz
    double       m_TimestampFrequency;
    // total number of channel headers in the file
    unsigned int m_NumberOfChannelHeaders;
    // numbers of channels below are for the sources that are recorded in the file
    // all spike channels
    unsigned int m_TotalNumberOfSpikeChannels;
    // recorded spike channels
    unsigned int m_NumberOfRecordedSpikeChannels;
    // all analog channels
    unsigned int m_TotalNumberOfAnalogChannels;
    // recorded analog channels
    unsigned int m_NumberOfRecordedAnalogChannels;
    // all event headers
    unsigned int m_NumberOfDigitalChannels;
    // min and max trodalities of all the recorded analog and spike channels
    unsigned int m_MinimumTrodality;
    unsigned int m_MaximumTrodality;
    // number of non-OmniPlex clients that were sending data (for example, CinePlex in the future)
    unsigned int m_NumberOfNonOmniPlexSources;
    // 4-byte unused here to maintain 8-byte structure alignment
    int m_Unused;
    // re-processor file comment
    char m_ReprocessorComment[256];
    // re-processor software name
    char m_ReprocessorSoftwareName[64];
    // re-processor software version
    char m_ReprocessorSoftwareVersion[16];
    // re-processor file creation date and time (local time)
    tm m_ReprocessorDateTime;
    int m_ReprocessorDateTimeMilliseconds;

    // timestamp of the start recording PDP
    unsigned long long    m_StartRecordingTime;
    // duration of recording in time ticks
    unsigned long long    m_DurationOfRecording;
};

struct PL2AnalogChannelInfo {
    PL2AnalogChannelInfo() { memset( this, 0, sizeof( *this ) ); }

    // channel name
    char m_Name[64];
    // 1-based source number
    unsigned int m_Source;
    // 1-based channel number within source
    unsigned int m_Channel;
    // m_ChannelEnabled can be either 0 or 1. 0: channel acquisition is disabled; 1: channel acquisition is enabled
    unsigned int m_ChannelEnabled;
    // m_ChannelRecordingEnabled can be either 0 or 1. 0: channel recording is disabled; 1: channel recording is enabled
    unsigned int m_ChannelRecordingEnabled;
    //  Units name. "Volts" by default
    char m_Units[16];
    // samples per second
    double m_SamplesPerSecond;
    // coefficient to convert raw a/d values to units
    // value_in_units = raw_short_saved_in_file * coeff
    double m_CoeffToConvertToUnits;
    // number of channels in one trode
    unsigned int m_SourceTrodality;
    // 1-based trode number; if m_SourceTrodality is 1, m_OneBasedTrode is the same as m_Channel
    unsigned short m_OneBasedTrode;
    // 1-based channel inside trode; possible values are from 1 to m_SourceTrodality inclusive
    unsigned short m_OneBasedChannelInTrode;
    // number of analog values for this channel
    unsigned long long m_NumberOfValues;
    // maximum number of fragments for this channel 
    // this number should be used to allocate enough memory for fragment timestamps when calling PL2_GetAnalogChannelData
    unsigned long long m_MaximumNumberOfFragments;
};

struct PL2SpikeChannelInfo {
    PL2SpikeChannelInfo() { memset( this, 0, sizeof( *this ) ); }

    // channel name
    char m_Name[64];
    // 1-based source number
    unsigned int m_Source;
    // 1-based channel number within source
    unsigned int m_Channel;
    // m_ChannelEnabled can be either 0 or 1. 0: channel acquisition is disabled; 1: channel acquisition is enabled
    unsigned int m_ChannelEnabled;
    // m_ChannelRecordingEnabled can be either 0 or 1. 0: channel recording is disabled; 1: channel recording is enabled
    unsigned int m_ChannelRecordingEnabled;
    //  Units name. "Volts" by default
    char m_Units[16];
    // samples per second
    double m_SamplesPerSecond;
    // coefficient to convert raw a/d values to units
    // value_in_units = raw_short_saved_in_file * coeff
    double m_CoeffToConvertToUnits;
    // number of values in one waveform
    unsigned int m_SamplesPerSpike;
    // raw a/d value of threshold
    int m_Threshold;
    // number of values before threshold
    unsigned int m_PreThresholdSamples;
    // m_SortEnabled can be either 0 or 1. 1 - sorting enabled, 0 - sorting disabled
    unsigned int m_SortEnabled;
    // sort method, see enum SortingMethodTypes above
    unsigned int m_SortMethod;
    // number of sorted units
    unsigned int m_NumberOfUnits;
    // sort range start
    unsigned int m_SortRangeStart;
    // sort range end
    unsigned int m_SortRangeEnd;
    // unit counts
    unsigned long long m_UnitCounts[256];
    // number of channels in one trode
    unsigned int m_SourceTrodality;
    // 1-based trode number; if m_SourceTrodality is 1, m_OneBasedTrode is the same as m_Channel
    unsigned short m_OneBasedTrode;
    // 1-based channel inside trode; possible values are from 1 to m_SourceTrodality inclusive
    unsigned short m_OneBasedChannelInTrode;
    // number of spikes for this channel
    unsigned long long m_NumberOfSpikes;
};

struct PL2DigitalChannelInfo {
    PL2DigitalChannelInfo() { memset( this, 0, sizeof( *this ) ); }

    // channel name
    char m_Name[64];
    // 1-based source number
    unsigned int m_Source;
    // 1-based channel number within source
    unsigned int m_Channel;
    // m_ChannelEnabled can be either 0 or 1. 0: channel acquisition is disabled; 1: channel acquisition is enabled
    unsigned int m_ChannelEnabled;
    // m_ChannelRecordingEnabled can be either 0 or 1. 0: channel recording is disabled; 1: channel recording is enabled
    unsigned int m_ChannelRecordingEnabled;
    // number of spikes for this channel
    unsigned long long m_NumberOfEvents;
};

#define PL2_BLOCK_TYPE_SPIKE (1)
#define PL2_BLOCK_TYPE_ANALOG (2)
#define PL2_BLOCK_TYPE_DIGITAL_EVENT (3)
#define PL2_BLOCK_TYPE_STARTSTOP_EVENT (4)

#define PL2_STOP (0)
#define PL2_START (1)
#define PL2_PAUSE (2)
#define PL2_RESUME (3)


struct PL2BlockInfo {
    PL2BlockInfo() { memset( this, 0, sizeof( *this ) ); }

    // block type. one of values described above
    int m_BlockType;
    // 1-based source number
    unsigned int m_Source;
    // 1-based channel number within source
    unsigned int m_Channel;
    // number of items in data block (spikes for spike block, analog values for analog bloc, events for event block)
    int m_NumberOfItems;
};


#pragma pack( pop )