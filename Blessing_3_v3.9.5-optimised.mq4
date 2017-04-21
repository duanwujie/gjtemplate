//+---------------------------------------------------------------------+
//|                                                   Blessing 3 v3.9.5 |
//|                                                        May 29, 2011 |
//|                     Copyright ?2007-2011, J Talon LLC/FiFtHeLeMeNt |
//|     In no event will authors be liable for any damages whatsoever.  |
//|                         Use at your own risk.                       |
//|                                                                     |
//|  This EA is dedicated to Mike McKeough, a member of the Blessing    |
//|  Development Group, who passed away on Saturday, 31st July 2010.    |
//|  His contributions to the development of this EA have helped make   |
//|  it what it is today, and we will miss his enthusiasm, dedication   |
//|  and desire to make this the best EA possible.                      |
//|  Rest In Peace.                                                     |
//+---------------------------------------------------------------------+

//http://www.forexbooknat.com/
//https://www.youtube.com/watch?v=NdU-8JqpMAI
#property copyright "Copyright ?2007-2011, J Talon LLC/FiFtHeLeMeNt"
#property link      "http://www.jtatoday.com"
#property link      "http://www.jtatoday.info/forum/index.php"

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

#define A 1 //All (Basket + Hedge)
#define B 2 //Basket
#define H 3 //Hedge
#define T 4 //Ticket
#define P 5 //Pending




#define TREND_UP 0			/*趋势向上*/
#define TREND_DOWN 1		/*趋势向下*/
#define TREND_RANGE 2		/*区间*/
#define TREND_OFF 3			/*没有趋势*/


#define TRADE_OFF 0			/*0 = Off */
#define TRADE_BASE 1		/* will base entry on indicator */
#define TRADE_REVERSE 2     /* will trade in reverse */


#define NO_BASKET_ORDERS 0
#define NO_HEDGE_ORDERS 0

#define NO_BUY_STOP_ORDERS 0
#define NO_BUY_LIMIT_ORDERS 0
#define NO_SELL_STOP_ORDERS 0
#define NO_SELL_LIMIT_ORDERS 0




//2000

//+-----------------------------------------------------------------+
//| Extern parameters sets                                                                 |
//+-----------------------------------------------------------------+

extern string   TradeComment        = "Blessing 3.9.5";
extern int      EANumber            = 1;        // Enter a unique number to identify this EA
extern bool     EmergencyCloseAll   = false;    // Setting this to true will close all open orders immediately

extern string   LabelAcc            = "Account Trading Settings:";
extern bool     ShutDown            = false;    // Setting this to true will stop the EA trading after any open trades have been closed
extern double   StopTradePercent    = 10;       // percent of account balance lost before trading stops
extern bool     NanoAccount         = false;    // set to true for nano "penny a pip" account (contract size is $10,000)
extern double   PortionPercentage           = 100;      // Percentage of account you want to trade on this pair
extern double   MaxDrawDownPercentage        = 50;       // Percent of portion for max drawdown level. 最大回撤率
extern double   MaxSpread           = 5;        // Maximum allowed spread while placing trades
extern bool     UseHolidayShutdown  = true;     // Will shutdown over holiday period
extern string   Holidays            = "18/12-01/01"; // List of holidays, each seperated by a comma, [day]/[mth]-[day]/[mth], dates inclusive
extern bool     PlaySounds          = false;    // will sound alarms
extern string   AlertSound          = "Alert.wav";  // Alarm sound to be played

extern string   LabelIES            = "Indicator / Entry Settings:";
extern bool     B3Traditional       = true;     // Stop/Limits for entry if true, Buys/Sells if false
extern int      ForceMarketCond     = 3;        // Market condition 0=uptrend 1=downtrend 2=range 3=off
extern bool     UseAnyEntry         = false;    // true = ANY entry can be used to open orders, false = ALL entries used to open orders
extern int      MAEntry             = 1;        // 0 = Off, 1 = will base entry on MA channel, 2 = will trade in reverse
extern int      CCIEntry            = 0;        // 0 = Off, 1 = will base entry on CCI indicator, 2 = will trade in reverse
extern int      BollingerEntry      = 0;        // 0 = Off, 1 = will base entry on BB, 2 = will trade in reverse
extern int      StochEntry          = 0;        // 0 = Off, 1 = will base entry on Stoch, 2 = will trade in reverse
extern int      MACDEntry           = 0;        // 0 = Off, 1 = will base entry on MACD, 2 = will trade in reverse
extern int      MADiffEntry         = 1;		// 0 = Off, 1 = will base entry on MA Diff, 2 = will trade in reverse.

extern string   LabelLS             = "Lot Size Settings:";
extern bool     UseMM               = true;    // Money Management
extern double   LAF                 = 0.5;      // Adjusts MM base lot for large accounts,Lot Adjustment Factor 
extern double   Lot                 = 0.01;     // Starting lots if Money Management is off
extern double   Multiplier          = 1.4;      // Multiplier on each level

extern string   LabelGS             = "Grid Settings:";
extern bool     AutoCal             = false;    // Auto calculation of TakeProfit and Grid size;(自动计算赢利和网格大小)
extern double   GAF                 = 1.0;      // Widens/Squishes Grid on increments/decrements of .1
extern int      EntryDelay          = 2400;     // Time Grid in seconds, to avoid opening of lots of levels in fast market
extern double   EntryOffset         = 5;        // In pips, used in conjunction with logic to offset first trade entry
extern bool     UseSmartGrid        = true;     // True = use RSI/MA calculation for next grid order

extern string   LabelTS             = "Trading Settings:";
extern int      MaxTrades           = 15;       // Maximum number of trades to place (stops placing orders when reaches MaxTrades)
extern int      BreakEvenTrade      = 12;       // Close All level, when reaches this level, doesn't wait for TP to be hit
extern double   BEPlusPips          = 2;        // Pips added to Break Even Point before BE closure
extern bool     UseCloseOldest      = false;    // True = will close the oldest open trade after CloseTradesLevel is reached
extern int      CloseTradesLevel    = 5;        // will start closing oldest open trade at this level
extern int      MaxCloseTrades      = 4;        // Maximum number of oldest trades to close
extern double   CloseTPPips         = 10;       // After Oldest Trades have closed, Forces Take Profit to BE +/- xx Pips
extern double   ForceTPPips         = 0;        // Force Take Profit to BE +/- xx Pips
extern double   MinTPPips           = 0;        // Ensure Take Profit is at least BE +/- xx Pips

extern string   LabelHS             = "Hedge Settings:";
extern string   HedgeSymbol         = "";       // Enter the Symbol of the same/correlated pair EXACTLY as used by your broker.
extern int      CorrPeriod          = 30;       // Number of days for checking Hedge Correlation
extern bool     UseHedge            = false;    // Turns DD hedge on/off
extern string   DDorLevel           = "DD";     // DD = start hedge at set DD; Level = Start at set level
extern double   HedgeStart          = 20;       // DD Percent or Level at which Hedge starts
extern double   hLotMult            = 0.8;      // Hedge Lots = Open Lots * hLotMult
extern double   hMaxLossPips        = 30;       // DD Hedge maximum pip loss - also hedge trailing stop
extern bool     hFixedSL            = false;    // true = fixed SL at hMaxLossPips
extern double   hTakeProfit         = 30;       // Hedge Take Profit
extern double   hReEntryPC          = 5;        // Increase to HedgeStart to stop early re-entry of the hedge
extern bool     StopTrailAtBE       = true;     // True = Trailing Stop will stop at BE; False = Hedge will continue into profit
extern bool     ReduceTrailStop     = true;     // False = Trailing Stop is Fixed; True = Trailing Stop will reduce after BE is reached

extern string   LabelES             = "Exit Settings:";
extern bool     MaximizeProfit      = false;    // Turns on TP move and Profit Trailing Stop Feature
extern double   ProfitSet           = 70;       // Locks in Profit at this percent of Total Profit Potential
extern double   MoveTP              = 30;       // Moves TP this amount in pips
extern int      TotalMoves          = 2;        // Number of times you want TP to move before stopping movement
extern bool     UseStopLoss         = false;    // Use Stop Loss and/or Trailing Stop Loss
extern double   SLPips              = 30;       // Pips for fixed StopLoss from BE, 0=off
extern double   TSLPips             = 10;       // Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
extern double   TSLPipsMin          = 3;        // Minimum trailing stop pips if using reducing TS
extern bool     UsePowerOutSL       = false;    // Transmits a SL in case of internet loss
extern double   POSLPips            = 600;      // Power Out Stop Loss in pips
extern bool     UseFIFO             = false;    // 

extern string   LabelEE             = "Early Exit Settings:";
extern bool     UseEarlyExit        = false;    // Reduces ProfitTarget by a percentage over time and number of levels open
extern double   EEStartHours        = 3;        // Number of Hours to wait before EE over time starts
extern bool     EEFirstTrade        = true;     // true = StartHours from FIRST trade: false = StartHours from LAST trade
extern double   EEHoursPC           = 0.5;      // Percentage reduction per hour (0 = OFF)
extern int      EEStartLevel        = 5;        // Number of Open Trades before EE over levels starts
extern double   EELevelPC           = 10;       // Percentage reduction at each level (0 = OFF)
extern bool     EEAllowLoss         = false;    // true = Will allow the basket to close at a loss : false = Minimum profit is Break Even

extern string   LabelAdv            = "Advanced Settings Change sparingly";

extern string   LabelGrid           = "Grid Size Settings:";
extern string   SetCountArray       = "4,4";    // Specifies number of open trades in each block (separated by a comma)
extern string   GridSetArray        = "25,50,100"; // Specifies number of pips away to issue limit order (separated by a comma)
extern string   TP_SetArray         = "50,100,200"; // Take profit for each block (separated by a comma)

extern string   LabelMA             = "MA Entry Settings:";
extern int      MAPeriod            = 100;      // Period of MA (H4 = 100, H1 = 400)
extern double   MADistance          = 10;       // Distance from MA to be treated as Ranging Market

extern string   LebelMADiff			= "MA Diff Entry Settings";
extern int      MAPeroid1           = 20;
extern int      MAPeroid2           = 20;
extern int      MAPeroid3           = 20;
extern int      MAPeroid4           = 21;
extern int      MAFilterUpL1        = 5;
extern int      MAFilterUpL2        = 5;
extern int      MAFilterUpL3        = 5;
extern int      MAFilterUpL4        = 5;
extern int      MAFiltrrUpLimitL1     = 10;
extern int      MAFiltrrUpLimitL2     = 10;
extern int      MAFiltrrUpLimitL3     = 10;
extern int      MAFiltrrUpLimitL4     = 10;

extern int      MAFilterDownL1      = -5;
extern int      MAFilterDownL2      = -5;
extern int      MAFilterDownL3      = -5;
extern int      MAFilterDownL4      = -5;

extern int      MAFiltrrDownLimitL1     = -10;
extern int      MAFiltrrDownLimitL2     = -10;
extern int      MAFiltrrDownLimitL3     = -10;
extern int      MAFiltrrDownLimitL4     = -10;

extern double   MAFactor            = 1000;
extern double   MAAngleFactor       = 0.017453;

extern int      MAPeroidPrivot      = 114;
extern double   MAUpRange           = 0.1;
extern double   MADownRange         = -0.1;


extern string   LabelCCI            = "CCI Entry Settings:";
extern int      CCIPeriod           = 14;       // Period for CCI calculation

extern string   LabelBBS            = "Bollinger Bands Entry Settings:";
extern int      BollPeriod          = 10;       // Period for Bollinger
extern double   BollDistance        = 10;       // Up/Down spread
extern double   BollDeviation       = 2.0;      // Standard deviation multiplier for channel

extern string   LabelSto            = "Stochastic Entry Settings:";
extern int      BuySellStochZone    = 20;       // Determines Overbought and Oversold Zones
extern int      KPeriod             = 10;       // Stochastic KPeriod
extern int      DPeriod             = 2;        // Stochastic DPeriod
extern int      Slowing             = 2;        // Stochastic Slowing

extern string   LabelMACD           = "MACD Entry Settings:";
extern string   LabelMACDTF         = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
extern int      MACD_TF             = 0;        // Time frame for MACD calculation
extern int      FastPeriod          = 12;       // MACD EMA Fast Period
extern int      SlowPeriod          = 26;       // MACD EMA Slow Period
extern int      SignalPeriod        = 9;        // MACD EMA Signal Period
extern int      MACDPrice           = 0;        // 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4

extern string   LabelSG             = "Smart Grid Settings:";
extern string   LabelSGTF           = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
extern int      RSI_TF              = 3;        // Timeframe for RSI calculation - should be less than chart TF.
extern int      RSI_Period          = 14;       // Period for RSI calculation
extern int      RSI_Price           = 0;        // 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4
extern int      RSI_MA_Period       = 10;       // Period for MA of RSI calculation
extern int      RSI_MA_Method       = 0;        // 0=Simple MA, 1=Exponential MA, 2=Smoothed MA, 3=Linear Weighted MA

extern string   LabelOS             = "Other Settings:";
extern bool     RecoupClosedLoss    = true;     // true = Recoup any Hedge/CloseOldest losses: false = Use original profit target.
extern int      Level               = 7;        // Largest Assumed Basket size.  Lower number = higher start lots
extern int      slip                = 99;       // Adjusts opening and closing orders by "slipping" this amount
extern bool     SaveStats           = false;    // true = will save equity statistics
extern int      StatsPeriod         = 3600;     // seconds betwen stats entries - off by default
extern bool     StatsInitialise     = true;     // true for backtest - false for foward/live to ACCUMULATE equity traces

extern string   LabelUE             = "Email Settings:";
extern bool     UseEmail            = false;
extern string   LabelEDD            = "At what DD% would you like Email warnings (Max: 49, Disable: 0)?";
extern double   EmailDD1            = 20;
extern double   EmailDD2            = 30;
extern double   EmailDD3            = 40;
extern string   LabelEH             = "Number of hours before DD timer resets";
extern double   EmailHours          = 24;       // Minimum number of hours between emails

extern string   LabelDisplay        = "Used to Adjust Overlay";
extern bool     displayOverlay      = true;     // Turns the display on and off
extern bool     displayLogo         = true;     // Turns off copyright and icon
extern bool     displayCCI          = true;     // Turns off the CCI display
extern bool     displayLines        = true;     // Show BE, TP and TS lines
extern int      displayXcord        = 100;      // Moves display left and right
extern int      displayYcord        = 22;       // Moves display up and down
extern int      displayCCIxCord     = 10;       // Moves CCI display left and right 
extern int      displayFontSize     = 9;        // Changes size of display characters
extern int      displaySpacing      = 14;       // Changes space between lines
extern double   displayRatio        = 1;        // Ratio to increase label width spacing
extern color    displayColor        = DeepSkyBlue; // default color of display characters
extern color    displayColorProfit  = Green;    // default color of profit display characters
extern color    displayColorLoss    = Red;      // default color of loss display characters
extern color    displayColorFGnd    = White;    // default color of ForeGround Text display characters

extern bool     Debug               = false;	// Use to control debug msg

extern string   LabelOpt            = "These values can only be used while optimizing";
extern bool     UseGridOpt          = false;    // Set to true if you want to be able to optimize the grid settings.
extern int      SetArray1           = 4;        // These values will replace the normal SetCountArray,
extern int      SetArray2           = 4;        // GridSetArray and TP_SetArray during optimization.
extern int      SetArray3           = 0;        // The default values are the same as the normal array defaults
extern int      SetArray4           = 0;
extern int      GridArray1          = 25;       // REMEMBER:
extern int      GridArray2          = 50;       // There must be one more value for GridArray and TPArray
extern int      GridArray3          = 100;      // than there is for SetArray
extern int      GridArray4          = 0;
extern int      GridArray5          = 0;
extern int      TPArray1            = 50;
extern int      TPArray2            = 100;
extern int      TPArray3            = 200;
extern int      TPArray4            = 0;
extern int      TPArray5            = 0;

//+-----------------------------------------------------------------+
//| Internal arguments set                                          |
//+-----------------------------------------------------------------+
int         ca;		
int         Magic;  //Magic Number
int			hMagic; //Hedge Magic Number  Hedge:对冲
int         CountOfBasketOrder;    //Total count of basket order (buy+sell)
int         CountOfPendingOrder;    //Total count of pending order (bl+sl+ss+bs)
int         CoundOfHedgeOrder;    //Total count of hedge order (hedge buy + hedge sell)
double      Pip,hPip;
int         POSLCount;
double      SLbL;
int         Moves;
double      MaxDD;
double      SLb;
int         AccountType;
double      StopTradeBalance;/*该净值是，单子亏损导致净值达到这个时，停止交易*/
double      InitialAB;/*EA开始运行时账户的净值*/
bool        Testing,Visual;
bool        AllowTrading;
bool        EmergencyWarning;
double      MaxDDPer;
int         Error,y;
int         Set1Level;
int         Set2Level;
int         Set3Level;
int         Set4Level;
int         EmailCount;
string      StringTimeFrame;
datetime    EmailSent;
int         GridArray[,2];
double      Lots[];
double		MinLotSize;//交易商允许的最小交易手数
double		LotStep;   //交易手数的最小增量
double		LotDecimal;//The lot decimal
int         LotMult;   //The Multiplier of the lots
int         MinMult;
bool        PendLot;
string      CS,UAE;
int         HolShutDown;
datetime    HolArray[,4];
datetime    HolFirst,HolLast,NextStats;
datetime    OpenTimeBasketFirst; //Opentime of the first basket order
double      RSI[];
int         Digit[,2],TF[10]={0,1,5,15,30,60,240,1440,10080,43200};

double      Email[3];
double      EETime;
double      PbC;
double      PhC;
double      hDDStart;
double 		ProfitBasketMax;//The max profit of basket order
double      ProfitBasketMin;//The min profit of basket order
double		ProfitHedgeMax;//The max profit of hedge order
double      ProfitHedgeMin;//The min profit of hedge order
double		LastClosedPL,ClosedPips,SLh,hLvlStart,StatLowEquity,StatHighEquity;
int         hActive,EECount;
int         TicketBasketFirst;	//Ticket of the first basket order
int         CbC,CaL,FileHandle;
bool        TradesOpen;
bool        FileClosed,HedgeTypeDD,hThisChart,hPosCorr,dLabels,FirstRun;
string      FileName,ID,StatFile;
double      TPb;
double      StopLevel;	//The broker stoplevel allowd 
double      TargetPips;
double      LotsBaksetFirst;//Lots of the first basket order
double      bTS;






// add by wujie.duan
/**
 * @brief EA初始化函数 
 * 
 *
 * @return 
 */
