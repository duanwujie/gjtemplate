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
ObjectDelete("XIT_FIBOTIME");
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
ObjectDelete("XIT_FIBOTIME");
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
         ObjectCreate("XIT_FIBOTIME",OBJ_FIBOTIMES,0,highTime,High[fibHigh],lowTime,Low[fibLow]);
         color levelColor = Red;
      }
      else{
         WindowRedraw();
         //ObjectCreate("XIT_FIBO",OBJ_FIBO,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
         ObjectCreate("XIT_FIBOTIME",OBJ_FIBOTIMES,0,lowTime,Low[fibLow],highTime,High[fibHigh]);
         levelColor = Yellow;
      }
      

     ObjectSet("XIT_FIBOTIME",OBJPROP_FIBOLEVELS,5);
     ObjectSet("XIT_FIBOTIME",OBJPROP_FIRSTLEVEL+0,0.0);
     ObjectSet("XIT_FIBOTIME",OBJPROP_FIRSTLEVEL+1,1.0);
     ObjectSet("XIT_FIBOTIME",OBJPROP_FIRSTLEVEL+2,1.618);
     ObjectSet("XIT_FIBOTIME",OBJPROP_FIRSTLEVEL+3,2.618);
     ObjectSet("XIT_FIBOTIME",OBJPROP_FIRSTLEVEL+4,4.618);

      
     
     ObjectSet("XIT_FIBOTIME",OBJPROP_LEVELCOLOR,levelColor);
     ObjectSet("XIT_FIBOTIME",OBJPROP_LEVELWIDTH,1);
     ObjectSet("XIT_FIBOTIME",OBJPROP_LEVELSTYLE,STYLE_DASHDOTDOT);
     ObjectSetFiboDescription( "XIT_FIBOTIME", 0,"0");
     ObjectSetFiboDescription( "XIT_FIBOTIME", 1,"1");
     ObjectSetFiboDescription( "XIT_FIBOTIME", 2,"1.618");
     ObjectSetFiboDescription( "XIT_FIBOTIME", 3,"2.618");
     ObjectSetFiboDescription( "XIT_FIBOTIME", 4,"4.618");




//----
   return(0);
  }
//+------------------------------------------------------------------+