//+------------------------------------------------------------------+
//|                                               MTF Stochastic.mq4 |
//|													2007, Christof Risch (iya)	|
//| Stochastic indicator from any timeframe.									|
//+------------------------------------------------------------------+
#property link "duanwujie"
#property indicator_separate_window
#property strict
#property indicator_buffers	3
#property indicator_color1		Green	
#property indicator_color2		Red 		

#property indicator_width1    3
#property indicator_width2    3

#property indicator_width3    1
#property indicator_color3    Black

#property indicator_maximum	100
#property indicator_minimum	-100

//---- input parameters
input int  KPeriod		= 14;
input int  DPeriod		= 3;
input int  Slowing		= 3;
input int  MAMethod		= 0;		// {0=SMA, 1=EMA, 2=SMMA, 3=LWMA}
input int  PriceField	= 0;		// {0=Hi/Low, 1=Close/Close}
input int  ExtAfterSeconds      = 300; //Th interval seconds per warning.
input int  ExtMaxMailAterTimes  = 5;   //Times of email warning
input bool EnableMailWaring     = true;//Enable email warning
input bool ShowSignal1 = false;   //Show Strong signal
input bool ShowSignal2 = false;   //Show Middle Strong signal
input bool ShowSignal3 = true;   //Show Weak signal
input bool ShowSignal4 = false;   //Show Pullback signal

//---- indicator buffers
double      BufferUp[];
double      BufferDown[];
double      BufferHorizontal[];


//---- internal parameters
datetime LastWaringDate;
bool     Noticed = false;
int      CurrentNoticedTimes = 0;
uint     LastTickCount  = 0;

//----
string	IndicatorName = "";

			

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- name for DataWindow and indicator subwindow label
	IndicatorName = IndicatorName+"Stoch("+KPeriod+","+DPeriod+","+Slowing+")";
	IndicatorShortName(IndicatorName);  
	IndicatorDigits(1);

//---- indicator lines
	SetIndexBuffer(0,BufferUp);
	SetIndexBuffer(1,BufferDown);
	SetIndexStyle(0,DRAW_HISTOGRAM);
	SetIndexStyle(1,DRAW_HISTOGRAM);
 	SetIndexLabel(0,"Up Signal");
 	SetIndexLabel(1,"Down Signal");
 	
 	
   SetIndexBuffer(2,BufferHorizontal);
	SetIndexStyle(2,DRAW_LINE);
 	
 	LastWaringDate = TimeCurrent();
   Noticed  = false;
   LastTickCount = 0;
   
   SetIndexDrawBegin(1,200);
   SetIndexDrawBegin(0,200);   
   
   
 	return 0;
}

//+------------------------------------------------------------------+
int deinit()
{
	return 0;
}


