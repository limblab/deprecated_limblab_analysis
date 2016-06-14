/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// plxVTdecoder.h : main header file for the PLXVTDECODER application
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_PLXVTDECODER_H__21F98E94_A450_4975_9659_8357357F39AD__INCLUDED_)
#define AFX_PLXVTDECODER_H__21F98E94_A450_4975_9659_8357357F39AD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CPlxVTdecoderApp:
// See plxVTdecoder.cpp for the implementation of this class
//

class CPlxVTdecoderApp : public CWinApp
{
public:
	CPlxVTdecoderApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPlxVTdecoderApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CPlxVTdecoderApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PLXVTDECODER_H__21F98E94_A450_4975_9659_8357357F39AD__INCLUDED_)
