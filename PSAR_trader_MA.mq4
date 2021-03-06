//+------------------------------------------------------------------+
//|                                                         Vita.mq4 |
//|                            Copyright © 2012, www.FxAutomated.com |
//|                                       http://www.FxAutomated.com |
//|                                              Author: Haibin Guan |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2012, www.FxAutomated.com"
#property link      "http://www.FxAutomated.com"
//PSAR, Parabolic SAR, or parabolic stop and reverse, is a popular indicator that is
// mainly used by traders to determine the future short-term momentum of a given asset.

//---- input parameters
extern string    Visit="www.fxautomated.com for more products";

extern string    SignalsAndManagedAccounts="www.TradingBug.com";
// Fixed lot size; lot size in first trade
extern double    Lots=0.1;
// Sllipage
extern int       Slip=5;
extern string    StopSettings="Set stops below";
//TakeProfit - is an order that closes your trade once it reaches a certain level of profit,
// teh value is expressed in pips. When this pip value is reached, the experd advisor automatically closes the position
extern double    TakeProfit=50;
//StopLoss - is designed to limit an inverstor's loss
// When the stop loss is reached, the Expert Advisor closes the position immediately in order to avoid further losses. 
extern double    StopLoss=50;

extern string    PSARsettings="Parabolic sar settings follow";
//The step of price increment
extern double    Step    =0.001;   //Parabolic setting
//The maximum rate of teh speed of convergence of the indicator with the price, which can influence the sensitivity
extern double    Maximum =0.2;    //Parabolic setting
// If true if an opposite signal is given all trades that had been opened with previous signal will be closed 
extern bool      CloseOnOpposite=true;
extern string    TimeSettings="Set the hour range the EA should trade";
// Start hour to trade
extern int       StartHour=0;
// End hour of trading
extern int       EndHour=23;
//Use Money Management 
//If MM is true, we will calculate the lot size based on the equity, and assign that value to the lots variable. 
//If MM is false, we simply assign the value of lots to the fixed lot size of Lots.
extern bool MoneyManagement = TRUE;
//Predefined risk percentage. if you choose a custom risk setting of 1, you will trade 0.01 micro lot for every 1K in equity size. 
//Thus, with a custom risk setting of 2 and a 10K account size, you will be starting with 0.2 lots, and it will automatically add/subtract 0.01 lot for every $100 in profit/loss.
extern double RiskPercent = 2;
//The decreased amount from total margin if you lose a trade.
extern int DecreaseFactor=3;

//+---------------------------------------+
//+---------------------------------------+
extern int SMA=200;      //Simple Moving Average
extern int EMA1=50;      //Exponential Moving Average
extern int EMA2=7;       //Exponential MOving Average

