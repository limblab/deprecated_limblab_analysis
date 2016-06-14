/////////////////////////////////////////////////////////////////////////////
// ddtReaderDlg.cpp : implementation file containing the functionality to
// read and display DDT files. 
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "ddtReader.h"
#include "ddtReaderDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


// A channel gain of 255 or 0 indicates that the channel was not recorded
#define DISABLED_CHANNEL (255)
#define DISABLED_CHANNEL_B (0)

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About
/////////////////////////////////////////////////////////////////////////////

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CDdtReaderDlg dialog
/////////////////////////////////////////////////////////////////////////////

CDdtReaderDlg::CDdtReaderDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CDdtReaderDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CDdtReaderDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	m_fileName = "Test1.ddt";
	m_filePath      = "..\\SampleData\\";
	m_bOpen = false ;
}

void CDdtReaderDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CDdtReaderDlg)
	DDX_Control(pDX, IDC_BUTTON_HEADER, m_buttonHeader);
	DDX_Control(pDX, IDC_SCROLLBAR_CHANNEL, m_scrollbarChannel);
	DDX_Control(pDX, IDC_LIST_FILEHEADER, m_listFileHeader);
	DDX_Control(pDX, IDC_LIST_DATA, m_listData);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CDdtReaderDlg, CDialog)
	//{{AFX_MSG_MAP(CDdtReaderDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_WM_CLOSE()
	ON_BN_CLICKED(IDC_BROWSE, OnBnClickedBrowse)
	ON_BN_CLICKED(IDC_READ_FILE, OnBnClickedReadFile)
	ON_WM_HSCROLL()
	//}}AFX_MSG_MAP

END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// Initializes the main dialog

BOOL CDdtReaderDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.
	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// Update the file name edit control
	m_fileName = m_filePath + m_fileName;
	SetDlgItemText(IDC_FILENAME,m_fileName);

	// Use a courier font for the button for the data header
	m_fontHeader.CreateFont(14, 0, 0, 0, 800, 0, 0, 0, 0, 0, 0, 0, 0, "Courier New") ;
	m_buttonHeader.SetFont(&m_fontHeader) ;

	// Use a courier font for the list box for the data items
	m_fontData.CreateFont(14, 0, 0, 0, 400, 0, 0, 0, 0, 0, 0, 0, 0, "Courier New") ;
	m_listData.SetFont(&m_fontData) ;

	return TRUE;  // return TRUE  unless you set the focus to a control
}

/////////////////////////////////////////////////////////////////////////////

void CDdtReaderDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CDdtReaderDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CDdtReaderDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


/////////////////////////////////////////////////////////////////////////////
// FileOpen dialog to allow the user to browse for a DDT file to open
/////////////////////////////////////////////////////////////////////////////

void CDdtReaderDlg::OnBnClickedBrowse()
{
	CString filter;
	CString temp;

	filter = "Plexon Files (*.ddt)|*.ddt|";

	CFileDialog dlg(TRUE, NULL, NULL, OFN_HIDEREADONLY, filter);
	if(dlg.DoModal() == IDOK){
		m_fileName = dlg.GetPathName();
	}	
	
	SetDlgItemText(IDC_FILENAME,m_fileName);
}

/////////////////////////////////////////////////////////////////////////////
// Extract the data samples for each channel and display in a list box
/////////////////////////////////////////////////////////////////////////////