int LastDirection  = 0;
int iCustomStochasticSignal(int shift)
{
   int mode = 0;
   double current_H4 = iCustom(NULL,PERIOD_CURRENT,"iCustomStochastic",PERIOD_H4,KPeriod,DPeriod,Slowing,mode,shift);
   double previous_H4 = iCustom(NULL,PERIOD_CURRENT,"iCustomStochastic",PERIOD_H4,KPeriod,DPeriod,Slowing,mode,shift+1);
   
   double current_H1  = iCustom(NULL,PERIOD_CURRENT,"iCustomStochastic",PERIOD_H1,KPeriod,DPeriod,Slowing,mode,shift);
   double previous_H1 = iCustom(NULL,PERIOD_CURRENT,"iCustomStochastic",PERIOD_H1,KPeriod,DPeriod,Slowing,mode,shift+1);
   
   double current_M30 = iCustom(NULL,PERIOD_CURRENT,"iCustomStochastic",PERIOD_M30,KPeriod,DPeriod,Slowing,mode,shift);
   double previous_M30 = iCustom(NULL,PERIOD_CURRENT,"iCustomStochastic",PERIOD_M30,KPeriod,DPeriod,Slowing,mode,shift+1);
   
   int sell_condition1 = (current_H4<=80) && (previous_H4>80);
   int sell_condition2 = current_H1>=50  && previous_H1<70;
   int sell_condition3 = current_M30>=50  && previous_M30<70;
   
   
   int buy_condition1 = current_H4>=20 && previous_H4<20;
   int buy_condition2 = current_H1>20  && previous_H1<50;
   int buy_condition3 = current_M30>20  && previous_M30<50;
   
   if(sell_condition1 && sell_condition2 && sell_condition3){
      if(ShowSignal1)
         BufferDown[shift] = -100;
      LastDirection = -1;
      return -1;
   }else if(sell_condition1 && sell_condition2){
      if(ShowSignal2)
         BufferDown[shift] = -80;
      LastDirection = -1;
      return -1;
   }else if(sell_condition1){
      if(ShowSignal3)
         BufferDown[shift] = -60;
      LastDirection = -1;
      return -1;
   }
   
   if(buy_condition1 && buy_condition2 && buy_condition3){
      if(ShowSignal1)
         BufferUp[shift] = 100;
      LastDirection = 1;
      return 1;
   }else if(buy_condition1 && buy_condition2){
      if(ShowSignal2)
         BufferUp[shift] = 80;
      LastDirection = 1;
      return 1;
   }else if(buy_condition1){
      if(ShowSignal3)
         BufferUp[shift] = 60;
      LastDirection = 1;
      return 1;
   }
   
   if(LastDirection == 1 && previous_H1<20 &&  current_H1>=20 && current_H4 > previous_H4)
   {
      if(ShowSignal4)
         BufferUp[shift] = 20;
      return 1;
   }
   
   if(LastDirection == -1 && previous_H1>70 && current_H1<= 70 && current_H4 < previous_H4)
   {
      if(ShowSignal4)
         BufferDown[shift] = -20;
      return -1;
   }
   return 0;
}


int iCustomMacdSignal(int shift)
{

   return 0;
}



int iCustomCCISignal(int shift)
{
   return 0;
}








//+------------------------------------------------------------------+
//| start                                                            |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars=IndicatorCounted();
   limit=MathMin(Bars-200,Bars-counted_bars+1);
   for(int i=0;i<limit;i++)
   {
      BufferHorizontal[i] = 0;
     iCustomStochasticSignal(i);
   }
	return(0);
}






string PTT()
{
   int period =Period();
   if(period == PERIOD_H4)
      return "H4";
   if(period == PERIOD_H1)
      return "H1";
   if(period == PERIOD_M30)
      return "M20";
   if(period == PERIOD_M15)
      return "M15";
   if(period == PERIOD_M5)
      return "M4";
   if(period == PERIOD_D1)
      return "D1";
   if(period == PERIOD_W1)
      return "W1";
   return "Other";
}


int Event(uint seconds)
{
  uint currentTickCount = GetTickCount();
  if(currentTickCount - LastTickCount > seconds*1000)
  {
      LastTickCount = currentTickCount;
      return 1;
  }
  return false;
}

void iSendNotice(string msg)
{
    SendNotification(msg);
}

void iSendEmail(int direction,double percent)
{
   string msg,subject;
   if(direction < 0)
   {
      msg = Symbol()+"+Sell"; 
      subject = "SellSignal-"+Symbol()+"-"+PTT();
      SendMail(subject,msg);
      iSendNotice(msg);
   }
   if(direction > 0)
   {
      msg = Symbol()+"+Buy"; 
      subject = "BuySignal-"+Symbol()+"-"+PTT();
      SendMail(subject,msg);
      iSendNotice(msg);
   }
}


void iWaring(int shift,int direction,double percent)
{
   datetime current_time = iTime(NULL,PERIOD_CURRENT,shift);
   if(LastWaringDate < current_time)
   {
      Noticed = false;
      LastWaringDate = current_time;
      CurrentNoticedTimes  = 0;
   }
   if(!Noticed)
   {
      if(Event(ExtAfterSeconds))
      {
         CurrentNoticedTimes++;
         iSendEmail(direction,percent);
      }
      if(CurrentNoticedTimes == ExtMaxMailAterTimes)
      {
         Noticed = true;
      }
   }
}