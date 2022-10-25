;Skalieren des Image und den Canvas übergeben
Enumeration
	#IMAGE_LoadSave
EndEnumeration

Enumeration
	#GADGET_Canvas
	#GADGET_Load
	#GADGET_Save
	#GADGET_Spin1
	#GADGET_Spin2
	#mBeenden
	#mInfo
	#mSpeichern
	#mLaden
EndEnumeration

Global File$
Version$="1.0 Alpha"
Procedure ZeichneGitter()
	w=ImageWidth(#IMAGE_LoadSave)
	h=ImageHeight(#IMAGE_LoadSave)
	Spalten=GetGadgetState(#GADGET_Spin1)	
	Zeilen=GetGadgetState(#GADGET_Spin2)
	zx.f=0
	zy.f=0
	If Spalten=0 
		Spalten=1
	EndIf
	If Zeilen=0
		Zeilen=1
	EndIf
	If StartDrawing(CanvasOutput(#GADGET_Canvas))
	  Line(1, 1, w, 1, RGB(100,100,100))
	  Line(w, 1, 1, h, RGB(100,100,100))
	  Line(w, h, -w, 1, RGB(100,100,100))
	  Line(1, 1, 1, h, RGB(100,100,100))
		While zy<h
			zx=0
			While zx<w
				Line(zx, 1, 1, h, RGB(100,100,100))
				Line(1, zy, w, 1,  RGB(100,100,100))
				zx=zx+(w/Spalten)
			Wend
			zy=zy+(h/Zeilen)
		Wend
		StopDrawing()
	EndIf
EndProcedure

Procedure ScaleImage(id)
	If File$
		If Not LoadImage(id, File$)
			MessageRequester("CanvasGadget", "Cannot load image: " + File$)
			Goto ende
		EndIf
	EndIf  
	If File$
		w=ImageWidth(id)
		h=ImageHeight(id)
		ww=WindowWidth(0)
		wh=WindowHeight(0)
		
		;Fenster darf nicht zu klein werden
		If ww<400 Or wh<400 
			If ww<400
				ww=400
			EndIf
			If wh<400
				wh=400
			EndIf
			x=WindowX(0)
			y=WindowY(0)
			ResizeWindow(0, x, y, ww, wh)
		EndIf
		
		
		faktorH.f=wh/h
		faktorW.f=ww/w
		Anpassung.f=0.9
		;-An das Fenster anpassen
		wAnpassung=0
		If faktorW>faktorH 
			ResizeImage(id,(w+wAnpassung)*faktorH*Anpassung, (h+wAnpassung)*FaktorH*Anpassung,#PB_Image_Raw)
			;CanvasGadget(ADGET_Canvas, 5, 25, w*faktorH-70, (h+90)*FaktorH-90)
		Else
		  
			ResizeImage(id,(w+wAnpassung)*faktorW*Anpassung, (h+wAnpassung)*FaktorW*Anpassung,#PB_Image_Raw)
			;CanvasGadget(ADGET_Canvas, 5, 25, w*faktorW-70, (h+90)*FaktorW-90)
		EndIf
		

		CanvasGadget(ADGET_Canvas, 5, 25, w*faktorW-70, h*FaktorH-70)
		If StartDrawing(CanvasOutput(#GADGET_Canvas))
			DrawImage(ImageID(id), 0, 0)
			StopDrawing()
		EndIf   
		ende:
	EndIf
EndProcedure


File$ = ProgramParameter(1)


;Bildformate die möglich sind
UseJPEGImageDecoder()
UseJPEGImageEncoder()
UsePNGImageDecoder()
UsePNGImageEncoder()
UseJPEG2000ImageDecoder()
UseJPEG2000ImageEncoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()

If OpenWindow(0, 0, 0, 400, 400, "Bild - Splitter", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget  | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget )	
	;--Statusbar
	CreateStatusBar(0, WindowID(Window_0))
	AddStatusBarField(200)
	StatusBarText(0, 0, "Wirtten by M3i10", #PB_StatusBar_BorderLess)
	
	;--Button    
	Text_0 = TextGadget(#PB_Any, 1, 5, 90, 20, "X-Spalten")
	SpinGadget(#GADGET_Spin1, 50, 1, 90, 20, 1, 100, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
	
	Text_0 = TextGadget(#PB_Any, 150, 5, 90, 20, "y-Spalten")
	SpinGadget(#GADGET_Spin2, 200, 1, 90, 20, 1, 100, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
	
	SetGadgetState(#GADGET_Spin1,1)
	SetGadgetState(#GADGET_Spin2,1)
	CreateImage(#IMAGE_LoadSave,1,1)
	CanvasGadget(#GADGET_Canvas, 10, 30, 1, 1)  
	
	;--Menübar erstellen
	CreateMenu(0, WindowID(Window_0))
	MenuTitle("Datei")
	MenuItem(#mLaden, "Laden...")
	MenuItem(#mSpeichern, "Speichern als...")
	DisableMenuItem(0, #mSpeichern,1)
	
	MenuItem(11, "Einstellungen")
	DisableMenuItem(0, 11,1)
	MenuItem(#mBeenden, "Beenden")
	MenuTitle("Hilfe")
	MenuItem(#mInfo, "Info")
	
	EnableWindowDrop(0, #PB_Drop_Files, #PB_Drag_Copy)
	ScaleImage(#IMAGE_LoadSave)

	Repeat
		Event = WaitWindowEvent()
		
		
		If Event = #PB_Event_Gadget
			Select EventGadget()
				Case #GADGET_Spin1
					ScaleImage(#IMAGE_LoadSave)
					ZeichneGitter()
				Case #GADGET_Spin2
					ScaleImage(#IMAGE_LoadSave)
					ZeichneGitter()
					
			EndSelect   
		EndIf
		
		If Event= #PB_Event_Menu
			Select EventMenu()
					
				Case #mInfo
				  MessageRequester("Bildspitter", "Version "+ Version$ + Chr(13) +
				                                  "Dieses Programm dient dazu ein Bild gleichmäßig in kleine Bilder aufzuteilen. "+
					                                "Die Nummerierungen gehen von links nach rechts und dann nach unten. Die Dateien "+
					                                "werden Bildname_1.jpg Bildname_2.jpg ...benannt. "+
					                                "Dies ist eine Alpha Version und ist somit nicht vollständig getestet. " +
					                                "Bei Probleme oder Wünsche richten Sie sich an: m3i10@t-online.de" )
				Case #mBeenden
					End
				Case #mLaden
					;--Laden
					File$ = OpenFileRequester("Bild laden...", "", "JPEG Images|*.jpg|PNG Images|*.png|BMP Images|*.bmp|All Files|*.*", 0)    
					ScaleImage(#IMAGE_LoadSave)
					If File$
					  DisableMenuItem(0, #mSpeichern,0)
					EndIf
					
				Case #mSpeichern
					;--Speichern
					Spalten=GetGadgetState(#GADGET_Spin1)	
					Zeilen=GetGadgetState(#GADGET_Spin2)	
					
					;Original größe herstellen und speichern
					FreeImage(#IMAGE_LoadSave)
					LoadImage(#IMAGE_LoadSave, File$)
					
					StartDrawing(CanvasOutput(#GADGET_Canvas))
					DrawImage(ImageID(#IMAGE_LoadSave), 0, 0)
					StopDrawing()
					
					;original Bildgröße ermitteln
					w=ImageWidth(#IMAGE_LoadSave)
					h=ImageHeight(#IMAGE_LoadSave)
					HideGadget(#GADGET_Canvas,1)
					FileS$ = SaveFileRequester("Bild speichern...", File$, "PNG Images|*.png|All Files|*.*", 0)
					Nr=0
					zy.f=0
					zx.f=0
					If FileS$ And (FileSize(FileS$) = -1 Or MessageRequester("Speichern", "Die Datei überschreiben? " + FileS$, #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes)
						While zy<h
							zx=0
							While zx<w
								Nr=Nr+1
								GrabImage(#IMAGE_LoadSave, Nr, zx, zy, w/Spalten, h/Zeilen)
								SaveImage(Nr, FileS$ + "_" + Str(Nr), #PB_ImagePlugin_PNG,1 )
								zx=zx+(w/Spalten)
							Wend
							zy=zy+(h/Zeilen)
						Wend
					EndIf  
					ScaleImage(#IMAGE_LoadSave) ;unterprogramm aufrufen
					HideGadget(#GADGET_Canvas,0);canvas bild verstecken
			EndSelect
		EndIf
		
		
		
		If event=#PB_Event_SizeWindow ; Wenn die Windowgröße geändert wird
			ScaleImage(#IMAGE_LoadSave)
			ZeichneGitter()
		EndIf     		
		
		
		If Event=#PB_Event_WindowDrop
			If EventDropType()= #PB_Drop_Files
				File$=EventDropFiles()
				ScaleImage(#IMAGE_LoadSave)
			EndIf
			
		EndIf
		
	Until Event = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 174
; FirstLine = 82
; Folding = -
; Optimizer
; EnableXP
; DPIAware
; UseIcon = Grid Cutter2.ico
; Executable = GridCutter(Alpha)-Mac.app
; DisableDebugger