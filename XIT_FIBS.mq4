//+------------------------------------------------------------------+
//|                                                    XIT_FIBS.mq4  |
//|                         Copyright © 2011, Jeff West - Forex-XIT  |
//|                                        http://www.forex-xit.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Jeff West - Forex-XIT"
#property link      "http://www.forex-xit.com"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
ObjectDelete("XIT_FIBO");
Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
ObjectDelete("XIT_FIBO");
Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  //----

     int fibHigh = iHighest(Symbol(),Period(),MODE_HIGH,WindowFirstVisibleBar()-1,1);
     int fibLow  = iLowest(Symbol(),Period(),MODE_LOW,WindowFirstVisibleBar()-1,1);
     
     datetime highTime = Time[fibHigh];
     datetime lowTime  = Time[fibLow];
     
      if(fibHigh>fibLow){
      WindowRedraw();
      ObjectCreate("XIT_FIBO",OBJ_FIBO,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
      color levelColor = Red;
      }
      else{
      WindowRedraw();
      ObjectCreate("XIT_FIBO",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
      levelColor = Green;
      }
      
      double fiboPrice1=ObjectGet("XIT_FIBO",OBJPROP_PRICE1);
      double fiboPrice2=ObjectGet("XIT_FIBO",OBJPROP_PRICE2);
      
      double fiboPriceDiff = fiboPrice2-fiboPrice1;
      string fiboValue0 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.0,Digits);
      string fiboValue23 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.236,Digits);
      string fiboValue38 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.382,Digits);
      string fiboValue50 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.50,Digits);
      string fiboValue61 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.618,Digits);
      string fiboValue100 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.0,Digits);
    
     ObjectSet("XIT_FIBO",OBJPROP_FIBOLEVELS,6);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+0,0.0);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+1,0.236);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+2,0.382);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+3,0.50);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+4,0.618);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+5,1.0);
     
     
     ObjectSet("XIT_FIBO",OBJPROP_LEVELCOLOR,levelColor);
     ObjectSet("XIT_FIBO",OBJPROP_LEVELWIDTH,1);
     ObjectSet("XIT_FIBO",OBJPROP_LEVELSTYLE,STYLE_DASHDOTDOT);
     ObjectSetFiboDescription( "XIT_FIBO", 0,fiboValue0+" --> 0.0%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 1,fiboValue23+" --> 23.6%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 2,fiboValue38+" --> 38.2%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 3,fiboValue50+" --> 50.0%");
     ObjectSetFiboDescription( "XIT_FIBO", 4,fiboValue61+" --> 61.8%");
     ObjectSetFiboDescription( "XIT_FIBO", 5,fiboValue100+" --> 100.0%");
   
   

//----
   return(0);
  }
//+------------------------------------------------------------------+