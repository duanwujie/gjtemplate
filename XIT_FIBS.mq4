//+------------------------------------------------------------------+
//|                                                    XIT_FIBS.mq4  |
//|                         Copyright ?2011, Jeff West - Forex-XIT  |
//|                                        http://www.forex-xit.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2011, Jeff West - Forex-XIT"
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
         //ObjectCreate("XIT_FIBO",OBJ_FIBO,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
         ObjectCreate("XIT_FIBO",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
         color levelColor = Red;
      }
      else{
         WindowRedraw();
         //ObjectCreate("XIT_FIBO",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
         ObjectCreate("XIT_FIBO",OBJ_FIBO,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
         levelColor = Green;
      }
      
      double fiboPrice1=ObjectGet("XIT_FIBO",OBJPROP_PRICE1);
      double fiboPrice2=ObjectGet("XIT_FIBO",OBJPROP_PRICE2);
      
      double fiboPriceDiff = fiboPrice2-fiboPrice1;
      string fiboValue0 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.0,Digits);
      string fiboValue9 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.09,Digits);
      string fiboValue14 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.146,Digits);
      
      string fiboValue23 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.236,Digits);
      string fiboValue38 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.382,Digits);
      string fiboValue50 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.50,Digits);
      string fiboValue61 = DoubleToStr(fiboPrice2-fiboPriceDiff*0.618,Digits);
      string fiboValue100 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.0,Digits);
      //string fiboValue127 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.27,Digits);
      //string fiboValue161 = DoubleToStr(fiboPrice2-fiboPriceDiff*1.618,Digits);
    
     ObjectSet("XIT_FIBO",OBJPROP_FIBOLEVELS,8);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+0,0.0);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+1,0.236);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+2,0.382);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+3,0.50);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+4,0.618);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+5,1.0);
     
     
     

     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+6,0.09);
     ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+7,0.146);
     //ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+8,1.27);
     //ObjectSet("XIT_FIBO",OBJPROP_FIRSTLEVEL+9,1.618);

      
     
     ObjectSet("XIT_FIBO",OBJPROP_LEVELCOLOR,levelColor);
     ObjectSet("XIT_FIBO",OBJPROP_LEVELWIDTH,1);
     ObjectSet("XIT_FIBO",OBJPROP_LEVELSTYLE,STYLE_DASHDOTDOT);
     ObjectSetFiboDescription( "XIT_FIBO", 0,fiboValue0+" --> 0.0%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 1,fiboValue23+" --> 23.6%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 2,fiboValue38+" --> 38.2%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 3,fiboValue50+" --> 50.0%");
     ObjectSetFiboDescription( "XIT_FIBO", 4,fiboValue61+" --> 61.8%");
     ObjectSetFiboDescription( "XIT_FIBO", 5,fiboValue100+" --> 100.0%");
   
     ObjectSetFiboDescription( "XIT_FIBO", 6,fiboValue9+" --> 0.09%"); 
     ObjectSetFiboDescription( "XIT_FIBO", 7,fiboValue14+" --> 14.6%");
     //ObjectSetFiboDescription( "XIT_FIBO", 8,fiboValue127+" --> 127.1%");
     //ObjectSetFiboDescription( "XIT_FIBO", 9,fiboValue161+" --> 161.8%");

//----
   return(0);
  }
//+------------------------------------------------------------------+