void CDdtReaderDlg :: DumpData(bool bReport)
{
  CWaitCursor wc;
  
	m_ddtFile.Seek(m_fileHeader.DataOffset, 0) ;

	CString str ;
	CString s ;
	CString s1 ;

	// Save index to the first visible item in the list box so if we
	// we won't scroll vertically if we only intend on scrolling 
	// channels horizontally
	int topIndex = m_listData.GetTopIndex() ;

	// Disable the list box from redrawing until all of the channel data has been loaded
	m_listData.SetRedraw(false) ;

	// Clear all of the old channel data from the list box
	m_listData.ResetContent () ;

	// Set the text for the button for a header
	str.Format("     Time(s) ") ;

  int iNumEnabledChans = 0;
  for (int iChannel = 0; iChannel < 64; iChannel++)
	{
    if (m_fileHeader.ChannelGain[iChannel] != DISABLED_CHANNEL && m_fileHeader.ChannelGain[iChannel] != DISABLED_CHANNEL_B) 
	  {
	    if (iNumEnabledChans++ >= m_startChannel)
	    {
		    s1.Format("CH %d", iChannel+1); // 1-based, as shown in Recorder
			  s.Format("%7s", (const char *) s1) ;
			  str += s ;
			}
		}
	}
	m_buttonHeader.SetWindowText(str) ;

	// Read the man body of the DDT file, extracting and displaying samples
	short* buf = new short[m_fileHeader.NChannels]; // one sample time's worth of samples 

	for (int iSample = 0 ; ; iSample++)
	{
		// Read one sample time's worth of samples; quit reading if EOF file is detected
		if (m_ddtFile.Read(buf, m_fileHeader.NChannels * sizeof(short)) != m_fileHeader.NChannels * sizeof(short))
		{
			break;
		}

		// Compute time in seconds based on sampling frequency
		double seconds = (double) iSample / (double) m_fileHeader.Freq ;
		str.Format("%12.6lf ", seconds) ;

		// Dump the samples 
		for (int iChannel = 0 ; iChannel < m_fileHeader.NChannels ; iChannel++)
		{
			if (iChannel >= m_startChannel)
			{
        if (m_fileHeader.Version >= 102)
			  {
			    // we have gain information and can display values as true voltages
          float fPreampGain = (float)m_fileHeader.Gain; 
	  	    int iTrueChannel = m_iChannelMap[iChannel];
    	    float fTotalGain = fPreampGain*m_fileHeader.ChannelGain[iTrueChannel];
    	    if (fPreampGain <= 100.0)
    	    {
    	      // display sample value in millivolts
            float fMillivolts = ((float)buf[iChannel]*m_fScaleRawSampleValueToVoltage) / fTotalGain;
            s.Format(" %6.1f", fMillivolts);
          }
          else
          {
            // display sample value in microvolts
            float fMicrovolts = 1000.0f*((float)buf[iChannel]*m_fScaleRawSampleValueToVoltage) / fTotalGain;
            s.Format(" %6.1f", fMicrovolts);
          }
			  }
	      else
	      {
	        // no per-channel gains, so just display raw integer sample values
				  s.Format(" %6d", buf[iChannel]) ;
				}
				str += s ;
			}
		}
		m_listData.AddString(str) ;

		// Quit reading samples when the maximum number of sample have been read.  
		// Note that a real appication would typically read all the samples.
		if ((iSample+1) >= MAX_SAMPLES)
		{
			if (bReport)
			{
				CString msg ;
				msg.Format("Only the first %d samples were extracted.", MAX_SAMPLES) ;
				m_listData.AddString(msg) ;
				AfxMessageBox (msg) ;
			}
			break ;
		}
	}

	delete [] buf ;
	// don't scroll vertically.
	m_listData.SetTopIndex(topIndex) ;
	// All the list box to redraw showing the new channel samples.
	m_listData.SetRedraw(true) ;

}


/////////////////////////////////////////////////////////////////////////////
// Open and read a DDT file displaying both the header and the data
/////////////////////////////////////////////////////////////////////////////