int init()
{	
	CS="Waiting for next tick .";          // To display comments while testing, simply use CS = .... and
	Comment(CS);                           // it will be displayed by the line at the end of the start() block.
	CS="";

	FirstRun=true;
	AllowTrading=true;
	if(EANumber<1)
        EANumber=1;
	if(Testing)
        EANumber=0;
	Magic=GenerateMagicNumber();
	hMagic=JenkinsHash(Magic);
	FileName="B3_"+Magic+".dat";
	if(Debug){	
		Print("Magic Number: "+DTS(Magic,0));
		Print("Hedge Number: "+DTS(hMagic,0));
		Print("FileName: "+FileName);
	}
	Pip=Point;
	if(Digits%2==1)Pip*=10;
	if(NanoAccount)
		AccountType=10;
	else 
		AccountType=1;

	MoveTP=ND(MoveTP*Pip,Digits);
	EntryOffset=ND(EntryOffset*Pip,Digits);
	MADistance=ND(MADistance*Pip,Digits);
	BollDistance=ND(BollDistance*Pip,Digits);
	POSLPips=ND(POSLPips*Pip,Digits);
	hMaxLossPips=ND(hMaxLossPips*Pip,Digits);
	hTakeProfit=ND(hTakeProfit*Pip,Digits);
	CloseTPPips=ND(CloseTPPips*Pip,Digits);
	ForceTPPips=ND(ForceTPPips*Pip,Digits);
	MinTPPips=ND(MinTPPips*Pip,Digits);
	BEPlusPips=ND(BEPlusPips*Pip,Digits);
	SLPips=ND(SLPips*Pip,Digits);
	TSLPips=ND(TSLPips*Pip,Digits);
	TSLPipsMin=ND(TSLPipsMin*Pip,Digits);
	slip*=Pip/Point;

	if(UseHedge)
	{	if(HedgeSymbol=="")HedgeSymbol=Symbol();
		if(HedgeSymbol==Symbol())hThisChart=true;
		else hThisChart=false;
		hPip=MarketInfo(HedgeSymbol,MODE_POINT);
		int hDigits=MarketInfo(HedgeSymbol,MODE_DIGITS);
		if(hDigits%2==1)hPip*=10;
		if(CheckCorr()>0.9||hThisChart)hPosCorr=true;
		else if(CheckCorr()<-0.9)hPosCorr=false;
		else
		{	AllowTrading=false;
			UseHedge=false;
			Print("The Hedge Symbol you have entered ("+HedgeSymbol+") is not closely correlated to "+Symbol());
		}
		if(StringSubstr(DDorLevel,0,1)=="D"||StringSubstr(DDorLevel,0,1)=="d")HedgeTypeDD=true;
		else if(StringSubstr(DDorLevel,0,1)=="L"||StringSubstr(DDorLevel,0,1)=="l")HedgeTypeDD=false;
		else UseHedge=false;
		if(HedgeTypeDD)
		{	HedgeStart/=100;
			hDDStart=HedgeStart;
		}
	}
	StopTradePercent/=100;
	ProfitSet/=100;
	EEHoursPC/=100;
	EELevelPC/=100;
	hReEntryPC/=100;
	PortionPercentage/=100;

	InitialAB=AccountBalance();
	StopTradeBalance=InitialAB*(1-StopTradePercent);
	Testing=IsTesting();
	Visual=IsVisualMode();
	if(Testing)
		ID="B3Test.";
	else 
		ID=DTS(Magic,0)+".";
	HideTestIndicators(true);

	MinLotSize=MarketInfo(Symbol(),MODE_MINLOT);
	if(MinLotSize>Lot)
	{	Print("Lot is less than your brokers minimum lot size");
		AllowTrading=false;
	}
	LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
	double MinLot=MathMin(MinLotSize,LotStep);
	LotMult=ND(MathMax(Lot,MinLotSize)/MinLot,0);
	MinMult=LotMult;
	Lot=MinLot;
	if(MinLot<0.01)LotDecimal=3;
	else if(MinLot<0.1)LotDecimal=2;
	else if(MinLot<1)LotDecimal=1;
	else LotDecimal=0;
	FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);
	if(FileHandle!=-1)
	{	TicketBasketFirst=FileReadInteger(FileHandle,LONG_VALUE);
		FileClose(FileHandle);
		Error=GetLastError();
		if(OrderSelect(TicketBasketFirst,SELECT_BY_TICKET))
		{	if(OrderCloseTime()==0)
			{	OpenTimeBasketFirst=OrderOpenTime();
				LotsBaksetFirst=OrderLots();
				LotMult=MathMax(1,LotsBaksetFirst/MinLot);
				PbC=FindClosedPL(B);
				PhC=FindClosedPL(H);
				TradesOpen=true;
				if(Debug)Print(FileName+" File Read: "+TicketBasketFirst+" Lots: "+DTS(LotsBaksetFirst,LotDecimal));
			}
			else 
				bool DeleteFile=true;
		}
		else DeleteFile=true;
		if(DeleteFile)
		{	FileDelete(FileName);
			TicketBasketFirst=0;
			OpenTimeBasketFirst=0;
			LotsBaksetFirst=0;
			Error=GetLastError();
			if(Error==ERR_NO_ERROR)
			{	if(Debug)Print(FileName+" File Deleted");
			}
			else Print("Error deleting file: "+FileName+" "+Error+" "+ErrorDescription(Error));
		}
	}
	GlobalVariableSet(ID+"LotMult",LotMult);
	if(Debug)
		Print("Lot Decimal: "+DTS(LotDecimal,0));
	EmergencyWarning=EmergencyCloseAll;

	if(IsOptimization())Debug=false;
	if(UseAnyEntry)UAE="||";
	else UAE="&&";
	
	//参数检查，设置错了参数将使用默认参数
	if(ForceMarketCond<0||ForceMarketCond>3)
		ForceMarketCond=3;
	if(MAEntry<0||MAEntry>2)
		MAEntry=TRADE_OFF;
	if(CCIEntry<0||CCIEntry>2)
		CCIEntry=TRADE_OFF;
	if(BollingerEntry<0||BollingerEntry>2)
		BollingerEntry=0;
	if(StochEntry<0||StochEntry>2)
		StochEntry=TRADE_OFF;
	if(MACDEntry<0||MACDEntry>2)
		MACDEntry=TRADE_OFF;
	if(MaxCloseTrades==0)
		MaxCloseTrades=MaxTrades;

	ArrayResize(Digit,6);
	for(y=0;y<ArrayRange(Digit,0);y++)
	{	if(y>0)Digit[y,0]=MathPow(10,y);
		Digit[y,1]=y;
		if(Debug)Print("Digit: "+y+" ["+Digit[y,0]+","+Digit[y,1]+"]");
	}
	LabelCreate();
	dLabels=false;

	//+-----------------------------------------------------------------+
	//| Set Lot Array                                                   |
	//+-----------------------------------------------------------------+
	ArrayResize(Lots,MaxTrades);
	if(Debug)
		Print("Lot Multiplier: "+LotMult);
	for(y=0;y<MaxTrades;y++)
	{
		if(y==0||Multiplier<1)
			Lots[y]=Lot;
		else 
			Lots[y]=ND(MathMax(Lots[y-1]*Multiplier,Lots[y-1]+LotStep),LotDecimal);
		if(Debug)
			Print("Lot Size for level "+DTS(y+1,0)+" : "+DTS(Lots[y]*MathMax(LotMult,1),LotDecimal));
	}
	/*
	 *  LotStep = 0.01
	 *  Multiplier = 1.4
	 *
	 *  Lots[0-14] ={
	 *		0.01,0.02,0.03,0.04,0.05,
	 *		0.07,0.09,0.12,0.16,0.22,
	 *      0.30,0.42,0.58,0.81,1.13
	 *	}
	 *
	 */
	
	if(Multiplier<1)
		Multiplier=1;

	
	/*   GridArray[15][2]
	 *
	 *   [25,50] [25,50] [25,50] [25,50] 
	 *   [50,100] [50,100] [50,100] [50,100]
	 *   [100,200] [100,200] [100,200] [100,200]
	 *   [100,200] [100,200] [100,200]
	 */
	
	
	//+-----------------------------------------------------------------+
	//| Set Grid and TP array                                           |
	//+-----------------------------------------------------------------+
	if(!AutoCal)
	{	int GridSet,GridTemp,GridTP,GridIndex,GridLevel,GridError;
		ArrayResize(GridArray,MaxTrades);
		if(IsOptimization()&&UseGridOpt)
		{//Returns true if Expert Advisor runs in the Strategy Tester optimization mode, otherwise returns false.
			if(SetArray1>0)
			{	SetCountArray=DTS(SetArray1,0);
				GridSetArray=DTS(GridArray1,0);
				TP_SetArray=DTS(TPArray1,0);
			}
			if(SetArray2>0||(SetArray1>0&&GridArray2>0))
			{	if(SetArray2>0)SetCountArray=SetCountArray+","+DTS(SetArray2,0);
				GridSetArray=GridSetArray+","+DTS(GridArray2,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray2,0);
			}
			if(SetArray3>0||(SetArray2>0&&GridArray3>0))
			{	if(SetArray3>0)SetCountArray=SetCountArray+","+DTS(SetArray3,0);
				GridSetArray=GridSetArray+","+DTS(GridArray3,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray3,0);
			}
			if(SetArray4>0||(SetArray3>0&&GridArray4>0))
			{	if(SetArray4>0)SetCountArray=SetCountArray+","+DTS(SetArray4,0);
				GridSetArray=GridSetArray+","+DTS(GridArray4,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray4,0);
			}
			if(SetArray4>0&&GridArray5>0)
			{	GridSetArray=GridSetArray+","+DTS(GridArray5,0);
				TP_SetArray=TP_SetArray+","+DTS(TPArray5,0);
			}
		}
		while(GridIndex<MaxTrades)
		{	if(StringFind(SetCountArray,",")==-1&&GridIndex==0)
			{	GridError=1;
				break;
			}
			else 
				GridSet=StrToInteger(StringSubstr(SetCountArray,0,StringFind(SetCountArray,",")));
			if(GridSet>0)
			{	
				SetCountArray=StringSubstr(SetCountArray,StringFind(SetCountArray,",")+1);
				GridTemp=StrToInteger(StringSubstr(GridSetArray,0,StringFind(GridSetArray,",")));
				GridSetArray=StringSubstr(GridSetArray,StringFind(GridSetArray,",")+1);
				GridTP=StrToInteger(StringSubstr(TP_SetArray,0,StringFind(TP_SetArray,",")));
				TP_SetArray=StringSubstr(TP_SetArray,StringFind(TP_SetArray,",")+1);
			}
			else 
				GridSet=MaxTrades;
			if(GridTemp==0||GridTP==0)
			{	GridError=2;
				break;
			}
			for(GridLevel=GridIndex;GridLevel<=MathMin(GridIndex+GridSet-1,MaxTrades-1);GridLevel++)
			{	
				GridArray[GridLevel,0]=GridTemp;
				GridArray[GridLevel,1]=GridTP;
				if(Debug)
					Print("GridArray "+(GridLevel+1)+"  : ["+GridArray[GridLevel,0]+","+GridArray[GridLevel,1]+"]");
			}
			GridIndex=GridLevel;
		}
		if(GridError>0||GridArray[0,0]==0||GridArray[0,1]==0)
		{	if(GridError==1)Print("Grid Array Error. Each value should be separated by a comma.");
			else Print("Grid Array Error. Check that there is one more 'Grid' and 'TP' number than there are 'Set' numbers, separated by commas.");
			AllowTrading=false;
		}
	}
	else
	{	while(GridIndex<4)
		{	
			GridSet=StrToInteger(StringSubstr(SetCountArray,0,StringFind(SetCountArray,",")));
			SetCountArray=StringSubstr(SetCountArray,StringFind(SetCountArray,DTS(GridSet,0))+2);
			if(GridIndex==0&&GridSet<1)
			{	GridError=1;
				break;
			}
			if(GridSet>0)
				GridLevel+=GridSet;
			else if(GridLevel<MaxTrades)
				GridLevel=MaxTrades;
			else 
				GridLevel=MaxTrades+1;
			if(GridIndex==0)
				Set1Level=GridLevel;
			else if(GridIndex==1&&GridLevel<=MaxTrades)
				Set2Level=GridLevel;
			else if(GridIndex==2&&GridLevel<=MaxTrades)
				Set3Level=GridLevel;
			else if(GridIndex==3&&GridLevel<=MaxTrades)
				Set4Level=GridLevel;
			GridIndex++;
		}
		if(GridError==1||Set1Level==0)
		{	Print("Error setting up the Grid Levels. Check that the SetCountArray has valid numbers, separated by a comma.");
			AllowTrading=false;
		}
	}

	//+-----------------------------------------------------------------+
	//| Set holidays array                                              |
	//+-----------------------------------------------------------------+
	if(UseHolidayShutdown)
	{	int HolTemp,NumHols,NumBS,HolCounter;
		string HolTempStr;
		if(StringFind(Holidays,",",0)==-1)NumHols=1;
		else
		{	NumHols=1;
			while(HolTemp!=-1)
			{	HolTemp=StringFind(Holidays,",",HolTemp+1);
				if(HolTemp!=-1)NumHols+=1;
			}
		}
		HolTemp=0;
		while(HolTemp!=-1)
		{	HolTemp=StringFind(Holidays,"/",HolTemp+1);
			if(HolTemp!=-1)NumBS+=1;
		}
		if(NumBS!=NumHols*2)
		{	Print("Holidays Error, number of back-slashes ("+NumBS+") should be equal to 2* number of Holidays ("+NumHols+
					", and separators should be a comma.");
			AllowTrading=false;
		}
		else
		{	HolTemp=0;
			ArrayResize(HolArray,NumHols);
			while(HolTemp!=-1)
			{	if(HolTemp==0)HolTempStr=StringTrimLeft(StringTrimRight(StringSubstr(Holidays,0,StringFind(Holidays,",",HolTemp))));
				else HolTempStr=StringTrimLeft(StringTrimRight(StringSubstr(Holidays,HolTemp+1,
					StringFind(Holidays,",",HolTemp+1)-StringFind(Holidays,",",HolTemp)-1)));
				HolTemp=StringFind(Holidays,",",HolTemp+1);
				HolArray[HolCounter,0]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),
					StringFind(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),"/")+1));
				HolArray[HolCounter,1]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),0,
					StringFind(StringSubstr(HolTempStr,0,StringFind(HolTempStr,"-",0)),"/")));
				HolArray[HolCounter,2]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),
					StringFind(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),"/")+1));
				HolArray[HolCounter,3]=StrToInteger(StringSubstr(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),0,
					StringFind(StringSubstr(HolTempStr,StringFind(HolTempStr,"-",0)+1),"/")));
				HolCounter+=1;
			}
		}
		for(HolTemp=0;HolTemp<HolCounter;HolTemp++)
		{	int Start1,Start2,Temp0,Temp1,Temp2,Temp3;
			for(int Item1=HolTemp+1;Item1<HolCounter;Item1++)
			{	Start1=HolArray[HolTemp,0]*100+HolArray[HolTemp,1];
				Start2=HolArray[Item1,0]*100+HolArray[Item1,1];
				if(Start1>Start2)
				{	Temp0=HolArray[Item1,0];
					Temp1=HolArray[Item1,1];
					Temp2=HolArray[Item1,2];
					Temp3=HolArray[Item1,3];
					HolArray[Item1,0]=HolArray[HolTemp,0];
					HolArray[Item1,1]=HolArray[HolTemp,1];
					HolArray[Item1,2]=HolArray[HolTemp,2];
					HolArray[Item1,3]=HolArray[HolTemp,3];
					HolArray[HolTemp,0]=Temp0;
					HolArray[HolTemp,1]=Temp1;
					HolArray[HolTemp,2]=Temp2;
					HolArray[HolTemp,3]=Temp3;
				}
			}
		}
		if(Debug)
		{	for(HolTemp=0;HolTemp<HolCounter;HolTemp++)
				Print("Holidays - From: ",HolArray[HolTemp,1],"/",HolArray[HolTemp,0]," - ",HolArray[HolTemp,3],"/",HolArray[HolTemp,2]);
		}
	}

	//+-----------------------------------------------------------------+
	//| Set email parameters                                            |
	//+-----------------------------------------------------------------+
	if(UseEmail)
	{	
		if(Period()==PERIOD_MN1)StringTimeFrame="MN1";
		else if(Period()==PERIOD_W1)StringTimeFrame="W1";
		else if(Period()==PERIOD_D1)StringTimeFrame="D1";
		else if(Period()==PERIOD_H4)StringTimeFrame="H4";
		else if(Period()==PERIOD_H1)StringTimeFrame="H1";
		else if(Period()==PERIOD_M30)StringTimeFrame="M30";
		else if(Period()==PERIOD_M15)StringTimeFrame="M15";
		else if(Period()==PERIOD_M5)StringTimeFrame="M5";
		else if(Period()==PERIOD_M1)StringTimeFrame="M1";
		Email[0]=MathMax(MathMin(EmailDD1,MaxDrawDownPercentage-1),0)/100;
		Email[1]=MathMax(MathMin(EmailDD2,MaxDrawDownPercentage-1),0)/100;
		Email[2]=MathMax(MathMin(EmailDD3,MaxDrawDownPercentage-1),0)/100;
		ArraySort(Email,WHOLE_ARRAY,0,MODE_ASCEND);
		for(int z=0;z<=2;z++)
		{	for(y=0;y<=2;y++)
			{	if(Email[y]==0)
				{	Email[y]=Email[y+1];
					Email[y+1]=0;
				}
			}
			if(Debug)Print("Email ["+(z+1)+"] : "+Email[z]);
		}
	}

	//+-----------------------------------------------------------------+
	//| Set SmartGrid parameters                                        |
	//+-----------------------------------------------------------------+
	if(UseSmartGrid)
	{	ArrayResize(RSI,RSI_Period+RSI_MA_Period);
		ArraySetAsSeries(RSI,true);
	}

	//+---------------------------------------------------------------+
	//| Initialize Statistics                                         |
	//+---------------------------------------------------------------+
	StatFile=Symbol()+"-"+Period()+"-"+EANumber+".csv";
	if(SaveStats)
	{	StatFile=Symbol()+"-"+Period()+"-"+EANumber+".csv";
		NextStats=TimeCurrent();
		Stats(StatsInitialise,false,AccountBalance()*PortionPercentage,0);
	}

	return(0);
}


// add by wujie.duan
/**
 * @brief EA退出时，清理函数
 * 
 *
 * @return 
 */
int deinit()
{	switch(UninitializeReason())
	{	case REASON_REMOVE:
		case REASON_CHARTCLOSE:
		case REASON_CHARTCHANGE:
			if(CountOfPendingOrder>0)while(CountOfPendingOrder>0)CountOfPendingOrder-=ExitTrades(P,displayColorLoss,"Blessing Removed");
			GlobalVariablesDeleteAll(ID);
		case REASON_RECOMPILE:
		case REASON_PARAMETERS:
		case REASON_ACCOUNT:
			if(!Testing)LabelDelete();
			Comment("");
	}
	return(0);
}


// add by wujie.duan
/**
 * @brief EA开始函数    
 * 
 *
 * @return 
 */
