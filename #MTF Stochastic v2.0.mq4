//+------------------------------------------------------------------+
//|                                               MTF Stochastic.mq4 |
//|													2007, Christof Risch (iya)	|
//| Stochastic indicator from any timeframe.									|
//+------------------------------------------------------------------+
#property link "http://www.forexfactory.com/showthread.php?t=30109"
#property indicator_separate_window
#property indicator_buffers	4
#property indicator_color1		LightSeaGreen	// %K line
#property indicator_color2		Red				// %D line
#property indicator_color3		LightGreen		// %K line of the current candle
#property indicator_color4		LightSalmon		// %D line of the current candle
#property indicator_level1		80
#property indicator_level2		20
#property indicator_maximum	100
#property indicator_minimum	0

//---- input parameters
extern int	TimeFrame	= 0,		// {1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}
				KPeriod		= 5,
				DPeriod		= 3,
				Slowing		= 3,
				MAMethod		= 0,		// {0=SMA, 1=EMA, 2=SMMA, 3=LWMA}
				PriceField	= 0;		// {0=Hi/Low, 1=Close/Close}
extern bool	ShowClock	= false;	// display time to candle close countdown
extern color ClockColor	= Red;

//---- indicator buffers
double		BufferK[],
				BufferD[],
				BufferK_Curr[],
				BufferD_Curr[];

//----
string	IndicatorName = "",
			TimeLabelName = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- name for DataWindow and indicator subwindow label
	switch(TimeFrame)
	{
		case 1:		IndicatorName="Period M1";	break;
		case 5:		IndicatorName="Period M5"; break;
		case 15:		IndicatorName="Period M15"; break;
		case 30:		IndicatorName="Period M30"; break;
		case 60:		IndicatorName="Period H1"; break;
		case 240:	IndicatorName="Period H4"; break;
		case 1440:	IndicatorName="Period D1"; break;
		case 10080:	IndicatorName="Period W1"; break;
		case 43200:	IndicatorName="Period MN1"; break;
		default:	  {TimeFrame = Period(); init(); return(0);}
	}

	IndicatorName = IndicatorName+" Stoch("+KPeriod+","+DPeriod+","+Slowing+")";
	IndicatorShortName(IndicatorName);  
	IndicatorDigits(1);

//---- indicator lines
	SetIndexBuffer(0,BufferK);
	SetIndexBuffer(1,BufferD);
	SetIndexBuffer(2,BufferK_Curr);
	SetIndexBuffer(3,BufferD_Curr);
 	SetIndexStyle(0,DRAW_LINE);
	SetIndexStyle(1,DRAW_LINE);
	SetIndexStyle(2,DRAW_LINE);
	SetIndexStyle(3,DRAW_LINE);
 	SetIndexLabel(0,IndicatorName+" %K line");
	SetIndexLabel(1,IndicatorName+" %D Signal");
 	SetIndexLabel(2,IndicatorName+" %K current candle");
 	SetIndexLabel(3,IndicatorName+" %D current candle");
}

//+------------------------------------------------------------------+
int deinit()
{
	if(TimeLabelName!="")
	if(ObjectFind	(TimeLabelName) != -1)
		ObjectDelete(TimeLabelName);
}

//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int start()
{
//----
//	counted bars from indicator time frame
	static int countedBars1 = 0;

//----
//	counted bars from display time frame
	if(Bars-1-IndicatorCounted() > 1 && countedBars1!=0)
		countedBars1 = 0;

	int bars1 = iBars(NULL,TimeFrame),
		 start1 = bars1-1-countedBars1,
		 limit1 = iBarShift(NULL,TimeFrame,Time[Bars-1]);

	if(countedBars1 != bars1-1)
	{
		countedBars1  = bars1-1;
		ArrayInitialize(BufferK_Curr,EMPTY_VALUE);
		ArrayInitialize(BufferD_Curr,EMPTY_VALUE);
		if(TimeLabelName!="")
		if(ObjectFind	(TimeLabelName) != -1)
			ObjectDelete(TimeLabelName);
	}

	if(start1 > limit1 && limit1 != -1)
		start1 = limit1;

//----
//	3... 2... 1... GO!
	for(int i = start1; i >= 0; i--)
	{
		int shift1 = i;

		if(TimeFrame < Period())
			shift1 = iBarShift(NULL,TimeFrame,Time[i]);

		int time1  = iTime    (NULL,TimeFrame,shift1),
			 shift2 = iBarShift(NULL,0,time1);

		double stochK = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1),
				 stochD = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,shift1);

	//----
	//	old (closed) candles
		if(shift1>=1)
		{
			BufferK[shift2] = stochK;
			BufferD[shift2] = stochD;
		}

	//----
	//	current candle
		if((TimeFrame >=Period() && shift1<=1)
		|| (TimeFrame < Period() &&(shift1==0||shift2==1)))
		{
			BufferK_Curr[shift2] = stochK;
			BufferD_Curr[shift2] = stochD;
		}

	//----
	//	linear interpolatior for the number of intermediate bars, between two higher timeframe candles.
		int n = 1;
		if(TimeFrame > Period())
		{
			int shift2prev = iBarShift(NULL,0,iTime(NULL,TimeFrame,shift1+1));

			if(shift2prev!=-1 && shift2prev!=shift2)
				n = shift2prev - shift2;
		}

	//----
	//	apply interpolation
		double factor = 1.0 / n;
		if(shift1>=1)
		if(BufferK[shift2+n]!=EMPTY_VALUE && BufferK[shift2]!=EMPTY_VALUE)
		{
			for(int k = 1; k < n; k++)
			{
				BufferK[shift2+k] = k*factor*BufferK[shift2+n] + (1.0-k*factor)*BufferK[shift2];
				BufferD[shift2+k] = k*factor*BufferD[shift2+n] + (1.0-k*factor)*BufferD[shift2];
			}
		}

	//----
	//	current candle
		if(shift1==0)
		if(BufferK_Curr[shift2+n]!=EMPTY_VALUE && BufferK_Curr[shift2]!=EMPTY_VALUE)
		{
			for(k = 1; k < n; k++)
			{
				BufferK_Curr[shift2+k] = k*factor*BufferK_Curr[shift2+n] + (1.0-k*factor)*BufferK_Curr[shift2];
				BufferD_Curr[shift2+k] = k*factor*BufferD_Curr[shift2+n] + (1.0-k*factor)*BufferD_Curr[shift2];
			}

		//----
		//	candle time countdown
			if(ShowClock)
			{
				int m,s;

				s = iTime(NULL,TimeFrame,0)+TimeFrame*60 - TimeCurrent();
				m = (s-s%60)/60;
				s = s%60;

				string text;
				if(s<10)	text = "0"+s;
				else		text = ""+s;
				text = "            "+m+":"+text;

				int window = WindowFind(IndicatorName);
				if(window==-1)
					window = WindowOnDropped() ;

				TimeLabelName = IndicatorName+" Time Counter "+window;

				if(ObjectFind	(TimeLabelName) == -1)
					ObjectCreate(TimeLabelName, OBJ_TEXT, window, Time[shift2], BufferK_Curr[shift2]+3);
				else
					ObjectMove	(TimeLabelName, 0, Time[shift2], BufferK_Curr[shift2]+3);

				ObjectSetText	(TimeLabelName, text, 8, "Verdana", ClockColor);
			}
		}
	}

	return(0);
}


