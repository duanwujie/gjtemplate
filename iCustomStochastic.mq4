//+------------------------------------------------------------------+
//|                                               MTF Stochastic.mq4 |
//|													2007, Christof Risch (iya)	|
//| Stochastic indicator from any timeframe.									|
//+------------------------------------------------------------------+
#property link "duanwujie"
#property copyright "dhacklove@163.com"
#property indicator_separate_window
#property strict
#property indicator_buffers	1
#property indicator_color1		Red	// %K line
#property indicator_level1		76.4
#property indicator_level2		23.6
#property indicator_maximum	100
#property indicator_minimum	0

//---- input parameters
input int	TimeFrame	= 240;
input int 	KPeriod		= 14;
input int   DPeriod		= 3;
input int	Slowing		= 3;


int   MAMethod		= 0;		// {0=SMA, 1=EMA, 2=SMMA, 3=LWMA}
int   PriceField	= 0;		// {0=Hi/Low, 1=Close/Close}

//---- indicator buffers
double		BufferK[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	SetIndexBuffer(0,BufferK);
 	SetIndexStyle(0,DRAW_LINE);
 	SetIndexDrawBegin(0,200);
 	return 0;
}

//+------------------------------------------------------------------+
int deinit()
{
	return 0;
}


void MTFSingalStochastic(int shift)
{
	int n = 1;
   int start_shift = iBarShift(NULL,0,iTime(NULL,TimeFrame,shift));
   int end_shift = iBarShift(NULL,0,iTime(NULL,TimeFrame,shift+1));
	double stochK = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift);
	double previousStock = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,shift+1);
	if(end_shift!=-1 && end_shift!=start_shift)
      n = end_shift - start_shift;
	double factor = 1.0 / n;
   for(int k = 1; k <=n; k++)
      BufferK[start_shift+k] = k*factor*previousStock + (1.0-k*factor)*stochK;
}

//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int start()
{
	static int countedBars1 = 0;
	if(Bars-1-IndicatorCounted() > 1 && countedBars1!=0)
		countedBars1 = 0;
	int bars1 = iBars(NULL,TimeFrame),
		 start1 = bars1-1-countedBars1,
		 limit1 = iBarShift(NULL,TimeFrame,Time[Bars-1]);
		 
	
	
	if(countedBars1 != bars1-1)
	{
		countedBars1  = bars1-1;
	}
	if(start1 > limit1 && limit1 != -1)
		start1 = limit1;
	for(int i = start1-24; i >= 0; i--)
	{
      MTFSingalStochastic(i);
   }
	return(0);
}