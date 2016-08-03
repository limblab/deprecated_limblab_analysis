/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// plxReaderDlg.h : header file
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_PLXREADERDLG_H__A5521970_EFBA_4B0D_9EB8_804D4E2E9A12__INCLUDED_)
#define AFX_PLXREADERDLG_H__A5521970_EFBA_4B0D_9EB8_804D4E2E9A12__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "stdafx.h"
#include <afxtempl.h>
#include <stdio.h>
#include <windows.h>
#include "..\plexon.h"

#define MAX_SPIKE_CHANNELS   (128)
#define MAX_EVENT_CHANNELS   (512)
#define MAX_SLOW_CHANNELS    (256)

/////////////////////////////////////////////////////////////////////////////
// Macros
/////////////////////////////////////////////////////////////////////////////

// Maximum number of samples per waveform
#define MAX_SAMPLES_PER_WAVEFORM  (256)

// Maximum number of data blocks read by this application
#define MAX_DATA_BLOCKS (5000)

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// CPlxReaderDlg dialog
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class CPlxReaderDlg : public CDialog
{
// Construction
public:
	CPlxReaderDlg(CWnd* pParent = NULL);	// standard constructor
	
// Dialog Data
	//{{AFX_DATA(CPlxReaderDlg)
	enum { IDD = IDD_PLXREADER_DIALOG };
	CButton	m_buttonHeader;
	CButton	m_buttonCheckSpike;
	CButton	m_buttonCheckSlow;
	CButton	m_buttonCheckEvent;
	CListBox	m_listHeader;
	CListBox	m_listData;
	CButton	m_buttonExtract;
	CProgressCtrl	m_progress;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPlxReaderDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// PLX file name and path
	CString		m_fileName;
	CString		m_filePath;

	bool m_bOpen ;
	// Open PLX file
	CFile m_file ;

	// PLX File header
	PL_FileHeader m_fileHeader ;

	// Spike channel headers
	PL_ChanHeader			m_spikeChannels[MAX_SPIKE_CHANNELS];

	// Event channel headers
	PL_EventHeader			m_eventChannels[MAX_EVENT_CHANNELS];

	// Slow channel headers
	PL_SlowChannelHeader	m_slowChannels[MAX_SLOW_CHANNELS];

	// Position in the PLX file where data blocks begin
	DWORD m_dataPosition ;

	// Courier font used by the button that displays the data block header
	CFont m_fontHeader ;
	// Courier font used by the list box that displays the data block items.
	CFont m_fontData ;

	// Sets the controls on the main dialog to indicate a PLX file is not loaded
	void EnableControlsToLoad () ;
	// Sets the controls on the main dialog to indicate that a PLX file is loaded
	void EnableControlsToExtract () ;

	// Reads the file header and channel header from the open PLX file.
	int ReadHeaders () ;

	// Helper function to dumping text to the header list box
	void Put(LPCTSTR lpszFormat, ...) ;
	// Dumps a textual verison of the header to the header list box.
	void DumpHeaders () ;


	// Generated message map functions
	//{{AFX_MSG(CPlxReaderDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnClose();
	afx_msg void OnBnClickedBrowse();
	afx_msg void OnBnClickedReadFile();
	afx_msg void OnExtract();
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PLXREADERDLG_H__A5521970_EFBA_4B0D_9EB8_804D4E2E9A12__INCLUDED_)
