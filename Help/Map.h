
{$IFDEF CIPP}

#define HELP_MAIN     1
//#define HELP_DELAY    2
//#define HELP_METROL   3
//#define HELP_METROL_INCLIN   4

//#define BTN_DELAY    20

{$ELSE}
 const

		HELP_MAIN  = 1;
		HELP_DELAY = 2;
		HELP_METROL =  3;
		HELP_METROL_INCLIN = 4;

{$ENDIF}
