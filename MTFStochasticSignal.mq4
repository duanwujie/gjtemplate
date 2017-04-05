//+------------------------------------------------------------------+
//|                                               MTF Stochastic.mq4 |
//|													2007, Christof Risch (iya)	|
//| Stochastic indicator from any timeframe.									|
//+------------------------------------------------------------------+
#property link "duanwujie"
#property indicator_separate_window
//#property strict
#property indicator_buffers	5
#property indicator_color1		Red	// %K line
#property indicator_color2		Red		// %K line of the current candle

#property indicator_color3    Red
#property indicator_color4		Green	// %K line
#property indicator_color5		Red		// %K line of the current candle
#property indicator_width3    3
#property indicator_width4    3
#property indicator_width5    3


#property indicator_level1		0
#property indicator_maximum	100
#property indicator_minimum	-100

//---- input parameters
extern int	TimeFrame	= 240,		// {1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}
				KPeriod		= 14,
				DPeriod		= 3,
				Slowing		= 3,
				MAMethod		= 0,		// {0=SMA, 1=EMA, 2=SMMA, 3=LWMA}
				PriceField	= 0;		// {0=Hi/Low, 1=Close/Close}

//---- indicator buffers
double		BufferK[],
				BufferK_Curr[];
double      BufferSingal[];
double      BufferUp[];
double      BufferDown[];

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
	SetIndexBuffer(1,BufferK_Curr);
	SetIndexBuffer(2,BufferSingal);
 	SetIndexStyle(0,DRAW_NONE);
	SetIndexStyle(1,DRAW_NONE);
	SetIndexStyle(2,DRAW_NONE);
	SetIndexBuffer(3,BufferUp);
	SetIndexBuffer(4,BufferDown);
	SetIndexStyle(3,DRAW_HISTOGRAM);
	SetIndexStyle(4,DRAW_HISTOGRAM);
	
 	SetIndexLabel(3,"Up Signal");
 	SetIndexLabel(4,"Down Signal");
 	return 0;
}

//+------------------------------------------------------------------+
int deinit()
{
	if(TimeLabelName!="")
	if(ObjectFind	(TimeLabelName) != -1)
		ObjectDelete(TimeLabelName);
	return 0;
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
		if(TimeLabelName!="")
		if(ObjectFind	(TimeLabelName) != -1)
			ObjectDelete(TimeLabelName);
	}

	if(start1 > limit1 && limit1 != -1)
		start1 = limit1;

	for(int i = start1; i >= 0; i--)
	{
		int shift1 = i;

		if(TimeFrame < Period())
			shift1 = iBarShift(NULL,TimeFrame,Time[i]);

		int time1  = iTime(NULL,TimeFrame,shift1),
			shift2 = iBarShift(NULL,0,time1);

		double stochK = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift1);

	
	   //	old (closed) candles
		if(shift1>=1)
			BufferK[shift2] = stochK;
	   //	current candle
		if((TimeFrame >=Period() && shift1<=1) 
		|| (TimeFrame < Period() &&(shift1==0||shift2==1)))
			BufferK_Curr[shift2] = stochK;

	   
	   //	linear interpolatior for the number of intermediate bars, between two higher timeframe candles.
		int n = 1;
		if(TimeFrame > Period())
		{
			int shift2prev = iBarShift(NULL,0,iTime(NULL,TimeFrame,shift1+1));
			if(shift2prev!=-1 && shift2prev!=shift2)
				n = shift2prev - shift2;
		}

	   
	   //	apply interpolation
		double factor = 1.0 / n;
		if(shift1>=1)
   		if(BufferK[shift2+n]!=EMPTY_VALUE && BufferK[shift2]!=EMPTY_VALUE)
   		{
   			for(int k = 1; k < n; k++)
   				BufferK[shift2+k] = k*factor*BufferK[shift2+n] + (1.0-k*factor)*BufferK[shift2];
   		}
   	
		
	   //	current candle
		if(shift1==0){
   		if(BufferK_Curr[shift2+n]!=EMPTY_VALUE && BufferK_Curr[shift2]!=EMPTY_VALUE)
   		{
   			for(k = 1; k < n; k++)
   				BufferK_Curr[shift2+k] = k*factor*BufferK_Curr[shift2+n] + (1.0-k*factor)*BufferK_Curr[shift2];
   		}
   	}
	}
	
   int current_start = Bars-1-IndicatorCounted();
	for(int j = current_start;j>=0;j--)
	{
	   if(BufferK[j]!=EMPTY_VALUE)
	      BufferSingal[j]= BufferK[j];
	   else if(BufferK_Curr[j]!=EMPTY_VALUE)
	      BufferSingal[j]= BufferK_Curr[j];
	}
	
	for(int l = current_start-1;l>=0;l--)
	{
	   if(BufferSingal[l+1] > 80 && BufferSingal[l]<=80)
	      BufferDown[l] = -100;
	   if(BufferSingal[l+1] < 20 && BufferSingal[l]>=20)
	      BufferUp[l] = 100;
	}
   

	return(0);
}