void CDdtReaderDlg::OnBnClickedReadFile() 
{
	CString str;
	CWaitCursor wait;

	m_listFileHeader.ResetContent() ;

	// Retrieve the file name (including path) of the DDT file to be read
	GetDlgItemText(IDC_FILENAME,m_fileName);

	if (m_bOpen)
	{
		m_ddtFile.Close() ;
		m_bOpen = false ;
	}
	// Open the DDT file using the built-in file exception logic to log any errors
	CFileException ex;
	if (!m_ddtFile.Open(m_fileName, CFile::shareDenyNone | CFile::modeRead, &ex)) 
	{
	  ex.ReportError() ;
		return ;
	}
	m_bOpen = true ;

	// Read the file header
	m_ddtFile.Read((void*)&m_fileHeader, sizeof(m_fileHeader));

	// Set the bottom horizontal scroll bar for scrolling channels
	m_scrollbarChannel.SetScrollRange(0, m_fileHeader.NChannels-1, false) ;

	// Dump a textual version of the file header to the upper listbox
	str.Format("Date created %d/%d/%d %d:%d:%d", 
		m_fileHeader.Month,
		m_fileHeader.Day,
		m_fileHeader.Year,
		m_fileHeader.Hour,
		m_fileHeader.Minute,
		m_fileHeader.Second) ;
	m_listFileHeader.AddString(str) ;

	str.Format("Version %d", m_fileHeader.Version) ;
	m_listFileHeader.AddString(str) ;
	str.Format("Comment %s", m_fileHeader.Comment) ;
	m_listFileHeader.AddString(str) ;

	// Note that fileHeader.NChannels is the number of channels actually
	// recorded in the file, not the total number of channels in the device.
	// The maximum number of recorded channels in a DDT file is 64.
	str.Format("Number of recorded channels %d", m_fileHeader.NChannels) ;
	m_listFileHeader.AddString(str) ;

	str.Format("Freq %f", m_fileHeader.Freq) ;
	m_listFileHeader.AddString(str) ;
	str.Format("Gain %d", m_fileHeader.Gain) ;
	m_listFileHeader.AddString(str) ;
	
	if (m_fileHeader.Version >= 101)
	{
		str.Format("Bits Per Sample %d", m_fileHeader.BitsPerSample) ;
	}
  else // Version 100
	{
		str.Format("Bits per sample 12 (assumed by default)\n");
		m_fileHeader.BitsPerSample = 12;
	}
  m_listFileHeader.AddString(str) ;
	
  // Calculate the scaling factor to convert raw sample values (12 or 16 bits) to
  // the equivalent voltage (in millivolts), not including any gain.
	if (m_fileHeader.Version >= 103)
	{
		str.Format("Max magnitude (A/D inputs) %d mV", m_fileHeader.MaxMagnitudeMV);
    m_listFileHeader.AddString(str) ;
    if (m_fileHeader.BitsPerSample == 12)
      m_fScaleRawSampleValueToVoltage = m_fileHeader.MaxMagnitudeMV/2048.0f;
    else // 16 bit samples
      m_fScaleRawSampleValueToVoltage = m_fileHeader.MaxMagnitudeMV/32768.0f;
  	if (m_fileHeader.Gain <= 100)
  	  m_listFileHeader.AddString("Sample values will be displayed in mV") ;
	  else
  	  m_listFileHeader.AddString("Sample values will be displayed in uV") ;
	}
		
	// If some channels were disabled, or their "to DDT" entry in Recorder's
	// parameter grid was "no", their samples will not be recorded in the file.
	// This is indicated by the corresponding ChannelGain entry being set to 255 or 0.  
	// We build an iChannelMap array here which contains a list of the channel
	// numbers for the channels actually recorded; this will be used later to 
	// access the gains for each channel. Version of the DDT format prior to 102
	// did not support disabled channels; those files will contain samples from all
	// the channels in the device, typically either 16 or 64.
	if (m_fileHeader.Version >= 102)
	{
    int iNumRecordedChans = 0;
		for (int iChannel = 0; iChannel < 64; iChannel++)
		{
		  if (m_fileHeader.ChannelGain[iChannel] == DISABLED_CHANNEL || m_fileHeader.ChannelGain[iChannel] == DISABLED_CHANNEL_B) 
		  {
		    str.Format("Channel %d not recorded", iChannel+1);
		  }
		  else
		  {
			  str.Format("Channel %d gain is %d", iChannel+1, m_fileHeader.ChannelGain[iChannel]);
			  m_iChannelMap[iNumRecordedChans++] = iChannel; // Add to channel map
			}
      m_listFileHeader.AddString(str) ;
		}
	}
	
	// Set the first displayed channel to 0.
	m_startChannel = 0 ;

	// Display the data for each channel in the lower list box.
	DumpData (true) ;
}


void CDdtReaderDlg::OnClose() 
{	
	CDialog::OnClose();
}

/////////////////////////////////////////////////////////////////////////////
// Horizontally scroll the channels in the data list box
/////////////////////////////////////////////////////////////////////////////

void CDdtReaderDlg::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
   int minpos;
   int maxpos;
   pScrollBar->GetScrollRange(&minpos, &maxpos); 
   maxpos = pScrollBar->GetScrollLimit();

   // Get the current position of scroll box.
   int curpos = pScrollBar->GetScrollPos();

   // Determine the new position of scroll box.
   switch (nSBCode)
   {
   case SB_LEFT:      // Scroll to far left.
      curpos = minpos;
      break;

   case SB_RIGHT:      // Scroll to far right.
      curpos = maxpos;
      break;

   case SB_ENDSCROLL:   // End scroll.
      break;

   case SB_LINELEFT:      // Scroll left.
      if (curpos > minpos)
         curpos--;
      break;

   case SB_LINERIGHT:   // Scroll right.
      if (curpos < maxpos)
         curpos++;
      break;

   case SB_PAGELEFT:    // Scroll one page left.
      if (curpos > minpos) curpos = max(minpos, curpos - 4);
      break;

   case SB_PAGERIGHT:      // Scroll one page right.
      if (curpos < maxpos) curpos = min(maxpos, curpos + 4);
      break;

   case SB_THUMBPOSITION: // Scroll to absolute position. nPos is the position
      curpos = nPos;      // of the scroll box at the end of the drag operation.
      break;

   case SB_THUMBTRACK:   // Drag scroll box to specified position. nPos is the
      curpos = nPos;     // position that the scroll box has been dragged to.
      break;
   }

   pScrollBar->SetScrollPos(curpos);

	m_startChannel = curpos ;

	DumpData(false) ;

	CDialog::OnHScroll(nSBCode, nPos, pScrollBar);
}