//+---------------------------------------+
//+---------------------------------------+


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
// init() is called (and executed) after the client terminal start and uploading of historic data, after changing the security and/or the chart period, 
// after program recompliation in MetaEditor, after changing any inpuy parameters from the EA setup window, and changing accounts.
int init()
  {
//----
//Alert - Displays a message in a separate window
   Alert("Visit www.FxAutomated.com for more goodies!");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
// Satrt() is called (and executed) immediately after a new tick comes. 
int start()
  {
//----
// MarketInfo - returns various data about securities listed in the "Market Watch" window
// MODE_DIGITS - Count of digits after decimal point in teh symbol prices. For the current symbol, it is stored in the predefined variable Digits
int digits=MarketInfo("EURUSD",MODE_DIGITS);
int StopMultd=10;
// The maximum difference (in pips) between the expected price (the price the EA tries to enter) and the actual executed price
int Slippage=Slip*StopMultd;
// MagicNumber - unique identrifier with the intention to keep track of orders placed by this EA and not inadvertently making changes to other orders
int MagicNumber1=220101,MagicNumber2=220102,i,closesell=0,closebuy=0;

//------------------------------------------------------------
//NormalizeDouble - Rounding of a floating point number to a specified accuracy
//--- 
//Predefined Variables:
//Digits - Number of digits after decimal point for the current symbol prices

double  TP=NormalizeDouble(TakeProfit*StopMultd,Digits);
double  SL=NormalizeDouble(StopLoss*StopMultd,Digits);

//Ask - The latest known seller's price (ask price) of the current symbol
//Bid - The latest known buyerls price (offer price, bid price) of the current symbol
//Point - The current symbol point value in the quote currency
 

double slb=NormalizeDouble(Ask-SL*Point,Digits);
double sls=NormalizeDouble(Bid+SL*Point,Digits);


double tpb=NormalizeDouble(Ask+TP*Point,Digits);
double tps=NormalizeDouble(Bid-TP*Point,Digits);


//-------------------------------------------------------------------+
//Check open orders
//-------------------------------------------------------------------+
// OrdersTotal - Returns the number of market and pending order 
if(OrdersTotal()>0){
  for(i=1; i<=OrdersTotal(); i++)          // Cycle searching in orders
     {
     // OrderSelect - The function selects an order for further processing
     // bool OrderSelect(
     //     int     index,    // index or order ticket
     //     int     select,   // flag, SELECT_BY_POS (index in the order pool) or SELECT_BY_TICKET (index is order ticket)
     //     int     pool=MODE_TRADES // mode 
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // If the next is available
        {
        // OrderMagicNumber - Returns an identifying number of the current selected order 
          if(OrderMagicNumber()==MagicNumber1) {int halt1=1;}
          if(OrderMagicNumber()==MagicNumber2) {int halt2=1;}

        }
     }
}
//-------------------------------------------------------------------+
// time check
//-------------------------------------------------------------------
// Hour - returns the hour of the last known server time by the moment of the program start

if((Hour()>=StartHour)&&(Hour()<=EndHour))
{
int TradeTimeOk=1;
}
else
{ TradeTimeOk=0; }
//-----------------------------------------------------------------
// Bar checks
//-----------------------------------------------------------------

 
 //-------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Opening criteria
//-----------------------------------------------------------------------------------------------------

Comment("For more goodies, managed accounts, forex signals and premium EAs visit www.FxAutomated.com");

//--------------------------------------------------------
// Moving Average Indicators
//-------------------------------------------------------
//Calcculates the Moving Average indicator and returns its value.
//double  iMA(
//   string       symbol,           // Symbol name on the data of which the indicator will be calculated. NULL means the current symbol.
//   int          timeframe,        // timeframe, it can be any of enumeration values. 0 means the current timeframe (PERIOD_M1,PERIOD_M5,etc)
//   int          ma_period,        // MA averaging period for calculation
//   int          ma_shift,         // MA shift. Indicators line offset relate to the chart by timeframe.
//   int          ma_method,        // averaging method (MODE_SMA: Simple averaging; MODE_EMA: Exponential averaging; MODE_SMMA: Smoothed averaging; MODE_LWMA: Linear-weighted averaging)
//   int          applied_price,    // applied price (PRICE_CLOSE, PRICE_OPEN, PRICE_MEDIAN, etc)
//   int          shift             // shift.  Index of the value taken from the indicator buffer (shift relative to the current bar the given amount of periods ago).
//   );
double SimpleMA;
double ExMA_slow; 
double ExMA_fast;
SimpleMA =iMA(NULL,0,SMA,0,MODE_SMA,PRICE_CLOSE,0);
ExMA_slow =iMA(NULL,0,EMA1,0,MODE_EMA,PRICE_CLOSE,0);
ExMA_fast =iMA(NULL,0,EMA2,0,MODE_EMA,PRICE_CLOSE,0);


//--------------------------------------------------------
// Parabolic SAR Indicators
//-------------------------------------------------------
// iSAR - Parabolic Stop And Reverse System
// double iSAR(
//    string   symbol,
//    int      timeframe,
//    double   step,
//    double   maximum,
//    int      shift (index of the value taken from the indicator buffer )
// )
//  iSAR returns the numerical value of the Parabolic Stop and Reverse system indicator
double SAR0; 
double SAR1;
SAR0 =iSAR(NULL, 0,Step,Maximum, 0);
SAR1 =iSAR(NULL, 0,Step,Maximum, 1);
//--------------------------------------------------------
// Actural Close Price
//-------------------------------------------------------

// iClose - returns Close price value for the bar of specified symbol with timeframe and shift
// double iClose(
//    string    symbol,
//    int       timeframe,
//    int       shift
// )
// If local history is empty (not loaded), function returns 0.
double close0;
double close1; 
close0 = iClose(NULL,0,0);
close1=iClose(NULL,0,1);
// Open buy
// ----------------------------------------------------
// Buy Order Condition: if the SAR value and SimpleMA is less than the current price bar && the Exponential MA fast is larger than the ExMA Slow
 if((SAR0<close0)&&(SAR1>close1)&&(SimpleMA<close0)&&(ExMA_fast>ExMA_slow)&&(TradeTimeOk==1)&&(halt1!=1)){
 // OrderSend - The main function used to open an order or place a pending order
 // int OrderSend(
 //    string   symbol,
 //    int      cmd,           //operation
 //    double   volume,        // Number of lots
 //    double   price,         //Order price
 //    int      sllippage,     //  MAximum price slippage for buy or sell orders
 //    double   stoploss,
 //    string   comment=NULL,
 //    int      magic=0,       // Order magic number. Maybe used as user defined identifier
 //    datetime expiration=0,
 //    color    arrow_color=clrNone
 // )
 // OrderSend returns number of the ticket assigned to the order by the trade server or -1 if it fails.
 // Symbol - Returns the name of a symbol of the current chart 
 int openbuy = OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,"PSAR trader buy order",MagicNumber1,0,Blue);
 if(CloseOnOpposite==true)closesell=1;
 }


// Open sell
// ---------------------------------------------------
// Sell Order Condition: if the  SAR value and SimpleMA is larger than the current price bar && the Exponential MA fast is less than the ExMA Slow
 if((SAR0>close0)&&(SAR1<close1)&&(SimpleMA>close0)&&(ExMA_fast<ExMA_slow)&&(TradeTimeOk==1)&&(halt2!=1)){
 int opensell=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,"PSAR trader sell order",MagicNumber2,0,Green);
 if(CloseOnOpposite==true)closebuy=1;
 }