int start()
{	
	

	int     count_of_buy_limit         =0;     // Total count of buy limit
	int     count_of_sell_limit         =0;     // Total count of sell limit
	int     count_of_buy_stop         =0;     // Total count of buy stop
	int     count_of_sell_stop         =0;     // Total count of sell stop


	double  total_lots_of_basket_order          =0;     // Total lots of basket order(buy+sell)
	double  open_price_buy_limit        =0;     // Buy limit open price
	double  open_price_sell_limit        =0;     // Sell limit open price
	double  stoploss_of_busket_buy_order         =0;     // stop losses are set to zero if POSL off
	double  stoploss_of_busket_sell_order         =0;     // stop losses are set to zero if POSL off
	double  broker_costs_of_basket_order          =0;	 // Broker costs of basket order
	double  broker_costs_of_hedge_order          =0;     // Broker costs of hedge order
	double  BCa          =0;     // Broker costs (swap + commission) [basket + hedge]
	double  ProfitPot    =0;     // The Potential Profit of a basket of Trades
	
	double  PipValue,PipVal2;
	double  OrderLot;


	double  g2,tp2,Entry,RSI_MA;

	double  total_lots_of_hedge_order;				//Total lots of hedge order




	int     Ticket;
	int     IndEntry;		//The indicator entry count
	double  PaC,ProfitBasketPips,PbTarget;
	double  DrawDownPercentage;  //Percent of portion for drawdown level
	double  BEbasket;
	double  BEhedge;
	double  BEa;
	
	bool    BuyMe;
	bool    SellMe,Success;
	bool    SetPOSL;
	string  IndicatorUsed;
	
	/*The hedge's var */
	double  profit_of_hedge_order;					 // Total profit of hedge order  (hedge sell profit + hedge buy profit)
	int 	count_of_hedge_buy_order = 0;			 // Count of hedge buy order
	int     count_of_hedge_sell_order = 0;			 // Count of hedge sell order
	double  total_lots_of_hedge_buy_order;				 // Total lots of hedge buy order
	double  total_lots_of_hedge_sell_order;                 // Total lots of hedge sell order
	double  OThO;				 // Opentime of the first hedge order
	double  ThO;				 // Ticket of the first hedge order
	double	OPhO;                // Openprice of the first hedge order
	
	/*The basket's var */
	
	double  profit_of_basket_order;					 // Total profit of basket order (sell+buy-hedge)
	int     count_of_basket_buy_order = 0;             // Count of basket buy order
	int     count_of_basket_sell_order = 0;             // Count of basket sell order
	int     open_time_basket_last;                // Opentime of the last basket order
	double  open_price_basket_last;				 // Openprice of the last basket order
	double  OTbO;				 // Opentime of the first basket order
    double  TbO;                 // Ticket of the first basket order
	double  OPbO;                // Openprice of the first basket order
	double  total_lots_of_busket_buy_order = 0;             // Total lots of basket buy order
	double  total_lots_of_busket_sell_order = 0;             // Total lots of basket sell order
	
	//+-----------------------------------------------------------------+
	//| Count Open Orders, Lots and Totals                              |
	//+-----------------------------------------------------------------+
	PipValue=MarketInfo(Symbol(),MODE_TICKVALUE)/MarketInfo(Symbol(),MODE_TICKSIZE)*Pip;
	PipVal2=PipValue/Pip;
	StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
	for(y=0;y<OrdersTotal();y++)
	{	
        if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
            continue;
		int Type=OrderType();
		if(OrderMagicNumber()==hMagic) //Process the hedge order
		{
			/*profit_of_hedge_order:Profit of hedge */
			profit_of_hedge_order+=OrderProfit();/*OrderProfit:当前选中，订单的利润*/
			broker_costs_of_hedge_order+=OrderSwap()+OrderCommission();/*OrderSwap:返回掉期值，OrderCommission() - 获取订单佣金*/
			BEhedge+=OrderLots()*OrderOpenPrice(); /*开仓价格*当前订单的手数*/
			if(OrderOpenTime()<OThO||OThO==0)
			{	
				OThO=OrderOpenTime();
				ThO=OrderTicket();
				OPhO=OrderOpenPrice();
			}
			if(Type==OP_BUY)
			{	
				count_of_hedge_buy_order++;
				total_lots_of_hedge_buy_order+=OrderLots();
			}
			else if(Type==OP_SELL)
			{	count_of_hedge_sell_order++;
				total_lots_of_hedge_sell_order+=OrderLots();
			}
			continue;
		}
		if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol())
            continue;
		if(OrderTakeProfit()>0)
            ModifyOrder(OrderOpenPrice(),OrderStopLoss());
		if(Type<=OP_SELL)
		{	
			profit_of_basket_order+=OrderProfit();/*profit_of_basket_order:非对冲单总的利润*/
			broker_costs_of_basket_order+=OrderSwap()+OrderCommission(); /* 过夜费 + 佣金 */
			BEbasket+=OrderLots()*OrderOpenPrice();
			if(OrderOpenTime()>=open_time_basket_last)
			{	open_time_basket_last=OrderOpenTime();
				open_price_basket_last=OrderOpenPrice();
			}
			if(OrderOpenTime()<OpenTimeBasketFirst||TicketBasketFirst==0)
			{	OpenTimeBasketFirst=OrderOpenTime();
				TicketBasketFirst=OrderTicket();
				LotsBaksetFirst=OrderLots();
			}
			if(OrderOpenTime()<OTbO||OTbO==0)
			{	OTbO=OrderOpenTime();
				TbO=OrderTicket();
				OPbO=OrderOpenPrice();
			}
			if(UsePowerOutSL&&(POSLPips>0&&OrderStopLoss()==0)||(POSLPips==0&&OrderStopLoss()>0))
                    SetPOSL=true;
			if(Type==OP_BUY)
			{	count_of_basket_buy_order++;
				total_lots_of_busket_buy_order+=OrderLots();
				continue;
			}
			else
			{	count_of_basket_sell_order++;
				total_lots_of_busket_sell_order+=OrderLots();
				continue;
			}
		}
		else
		{	if(Type==OP_BUYLIMIT)
			{	count_of_buy_limit++;
				open_price_buy_limit=OrderOpenPrice();
				continue;
			}
			else if(Type==OP_SELLLIMIT)
			{	count_of_sell_limit++;
				open_price_sell_limit=OrderOpenPrice();
				continue;
			}
			else if(Type==OP_BUYSTOP)count_of_buy_stop++;
			else count_of_sell_stop++;
		}
	}
	CountOfBasketOrder=count_of_basket_buy_order+count_of_basket_sell_order;
	total_lots_of_basket_order=total_lots_of_busket_buy_order+total_lots_of_busket_sell_order;
	profit_of_basket_order=ND(profit_of_basket_order+broker_costs_of_basket_order,2);
	CoundOfHedgeOrder=count_of_hedge_buy_order+count_of_hedge_sell_order;
	total_lots_of_hedge_order=total_lots_of_hedge_buy_order+total_lots_of_hedge_sell_order;
	profit_of_hedge_order=ND(profit_of_hedge_order+broker_costs_of_hedge_order,2);
	CountOfPendingOrder=count_of_buy_limit+count_of_sell_limit+count_of_buy_stop+count_of_sell_stop; /* Total count of pending order */
	
	BCa=broker_costs_of_basket_order+broker_costs_of_hedge_order;/*总的交易商手续费*/

	//+-----------------------------------------------------------------+
	//| Calculate Min/Max Profit and Break Even Points                  |
	//+-----------------------------------------------------------------+
	if(total_lots_of_basket_order>0)/*Basket lots >0*/
	{	
		BEbasket=ND(BEbasket/total_lots_of_basket_order,Digits);/*计算平均开仓价格*/
		if(BCa<0)
			BEbasket-=ND(BCa/PipVal2/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);/* 交易商倒给钱的情况*/
		if(profit_of_basket_order>ProfitBasketMax||ProfitBasketMax==0)
			ProfitBasketMax=profit_of_basket_order;
		if(profit_of_basket_order<ProfitBasketMin||ProfitBasketMin==0)
			ProfitBasketMin=profit_of_basket_order;
		if(!TradesOpen)/*EA没有开单，只是统计*/
		{	
			FileHandle=FileOpen(FileName,FILE_BIN|FILE_WRITE);
			if(FileHandle>-1)
			{	FileWriteInteger(FileHandle,TicketBasketFirst);
				FileClose(FileHandle);
				TradesOpen=true;
				if(Debug)Print(FileName+" File Written: "+TicketBasketFirst);
			}
		}
	}
	else if(TradesOpen)
	{	
		TPb=0;
		ProfitBasketMax=0;
		ProfitBasketMin=0;
		OpenTimeBasketFirst=0;
		TicketBasketFirst=0;
		LotsBaksetFirst=0;
		PbC=0;
		PhC=0;
		PaC=0;
		ClosedPips=0;
		CbC=0;
		CaL=0;
		bTS=0;
		if(HedgeTypeDD)hDDStart=HedgeStart;
		else hLvlStart=HedgeStart;
		EmailCount=0;
		EmailSent=0;
		FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);
		if(FileHandle>-1)
		{	FileClose(FileHandle);
			Error=GetLastError();
			FileDelete(FileName);
			Error=GetLastError();
			if(Error==ERR_NO_ERROR)
			{	if(Debug)Print(FileName+" File Deleted");
				TradesOpen=false;
			}
			else Print("Error deleting file: "+FileName+" "+Error+" "+ErrorDescription(Error));
		}
		else 
			TradesOpen=false;
	}
	if(total_lots_of_hedge_order>0)
	{	
		BEhedge=ND(BEhedge/total_lots_of_hedge_order,Digits);/*计算平均开仓价格*/
		if(profit_of_hedge_order>ProfitHedgeMax||ProfitHedgeMax==0)
			ProfitHedgeMax=profit_of_hedge_order;
		if(profit_of_hedge_order<ProfitHedgeMin||ProfitHedgeMin==0)
			ProfitHedgeMin=profit_of_hedge_order;
	}
	else
	{	ProfitHedgeMax=0;
		ProfitHedgeMin=0;
		SLh=0;
	}

	//+-----------------------------------------------------------------+
	//| Check if trading is allowed                                     |
	//+-----------------------------------------------------------------+
	if(CountOfBasketOrder==NO_BASKET_ORDERS && CoundOfHedgeOrder==NO_HEDGE_ORDERS && ShutDown)
	{	
		/* Exit the pending order */
		if(CountOfPendingOrder>0)
		{	
            ExitTrades(P,displayColorLoss,"Blessing is shutting down");
			return;
		}
		if(AllowTrading)
		{	
            Print("Blessing has ShutDown. Set ShutDown = 'false' to continue trading");
			TryPlaySounds();
			AllowTrading=false;
		}
		if(UseEmail&&EmailCount<4&&!Testing)
		{	
			SendMail("Blessing EA","Blessing has shut down on "+Symbol()+" "+StringTimeFrame+
					". Trading has been suspended. To resume trading, set ShutDown to false.");
			Error=GetLastError();
			if(Error>0)
				Print("Error sending Email: "+Error+" "+ErrorDescription(Error));
			else 
				EmailCount=4;
		}
	}
	
	if(!AllowTrading)
	{	
		static bool LDelete;
		if(!LDelete){	
			LDelete=true;
			LabelDelete();
			if(ObjectFind("B3LStop")==-1)
				CreateLabel("B3LStop","Trading has been stopped on this pair.",10,0,0,3,displayColorLoss);
			if(Testing)
				string Tab="Tester Journal";
			else 
				Tab="Terminal Experts";
			if(ObjectFind("B3LExpt")==-1)
				CreateLabel("B3LExpt","Check the "+Tab+" tab for the reason why.",10,0,0,6,displayColorLoss);
			if(ObjectFind("B3LResm")==-1)
				CreateLabel("B3LResm","Reset Blessing to resume trading.",10,0,0,9,displayColorLoss);
		}
		return;
	}
	else
	{	
		LDelete=false;
		ObjDel("B3LStop");
		ObjDel("B3LExpt");
		ObjDel("B3LResm");
	}

    /* (-Profit)/Balance = DrawDown Level */
	//+-----------------------------------------------------------------+
	//| Calculate Drawdown and Equity Protection,                       |
	//+-----------------------------------------------------------------+
    //PortionBalance:想在该货币对上进行交易的金额
	double PortionBalance=ND(AccountBalance()*PortionPercentage,2);/* Acount Balance * Percentage */
    
	if(profit_of_basket_order+profit_of_hedge_order<0)//利润小于0
        DrawDownPercentage=-(profit_of_basket_order+profit_of_hedge_order)/PortionBalance;/*  DrawDownPercentage:DrawDown Percentage */
	if(DrawDownPercentage>=MaxDrawDownPercentage/100) /* Beyond the max drawdown percents stop trading */
	{   	
        ExitTrades(A,displayColorLoss,"Equity Stop Loss Reached");
		TryPlaySounds();
		return;
	}
	if(-(profit_of_basket_order+profit_of_hedge_order)>MaxDD)
        MaxDD=-(profit_of_basket_order+profit_of_hedge_order);
	MaxDDPer=MathMax(MaxDDPer, DrawDownPercentage*100);
	if(SaveStats)/*保存统计信息*/
        Stats(false,TimeCurrent()<NextStats,PortionBalance,profit_of_basket_order+profit_of_hedge_order);

	//+-----------------------------------------------------------------+
	//| Calculate  Stop Trade Percent                                   |
	//+-----------------------------------------------------------------+
	double StepAB=InitialAB*(1+StopTradePercent);
	double StepSTB=AccountBalance()*(1-StopTradePercent);
	double NextISTB=StepAB*(1-StopTradePercent);
	if(StepSTB>NextISTB) /*净值增长到110%,更新初始净值，和Stop净值,用于保护利润 */
	{	
        InitialAB=StepAB;
		StopTradeBalance=StepSTB;
	}
	double InitialAccountMultiPortion=StopTradeBalance*PortionPercentage;
	if(PortionBalance<InitialAccountMultiPortion)
	{	
		if(CountOfBasketOrder==NO_BASKET_ORDERS)
		{	
			AllowTrading=false;
			TryPlaySounds();
			Print("Portion Balance dropped below stop trade percent");
			MessageBox("Reset Blessing, account balance dropped below stop trade percent on "+Symbol()+Period(),"Blessing 3: Warning",48);
			return(0);
		}
		else if(!ShutDown&&!RecoupClosedLoss)
		{	
			ShutDown=true;
			TryPlaySounds();
			Print("Portion Balance dropped below stop trade percent");
			return(0);
		}
	}

	//+-----------------------------------------------------------------+
	//| dwj Calculation of Trend Direction                                  |
	//+-----------------------------------------------------------------+
	int Trend;
	string ATrend;
	double ima_0=iMA(Symbol(),0,MAPeriod,0,MODE_EMA,PRICE_CLOSE,0);
	if(ForceMarketCond==TREND_OFF)//Dynamic caculate the trend direction
	{	
        if(Bid>ima_0+MADistance)//Beyond the ma+distance,[Trend up]
            Trend=TREND_UP;
		else if(Ask<ima_0-MADistance)//Bellow the ma-distance,[Trend down]
            Trend=TREND_DOWN;
		else 
            Trend=TREND_RANGE;//between ma-distance and ma+distance consider to [Range]
	}
	else
	{	
        Trend=ForceMarketCond;/*手动指定趋势方向*/
		if(Trend!=TREND_UP && Bid>ima_0+MADistance)
            ATrend="U";
		if(Trend!=TREND_DOWN && Ask<ima_0-MADistance)
            ATrend="D";
		if(Trend!=TREND_RANGE && (Bid<ima_0+MADistance&&Ask>ima_0-MADistance))
            ATrend="R";
	}
	//+-----------------------------------------------------------------+
	//| Hedge/Basket/ClosedTrades Profit Management                     |
	//+-----------------------------------------------------------------+
	double Pa=profit_of_basket_order;
	PaC=PbC+PhC;
	if(hActive==1&&CoundOfHedgeOrder==NO_HEDGE_ORDERS)
	{	
		PhC=FindClosedPL(H);
		hActive=0;
		return;
	}
	if(total_lots_of_basket_order>0) /* 还有Basket单子 */
	{	
		if(PbC>0||(PbC<0&&RecoupClosedLoss))
		{	
			Pa+=PbC;
			BEbasket-=ND(PbC/PipVal2/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);
		}
		if(PhC>0||(PhC<0&&RecoupClosedLoss))
		{	
			Pa+=PhC;
			BEbasket-=ND(PhC/PipVal2/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);
		}
		if(profit_of_hedge_order>0||(profit_of_hedge_order<0&&RecoupClosedLoss))
			Pa+=profit_of_hedge_order;
	}

	//+-----------------------------------------------------------------+
	//| dwj Close oldest open trade after CloseTradesLevel reached          |
	//+-----------------------------------------------------------------+
	if(UseCloseOldest && CountOfBasketOrder>=CloseTradesLevel && CbC<MaxCloseTrades)
	{	
		if((TPb>0)&&((count_of_basket_buy_order>0&&OPbO>TPb)||(count_of_basket_sell_order>0&&OPbO<TPb)))
		{	y=ExitTrades(T,DarkViolet,"Close Oldest Trade",TbO);
			if(y==1)
			{	OrderSelect(TbO,SELECT_BY_TICKET);
				PbC+=OrderProfit()+OrderSwap()+OrderCommission();
				ca=0;
				CbC++;
				return;
			}
		}
	}

	//+-----------------------------------------------------------------+
	//| ATR for Auto Grid Calculation and Grid Set Block                |
	//+-----------------------------------------------------------------+
	if(AutoCal)
	{	double GridTP;
		double GridATR=iATR(NULL,0,21,0)/Pip;
		if((CountOfBasketOrder+CbC>Set4Level)&&Set4Level>0)
		{	g2=GridATR*12;    //GS*2*2*2*1.5
			tp2=GridATR*18;   //GS*2*2*2*1.5*1.5
		}
		else if((CountOfBasketOrder+CbC>Set3Level)&&Set3Level>0)
		{	g2=GridATR*8;     //GS*2*2*2
			tp2=GridATR*12;   //GS*2*2*2*1.5
		}
		else if((CountOfBasketOrder+CbC>Set2Level)&&Set2Level>0)
		{	g2=GridATR*4;     //GS*2*2
			tp2=GridATR*8;    //GS*2*2*2
		}
		else if((CountOfBasketOrder+CbC>Set1Level)&&Set1Level>0)
		{	g2=GridATR*2;     //GS*2
			tp2=GridATR*4;    //GS*2*2
		}
		else
		{	g2=GridATR;
			tp2=GridATR*2;
		}
		GridTP=GridATR*2;
	}
	else
	{	y=MathMax(MathMin(CountOfBasketOrder+CbC,MaxTrades)-1,0);
		g2=GridArray[y,0];
		tp2=GridArray[y,1];
		GridTP=GridArray[0,1];
	}
	g2=ND(g2*GAF*Pip,Digits);
	tp2=ND(tp2*GAF*Pip,Digits);
	GridTP=ND(GridTP*GAF*Pip,Digits);

	//+-----------------------------------------------------------------+
	//| Money Management and Lot size coding                            |
	//+-----------------------------------------------------------------+
	if(UseMM)
	{	
		if(CountOfBasketOrder>0)
		{	
			if(GlobalVariableCheck(ID+"LotMult"))
				LotMult=GlobalVariableGet(ID+"LotMult");
			if(LotsBaksetFirst!=iLotSize(Lots[0]*LotMult))
			{	
				LotMult=LotsBaksetFirst/Lots[0];
				GlobalVariableSet(ID+"LotMult",LotMult);
				Print("LotMult reset to "+DTS(LotMult,0));
			}
		}
		if(CountOfBasketOrder==NO_BASKET_ORDERS)
		{	

			/*
				Account Balance = 10000* (Lots * (1 + Factor))  //Standard Account
				Account Balance = 1000*  (Lots * (1 + Factor))  //Micro Account
				y+y^2+y^3+y^4+y^5+y^6 = (y^7-y)(y-1)
			 */
			double Contracts,Factor,Lotsize;
			Contracts=PortionBalance/10000;
			if(Multiplier<=1)
				Factor=Level;
			else 
				Factor=(MathPow(Multiplier,Level)-Multiplier)/(Multiplier-1);
			Lotsize=LAF*AccountType*Contracts/(1+Factor);
			LotMult=MathMax(MathFloor(Lotsize/Lot),MinMult);
			GlobalVariableSet(ID+"LotMult",LotMult);

			/*
			 *
			 *  MinMult = 1
			 *  AccountType = 10
			 *  LAF = 0.5
			 *	
			 *  Contracts = 500/10000 = 0.05
			 *  
			 *  Lotsize = 0.5*10*0.05/(1+22) = 0.01
			 *
			 *  LotMult = MathMax(x,MinMult) = 1
			 *
			 *	Rel Contracts  = 500/1000 = 0.5
			 *
			 *  Level 7 = 0.43
			 */

			
		}
	}
	else if(CountOfBasketOrder==NO_BASKET_ORDERS)
		LotMult=MinMult;


	//+-----------------------------------------------------------------+
	//| Calculate Take Profit                                           |
	//+-----------------------------------------------------------------+
	static double BCaL,BEbL;
	double nLots=total_lots_of_busket_buy_order-total_lots_of_busket_sell_order;
	if(hThisChart)
		nLots+=total_lots_of_hedge_buy_order-total_lots_of_hedge_sell_order;
	if(CountOfBasketOrder>0&&(TPb==0||CountOfBasketOrder+CoundOfHedgeOrder!=CaL||BEbL!=BEbasket||BCa!=BCaL||FirstRun))
	{	
		string sCalcTP="Set New TP: ";
		double NewTakeProfit,BasePips;
		CaL=CountOfBasketOrder+CoundOfHedgeOrder;
		BCaL=BCa;
		BEbL=BEbasket;
		BasePips=ND(Lot*LotMult*GridTP*(CountOfBasketOrder+CbC)/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);
		if(count_of_basket_buy_order>0)
		{	if(ForceTPPips>0)
			{	NewTakeProfit=BEbasket+ForceTPPips;
				sCalcTP=sCalcTP+" +Force TP ("+DTS(ForceTPPips,Digits)+") ";
			}
			else if(CbC>0&&CloseTPPips>0)
			{	NewTakeProfit=BEbasket+CloseTPPips;
				sCalcTP=sCalcTP+" +Close TP ("+DTS(CloseTPPips,Digits)+") ";
			}
			else if(BEbasket+BasePips>open_price_basket_last+tp2)
			{	NewTakeProfit=BEbasket+BasePips;
				sCalcTP=sCalcTP+" +Base TP: ("+DTS(BasePips,Digits)+") ";
			}
			else
			{	NewTakeProfit=open_price_basket_last+tp2;
				sCalcTP=sCalcTP+" +Grid TP: ("+DTS(tp2,Digits)+") ";
			}
			if(MinTPPips>0)
			{	NewTakeProfit=MathMax(NewTakeProfit,BEbasket+MinTPPips);
				sCalcTP=sCalcTP+" >Minimum TP: ";
			}
			NewTakeProfit+=MoveTP*Moves;
			if(BreakEvenTrade>0&&CountOfBasketOrder+CbC>=BreakEvenTrade)
			{	NewTakeProfit=BEbasket+BEPlusPips;
				sCalcTP=sCalcTP+" >BreakEven: ("+DTS(BEPlusPips,Digits)+") ";
			}
			if(BCa<0)
			{	double TPAdj=ND(BCa/PipVal2/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);
				NewTakeProfit-=TPAdj;
				sCalcTP=sCalcTP+" +BC: ("+DTS(-TPAdj,Digits)+") :";
			}
			sCalcTP=(sCalcTP+"Buy: TakeProfit: ");
		}
		else if(count_of_basket_sell_order>0)
		{	if(ForceTPPips>0)
			{	NewTakeProfit=BEbasket-ForceTPPips;
				sCalcTP=sCalcTP+" -Force TP ("+DTS(ForceTPPips,Digits)+") ";
			}
			else if(CbC>0&&CloseTPPips>0)
			{	NewTakeProfit=BEbasket-CloseTPPips;
				sCalcTP=sCalcTP+" -Close TP ("+DTS(CloseTPPips,Digits)+") ";
			}
			else if(BEbasket+BasePips<open_price_basket_last-tp2)
			{	NewTakeProfit=BEbasket+BasePips;
				sCalcTP=sCalcTP+" -Base TP: ("+DTS(BasePips,Digits)+") ";
			}
			else
			{	NewTakeProfit=open_price_basket_last-tp2;
				sCalcTP=sCalcTP+" -Grid TP: ("+DTS(tp2,Digits)+") ";
			}
			if(MinTPPips>0)
			{	NewTakeProfit=MathMin(NewTakeProfit,BEbasket-MinTPPips);
				sCalcTP=sCalcTP+" >Minimum TP: ";
			}
			NewTakeProfit-=MoveTP*Moves;
			if(BreakEvenTrade>0&&CountOfBasketOrder+CbC>=BreakEvenTrade)
			{	NewTakeProfit=BEbasket-BEPlusPips;
				sCalcTP=sCalcTP+" >BreakEven: ("+DTS(BEPlusPips,Digits)+") ";
			}
			if(BCa<0)
			{	TPAdj=ND(BCa/PipVal2/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);
				NewTakeProfit-=TPAdj;
				sCalcTP=sCalcTP+" -BC: ("+DTS(-TPAdj,Digits)+") :";
			}
			sCalcTP=(sCalcTP+"Sell: TakeProfit: ");
		}
		if(Debug)Print(sCalcTP+DTS(NewTakeProfit,Digits));
		if(TPb!=NewTakeProfit)
		{	TPb=NewTakeProfit;
			if(nLots>0)
				TargetPips=ND(TPb-BEbasket,Digits);
			else 
				TargetPips=ND(BEbasket-TPb,Digits);
			return;
		}
	}
	PbTarget=TargetPips/Pip;
	ProfitPot=ND(TargetPips*PipVal2*MathAbs(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),2);
	if(count_of_basket_buy_order>0)
		ProfitBasketPips=ND((Bid-BEbasket)/Pip,1);
	if(count_of_basket_sell_order>0)
		ProfitBasketPips=ND((BEbasket-Ask)/Pip,1);

	//+-----------------------------------------------------------------+
	//| Adjust BEbasket/TakeProfit if Hedge is active                        |
	//+-----------------------------------------------------------------+
	double hAsk=MarketInfo(HedgeSymbol,MODE_ASK);
	double hBid=MarketInfo(HedgeSymbol,MODE_BID);
	if(hActive==1)
	{	double TPa,PhPips;
		if(nLots==0)
		{	BEa=0;
			TPa=0;
		}
		else if(hThisChart)
		{	BEa=ND(((BEbasket*total_lots_of_basket_order-(BEhedge+hAsk-hBid)*total_lots_of_hedge_order)/(total_lots_of_basket_order-total_lots_of_hedge_order)),Digits);
			if(nLots>0)TPa=ND(BEa+TargetPips,Digits);
			else if(nLots<0)TPa=ND(BEa-TargetPips,Digits);
		}
		else
		{	//BEa=BEbasket-ND(profit_of_hedge_order/PipVal2/(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),Digits);
		}
		if(count_of_hedge_buy_order>0)PhPips=ND((hBid-BEhedge)/hPip,1);
		if(count_of_hedge_sell_order>0)PhPips=ND((BEhedge-hAsk)/hPip,1);
	}
	else
	{	BEa=BEbasket;
		TPa=TPb;
	}

	//+-----------------------------------------------------------------+
	//| Calculate Early Exit Percentage                                 |
	//+-----------------------------------------------------------------+
	if(UseEarlyExit&&CountOfBasketOrder>0)
	{	double EEpc,EEopt,EEStartTime,TPaF;
		if(EEFirstTrade)EEopt=OpenTimeBasketFirst;
		else EEopt=open_time_basket_last;
		if(DayOfWeek()<TimeDayOfWeek(EEopt))EEStartTime=2*24*3600;
		EEStartTime+=EEopt+EEStartHours*3600;
		if(EEHoursPC>0&&TimeCurrent()>=EEStartTime)EEpc=EEHoursPC*(TimeCurrent()-EEStartTime)/3600;
		if(EELevelPC>0&&(CountOfBasketOrder+CbC)>=EEStartLevel)EEpc+=EELevelPC*(CountOfBasketOrder+CbC-EEStartLevel+1);
		EEpc=1-EEpc;
		if(!EEAllowLoss&&EEpc<0)EEpc=0;
		PbTarget*=EEpc;
		TPaF=ND((TPa-BEa)*EEpc+BEa,Digits);
		if(displayOverlay&&displayLines&&(hActive!=1||(hActive==1&&hThisChart))&&(!Testing||(Testing&&Visual))&&EEpc<1
			&&(CountOfBasketOrder+CbC+CoundOfHedgeOrder>EECount||EETime!=Time[0])&&(EEHoursPC>0&&EEopt+EEStartHours*3600<Time[0])||(EELevelPC>0&&CountOfBasketOrder+CbC>=EEStartLevel))
		{	EETime=Time[0];
			EECount=CountOfBasketOrder+CbC+CoundOfHedgeOrder;
			if(ObjectFind("B3LEELn")<0)
			{	ObjectCreate("B3LEELn",OBJ_TREND,0,0,0);
				ObjectSet("B3LEELn",OBJPROP_COLOR,Yellow);
				ObjectSet("B3LEELn",OBJPROP_WIDTH,1);
				ObjectSet("B3LEELn",OBJPROP_STYLE,0);
				ObjectSet("B3LEELn",OBJPROP_RAY,false);
			}
			if(EEHoursPC>0)ObjectMove("B3LEELn",0,MathFloor(EEopt/3600+EEStartHours)*3600,TPa);
			else ObjectMove("B3LEELn",0,MathFloor(EEopt/3600)*3600,TPaF);
			ObjectMove("B3LEELn",1,Time[1],TPaF);
			if(ObjectFind("B3VEELn")<0)
			{	ObjectCreate("B3VEELn",OBJ_TEXT,0,0,0);
				ObjectSet("B3VEELn",OBJPROP_COLOR,Yellow);
				ObjectSet("B3VEELn",OBJPROP_WIDTH,1);
				ObjectSet("B3VEELn",OBJPROP_STYLE,0);
			}
			ObjSetTxt("B3VEELn","              "+DTS(TPaF,Digits),-1,Yellow);
			ObjectSet("B3VEELn",OBJPROP_PRICE1,TPaF+2*Pip);
			ObjectSet("B3VEELn",OBJPROP_TIME1,Time[1]);
		}
		else if((!displayLines||EEpc==1||(!EEAllowLoss&&EEpc==0)||(EEHoursPC>0&&EEopt+EEStartHours*3600>=Time[0])))
		{	ObjDel("B3LEELn");
			ObjDel("B3VEELn");
		}
	}
	else
	{	TPaF=TPa;
		EETime=0;
		EECount=0;
		ObjDel("B3LEELn");
		ObjDel("B3VEELn");
	}

	//+-----------------------------------------------------------------+
	//| Maximize Profit with Moving TP and setting Trailing Profit Stop |
	//+-----------------------------------------------------------------+
	if(MaximizeProfit)
	{	if(CountOfBasketOrder==NO_BASKET_ORDERS)
		{	SLbL=0;
			Moves=0;
			SLb=0;
		}
		if(CountOfBasketOrder>0)
		{	if((ProfitBasketPips+PhPips*total_lots_of_hedge_order/total_lots_of_basket_order)<0&&SLb>0)SLb=0;
			if(SLb>0&&(ProfitBasketPips+PhPips*total_lots_of_hedge_order/total_lots_of_basket_order)<=SLb)
			{	ExitTrades(A,displayColorProfit,"Profit Trailing Stop Reached ("+DTS(ProfitSet*100,2)+"%)");
				return;
			}
			if(PbTarget>0)
			{	double TPbMP=ND(PbTarget*ProfitSet,Digits);
				if((ProfitBasketPips+PhPips*total_lots_of_hedge_order/total_lots_of_basket_order)>PbTarget*ProfitSet)
					SLb=ND(PbTarget*ProfitSet,Digits);
			}
			if(SLb>0&&SLb>SLbL&&MoveTP>0&&TotalMoves>Moves)
			{	TPb=0;
				Moves++;
				if(Debug)Print("MoveTP");
				SLbL=SLb;
				TryPlaySounds();
				return;
			}
		}
	}
	if(TPa>0)
	{	if((nLots>0&&Bid>=TPaF)||(nLots<0&&Ask<=TPaF))
		{	ExitTrades(A,displayColorProfit,"Profit Target Reached");
			return;
		}
	}
	if(UseStopLoss)
	{	double bSL;
		if(SLPips>0)
		{	if(nLots>0)
			{	bSL=BEa-SLPips;
				if(Bid<=bSL)
				{	ExitTrades(A,displayColorProfit,"Stop Loss Reached");
					return;
				}
			}
			else if(nLots<0)
			{	bSL=BEa+SLPips;
				if(Ask>=bSL)
				{	ExitTrades(A,displayColorProfit,"Stop Loss Reached");
					return;
				}
			}
		}
		if(TSLPips!=0)
		{	if(nLots>0)
			{	if(TSLPips>0&&Bid>BEa+TSLPips)bTS=MathMax(bTS,Bid-TSLPips);
				if(TSLPips<0&&Bid>BEa-TSLPips)bTS=MathMax(bTS,Bid-MathMax(TSLPipsMin,-TSLPips*(1-(Bid-BEa+TSLPips)/(-TSLPips*2))));
				if(bTS>0&&Bid<=bTS)
				{	ExitTrades(A,displayColorProfit,"Trailing Stop Reached");
					return;
				}
			}
			else if(nLots<0)
			{	if(TSLPips>0&&Ask<BEa-TSLPips)
				{	if(bTS>0)bTS=MathMin(bTS,Ask+TSLPips);
				   else bTS=Ask+TSLPips;
				}
				if(TSLPips<0&&Ask<BEa+TSLPips)bTS=MathMin(bTS,Ask+MathMax(TSLPipsMin,-TSLPips*(1-(BEa-Ask+TSLPips)/(-TSLPips*2))));
				if(bTS>0&&Ask>=bTS)
				{	ExitTrades(A,displayColorProfit,"Trailing Stop Reached");
					return;
				}
			}
		}
	}

	//+-----------------------------------------------------------------+
	//| Check for and Delete hanging pending orders                     |
	//+-----------------------------------------------------------------+
	if(CountOfBasketOrder==NO_BASKET_ORDERS&&!PendLot)
	{	PendLot=true;
		for(y=OrdersTotal()-1;y>=0;y--)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
			if(OrderMagicNumber()!=Magic||OrderType()<=OP_SELL)continue;
			if(OrderLots()>Lots[0]*LotMult)
			{	PendLot=false;
				while(IsTradeContextBusy())Sleep(100);
				if(IsStopped())return(-1);
				Success=OrderDelete(OrderTicket());
				if(Success)
				{	PendLot=true;
					if(Debug)Print("Delete pending > Lot");
				}
			}
		}
		return;
	}
	else if((CountOfBasketOrder>0||(CountOfBasketOrder==NO_BASKET_ORDERS&&CountOfPendingOrder>0&&B3Traditional==false))&&PendLot)
	{	PendLot=false;
		for(y=OrdersTotal()-1;y>=0;y--)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
			if(OrderMagicNumber()!=Magic||OrderType()<=OP_SELL)continue;
			if(OrderLots()==Lots[0]*LotMult)
			{	PendLot=true;
				while(IsTradeContextBusy())Sleep(100);
				if(IsStopped())return(-1);
				Success=OrderDelete(OrderTicket());
				if(Success)
				{	PendLot=false;
					if(Debug)Print("Delete pending = Lot");
				}
			}
		}
		return;
	}
	//+-----------------------------------------------------------------+
	//| Check ca, Breakeven Trades and Emergency Close All              |
	//+-----------------------------------------------------------------+
	switch(ca)
	{	case B:  if(CountOfBasketOrder==NO_BASKET_ORDERS&&CountOfPendingOrder==0)ca=0;break;
		case H:  if(CoundOfHedgeOrder==NO_HEDGE_ORDERS)ca=0;break;
		case A:  if(CountOfBasketOrder==NO_BASKET_ORDERS&&CountOfPendingOrder==0&&CoundOfHedgeOrder==NO_HEDGE_ORDERS)ca=0;break;
		case P:  if(CountOfPendingOrder==0)ca=0;break;
		case T:  break;
		default: break;
	}
	if(ca>0)
	{	ExitTrades(ca,displayColorLoss,"Close All ("+DTS(ca,0)+")");
		return;
	}
	if(CountOfBasketOrder==NO_BASKET_ORDERS&&CoundOfHedgeOrder>0)
	{	ExitTrades(H,displayColorLoss,"Basket Closed");
		return;
	}
	if(EmergencyCloseAll)
	{	
		ExitTrades(A,displayColorLoss,"Emergency Close All Trades");
		EmergencyCloseAll=false;
		return;
	}

	//+-----------------------------------------------------------------+
	//| Check Holiday Shutdown                                          |
	//+-----------------------------------------------------------------+
	if(UseHolidayShutdown)
	{	if(HolShutDown>0&&TimeCurrent()>=HolLast&&HolLast>0)
		{	Print("Blessing has resumed after the holidays. From: "+TimeToStr(HolFirst,TIME_DATE)+" To: "+TimeToStr(HolLast,TIME_DATE));
			HolShutDown=0;
			LabelDelete();
			LabelCreate();
			if(PlaySounds)PlaySound(AlertSound);
		}
		else if(HolShutDown==3)
		{	if(ObjectFind("B3LStop")==-1)
				CreateLabel("B3LStop","Trading has been stopped on this pair for the holidays.",10,0,0,3,displayColorLoss);
			if(ObjectFind("B3LResm")==-1)
				CreateLabel("B3LResm","Blessing will resume trading after "+TimeToStr(HolLast,TIME_DATE)+".",10,0,0,9,displayColorLoss);
			return;
		}
		else if((HolShutDown==0&&TimeCurrent()>=HolLast)||HolFirst==0)
		{	for(y=0;y<ArraySize(HolArray);y++)
			{	HolFirst=StrToTime(Year()+"."+HolArray[y,0]+"."+HolArray[y,1]);
				HolLast=StrToTime(Year()+"."+HolArray[y,2]+"."+HolArray[y,3]+" 23:59:59");
				if(TimeCurrent()<HolFirst)
				{	if(HolFirst>HolLast)HolLast=StrToTime(DTS(Year()+1,0)+"."+HolArray[y,2]+"."+HolArray[y,3]+" 23:59:59");
					break;
				}
				if(TimeCurrent()<HolLast)
				{	if(HolFirst>HolLast)HolFirst=StrToTime(DTS(Year()-1,0)+"."+HolArray[y,0]+"."+HolArray[y,1]);
					break;
				}
				if(TimeCurrent()>HolFirst&&HolFirst>HolLast)
				{	HolLast=StrToTime(DTS(Year()+1,0)+"."+HolArray[y,2]+"."+HolArray[y,3]+" 23:59:59");
					if(TimeCurrent()<HolLast)break;
				}
			}
			if(TimeCurrent()>=HolFirst&&TimeCurrent()<=HolLast)
			{  Comment("");
			   HolShutDown=1;
			}
			return;
		}
		else if(HolShutDown==0&&TimeCurrent()>=HolFirst&&TimeCurrent()<HolLast)HolShutDown=1;
		else if(HolShutDown==1&&CountOfBasketOrder==NO_BASKET_ORDERS)
		{	Print("Blessing has shut down for the holidays. From: "+TimeToStr(HolFirst,TIME_DATE)+
					" To: "+TimeToStr(HolLast,TIME_DATE));
			if(CountOfPendingOrder>0)
			{	y=ExitTrades(P,displayColorLoss,"Holiday Shutdown");
				if(y==CountOfPendingOrder)ca=0;
			}
			HolShutDown=2;
			ObjDel("B3LClos");
		}
		else if(HolShutDown==1)
		{	if(ObjectFind("B3LClos")==-1)CreateLabel("B3LClos","",5,0,0,23,displayColorLoss);
			ObjSetTxt("B3LClos","Blessing will shutdown for the holidays when this basket closes",5);
		}
		if(HolShutDown==2)
		{	LabelDelete();
			if(PlaySounds)PlaySound(AlertSound);
			HolShutDown=3;
		}
		if(HolShutDown==3)
		{	if(ObjectFind("B3LStop")==-1)
				CreateLabel("B3LStop","Trading has been stopped on this pair for the holidays.",10,0,0,3,displayColorLoss);
			if(ObjectFind("B3LResm")==-1)
				CreateLabel("B3LResm","Blessing will resume trading after "+TimeToStr(HolLast,TIME_DATE)+".",10,0,0,9,displayColorLoss);
			Comment("");
			return;
		}
	}

	//+-----------------------------------------------------------------+
	//| Power Out Stop Loss Protection                                  |
	//+-----------------------------------------------------------------+
	if(SetPOSL)
	{	if(UsePowerOutSL&&POSLPips>0)
		{	double POSL=MathMin(PortionBalance*(MaxDrawDownPercentage+1)/100/PipVal2/total_lots_of_basket_order,POSLPips);
			stoploss_of_busket_buy_order=ND(BEbasket-POSL,Digits);
			stoploss_of_busket_sell_order=ND(BEbasket+POSL,Digits);
		}
		else
		{	stoploss_of_busket_buy_order=0;
			stoploss_of_busket_sell_order=0;
		}
		for(y=0;y<OrdersTotal();y++)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
			if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol()||OrderType()>OP_SELL)continue;
			if(OrderType()==OP_BUY&&OrderStopLoss()!=stoploss_of_busket_buy_order)
			{	Success=ModifyOrder(OrderOpenPrice(),stoploss_of_busket_buy_order,Purple);
				if(Debug&&Success)Print("Order: "+OrderTicket()+" Sync POSL Buy");
			}
			else if(OrderType()==OP_SELL&&OrderStopLoss()!=stoploss_of_busket_sell_order)
			{	Success=ModifyOrder(OrderOpenPrice(),stoploss_of_busket_sell_order,Purple);
				if(Debug&&Success)Print("Order: "+OrderTicket()+" Sync POSL Sell");
			}
		}
	}

	//+-----------------------------------------------------------------+  << This must be the first Entry check.
	//| Moving Average Indicator for Order Entry                        |  << Add your own Indicator Entry checks
	//+-----------------------------------------------------------------+  << after the Moving Average Entry.
	if(MAEntry>0 && CountOfBasketOrder==NO_BASKET_ORDERS && CountOfPendingOrder<2)
	{	
		if(Bid>ima_0+MADistance&&(!B3Traditional||(B3Traditional && Trend!=TREND_RANGE)))
		{	
			if(MAEntry==TRADE_BASE){	
				if(ForceMarketCond!=TREND_DOWN &&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))
					BuyMe=true;
				else 
					BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
					SellMe=false;
			}
			else if(MAEntry==TRADE_REVERSE){	
				if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))
					SellMe=true;
				else 
					SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
					BuyMe=false;
			}
		}
		else if(Ask<ima_0-MADistance&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
		{	
			if(MAEntry==TRADE_BASE)
			{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))
					SellMe=true;
				else 
					SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
					BuyMe=false;
			}
			else if(MAEntry==TRADE_REVERSE)
			{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))
					BuyMe=true;
				else 
					BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
					SellMe=false;
			}
		}
		else if(B3Traditional&&Trend==TREND_RANGE)
		{	
			if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))
				BuyMe=true;
			if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))
				SellMe=true;
		}
		else
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)
			IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" MA ";
	}


   
   

	if(MADiffEntry>0)
	{

		double mma_01=iMA(Symbol(),PERIOD_M5,MAPeroid1,0,MODE_SMA,PRICE_CLOSE,0);
		double mma_02=iMA(Symbol(),PERIOD_M15,MAPeroid2,0,MODE_SMA,PRICE_CLOSE,0);
		double mma_03=iMA(Symbol(),PERIOD_M30,MAPeroid3,0,MODE_SMA,PRICE_CLOSE,0);
		double mma_04=iMA(Symbol(),PERIOD_H1,MAPeroid4,0,MODE_SMA,PRICE_CLOSE,0);

		double mma_11=iMA(Symbol(),PERIOD_M5,MAPeroid1,0,MODE_SMA,PRICE_CLOSE,1);
		double mma_12=iMA(Symbol(),PERIOD_M15,MAPeroid2,0,MODE_SMA,PRICE_CLOSE,1);
		double mma_13=iMA(Symbol(),PERIOD_M30,MAPeroid3,0,MODE_SMA,PRICE_CLOSE,1);
		double mma_14=iMA(Symbol(),PERIOD_H1,MAPeroid4,0,MODE_SMA,PRICE_CLOSE,1);
		
		
		
		double mma_21=iMA(Symbol(),PERIOD_M5,MAPeroid1,0,MODE_SMA,PRICE_CLOSE,2);
		double mma_22=iMA(Symbol(),PERIOD_M15,MAPeroid2,0,MODE_SMA,PRICE_CLOSE,2);
		double mma_23=iMA(Symbol(),PERIOD_M30,MAPeroid3,0,MODE_SMA,PRICE_CLOSE,2);
		double mma_24=iMA(Symbol(),PERIOD_H1,MAPeroid4,0,MODE_SMA,PRICE_CLOSE,2);
		
		

		


		double diff1 = MAFactor*(mma_01 - mma_11)/MAAngleFactor;
		double diff2 = MAFactor*(mma_02 - mma_12)/MAAngleFactor;
		double diff3 = MAFactor*(mma_03 - mma_13)/MAAngleFactor;
		double diff4 = MAFactor*(mma_04 - mma_14)/MAAngleFactor;
		
		
		double diff5 = MAFactor*(mma_11 - mma_21)/MAAngleFactor;
		double diff6 = MAFactor*(mma_12 - mma_22)/MAAngleFactor;
		double diff7 = MAFactor*(mma_13 - mma_23)/MAAngleFactor;
		double diff8 = MAFactor*(mma_14 - mma_24)/MAAngleFactor;
		


      double diffStochastic = iStochastic(Symbol(),PERIOD_M15,56,12,12,MODE_SMA,0,MODE_MAIN,0);

		//printf("%f,%f,%f,%f\n",diff1,diff2,diff3,diff4);


		if(CountOfBasketOrder==NO_BASKET_ORDERS && CountOfPendingOrder<2)
		{

			if(diff1>MAFilterUpL1 && diff2>MAFilterUpL2 && diff3>MAFilterUpL3  && diff4>MAFilterUpL4 && diffStochastic<60)
			//if(diff1>0 && diff1<MAFilterUpL1  && diff2>MAFilterUpL2 && diff3>MAFilterUpL3  && diff4>MAFilterUpL4 )
			{
				if(ForceMarketCond==TREND_OFF)
					Trend=TREND_UP;
				if(MADiffEntry==TRADE_BASE)
				{	
					if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))
						BuyMe=true;
					else 
						BuyMe=false;
					if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
						SellMe=false;
				}
				else if(MADiffEntry==TRADE_REVERSE)
				{	
					if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))
						SellMe=true;
					else 
						SellMe=false;
					if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
						BuyMe=false;
				}
			}
			else if(diff1<MAFilterDownL1 && diff2<MAFilterDownL2 && diff3<MAFilterDownL3 && diff4<MAFilterDownL4 && diffStochastic > 40)
			//else if(diff1<0 && diff1>MAFilterDownL1 && diff2<MAFilterDownL2 && diff3<MAFilterDownL3 && diff4<MAFilterDownL4 )
			{
				if(ForceMarketCond==TREND_OFF)
					Trend=TREND_DOWN;
				if(MADiffEntry==TRADE_BASE)
				{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
					else SellMe=false;
					if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
				}
				else if(MADiffEntry==TRADE_REVERSE)
				{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
					else BuyMe=false;
					if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
				}
			}
			else if(!UseAnyEntry&&IndEntry>0)
			{	
				BuyMe=false;
				SellMe=false;
			}
			if(IndEntry>0)
				IndicatorUsed=IndicatorUsed+UAE;
			IndEntry++;
			IndicatorUsed=IndicatorUsed+" MADiff";


		}
		

	
	}

	//+----------------------------------------------------------------+
	//| CCI of 5M,15M,30M,1H for Market Condition and Order Entry      |
	//+----------------------------------------------------------------+
	if(CCIEntry>0)
	{	
		double cci_01=iCCI(Symbol(),PERIOD_M5,CCIPeriod,PRICE_CLOSE,0);
		double cci_02=iCCI(Symbol(),PERIOD_M15,CCIPeriod,PRICE_CLOSE,0);
		double cci_03=iCCI(Symbol(),PERIOD_M30,CCIPeriod,PRICE_CLOSE,0);
		double cci_04=iCCI(Symbol(),PERIOD_H1,CCIPeriod,PRICE_CLOSE,0);
		double cci_11=iCCI(Symbol(),PERIOD_M5,CCIPeriod,PRICE_CLOSE,1);
		double cci_12=iCCI(Symbol(),PERIOD_M15,CCIPeriod,PRICE_CLOSE,1);
		double cci_13=iCCI(Symbol(),PERIOD_M30,CCIPeriod,PRICE_CLOSE,1);
		double cci_14=iCCI(Symbol(),PERIOD_H1,CCIPeriod,PRICE_CLOSE,1);

		if(CountOfBasketOrder==NO_BASKET_ORDERS && CountOfPendingOrder<2)
		{	if(cci_11>0&&cci_12>0&&cci_13>0&&cci_14>0&&cci_01>0&&cci_02>0&&cci_03>0&&cci_04>0)
			{	
				if(ForceMarketCond==TREND_OFF)
					Trend=TREND_UP;
				if(CCIEntry==TRADE_BASE)
				{	
					if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))
						BuyMe=true;
					else 
						BuyMe=false;
					if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
						SellMe=false;
				}
				else if(CCIEntry==TRADE_REVERSE)
				{	
					if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))
						SellMe=true;
					else 
						SellMe=false;
					if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
						BuyMe=false;
				}
			}
			else if(cci_11<0&&cci_12<0&&cci_13<0&&cci_14<0&&cci_01<0&&cci_02<0&&cci_03<0&&cci_04<0)
			{	
				if(ForceMarketCond==TREND_OFF)
					Trend=TREND_DOWN;
				if(CCIEntry==TRADE_BASE)
				{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
					else SellMe=false;
					if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
				}
				else if(CCIEntry==TRADE_REVERSE)
				{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
					else BuyMe=false;
					if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
				}
			}
			else if(!UseAnyEntry&&IndEntry>0)
			{	
				BuyMe=false;
				SellMe=false;
			}
			if(IndEntry>0)
				IndicatorUsed=IndicatorUsed+UAE;
			IndEntry++;
			IndicatorUsed=IndicatorUsed+" CCI ";
		}
	}

	//+----------------------------------------------------------------+
	//| Bollinger Band Indicator for Order Entry                       |
	//+----------------------------------------------------------------+
	if(BollingerEntry>0&&CountOfBasketOrder==NO_BASKET_ORDERS&&CountOfPendingOrder<2)
	{	double ma=iMA(Symbol(),0,BollPeriod,0,MODE_SMA,PRICE_OPEN,0);
		double stddev=iStdDev(Symbol(),0,BollPeriod,0,MODE_SMA,PRICE_OPEN,0);
		double bup=ma+(BollDeviation*stddev);
		double bdn=ma-(BollDeviation*stddev);
		double bux=bup+BollDistance;
		double bdx=bdn-BollDistance;
		if(Ask<bdx)
		{	if(BollingerEntry==1)
			{	
				if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))
					BuyMe=true;
				else 
					BuyMe=false;
				 
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
					SellMe=false;
			}
			else if(BollingerEntry==2)
			{	
				if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))
					SellMe=true;
				else 
					SellMe=false;
				
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))
					BuyMe=false;
			}
		}
		else if(Bid>bux)
		{	if(BollingerEntry==1)
			{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
			}
			else if(BollingerEntry==2)
			{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" BBands ";
	}

	//+----------------------------------------------------------------+
	//| Stochastic Indicator for Order Entry                           |
	//+----------------------------------------------------------------+
	if(StochEntry>0&&CountOfBasketOrder==NO_BASKET_ORDERS&&CountOfPendingOrder<2)
	{	int zoneBUY=BuySellStochZone;
		int zoneSELL=100-BuySellStochZone;
		double stoc_0=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_LWMA,1,0,1);
		double stoc_1=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MODE_LWMA,1,1,1);
		if(stoc_0<zoneBUY&&stoc_1<zoneBUY)
		{	if(StochEntry==1)
			{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
			}
			else if(StochEntry==2)
			{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
			}
		}
		else if(stoc_0>zoneSELL&&stoc_1>zoneSELL)
		{	if(StochEntry==1)
			{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
			}
			else if(StochEntry==2)
			{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" Stoch ";
	}

	//+----------------------------------------------------------------+
	//| MACD Indicator for Order Entry                                 |
	//+----------------------------------------------------------------+
	if(MACDEntry>0&&CountOfBasketOrder==NO_BASKET_ORDERS&&CountOfPendingOrder<2)
	{	double MACDm=iMACD(NULL,TF[MACD_TF],FastPeriod,SlowPeriod,SignalPeriod,MACDPrice,0,0);
		double MACDs=iMACD(NULL,TF[MACD_TF],FastPeriod,SlowPeriod,SignalPeriod,MACDPrice,1,0);
		if(MACDm>MACDs)
		{	if(MACDEntry==1)
			{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
			}
			else if(MACDEntry==2)
			{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
			}
		}
		else if(MACDm<MACDs)
		{	if(MACDEntry==1)
			{	if(ForceMarketCond!=TREND_UP&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&SellMe)))SellMe=true;
				else SellMe=false;
				if(!UseAnyEntry&&IndEntry>0&&BuyMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))BuyMe=false;
			}
			else if(MACDEntry==2)
			{	if(ForceMarketCond!=TREND_DOWN&&(UseAnyEntry||IndEntry==0||(!UseAnyEntry&&IndEntry>0&&BuyMe)))BuyMe=true;
				else BuyMe=false;
				if(!UseAnyEntry&&IndEntry>0&&SellMe&&(!B3Traditional||(B3Traditional&&Trend!=TREND_RANGE)))SellMe=false;
			}
		}
		else if(!UseAnyEntry&&IndEntry>0)
		{	BuyMe=false;
			SellMe=false;
		}
		if(IndEntry>0)IndicatorUsed=IndicatorUsed+UAE;
		IndEntry++;
		IndicatorUsed=IndicatorUsed+" MACD ";
	}

	//+-----------------------------------------------------------------+  << This must be the last Entry check before
	//| UseAnyEntry Check && Force Market Condition Buy/Sell Entry      |  << the Trade Selection Logic. Add checks for
	//+-----------------------------------------------------------------+  << additional indicators before this block.
	if((!UseAnyEntry && IndEntry>1 && BuyMe && SellMe)||FirstRun)
	{	
		BuyMe=false;
		SellMe=false;
	}
	if(ForceMarketCond<TREND_RANGE&&IndEntry==0&&CountOfBasketOrder==NO_BASKET_ORDERS&&!FirstRun)
	{	
		if(ForceMarketCond==TREND_UP)
			BuyMe=true;
		if(ForceMarketCond==TREND_DOWN)
			SellMe=true;
		IndicatorUsed=" FMC ";
	}

	//+-----------------------------------------------------------------+
	//| Trade Selection Logic                                           |
	//+-----------------------------------------------------------------+
	OrderLot=iLotSize(Lots[StrToInteger(DTS(MathMin(CountOfBasketOrder+CbC,MaxTrades-1),0))]*LotMult);
	
	if(CountOfBasketOrder==NO_BASKET_ORDERS && CountOfPendingOrder<2 && !FirstRun)
	{	
		if(B3Traditional)
		{	if(BuyMe)
			{	
				//Buy Stop == 0 && Sell Limit == 0	
				if(count_of_buy_stop==NO_BUY_STOP_ORDERS &&
					count_of_sell_limit==NO_SELL_LIMIT_ORDERS &&
					((Trend!=TREND_RANGE||MAEntry==TRADE_OFF)||(Trend==TREND_RANGE && MAEntry==TRADE_BASE)))
				{
					Entry=g2-MathMod(Ask,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	
						Ticket=SendOrder(Symbol(),OP_BUYSTOP,OrderLot,Entry,0,Magic,CLR_NONE);
						if(Ticket>0){	
							if(Debug)
								Print("Indicator Entry - ("+IndicatorUsed+") BuyStop MC = "+Trend);
							count_of_buy_stop++;
						}
					}
				}
				if(count_of_buy_limit==NO_BUY_LIMIT_ORDERS &&
					count_of_sell_stop==NO_SELL_STOP_ORDERS&&
					((Trend!=TREND_RANGE||MAEntry==TRADE_OFF)||(Trend==TREND_RANGE&&MAEntry==TRADE_REVERSE)))
				{	Entry=MathMod(Ask,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_BUYLIMIT,OrderLot,-Entry,0,Magic,CLR_NONE);
						if(Ticket>0)
						{	if(Debug)Print("Indicator Entry - ("+IndicatorUsed+") BuyLimit MC = "+Trend);
							count_of_buy_limit++;
						}
					}
				}
			}
			if(SellMe)
			{	if(count_of_sell_limit==0&&count_of_buy_stop==0&&((Trend!=TREND_RANGE||MAEntry==TRADE_OFF)||(Trend==TREND_RANGE&&MAEntry==TRADE_REVERSE)))
				{	Entry=g2-MathMod(Bid,g2)-EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_SELLLIMIT,OrderLot,Entry,0,Magic,CLR_NONE);
						if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") SellLimit MC = "+Trend);
					}
				}
				if(count_of_sell_stop==0&&count_of_buy_limit==0&&((Trend!=TREND_RANGE||MAEntry==TRADE_OFF)||(Trend==TREND_RANGE&&MAEntry==TRADE_BASE)))
				{	Entry=MathMod(Bid,g2)+EntryOffset;
					if(Entry>StopLevel)
					{	Ticket=SendOrder(Symbol(),OP_SELLSTOP,OrderLot,-Entry,0,Magic,CLR_NONE);
						if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") SellStop MC = "+Trend);
					}
				}
			}
		}
		else
		{	if(BuyMe)
			{	Ticket=SendOrder(Symbol(),OP_BUY,OrderLot,0,slip,Magic,Blue);
				if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") Buy");
			}
			else if(SellMe)
			{	Ticket=SendOrder(Symbol(),OP_SELL,OrderLot,0,slip,Magic,displayColorLoss);
				if(Ticket>0&&Debug)Print("Indicator Entry - ("+IndicatorUsed+") Sell");
			}
		}
		if(Ticket>0)
			return;
	}
	else if(TimeCurrent()-EntryDelay>open_time_basket_last&&CountOfBasketOrder+CbC<MaxTrades&&!FirstRun)
	{	if(UseSmartGrid)
		{	if(RSI[1]!=iRSI(NULL,TF[RSI_TF],RSI_Period,RSI_Price,1))
				for(y=0;y<RSI_Period+RSI_MA_Period;y++)RSI[y]=iRSI(NULL,TF[RSI_TF],RSI_Period,RSI_Price,y);
			else RSI[0]=iRSI(NULL,TF[RSI_TF],RSI_Period,RSI_Price,0);
			RSI_MA=iMAOnArray(RSI,0,RSI_MA_Period,0,RSI_MA_Method,0);
		}
		if(count_of_basket_buy_order>0)
		{	if(open_price_basket_last>Ask)Entry=open_price_basket_last-(MathRound((open_price_basket_last-Ask)/g2)+1)*g2;
			else Entry=open_price_basket_last-g2;
			double OPbN=Entry;
			if(UseSmartGrid)
			{	if(Ask<open_price_basket_last-g2)
				{	if(RSI[0]>RSI_MA)
					{	Ticket=SendOrder(Symbol(),OP_BUY,OrderLot,0,slip,Magic,Blue);
						if(Ticket>0&&Debug)Print("SmartGrid Buy RSI: "+RSI[0]+" > MA: "+RSI_MA);
					}
					OPbN=0;
				}
				else OPbN=open_price_basket_last-g2;
			}
			else if(count_of_buy_limit==0)
			{	if(Ask-Entry>StopLevel)
				{	Ticket=SendOrder(Symbol(),OP_BUYLIMIT,OrderLot,Entry-Ask,0,Magic,SkyBlue);
					if(Ticket>0&&Debug)Print("BuyLimit grid");
				}
			}
			else if(count_of_buy_limit==1&&Entry-open_price_buy_limit>g2/2&&Ask-Entry>StopLevel)
			{	for(y=OrdersTotal();y>=0;y--)
				{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
					if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol()||OrderType()!=OP_BUYLIMIT)continue;
					Success=ModifyOrder(Entry,0,SkyBlue);
					if(Success&&Debug)Print("Mod BuyLimit Entry");
				}
			}
		}
		else if(count_of_basket_sell_order>0)
		{	if(Bid>open_price_basket_last)Entry=open_price_basket_last+(MathRound((-open_price_basket_last+Bid)/g2)+1)*g2;
			else Entry=open_price_basket_last+g2;
			OPbN=Entry;
			if(UseSmartGrid)
			{	if(Bid>open_price_basket_last+g2)
				{	if(RSI[0]<RSI_MA)
					{	Ticket=SendOrder(Symbol(),OP_SELL,OrderLot,0,slip,Magic,displayColorLoss);
						if(Ticket>0&&Debug)Print("SmartGrid Sell RSI: "+RSI[0]+" < MA: "+RSI_MA);
					}
					OPbN=0;
				}
				else OPbN=open_price_basket_last+g2;
			}
			else if(count_of_sell_limit==0)
			{	if(Entry-Bid>StopLevel)
				{	Ticket=SendOrder(Symbol(),OP_SELLLIMIT,OrderLot,Entry-Bid,0,Magic,Coral);
					if(Ticket>0&&Debug)Print("SellLimit grid");
				}
			}
			else if(count_of_sell_limit==1&&open_price_sell_limit-Entry>g2/2&&Entry-Bid>StopLevel)
			{	for(y=OrdersTotal()-1;y>=0;y--)
				{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
					if(OrderMagicNumber()!=Magic||OrderSymbol()!=Symbol()||OrderType()!=OP_SELLLIMIT)continue;
					Success=ModifyOrder(Entry,0,Coral);
					if(Success&&Debug)Print("Mod SellLimit Entry");
				}
			}
		}
		if(Ticket>0)return;
	}


	//+-----------------------------------------------------------------+
	//| Hedge Trades Set-Up and Monitoring                              |
	//+-----------------------------------------------------------------+
	if((UseHedge && CountOfBasketOrder>0)||CoundOfHedgeOrder>0)
	{	
		if(CoundOfHedgeOrder>0 && hActive==0)
			hActive=1;
		int hLevel=CountOfBasketOrder+CbC;
		if(HedgeTypeDD)
		{	
			if(hDDStart==0&&CoundOfHedgeOrder>0)
				hDDStart=MathMax(HedgeStart, DrawDownPercentage+hReEntryPC);
			if(hDDStart>HedgeStart&&hDDStart> DrawDownPercentage+hReEntryPC)
				hDDStart= DrawDownPercentage+hReEntryPC;
			if(hActive==2)
			{	hActive=0;
				hDDStart=MathMax(HedgeStart, DrawDownPercentage+hReEntryPC);
			}
		}
		if(hActive==0)
		{	if(!hThisChart&&(hPosCorr&&CheckCorr()<0.9||!hPosCorr&&CheckCorr()>-0.9))
			{	if(ObjectFind("B3LhCor")==-1)
					CreateLabel("B3LhCor","The correlation with the hedge pair has dropped below 90%.",0,0,190,10,displayColorLoss);
			}
			else ObjDel("B3LhCor");
			if(hLvlStart>hLevel+1||!HedgeTypeDD&&hLvlStart==0)hLvlStart=MathMax(HedgeStart,hLevel+1);
			if((HedgeTypeDD&& DrawDownPercentage>hDDStart)||(!HedgeTypeDD&&hLevel>=hLvlStart))
			{	OrderLot=iLotSize(total_lots_of_basket_order*hLotMult);
				if((count_of_basket_buy_order>0&&!hPosCorr)||(count_of_basket_sell_order>0&&hPosCorr))
				{	Ticket=SendOrder(HedgeSymbol,OP_BUY,OrderLot,0,slip,hMagic,MidnightBlue);
					if(Ticket>0)
					{	if(hMaxLossPips>0)SLh=hAsk-hMaxLossPips;
						if(Debug)Print("Hedge Buy : Stoploss @ "+DTS(SLh,Digits));
					}
				}
				if((count_of_basket_buy_order>0&&hPosCorr)||(count_of_basket_sell_order>0&&!hPosCorr))
				{	Ticket=SendOrder(HedgeSymbol,OP_SELL,OrderLot,0,slip,hMagic,Maroon);
					if(Ticket>0)
					{	if(hMaxLossPips>0)SLh=hBid+hMaxLossPips;
						if(Debug)Print("Hedge Sell : Stoploss @ "+DTS(SLh,Digits));
					}
				}
				if(Ticket>0)
				{	hActive=1;
					if(HedgeTypeDD)hDDStart+=hReEntryPC;
					hLvlStart=hLevel+1;
					return;
				}
			}
		}
		else if(hActive==1)
		{	if(HedgeTypeDD&&hDDStart>HedgeStart&&hDDStart< DrawDownPercentage+hReEntryPC)hDDStart= DrawDownPercentage+hReEntryPC;
			if(hLvlStart==0)
			{	if(HedgeTypeDD)hLvlStart=hLevel+1;
				else hLvlStart=MathMax(HedgeStart,hLevel+1);
			}
			if(hLevel>=hLvlStart)
			{	OrderLot=iLotSize(Lots[CountOfBasketOrder+CbC-1]*LotMult*hLotMult);
				if(OrderLot>0&&(count_of_basket_buy_order>0&&!hPosCorr)||(count_of_basket_sell_order>0&&hPosCorr))
				{	Ticket=SendOrder(HedgeSymbol,OP_BUY,OrderLot,0,slip,hMagic,MidnightBlue);
					if(Ticket>0&&Debug)Print("Hedge Buy");
				}
				if(OrderLot>0&&(count_of_basket_buy_order>0&&hPosCorr)||(count_of_basket_sell_order>0&&!hPosCorr))
				{	Ticket=SendOrder(HedgeSymbol,OP_SELL,OrderLot,0,slip,hMagic,Maroon);
					if(Ticket>0&&Debug)Print("Hedge Sell");
				}
				if(Ticket>0)
				{	hLvlStart=hLevel+1;
					return;
				}
			}
			y=0;
			if(hMaxLossPips>0)
			{	if(count_of_hedge_buy_order>0)
				{	if(hFixedSL)
					{	if(SLh==0)SLh=hAsk-hMaxLossPips;
					}
					else
					{	if(SLh==0||(SLh<BEhedge&&SLh<hAsk-hMaxLossPips))SLh=hAsk-hMaxLossPips;
						else if(StopTrailAtBE&&hAsk-hMaxLossPips>=BEhedge)SLh=BEhedge;
						else if(SLh>=BEhedge&&!StopTrailAtBE)
						{	if(!ReduceTrailStop)SLh=MathMax(SLh,hAsk-hMaxLossPips);
							else SLh=MathMax(SLh,hAsk-MathMax(StopLevel,hMaxLossPips*(1-(hAsk-hMaxLossPips-BEhedge)/(hMaxLossPips*2))));
						}
					}
					if(hBid<=SLh)y=ExitTrades(H,DarkViolet,"Hedge Stop Loss");
				}
				else if(count_of_hedge_sell_order>0)
				{	if(hFixedSL)
					{	if(SLh==0)SLh=hBid+hMaxLossPips;
					}
					else
					{	if(SLh==0||(SLh>BEhedge&&SLh>hBid+hMaxLossPips))SLh=hBid+hMaxLossPips;
						else if(StopTrailAtBE&&hBid+hMaxLossPips<=BEhedge)SLh=BEhedge;
						else if(SLh<=BEhedge&&!StopTrailAtBE)
						{	if(!ReduceTrailStop)SLh=MathMin(SLh,hBid+hMaxLossPips);
							else SLh=MathMin(SLh,hBid+MathMax(StopLevel,hMaxLossPips*(1-(BEhedge-hBid-hMaxLossPips)/(hMaxLossPips*2))));
						}
					}
					if(hAsk>=SLh)y=ExitTrades(H,DarkViolet,"Hedge Stop Loss");
				}
			}
			if(y==0&&hTakeProfit>0)
			{	if(count_of_hedge_buy_order>0&&hBid>OPhO+hTakeProfit)y=ExitTrades(T,DarkViolet,"Hedge Take Profit reached",ThO);
				if(count_of_hedge_sell_order>0&&hAsk<OPhO-hTakeProfit)y=ExitTrades(T,DarkViolet,"Hedge Take Profit reached",ThO);
			}
			if(y>0)
			{	PhC=FindClosedPL(H);
				if(y==CoundOfHedgeOrder)
				{	if(HedgeTypeDD)hActive=2;
					else hActive=0;
				}
				return;
			}
		}
	}

	//+-----------------------------------------------------------------+
	//| Check DD% and send Email                                        |
	//+-----------------------------------------------------------------+
	if((UseEmail||PlaySounds)&&!Testing)
	{	if(EmailCount<2&&Email[EmailCount]>0&& DrawDownPercentage>Email[EmailCount])
		{	if(UseEmail)SendMail("Blessing EA","Blessing has exceeded a drawdown of "+Email[EmailCount]*100+"% on "+Symbol()+" "+StringTimeFrame);
			TryPlaySounds();
			Error=GetLastError();
			if(Error>0)Print("Email DD: "+DTS( DrawDownPercentage*100,2)+" Error: "+Error+" "+ErrorDescription(Error));
			else
			{	if(UseEmail&&Debug)Print("DrawDown Email sent on "+Symbol()+" "+StringTimeFrame+ " DD: "+DTS( DrawDownPercentage*100,2));
				EmailSent=TimeCurrent();
				EmailCount++;
			}
		}
		else if(EmailCount>0&&EmailCount<3&& DrawDownPercentage<Email[EmailCount]&&TimeCurrent()>EmailSent+EmailHours*3600)EmailCount--;
	}

	//+-----------------------------------------------------------------+
	//| Display Overlay Code                                            |
	//+-----------------------------------------------------------------+
	if((Testing&&Visual)||!Testing)
	{	if(displayOverlay)
		{	color Colour;
			int dDigits;
			ObjSetTxt("B3VTime",TimeToStr(TimeCurrent(),TIME_SECONDS));
			DrawLabel("B3VSTAm",InitialAccountMultiPortion,167,2,displayColorLoss);
			if(UseHolidayShutdown)
			{	ObjSetTxt("B3VHolF",TimeToStr(HolFirst,TIME_DATE));
				ObjSetTxt("B3VHolT",TimeToStr(HolLast,TIME_DATE));
			}
			DrawLabel("B3VPBal",PortionBalance,167);
			if( DrawDownPercentage>0.4)Colour=displayColorLoss;
			else if( DrawDownPercentage>0.3)Colour=Orange;
			else if( DrawDownPercentage>0.2)Colour=Yellow;
			else if( DrawDownPercentage>0.1)Colour=displayColorProfit;
			else Colour=displayColor;
			DrawLabel("B3VDrDn", DrawDownPercentage*100,315,2,Colour);
			if(UseHedge&&HedgeTypeDD)ObjSetTxt("B3VhDDm",DTS(hDDStart*100,2));
			else if(UseHedge&&!HedgeTypeDD)
			{	DrawLabel("B3VhLvl",CountOfBasketOrder+CbC,318,0);
				ObjSetTxt("B3VhLvT",DTS(hLvlStart,0));
			}
			ObjSetTxt("B3VSLot",DTS(Lot*LotMult,2));
			if(ProfitPot>=0)DrawLabel("B3VPPot",ProfitPot,190);
			else
			{	ObjSetTxt("B3VPPot",DTS(ProfitPot,2),0,displayColorLoss);
				dDigits=Digit[ArrayBsearch(Digit,-ProfitPot,WHOLE_ARRAY,0,MODE_ASCEND),1];
				ObjSet("B3VPPot",186-dDigits*7);
			}
			if(UseEarlyExit&&EEpc<1)
			{	if(ObjectFind("B3SEEPr")==-1)CreateLabel("B3SEEPr","/",0,0,220,12);
				if(ObjectFind("B3VEEPr")==-1)CreateLabel("B3VEEPr","",0,0,229,12);
				ObjSetTxt("B3VEEPr",DTS(PbTarget*PipValue*MathAbs(total_lots_of_busket_buy_order-total_lots_of_busket_sell_order),2));
			}
			else
			{	ObjDel("B3SEEPr");
				ObjDel("B3VEEPr");
			}
			if(SLb>0)
			{	if(count_of_basket_buy_order>0)DrawLabel("B3VPrSL",BEbasket+SLb*Pip,190);
				else if(count_of_basket_sell_order>0)DrawLabel("B3VPrSL",BEbasket-SLb*Pip,190);
			}
			else DrawLabel("B3VPrSL",0,190);
			if(profit_of_basket_order>=0)
			{	DrawLabel("B3VPnPL",profit_of_basket_order,190,2,displayColorProfit);
				ObjSetTxt("B3VPPip",DTS(ProfitBasketPips,1),0,displayColorProfit);
				ObjSet("B3VPPip",229);
			}
			else
			{	ObjSetTxt("B3VPnPL",DTS(profit_of_basket_order,2),0,displayColorLoss);
				dDigits=Digit[ArrayBsearch(Digit,-profit_of_basket_order,WHOLE_ARRAY,0,MODE_ASCEND),1];
				ObjSet("B3VPnPL",186-dDigits*7);
				ObjSetTxt("B3VPPip",DTS(ProfitBasketPips,1),0,displayColorLoss);
				ObjSet("B3VPPip",225);
			}
			if(ProfitBasketMax>=0)DrawLabel("B3VPLMx",ProfitBasketMax,190,2,displayColorProfit);
			else
			{	ObjSetTxt("B3VPLMx",DTS(ProfitBasketMax,2),0,displayColorLoss);
				dDigits=Digit[ArrayBsearch(Digit,-ProfitBasketMax,WHOLE_ARRAY,0,MODE_ASCEND),1];
				ObjSet("B3VPLMx",186-dDigits*7);
			}
			if(ProfitBasketMin<0)ObjSet("B3VPLMn",225);
			else ObjSet("B3VPLMn",229);
			ObjSetTxt("B3VPLMn",DTS(ProfitBasketMin,2),0,displayColorLoss);
			if(CountOfBasketOrder+CbC<BreakEvenTrade&&CountOfBasketOrder+CbC<MaxTrades)Colour=displayColor;
			else if(CountOfBasketOrder+CbC<MaxTrades)Colour=Orange;
			else Colour=displayColorLoss;
			if(count_of_basket_buy_order>0)
			{	ObjSetTxt("B3LType","Buy:");
				DrawLabel("B3VOpen",count_of_basket_buy_order,207,0,Colour);
			}
			else if(count_of_basket_sell_order>0)
			{	ObjSetTxt("B3LType","Sell:");
				DrawLabel("B3VOpen",count_of_basket_sell_order,207,0,Colour);
			}
			else
			{	ObjSetTxt("B3LType","");
				ObjSetTxt("B3VOpen",DTS(0,0),0,Colour);
				ObjSet("B3VOpen",207);
			}
			ObjSetTxt("B3VLots",DTS(total_lots_of_basket_order,2));
			ObjSetTxt("B3VMove",DTS(Moves,0));
			DrawLabel("B3VMxDD",MaxDD,107);
			DrawLabel("B3VDDPC",MaxDDPer,229);
			if(Trend==0)
			{	ObjSetTxt("B3LTrnd","Trend is UP",10,displayColorProfit);
				if(ObjectFind("B3ATrnd")==-1)CreateLabel("B3ATrnd","",0,0,160,20,displayColorProfit,"Wingdings");
				ObjectSetText("B3ATrnd","?",displayFontSize+9,"Wingdings",displayColorProfit);
				ObjSet("B3ATrnd",160);
				ObjectSet("B3ATrnd",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
				if(StringLen(ATrend)>0)
				{	if(ObjectFind("B3AATrn")==-1)CreateLabel("B3AATrn","",0,0,200,20,displayColorProfit,"Wingdings");
					if(ATrend=="D")
					{	ObjectSetText("B3AATrn","?",displayFontSize+9,"Wingdings",displayColorLoss);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20+5);
					}
					else if(ATrend=="R")
					{	ObjSetTxt("B3AATrn","R",10,Orange);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
				}
				else ObjDel("B3AATrn");
			}
			else if(Trend==1)
			{	ObjSetTxt("B3LTrnd","Trend is DOWN",10,displayColorLoss);
				if(ObjectFind("B3ATrnd")==-1)CreateLabel("B3ATrnd","",0,0,210,20,displayColorLoss,"WingDings");
				ObjectSetText("B3ATrnd","?",displayFontSize+9,"Wingdings",displayColorLoss);
				ObjSet("B3ATrnd",210);
				ObjectSet("B3ATrnd",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20+5);
				if(StringLen(ATrend)>0)
				{	if(ObjectFind("B3AATrn")==-1)CreateLabel("B3AATrn","",0,0,250,20,displayColorProfit,"Wingdings");
					if(ATrend=="U")
					{	ObjectSetText("B3AATrn","?",displayFontSize+9,"Wingdings",displayColorProfit);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
					else if(ATrend=="R")
					{	ObjSetTxt("B3AATrn","R",10,Orange);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
				}
				else ObjDel("B3AATrn");
			}
			else if(Trend==TREND_RANGE)
			{	ObjSetTxt("B3LTrnd","Trend is Ranging",10,Orange);
				ObjDel("B3ATrnd");
				if(StringLen(ATrend)>0)
				{	if(ObjectFind("B3AATrn")==-1)CreateLabel("B3AATrn","",0,0,220,20,displayColorProfit,"Wingdings");
					if(ATrend=="U")
					{	ObjectSetText("B3AATrn","?",displayFontSize+9,"Wingdings",displayColorProfit);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20);
					}
					else if(ATrend=="D")
					{	ObjectSetText("B3AATrn","?",displayFontSize+8,"Wingdings",displayColorLoss);
						ObjectSet("B3AATrn",OBJPROP_YDISTANCE,displayYcord+displaySpacing*20+5);
					}
				}
				else ObjDel("B3AATrn");
			}
			if(PaC!=0)
			{	if(ObjectFind("B3LClPL")==-1)CreateLabel("B3LClPL","Closed P/L",0,0,312,11);
				if(ObjectFind("B3VClPL")==-1)CreateLabel("B3VClPL","",0,0,327,12);
				if(PaC>=0)DrawLabel("B3VClPL",PaC,327,2,displayColorProfit);
				else
				{	ObjSetTxt("B3VClPL",DTS(PaC,2),0,displayColorLoss);
					dDigits=Digit[ArrayBsearch(Digit,-PaC,WHOLE_ARRAY,0,MODE_ASCEND),1];
					ObjSet("B3VClPL",323-dDigits*7);
				}
			}
			else
			{	ObjDel("B3LClPL");
				ObjDel("B3VClPL");
			}
			if(hActive==1)
			{	if(ObjectFind("B3LHdge")==-1)CreateLabel("B3LHdge","Hedge",0,0,323,13);
				if(ObjectFind("B3VhPro")==-1)CreateLabel("B3VhPro","",0,0,312,14);
				if(profit_of_hedge_order>=0)DrawLabel("B3VhPro",profit_of_hedge_order,312,2,displayColorProfit);
				else
				{	ObjSetTxt("B3VhPro",DTS(profit_of_hedge_order,2),0,displayColorLoss);
					dDigits=Digit[ArrayBsearch(Digit,-profit_of_hedge_order,WHOLE_ARRAY,0,MODE_ASCEND),1];
					ObjSet("B3VhPro",308-dDigits*7);
				}
				if(ObjectFind("B3VhPMx")==-1)CreateLabel("B3VhPMx","",0,0,312,15);
				if(ProfitHedgeMax>=0)DrawLabel("B3VhPMx",ProfitHedgeMax,312,2,displayColorProfit);
				else
				{	ObjSetTxt("B3VhPMx",DTS(ProfitHedgeMax,2),0,displayColorLoss);
					dDigits=Digit[ArrayBsearch(Digit,-ProfitHedgeMax,WHOLE_ARRAY,0,MODE_ASCEND),1];
					ObjSet("B3VhPMx",308-dDigits*7);
				}
				if(ObjectFind("B3ShPro")==-1)CreateLabel("B3ShPro","/",0,0,342,15);
				if(ObjectFind("B3VhPMn")==-1)CreateLabel("B3VhPMn","",0,0,351,15,displayColorLoss);
				if(ProfitHedgeMin<0)ObjSet("B3VhPMn",347);
				else ObjSet("B3VhPMn",351);
				ObjSetTxt("B3VhPMn",DTS(ProfitHedgeMin,2),0,displayColorLoss);
				if(ObjectFind("B3LhTyp")==-1)CreateLabel("B3LhTyp","",0,0,292,16);
				if(ObjectFind("B3VhOpn")==-1)CreateLabel("B3VhOpn","",0,0,329,16);
				if(count_of_hedge_buy_order>0)
				{	ObjSetTxt("B3LhTyp","Buy:");
					DrawLabel("B3VhOpn",count_of_hedge_buy_order,329,0);
				}
				else if(count_of_hedge_sell_order>0)
				{	ObjSetTxt("B3LhTyp","Sell:");
					DrawLabel("B3VhOpn",count_of_hedge_sell_order,329,0);
				}
				else
				{	ObjSetTxt("B3LhTyp","");
					ObjSetTxt("B3VhOpn",DTS(0,0));
					ObjSet("B3VhOpn",329);
				}
				if(ObjectFind("B3ShOpn")==-1)CreateLabel("B3ShOpn","/",0,0,342,16);
				if(ObjectFind("B3VhLot")==-1)CreateLabel("B3VhLot","",0,0,351,16);
				ObjSetTxt("B3VhLot",DTS(total_lots_of_hedge_order,2));
			}
			else
			{	ObjDel("B3LHdge");
				ObjDel("B3VhPro");
				ObjDel("B3VhPMx");
				ObjDel("B3ShPro");
				ObjDel("B3VhPMn");
				ObjDel("B3LhTyp");
				ObjDel("B3VhOpn");
				ObjDel("B3ShOpn");
				ObjDel("B3VhLot");
			}
		}
		if(displayLines)
		{	if(BEbasket>0)
			{	if(ObjectFind("B3LBELn")==-1)CreateLine("B3LBELn",DodgerBlue,1,0);
				ObjectMove("B3LBELn",0,Time[1],BEbasket);
			}
			else ObjDel("B3LBELn");
			if(TPa>0)
			{	if(ObjectFind("B3LTPLn")==-1)CreateLine("B3LTPLn",Gold,1,0);
				ObjectMove("B3LTPLn",0,Time[1],TPa);
			}
			else if(TPb>0&&nLots!=0)
			{	if(ObjectFind("B3LTPLn")==-1)CreateLine("B3LTPLn",Gold,1,0);
				ObjectMove("B3LTPLn",0,Time[1],TPb);
			}
			else ObjDel("B3LTPLn");
			if(OPbN>0)
			{	if(ObjectFind("B3LOPLn")==-1)CreateLine("B3LOPLn",Red,1,4);
				ObjectMove("B3LOPLn",0,Time[1],OPbN);
			}
			else ObjDel("B3LOPLn");
			if(bSL>0)
			{	if(ObjectFind("B3LSLbT")==-1)CreateLine("B3LSLbT",Red,1,3);
				ObjectMove("B3LSLbT",0,Time[1],bSL);
			}
			else ObjDel("B3LSLbT");
			if(bTS>0)
			{	if(ObjectFind("B3LTSbT")==-1)CreateLine("B3LTSbT",Gold,1,3);
				ObjectMove("B3LTSbT",0,Time[1],bTS);
			}
			else ObjDel("B3LTSbT");
			if(hActive==1&&BEa>0)
			{	if(ObjectFind("B3LNBEL")==-1)CreateLine("B3LNBEL",Crimson,1,0);
				ObjectMove("B3LNBEL",0,Time[1],BEa);
			}
			else ObjDel("B3LNBEL");
			if(SLb>0||TPbMP>0)
			{	double TSLine,TSBEPoint,TSbSL;
				if(ObjectFind("B3LTSLn")==-1)CreateLine("B3LTSLn",Gold,1,3);
				if(BEa>0)TSBEPoint=BEa;
				else TSBEPoint=BEbasket;
				if(SLb>0)TSbSL=SLb;
				else TSbSL=TPbMP;
				if(nLots>0)TSLine=ND(TSBEPoint+TSbSL*Pip,Digits);
				else if(nLots<0)TSLine=ND(TSBEPoint-TSbSL*Pip,Digits);
				ObjectMove("B3LTSLn",0,Time[1],TSLine);
			}
			else ObjDel("B3LTSLn");
			if(hThisChart&&BEhedge>0)
			{	if(ObjectFind("B3LhBEL")==-1)CreateLine("B3LhBEL",SlateBlue,1,0);
				ObjectMove("B3LhBEL",0,Time[1],BEhedge);
			}
			else ObjDel("B3LhBEL");
			if(hThisChart&&SLh>0)
			{	if(ObjectFind("B3LhSLL")==-1)CreateLine("B3LhSLL",SlateBlue,1,3);
				ObjectMove("B3LhSLL",0,Time[1],SLh);
			}
			else ObjDel("B3LhSLL");
		}
		else
		{	ObjDel("B3LBELn");
			ObjDel("B3LTPLn");
			ObjDel("B3LTSLn");
			ObjDel("B3LhBEL");
			ObjDel("B3LhSLL");
			ObjDel("B3LNBEL");
		}
		if(CCIEntry&&displayCCI)
		{	if(cci_01>0&&cci_11>0)ObjectSetText("B3VCm05","?",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_01<0&&cci_11<0)ObjectSetText("B3VCm05","?",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm05","?",displayFontSize+6,"Wingdings",Orange);
			if(cci_02>0&&cci_12>0)ObjectSetText("B3VCm15","?",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_02<0&&cci_12<0)ObjectSetText("B3VCm15","?",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm15","?",displayFontSize+6,"Wingdings",Orange);
			if(cci_03>0&&cci_13>0)ObjectSetText("B3VCm30","?",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_03<0&&cci_13<0)ObjectSetText("B3VCm30","?",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm30","?",displayFontSize+6,"Wingdings",Orange);
			if(cci_04>0&&cci_14>0)ObjectSetText("B3VCm60","?",displayFontSize+6,"Wingdings",displayColorProfit);
			else if(cci_04<0&&cci_14<0)ObjectSetText("B3VCm60","?",displayFontSize+6,"Wingdings",displayColorLoss);
			else ObjectSetText("B3VCm60","?",displayFontSize+6,"Wingdings",Orange);
		}
		if(Debug)
		{	string dSpace;
			for(y=0;y<=175;y++)dSpace=dSpace+" ";
			string dMess="\n\n"+dSpace+"Ticket   Magic     Type Lots OpenPrice  Costs  Profit  Potential";
			for(y=0;y<OrdersTotal();y++)
			{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))continue;
				if(OrderMagicNumber()!=Magic&&OrderMagicNumber()!=hMagic)continue;
				dMess=(dMess+"\n"+dSpace+" "+OrderTicket()+"  "+DTS(OrderMagicNumber(),0)+"   "+OrderType());
				dMess=(dMess+"   "+DTS(OrderLots(),LotDecimal)+"  "+DTS(OrderOpenPrice(),Digits));
				dMess=(dMess+"     "+DTS(OrderSwap()+OrderCommission(),2));
				dMess=(dMess+"    "+DTS(OrderProfit()+OrderSwap()+OrderCommission(),2));
				if(OrderMagicNumber()!=Magic)continue;
				if(OrderType()==OP_BUY)dMess=(dMess+"      "+DTS(OrderLots()*(TPb-OrderOpenPrice())*PipVal2+OrderSwap()+OrderCommission(),2));
				if(OrderType()==OP_SELL)dMess=(dMess+"      "+DTS(OrderLots()*(OrderOpenPrice()-TPb)*PipVal2+OrderSwap()+OrderCommission(),2));
			}
			if(!dLabels)
			{	dLabels=true;
				CreateLabel("B3LPipV","Pip Value",0,2,0,0);
				CreateLabel("B3VPipV","",0,2,100,0);
				CreateLabel("B3LDigi","Digits Value",0,2,0,1);
				CreateLabel("B3VDigi","",0,2,100,1);
				ObjSetTxt("B3VDigi",DTS(Digits,0));
				CreateLabel("B3LPoin","Point Value",0,2,0,2);
				CreateLabel("B3VPoin","",0,2,100,2);
				ObjSetTxt("B3VPoin",DTS(Point,Digits));
				CreateLabel("B3LSprd","Spread Value",0,2,0,3);
				CreateLabel("B3VSprd","",0,2,100,3);
				CreateLabel("B3LBid","Bid Value",0,2,0,4);
				CreateLabel("B3VBid","",0,2,100,4);
				CreateLabel("B3LAsk","Ask Value",0,2,0,5);
				CreateLabel("B3VAsk","",0,2,100,5);
				CreateLabel("B3LLotP","Lot Step",0,2,200,0);
				CreateLabel("B3VLotP","",0,2,300,0);
				ObjSetTxt("B3VLotP",DTS(MarketInfo(Symbol(),MODE_LOTSTEP),LotDecimal));
				CreateLabel("B3LLotX","Lot Max",0,2,200,1);
				CreateLabel("B3VLotX","",0,2,300,1);
				ObjSetTxt("B3VLotX",DTS(MarketInfo(Symbol(),MODE_MAXLOT),0));
				CreateLabel("B3LLotN","Lot Min",0,2,200,2);
				CreateLabel("B3VLotN","",0,2,300,2);
				ObjSetTxt("B3VLotN",DTS(MarketInfo(Symbol(),MODE_MINLOT),LotDecimal));
				CreateLabel("B3LLotD","Lot Decimal",0,2,200,3);
				CreateLabel("B3VLotD","",0,2,300,3);
				ObjSetTxt("B3VLotD",DTS(LotDecimal,0));
				CreateLabel("B3LAccT","Account Type",0,2,200,4);
				CreateLabel("B3VAccT","",0,2,300,4);
				ObjSetTxt("B3VAccT",DTS(AccountType,0));
				CreateLabel("B3LPnts","Pip",0,2,200,5);
				CreateLabel("B3VPnts","",0,2,300,5);
				ObjSetTxt("B3VPnts",DTS(Pip,Digits));
				CreateLabel("B3LTicV","Tick Value",0,2,400,0);
				CreateLabel("B3VTicV","",0,2,500,0);
				CreateLabel("B3LTicS","Tick Size",0,2,400,1);
				CreateLabel("B3VTicS","",0,2,500,1);
				ObjSetTxt("B3VTicS",DTS(MarketInfo(Symbol(),MODE_TICKSIZE),Digits));
				CreateLabel("B3LLev","Leverage",0,2,400,2);
				CreateLabel("B3VLev","",0,2,500,2);
				ObjSetTxt("B3VLev",DTS(AccountLeverage(),0)+":1");
				CreateLabel("B3LSGTF","SmartGrid",0,2,400,3);
				if(UseSmartGrid)CreateLabel("B3VSGTF","True",0,2,500,3);
				else CreateLabel("B3VSGTF","False",0,2,500,3);
				CreateLabel("B3LCOTF","Close Oldest",0,2,400,4);
				if(UseCloseOldest)CreateLabel("B3VCOTF","True",0,2,500,4);
				else CreateLabel("B3VCOTF","False",0,2,500,4);
				CreateLabel("B3LUHTF","Hedge",0,2,400,5);
				if(UseHedge&&HedgeTypeDD)CreateLabel("B3VUHTF","DrawDown",0,2,500,5);
				else if(UseHedge&&!HedgeTypeDD)CreateLabel("B3VUHTF","Level",0,2,500,5);
				else CreateLabel("B3VUHTF","False",0,2,500,5);
			}
			ObjSetTxt("B3VPipV",DTS(PipValue,2));
			ObjSetTxt("B3VSprd",DTS(Ask-Bid,Digits));
			ObjSetTxt("B3VBid",DTS(Bid,Digits));
			ObjSetTxt("B3VAsk",DTS(Ask,Digits));
			ObjSetTxt("B3VTicV",DTS(MarketInfo(Symbol(),MODE_TICKVALUE),Digits));
		}
		if(EmergencyWarning)
		{	if(ObjectFind("B3LClos")==-1)CreateLabel("B3LClos","",5,0,0,23,displayColorLoss);
			ObjSetTxt("B3LClos","WARNING: EmergencyCloseAll is set to TRUE",5,displayColorLoss);
		}
		else if(ShutDown)
		{	if(ObjectFind("B3LClos")==-1)CreateLabel("B3LClos","",5,0,0,23,displayColorLoss);
			ObjSetTxt("B3LClos","Blessing will stop trading when this basket closes.",5,displayColorLoss);
		}
		else if(HolShutDown!=1)ObjDel("B3LClos");
	}
	FirstRun=false;
	Comment(CS,dMess);
	return(0);
}


// add by wujie.duan
/**
 * @brief 检查手数的正确性(Check Lot Size Funtion)
 * 
 *
 * @return 
 * @param Lot
 */
double iLotSize(double Lot)
{	
	Lot=ND(Lot,LotDecimal);
	Lot=MathMin(Lot,MarketInfo(Symbol(),MODE_MAXLOT));
	Lot=MathMax(Lot,MinLotSize);
	return(Lot);
}

//+-----------------------------------------------------------------+
//| Open Order Funtion                                              |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *

 * @param OSymbol : 货币对
 * @param OCmd    : Operation type for the OrderSend(),
 * 					OP_BUY,
 * 					OP_SELL,
 * 					OP_BUYLIMIT,
 * 					OP_SELLLIMIT,
 * 					OP_SELLSTOP,
 * 					OP_BUYSTOP,
 * @param OLot    : Number of lots
 * @param OPrice  : Order price.
 * @param OSlip   : Maximum price slippage for buy or sell orders.
 * @param OMagic  : Order magic number. May be used as user defined identifier
 * @param OColor  : Color of the opening arrow on the chart. 
 *					If parameter is missing or has CLR_NONE value opening arrow is not drawn on the chart.
 * @return        : 成功，返回订单编号
 */
int SendOrder(string OSymbol,int OCmd,double OLot,double OPrice,double OSlip,int OMagic,color OColor=CLR_NONE)
{	
	if(FirstRun)
		return(-1);
	int Ticket;
	int retryTimes=5,i=0;
	int OType=MathMod(OCmd,2);
	double OrderPrice;
	if(AccountFreeMarginCheck(OSymbol,OType,OLot)<=0)/*钱不够了，不能开单了*/
		return(-1);
	if(MaxSpread>0&&MarketInfo(OSymbol,MODE_SPREAD)*Point/Pip>MaxSpread)/* 差价点数太高也不允许开单*/
		return(-1);
	while(i<5)
	{	
		i+=1;
		while(IsTradeContextBusy())
			Sleep(100);
		if(IsStopped())
			return(-1);
		if(OType==0) /*OP_BUY,OP_BUYLIMIT,OP_BUYSTOP */
			OrderPrice=ND(MarketInfo(OSymbol,MODE_ASK)+OPrice,MarketInfo(OSymbol,MODE_DIGITS));
		else /*OP_SELL,OP_SELLLIMIT,OP_SELLSTOP */
			OrderPrice=ND(MarketInfo(OSymbol,MODE_BID)+OPrice,MarketInfo(OSymbol,MODE_DIGITS));
		Ticket=OrderSend(OSymbol,OCmd,OLot,OrderPrice,OSlip,0,0,TradeComment,OMagic,0,OColor);
		if(Ticket<0)
		{	
			Error=GetLastError();
			if(Error!=0)Print("Error opening order: "+Error+" "+ErrorDescription(Error)
				+" Symbol: "+OSymbol
				+" TradeOP: "+OCmd
				+" OType: "+OType
				+" Ask: "+MarketInfo(OSymbol,MODE_ASK)
				+" Bid: "+MarketInfo(OSymbol,MODE_BID)
				+" OPrice: "+DTS(OPrice,Digits)
				+" Price: "+DTS(OrderPrice,Digits)
				+" Lots: "+DTS(OLot,2)
				);
			switch(Error)
			{	case ERR_OFF_QUOTES:
				case ERR_INVALID_PRICE:
					Sleep(5000);
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY:
					i++;
					break;
				case 149://ERR_TRADE_HEDGE_PROHIBITED:
					UseHedge=false;
					if(Debug)Print("Hedge trades are not allowed on this pair");
					i=retryTimes;
					break;
				default:
					i=retryTimes;
			}
		}
		else
		{	
			TryPlaySounds();
			break;
		}
	}
	return(Ticket);
}

//+-----------------------------------------------------------------+
//| Modify Order Function                                           |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 修改订单
 * 
 *
 * @param OrderOP:订单的开仓价格
 * @param OrderSL:订单的止损
 * @param Color
 * @return 
 */
bool ModifyOrder(double OrderOP,double OrderSL,color Color=CLR_NONE)
{	bool Success=false;
	int retryTimes=5,i=0;
	while(i<5&&!Success)
	{	i+=1;
		while(IsTradeContextBusy())Sleep(100);
		if(IsStopped())return(-1);
		Success=OrderModify(OrderTicket(),OrderOP,OrderSL,0,0,Color);
		if(!Success)
		{	Error=GetLastError();
			if(Error>0)
				Print(" Error Modifying Order:",OrderTicket(),", ",Error," :" +ErrorDescription(Error),", Ask:",Ask,
					", Bid:",Bid," OrderPrice: ",OrderOP," StopLevel: ",StopLevel,", SL: ",OrderSL,", OSL: ",OrderStopLoss());
			else Success=true;
			switch(Error)
			{	case ERR_NO_ERROR:
				case ERR_NO_RESULT:
					i=retryTimes;
					break;
				case ERR_TRADE_MODIFY_DENIED:
					Sleep(10000);
				case ERR_OFF_QUOTES:
				case ERR_INVALID_PRICE:
					Sleep(5000);
				case ERR_PRICE_CHANGED:
				case ERR_REQUOTE:
					RefreshRates();
				case ERR_SERVER_BUSY:
				case ERR_NO_CONNECTION:
				case ERR_BROKER_BUSY:
				case ERR_TRADE_CONTEXT_BUSY:
				case ERR_TRADE_TIMEOUT:
					i+=1;
					break;
				default:
					i=retryTimes;
					break;
			}
		}
		else break;
	}
	return(Success);
}

//+-------------------------------------------------------------------------+
//| Exit Trade Function - Type: All Basket Hedge Ticket Pending             |
//+-------------------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Color
 * @return 
 * @param OTicket
 * @param Reason
 * @param Type
 */
int ExitTrades(int Type,color Color,string Reason,int OTicket=0)
{	if(FirstRun&&!EmergencyCloseAll)return(-1);
	static int OTicketNo;
	bool Success;
	int Tries,Closed,CloseCount;
	int CloseTrades[,2];
	double OPrice;
	string s;
	ca=Type;
	if(Type==T)
	{	if(OTicket==0)OTicket=OTicketNo;
		else OTicketNo=OTicket;
	}
	for(y=OrdersTotal()-1;y>=0;y--)
	{	if(!OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
			continue;
		if(Type==B&&OrderMagicNumber()!=Magic)
			continue;
		else if(Type==H&&OrderMagicNumber()!=hMagic)
			continue;
		else if(Type==A&&OrderMagicNumber()!=Magic&&OrderMagicNumber()!=hMagic)
			continue;
		else if(Type==T&&OrderTicket()!=OTicket)
			continue;
		else if(Type==P&&(OrderMagicNumber()!=Magic||OrderType()<=OP_SELL))
			continue;
		ArrayResize(CloseTrades,CloseCount+1);
		CloseTrades[CloseCount,0]=OrderOpenTime();
		CloseTrades[CloseCount,1]=OrderTicket();
		CloseCount++;
	}
	if(CloseCount>0)
	{	if(!UseFIFO)
			ArraySort(CloseTrades,WHOLE_ARRAY,0,MODE_DESCEND);
		else if(CloseCount!=ArraySort(CloseTrades))
			Print("Error sorting CloseTrades Array");
		for(y=0;y<CloseCount;y++)
		{	if(!OrderSelect(CloseTrades[y,1],SELECT_BY_TICKET))
				continue;
			while(IsTradeContextBusy())
				Sleep(100);
			if(IsStopped())
				return(-1);
			if(!OrderSelect(CloseTrades[y,1],SELECT_BY_TICKET))continue;
			if(OrderType()>OP_SELL)Success=OrderDelete(OrderTicket(),Color);
			else
			{	if(OrderType()==OP_BUY)OPrice=ND(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS));
				else OPrice=ND(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS));
				Success=OrderClose(OrderTicket(),OrderLots(),OPrice,slip,Color);
			}
			if(Success)Closed++;
			else
			{	Error=GetLastError();Print("Order ",OrderTicket()," failed to close. Error:",ErrorDescription(Error));
				switch(Error)
				{	case ERR_NO_ERROR:
					case ERR_NO_RESULT:
						Success=true;
						break;
					case ERR_OFF_QUOTES:
					case ERR_INVALID_PRICE:
						Sleep(5000);
					case ERR_PRICE_CHANGED:
					case ERR_REQUOTE:
						RefreshRates();
					case ERR_SERVER_BUSY:
					case ERR_NO_CONNECTION:
					case ERR_BROKER_BUSY:
					case ERR_TRADE_CONTEXT_BUSY:
						Print("Try: "+(Tries+1)+" of 5: Order ",OrderTicket()," failed to close. Error:",ErrorDescription(Error));
						Tries++;
						break;
					case ERR_TRADE_TIMEOUT:
					default:
						Print("Try: "+(Tries+1)+" of 5: Order ",OrderTicket()," failed to close. Fatal Error:",ErrorDescription(Error));
						Tries=5;
						ca=0;
						break;
				}
			}
		}
		if(Closed==CloseCount)ca=0;
	}
	else ca=0;
	if(Closed>0)
	{	if(Closed!=1)s="s";
		Print("Closed "+Closed+" position"+s+" because ",Reason);
		TryPlaySounds();
	}
	return(Closed);
}

//+-----------------------------------------------------------------+
//| Find Hedge Profit                                               |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @return 
 * @param Type
 */
double FindClosedPL(int Type)
{	
    double ClosedProfit;
	if(Type==B&&UseCloseOldest)
        CbC=0;
	if(OpenTimeBasketFirst>0)
	{	for(y=OrdersHistoryTotal()-1;y>=0;y--)
		{	if(!OrderSelect(y,SELECT_BY_POS,MODE_HISTORY))
                continue;
			if(OrderOpenTime()<OpenTimeBasketFirst)
                continue;
			if(Type==B && OrderMagicNumber()==Magic && OrderType()<=OP_SELL)
			{	
                ClosedProfit+=OrderProfit()+OrderSwap()+OrderCommission();
				CbC++;
			}
			if(Type==H&&OrderMagicNumber()==hMagic)
                ClosedProfit+=OrderProfit()+OrderSwap()+OrderCommission();
		}
	}
	return(ClosedProfit);
}

//+-----------------------------------------------------------------+
//| Check Correlation                                               |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @return 
 */
double CheckCorr()
{	double BaseDiff,HedgeDiff,BasePow,HedgePow,Mult;
	for(y=CorrPeriod-1;y>=0;y--)
	{	BaseDiff=iClose(Symbol(),1440,y)-iMA(Symbol(),1440,CorrPeriod,0,MODE_SMA,PRICE_CLOSE,y);
		HedgeDiff=iClose(HedgeSymbol,1440,y)-iMA(HedgeSymbol,1440,CorrPeriod,0,MODE_SMA,PRICE_CLOSE,y);
		Mult+=BaseDiff*HedgeDiff;
		BasePow+=MathPow(BaseDiff,2);
		HedgePow+=MathPow(HedgeDiff,2);
	}
	if(BasePow*HedgePow>0)return(Mult/MathSqrt(BasePow*HedgePow));
	else return(0);
}

//+------------------------------------------------------------------+
//|  Save Equity / Balance Statistics                                |
//+------------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Balance
 * @param DrawDown
 * @param IsTick
 * @param NewFile
 */
void Stats(bool NewFile,bool IsTick,double Balance,double DrawDown)
{	double Equity=Balance+DrawDown;
	datetime TimeNow=TimeCurrent();
	if(IsTick)
	{	if(Equity<StatLowEquity)StatLowEquity=Equity;
		if(Equity>StatHighEquity)StatHighEquity=Equity;
	}
	else
	{	while(TimeNow>=NextStats)NextStats+=StatsPeriod;
		int StatHandle;
		if(NewFile)
		{	StatHandle=FileOpen(StatFile,FILE_WRITE|FILE_CSV,',');
			Print("Stats "+StatFile+" "+StatHandle);
			FileWrite(StatHandle,"Date","Time","Balance","Equity Low","Equity High",TradeComment);
		}
		else
		{	StatHandle=FileOpen(StatFile,FILE_READ|FILE_WRITE|FILE_CSV,',');
			FileSeek(StatHandle,0,SEEK_END);
		}
		if(StatLowEquity==0)
		{	StatLowEquity=Equity;
			StatHighEquity=Equity;
		}
		FileWrite(StatHandle,TimeToStr(TimeNow,TIME_DATE),TimeToStr(TimeNow,TIME_SECONDS),DTS(Balance,0),DTS(StatLowEquity,0),DTS(StatHighEquity,0));
		FileClose(StatHandle);
		StatLowEquity=Equity;
		StatHighEquity=Equity;
	}
}


// add by wujie.duan
/**
 * @brief 生成魔数(Generate the magic number) 
 * 
 *
 * @return 
 */
int GenerateMagicNumber()
{	if(EANumber>99)return(EANumber);
	return(JenkinsHash(EANumber+"_"+Symbol()+"__"+Period()));
}

// add by wujie.duan
/**
 * @brief 生成hash值，用于生成魔数
 * 
 *
 * @param Input
 * @return 
 */
int JenkinsHash(string Input)
{	
	int Magic;
	for(y=0;y<StringLen(Input);y++){	
		Magic+=StringGetChar(Input,y);
		Magic+=(Magic<<10);
		Magic^=(Magic>>6);
	}
	Magic+=(Magic<<3);
	Magic^=(Magic>>11);
	Magic+=(Magic<<15);
	Magic=MathAbs(Magic);
	return(Magic);
}

//+-----------------------------------------------------------------+
//|                                                 |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 格式化浮点数
 * 
 *
 * @param Value:要格式的值
 * @param Precision:精度
 * @return 
 */
double ND(double Value,int Precision)
{
	return(NormalizeDouble(Value,Precision));
}

//+-----------------------------------------------------------------+
//|                                             |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 将double类型转换成String  
 * 
 * 
 * @param Value:要转换的浮点数
 * @param Precision:精度
 * @return 
 */
string DTS(double Value,int Precision)
{
	return(DoubleToStr(Value,Precision));
}

//+-----------------------------------------------------------------+
//| Create Label Function (OBJ_LABEL ONLY)                          |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Colour
 * @param Corner
 * @param Font
 * @param FontSize
 * @param Name
 * @param Text
 * @param XOffset
 * @param YLine
 */
void CreateLabel(string Name,string Text,int FontSize,int Corner,int XOffset,double YLine,color Colour=CLR_NONE,string Font="Arial Bold")
{	int XDistance,YDistance;
	FontSize+=displayFontSize;
	YDistance=displayYcord+displaySpacing*YLine;
	if(Corner==0)XDistance=displayXcord+(XOffset*displayFontSize/9*displayRatio);
	else if(Corner==1)XDistance=displayCCIxCord+XOffset*displayRatio;
	else if(Corner==2)XDistance=displayXcord+(XOffset*displayFontSize/9*displayRatio);
	else if(Corner==3)
	{	XDistance=XOffset*displayRatio;
		YDistance=YLine;
	}
	else if(Corner==5)
	{	XDistance=XOffset*displayRatio;
		YDistance=14*YLine;
		Corner=1;
	}
	if(Colour==CLR_NONE)Colour=displayColor;
	ObjectCreate(Name,OBJ_LABEL,0,0,0);
	ObjectSetText(Name,Text,FontSize,Font,Colour);
	ObjectSet(Name,OBJPROP_CORNER,Corner);
	ObjectSet(Name,OBJPROP_XDISTANCE,XDistance);
	ObjectSet(Name,OBJPROP_YDISTANCE,YDistance);
}





//+-----------------------------------------------------------------+
//| Create Line Function (OBJ_HLINE ONLY)                           |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Colour
 * @param Name
 * @param Style
 * @param Width
 */
void CreateLine(string Name,color Colour,int Width,int Style)
{	ObjectCreate(Name,OBJ_HLINE,0,0,0);
	ObjectSet(Name,OBJPROP_COLOR,Colour);
	ObjectSet(Name,OBJPROP_WIDTH,Width);
	ObjectSet(Name,OBJPROP_STYLE,Style);
}

//+------------------------------------------------------------------+
//| Draw Label Function (OBJ_LABEL ONLY)                             |
//+------------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Colour
 * @param Decimal
 * @param Name
 * @param Value
 * @param XOffset
 */
void DrawLabel(string Name,double Value,int XOffset,int Decimal=2,color Colour=CLR_NONE)
{	int dDigits;
	dDigits=Digit[ArrayBsearch(Digit,Value,WHOLE_ARRAY,0,MODE_ASCEND),1];
	ObjectSet(Name,OBJPROP_XDISTANCE,displayXcord+(XOffset-7*dDigits)*displayFontSize/9*displayRatio);
	ObjSetTxt(Name,DTS(Value,Decimal),0,Colour);
}

//+-----------------------------------------------------------------+
//| Object Set Function                                             |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Name
 * @param XCoord
 */
void ObjSet(string Name,int XCoord){ObjectSet(Name,OBJPROP_XDISTANCE,displayXcord+XCoord*displayFontSize/9*displayRatio);}

//+-----------------------------------------------------------------+
//| Object Set Text Function                                        |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Colour
 * @param FontSize
 * @param Name
 * @param Text
 */
void ObjSetTxt(string Name,string Text,int FontSize=0,color Colour=CLR_NONE)
{	FontSize+=displayFontSize;
	if(Colour==CLR_NONE)Colour=displayColor;
	ObjectSetText(Name,Text,FontSize,"Arial Bold",Colour);
}

//+------------------------------------------------------------------+
//| Delete Overlay Label Function                                    |
//+------------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 */
void LabelDelete(){for(y=ObjectsTotal();y>=0;y--){if(StringSubstr(ObjectName(y),0,2)=="B3")ObjectDelete(ObjectName(y));}}

//+------------------------------------------------------------------+
//| Delete Object Function                                           |
//+------------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 * @param Name
 */
void ObjDel(string Name){
        if(ObjectFind(Name)!=-1)
                ObjectDelete(Name);
}

//+-----------------------------------------------------------------+
//| Create Object List Function                                     |
//+-----------------------------------------------------------------+
// add by wujie.duan
/**
 * @brief 
 * 
 *
 */
void LabelCreate()
{	if(displayOverlay&&((Testing&&Visual)||!Testing))
	{	int dDigits;
		string ObjText;
		color ObjClr;
		CreateLabel("B3LMNum","Magic: ",8-displayFontSize,5,59,1,displayColorFGnd,"Tahoma");
		CreateLabel("B3VMNum",DTS(Magic,0),8-displayFontSize,5,5,1,displayColorFGnd,"Tahoma");
		CreateLabel("B3LComm","Trade Comment: "+TradeComment,8-displayFontSize,5,5,1.8,displayColorFGnd,"Tahoma");
		if(displayLogo)
		{	CreateLabel("B3LLogo","Q",27,3,10,10,Crimson,"Wingdings");
			CreateLabel("B3LCopy","?"+DTS(Year(),0)+", J Talon LLC/FiFtHeLeMeNt",10-displayFontSize,3,5,3,Silver,"Arial");
		}
		CreateLabel("B3LTime","Broker Time is:",0,0,0,0);
		CreateLabel("B3VTime","",0,0,125,0);
		CreateLabel("B3Line1","=========================",0,0,0,1);
		CreateLabel("B3LEPPC","Equity Protection % Set:",0,0,0,2);
		dDigits=Digit[ArrayBsearch(Digit,MaxDrawDownPercentage,WHOLE_ARRAY,0,MODE_ASCEND),1];
		CreateLabel("B3VEPPC",DTS(MaxDrawDownPercentage,2),0,0,167-7*dDigits,2);
		CreateLabel("B3PEPPC","%",0,0,193,2);
		CreateLabel("B3LSTPC","Stop Trade % Set:",0,0,0,3);
		dDigits=Digit[ArrayBsearch(Digit,StopTradePercent*100,WHOLE_ARRAY,0,MODE_ASCEND),1];
		CreateLabel("B3VSTPC",DTS(StopTradePercent*100,2),0,0,167-7*dDigits,3);
		CreateLabel("B3PSTPC","%",0,0,193,3);
		CreateLabel("B3LSTAm","Stop Trade Amount:",0,0,0,4);
		CreateLabel("B3VSTAm","",0,0,167,4,displayColorLoss);
		CreateLabel("B3LAPPC","Account Portion:",0,0,0,5);
		dDigits=Digit[ArrayBsearch(Digit,PortionPercentage*100,WHOLE_ARRAY,0,MODE_ASCEND),1];
		CreateLabel("B3VAPPC",DTS(PortionPercentage*100,2),0,0,167-7*dDigits,5);
		CreateLabel("B3PAPPC","%",0,0,193,5);
		CreateLabel("B3LPBal","Portion Balance:",0,0,0,6);
		CreateLabel("B3VPBal","",0,0,167,6);
		CreateLabel("B3LAPCR","Account % Risked:",0,0,228,6);
		CreateLabel("B3VAPCR",DTS(MaxDrawDownPercentage*PortionPercentage,2),0,0,347,6);
		CreateLabel("B3PAPCR","%",0,0,380,6);
		if(UseMM)
		{	ObjText="Money Management is On";
			ObjClr=displayColorProfit;
		}
		else
		{	ObjText="Money Management is Off";
			ObjClr=displayColorLoss;
		}
		CreateLabel("B3LMMOO",ObjText,0,0,0,7,ObjClr);
		if(UsePowerOutSL)
		{	ObjText="Power Off Stop Loss is On";
			ObjClr=displayColorProfit;
		}
		else
		{	ObjText="Power Off Stop Loss is Off";
			ObjClr=displayColorLoss;
		}
		CreateLabel("B3LPOSL",ObjText,0,0,0,8,ObjClr);
		CreateLabel("B3LDrDn","Draw Down %:",0,0,228,8);
		CreateLabel("B3VDrDn","",0,0,315,8);
		if(UseHedge)
		{	if(HedgeTypeDD)
			{	CreateLabel("B3LhDDn","Hedge",0,0,190,8);
				CreateLabel("B3ShDDn","/",0,0,342,8);
				CreateLabel("B3VhDDm","",0,0,347,8);
			}
			else
			{	CreateLabel("B3LhLvl","Hedge Level:",0,0,228,9);
				CreateLabel("B3VhLvl","",0,0,318,9);
				CreateLabel("B3ShLvl","/",0,0,328,9);
				CreateLabel("B3VhLvT","",0,0,333,9);
			}
		}
		CreateLabel("B3Line2","======================",0,0,0,9);
		CreateLabel("B3LSLot","Starting Lot Size:",0,0,0,10);
		CreateLabel("B3VSLot","",0,0,130,10);
		if(MaximizeProfit)
		{	ObjText="Profit Maximizer is On";
			ObjClr=displayColorProfit;
		}
		else
		{	ObjText="Profit Maximizer is Off";
			ObjClr=displayColorLoss;
		}
		CreateLabel("B3LPrMx",ObjText,0,0,0,11,ObjClr);
		CreateLabel("B3LBask","Basket",0,0,200,11);
		CreateLabel("B3LPPot","Profit Potential:",0,0,30,12);
		CreateLabel("B3VPPot","",0,0,190,12);
		CreateLabel("B3LPrSL","Profit Trailing Stop:",0,0,30,13);
		CreateLabel("B3VPrSL","",0,0,190,13);
		CreateLabel("B3LPnPL","Portion P/L / Pips:",0,0,30,14);
		CreateLabel("B3VPnPL","",0,0,190,14);
		CreateLabel("B3SPnPL","/",0,0,220,14);
		CreateLabel("B3VPPip","",0,0,229,14);
		CreateLabel("B3LPLMM","Profit/Loss Max/Min:",0,0,30,15);
		CreateLabel("B3VPLMx","",0,0,190,15);
		CreateLabel("B3SPLMM","/",0,0,220,15);
		CreateLabel("B3VPLMn","",0,0,225,15);
		CreateLabel("B3LOpen","Open Trades / Lots:",0,0,30,16);
		CreateLabel("B3LType","",0,0,170,16);
		CreateLabel("B3VOpen","",0,0,207,16);
		CreateLabel("B3SOpen","/",0,0,220,16);
		CreateLabel("B3VLots","",0,0,229,16);
		CreateLabel("B3LMvTP","Move TP by:",0,0,0,17);
		CreateLabel("B3VMvTP",DTS(MoveTP/Pip,0),0,0,100,17);
		CreateLabel("B3LMves","# Moves:",0,0,150,17);
		CreateLabel("B3VMove","",0,0,229,17);
		CreateLabel("B3SMves","/",0,0,242,17);
		CreateLabel("B3VMves",DTS(TotalMoves,0),0,0,249,17);
		CreateLabel("B3LMxDD","Max DD:",0,0,0,18);
		CreateLabel("B3VMxDD","",0,0,107,18);
		CreateLabel("B3LDDPC","Max DD %:",0,0,150,18);
		CreateLabel("B3VDDPC","",0,0,229,18);
		CreateLabel("B3PDDPC","%",0,0,257,18);
		if(ForceMarketCond<3)CreateLabel("B3LFMCn","Market trend is forced",0,0,0,19);
		CreateLabel("B3LTrnd","",0,0,0,20);
		if(CCIEntry>0&&displayCCI)
		{	CreateLabel("B3LCCIi","CCI",2,1,12,1);
			CreateLabel("B3LCm05","m5",2,1,25,2.2);
			CreateLabel("B3VCm05","?",6,1,0,2,Orange,"Wingdings");
			CreateLabel("B3LCm15","m15",2,1,25,3.4);
			CreateLabel("B3VCm15","?",6,1,0,3.2,Orange,"Wingdings");
			CreateLabel("B3LCm30","m30",2,1,25,4.6);
			CreateLabel("B3VCm30","?",6,1,0,4.4,Orange,"Wingdings");
			CreateLabel("B3LCm60","h1",2,1,25,5.8);
			CreateLabel("B3VCm60","?",6,1,0,5.6,Orange,"Wingdings");
		}
		if(UseHolidayShutdown)
		{	CreateLabel("B3LHols","Next Holiday Period",0,0,240,2);
			CreateLabel("B3LHolD","From: (yyyy.mm.dd) To:",0,0,232,3);
			CreateLabel("B3VHolF","",0,0,232,4);
			CreateLabel("B3VHolT","",0,0,300,4);
		}
	}
	return;
}

//+-----------------------------------------------------------------+
//| expert end function                                             |
//+-----------------------------------------------------------------+

void TryPlaySounds()
{
	if(PlaySounds)
		PlaySound(AlertSound);
}