//-------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// Closing criteria
//-------------------------------------------------------------------------------------------------

if(closesell==1||closebuy==1||openbuy<1||opensell<1){// start

if(OrdersTotal()>0){
  for(i=1; i<=OrdersTotal(); i++){          // Cycle searching in orders
  
      if (OrderSelect(i-1,SELECT_BY_POS)==true){ // If the next is available
          // OrderTicket - Returns ticket number of the currently selected order
          // OrderLots - returns amount of lots of the selected order 
          // OrderClose - closes opened order (returns true if successfully, otherwise false. )
          // bool OrderClose(
          //      int      ticket,
          //      double   lots,
          //      double   price,
          //      int      cllipage,
          //      color    arrow_color (arrow color for stoploss/takeprofit modifications in the chart. If the parameter is missing or CLR_None value, the arrows will not be shown in the chart)
          // );
          if(OrderMagicNumber()==MagicNumber1&&closebuy==1) 
          {
          bool a =  OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,CLR_NONE); 
          if(!a) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully."); 
                     }
          if(OrderMagicNumber()==MagicNumber2&&closesell==1) 
          { 
          a =  OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,CLR_NONE); 
          if(!a) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully."); 
          }
          
          // set stops
          // OrderStopLoss - returns stop loss value of the currently selected order
          // OrderTakeProfit - retuns take profit value of the currently selected order
          // OrderModify - Modification of characteristics of the previously opened or pending orders
          // bool OrderModify(
          //      int      ticket,
          //      double   price,
          //      double   stoploss,
          //      double   takeprofit,
          //      datetime expiration,
          //      color    arrow_color (arrow color for stoploss/takeprofit modifications in the chart. If the parameter is missing or CLR_None value, the arrows will not be shown in the chart)
          // );
          // OrderSymbol - returns the symbol name of the currently selected order
          if((OrderMagicNumber()==MagicNumber1)&&(OrderTakeProfit()==0)&&(OrderSymbol()==Symbol()))
          { 
          bool b = OrderModify(OrderTicket(),0,OrderStopLoss(),tpb,0,CLR_NONE); 
          if(!b) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully.");
          }
          if((OrderMagicNumber()==MagicNumber2)&&(OrderTakeProfit()==0)&&(OrderSymbol()==Symbol()))
          { 
           b = OrderModify(OrderTicket(),0,OrderStopLoss(),tps,0,CLR_NONE); 
           if(!b) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully.");
           }
          if((OrderMagicNumber()==MagicNumber1)&&(OrderStopLoss()==0)&&(OrderSymbol()==Symbol()))
          { 
          b = OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,CLR_NONE); 
          if(!b) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully.");
          }
          if((OrderMagicNumber()==MagicNumber2)&&(OrderStopLoss()==0)&&(OrderSymbol()==Symbol()))
          { 
          b =OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,CLR_NONE);
           if(!b) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully.");
                      }

        }
     }
}


}// stop

//----
// GetLastError - returns the last error 
// Call the GetLastError() function to chech error information
// RefreshRates - refreshing of data in pre-defined variabless and series arrays
int Error=GetLastError();
  if(Error==130){Alert("Wrong stops. Retrying."); RefreshRates();}
  if(Error==133){Alert("Trading prohibited.");}
  if(Error==2){Alert("Common error.");}
  //sleep - suspends execution of the current expert advisor or script within a specifed interval
  if(Error==146){Alert("Trading subsystem is busy. Retrying."); Sleep(500); RefreshRates();}

//----

//-------------------------------------------------------------------
 // finish the operation of start(), control is returned to the client terminal until a new tick comes
   return(0);
  }
//+------------------------------------------------------------------+
