#property copyright "Copyright 2018-2020, Level Up Software"
#property link      "http://www.az-invest.eu"

#ifdef DEVELOPER_VERSION
   #define VOLUMECHART_INDICATOR_NAME "VolumeChart\\VolumeChart107" 
#else
   #define VOLUMECHART_INDICATOR_NAME "Market\\Volume var chart" 
#endif

#define VOLUMECHART_OPEN            00
#define VOLUMECHART_HIGH            01
#define VOLUMECHART_LOW             02
#define VOLUMECHART_CLOSE           03 
#define VOLUMECHART_BAR_COLOR       04
#define VOLUMECHART_SESSION_RECT_H  05
#define VOLUMECHART_SESSION_RECT_L  06
#define VOLUMECHART_MA1             07
#define VOLUMECHART_MA2             08
#define VOLUMECHART_MA3             09
#define VOLUMECHART_MA4             10
#define VOLUMECHART_CHANNEL_HIGH    11
#define VOLUMECHART_CHANNEL_MID     12
#define VOLUMECHART_CHANNEL_LOW     13
#define VOLUMECHART_BAR_OPEN_TIME   14
#define VOLUMECHART_TICK_VOLUME     15
#define VOLUMECHART_REAL_VOLUME     16
#define VOLUMECHART_BUY_VOLUME      17
#define VOLUMECHART_SELL_VOLUME     18
#define VOLUMECHART_BUYSELL_VOLUME  19
#define VOLUMECHART_RUNTIME_ID      20

#include <az-invest/sdk/VolumeCustomChartSettings.mqh>

class TickChart
{
   private:
   
      CVolumeCustomChartSettigns * volumeChartSettings;      
      
      int volumeChartHandle; //  tick chart indicator handle      
      string tickChartSymbol;
      bool usedByIndicatorOnVolumeChart;
      
      datetime prevBarTime;      
   
   public:
      
      TickChart();   
      TickChart(bool isUsedByIndicatorOnVolumeChart);
      TickChart(string symbol);
      ~TickChart(void);
      
      int Init();
      void Deinit();
      bool Reload();
      void ReleaseHandle();
      
      int GetHandle(void) { return volumeChartHandle; };
      double GetRuntimeId();
      
      bool IsNewBar();
      
      bool GetMqlRates(MqlRates &ratesInfoArray[], int start, int count);
      bool GetBuySellVolumeBreakdown(double &buy[], double &sell[], double &buySell[], int start, int count);      
      bool GetMA(int MaBufferId, double &MA[], int start, int count);
      bool GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      
      // The following 6 functions are deprecated, please use GetMA & GetChannelData functions instead
      bool GetMA1(double &MA[], int start, int count);
      bool GetMA2(double &MA[], int start, int count);
      bool GetMA3(double &MA[], int start, int count);
      bool GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
      bool GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count); 
      //
            
   private:

      int GetIndicatorHandle(void);
      bool GetChannelData(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count);
};

TickChart::TickChart(void)
{
   volumeChartSettings = new CVolumeCustomChartSettigns();
   volumeChartHandle = INVALID_HANDLE;
   tickChartSymbol = _Symbol;
   usedByIndicatorOnVolumeChart = false;
   prevBarTime = 0;
}

TickChart::TickChart(bool isUsedByIndicatorOnVolumeChart)
{
   volumeChartSettings = new CVolumeCustomChartSettigns(); 
   volumeChartHandle = INVALID_HANDLE;
   tickChartSymbol = _Symbol;
   usedByIndicatorOnVolumeChart = isUsedByIndicatorOnVolumeChart;
   prevBarTime = 0;
}

TickChart::TickChart(string symbol)
{
   volumeChartSettings = new CVolumeCustomChartSettigns();
   volumeChartHandle = INVALID_HANDLE;
   tickChartSymbol = symbol;
   usedByIndicatorOnVolumeChart = false;
   prevBarTime = 0;
}

TickChart::~TickChart(void)
{
   if(volumeChartSettings != NULL)
      delete volumeChartSettings;
}

void TickChart::ReleaseHandle()
{ 
   if(volumeChartHandle != INVALID_HANDLE)
   {
      IndicatorRelease(volumeChartHandle); 
   }
}

//
//  Function for initializing the median renko indicator handle
//

int TickChart::Init()
{
   if(!MQLInfoInteger((int)MQL5_TESTING))
   {
      if(usedByIndicatorOnVolumeChart) 
      {
         //
         // Indicator on Tick Chart uses the values of the TickChart for calculations
         //      
         
         IndicatorRelease(volumeChartHandle);
         
         volumeChartHandle = GetIndicatorHandle();
         return volumeChartHandle;
      }
   
      if(!volumeChartSettings.Load())
      {
         if(volumeChartHandle != INVALID_HANDLE)
         {
            // could not read new settings - keep old settings
            
            return volumeChartHandle;
         }
         else
         {
            Print("Failed to load indicator settings - "+VOLUMECHART_INDICATOR_NAME+" not on chart");
            return INVALID_HANDLE;
         }
      }   
      
      if(volumeChartHandle != INVALID_HANDLE)
         Deinit();

   }
   else
   {
      if(usedByIndicatorOnVolumeChart)
      {
         //
         // Indicator on Tick Chart uses the values of the TickChart for calculations
         //      
         volumeChartHandle = GetIndicatorHandle();
         return volumeChartHandle;      
      }
      else
      {     
         #ifdef SHOW_INDICATOR_INPUTS
            //
            //  Load settings from EA inputs
            //
            volumeChartSettings.Load();
         #endif
      }
   }   

   VOLUMECHART_SETTINGS s = volumeChartSettings.GetVolumeChartSettings();         
   CHART_INDICATOR_SETTINGS cis = volumeChartSettings.GetChartIndicatorSettings(); 

   volumeChartHandle = iCustom(this.tickChartSymbol, _Period, VOLUMECHART_INDICATOR_NAME, 
                                       s.barSizeInVolume, s.algorithm, s.showNumberOfDays, s.resetOpenOnNewTradingDay,
                                       TradingSessionTime,
                                       showPivots,
                                       pivotPointCalculationType,
                                       RColor,
                                       PColor,
                                       SColor,
                                       PDHColor,
                                       PDLColor,
                                       PDCColor,   
                                       AlertMeWhen,
                                       AlertNotificationType,
                                       cis.MA1on, 
                                       cis.MA1lineType,
                                       cis.MA1period,
                                       cis.MA1method,
                                       cis.MA1applyTo,
                                       cis.MA1shift,
                                       cis.MA1priceLabel,
                                       cis.MA2on, 
                                       cis.MA2lineType,
                                       cis.MA2period,
                                       cis.MA2method,
                                       cis.MA2applyTo,
                                       cis.MA2shift,
                                       cis.MA2priceLabel,
                                       cis.MA3on, 
                                       cis.MA3lineType,
                                       cis.MA3period,
                                       cis.MA3method,
                                       cis.MA3applyTo,
                                       cis.MA3shift,
                                       cis.MA3priceLabel,
                                       cis.MA4on, 
                                       cis.MA4lineType,
                                       cis.MA4period,
                                       cis.MA4method,
                                       cis.MA4applyTo,
                                       cis.MA4shift,
                                       cis.MA4priceLabel,
                                       cis.ShowChannel,
                                       cis.ChannelPeriod,
                                       cis.ChannelAtrPeriod,
                                       cis.ChannelAppliedPrice,
                                       cis.ChannelMultiplier,
                                       cis.ChannelPriceLabel,
                                       cis.ChannelMidPriceLabel,
                                       true); // used in EA
// TopBottomPaddingPercentage,
// showCurrentBarOpenTime,
// SoundFileBull,
// SoundFileBear,
// DisplayAsBarChart
// ShiftObj; all letft at defaults

    if(volumeChartHandle == INVALID_HANDLE)
    {
      Print(VOLUMECHART_INDICATOR_NAME+" indicator init failed on error ",GetLastError());
    }
    else
    {
      Print(VOLUMECHART_INDICATOR_NAME+" indicator init OK");
    }
     
    return volumeChartHandle;
}

//
// Function for reloading the TickChart indicator if needed
//

bool TickChart::Reload()
{
   bool actionNeeded = false;
   int temp = GetIndicatorHandle();
   
   if(temp != volumeChartHandle)
   {
      IndicatorRelease(volumeChartHandle); 
      volumeChartHandle = INVALID_HANDLE;

      actionNeeded = true;
   }
   
   if(volumeChartSettings.Changed(GetRuntimeId()))
   {
      actionNeeded = true;      
   }
   
   if(actionNeeded)
   {
      if(volumeChartHandle != INVALID_HANDLE)
      {
         IndicatorRelease(volumeChartHandle); 
         volumeChartHandle = INVALID_HANDLE;
      }

      if(Init() == INVALID_HANDLE)
         return false;
         
      return true;
   }    

   return false;
}

//
// Function for releasing the TickChart indicator handle - free resources
//

void TickChart::Deinit()
{
   if(volumeChartHandle == INVALID_HANDLE)
      return;
      
   if(!usedByIndicatorOnVolumeChart)
   {
      if(IndicatorRelease(volumeChartHandle))
         Print(VOLUMECHART_INDICATOR_NAME+" indicator handle released");
      else 
         Print("Failed to release "+VOLUMECHART_INDICATOR_NAME+" indicator handle");
   }
}

//
// Function for detecting a new TickChart bar
//

bool TickChart::IsNewBar()
{
   MqlRates currentBar[1];   
   GetMqlRates(currentBar,0,1);
   
   if(currentBar[0].time == 0)
   {
      return false;
   }
   
   if(prevBarTime < currentBar[0].time)
   {
      prevBarTime = currentBar[0].time;
      return true;
   }

   return false;
}

//
// Get "count" Renko MqlRates into "ratesInfoArray[]" array starting from "start" bar  
//

bool TickChart::GetMqlRates(MqlRates &ratesInfoArray[], int start, int count)
{
   double o[],l[],h[],c[],barColor[],time[],tick_volume[],real_volume[];

   if(ArrayResize(o,count) == -1)
      return false;
   if(ArrayResize(l,count) == -1)
      return false;
   if(ArrayResize(h,count) == -1)
      return false;
   if(ArrayResize(c,count) == -1)
      return false;
   if(ArrayResize(barColor,count) == -1)
      return false;
   if(ArrayResize(time,count) == -1)
      return false;
   if(ArrayResize(tick_volume,count) == -1)
      return false;
   if(ArrayResize(real_volume,count) == -1)
      return false;

  
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_OPEN,start,count,o) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_LOW,start,count,l) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_HIGH,start,count,h) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_CLOSE,start,count,c) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_BAR_OPEN_TIME,start,count,time) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_BAR_COLOR,start,count,barColor) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_TICK_VOLUME,start,count,tick_volume) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_REAL_VOLUME,start,count,real_volume) == -1)
      return false;

   if(ArrayResize(ratesInfoArray,count) == -1)
      return false; 

   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      ratesInfoArray[tempOffset-i].open = o[i];
      ratesInfoArray[tempOffset-i].low = l[i];
      ratesInfoArray[tempOffset-i].high = h[i];
      ratesInfoArray[tempOffset-i].close = c[i];
      ratesInfoArray[tempOffset-i].time = (datetime)time[i];
      ratesInfoArray[tempOffset-i].tick_volume = (long)tick_volume[i];
      ratesInfoArray[tempOffset-i].real_volume = (long)real_volume[i];
      ratesInfoArray[tempOffset-i].spread = (int)barColor[i];
   }
   
   ArrayFree(o);
   ArrayFree(l);
   ArrayFree(h);
   ArrayFree(c);
   ArrayFree(barColor);
   ArrayFree(time);
   ArrayFree(tick_volume);   
   ArrayFree(real_volume);  
   
   return true;
}
bool TickChart::GetBuySellVolumeBreakdown(double &buy[], double &sell[], double &buySell[], int start, int count)
{
   double b[],s[],bs[];
   
   if(ArrayResize(b,count) == -1)
      return false;
   if(ArrayResize(s,count) == -1)
      return false;
   if(ArrayResize(bs,count) == -1)
      return false;

   if(CopyBuffer(volumeChartHandle,VOLUMECHART_BUY_VOLUME,start,count,b) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_SELL_VOLUME,start,count,s) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_BUYSELL_VOLUME,start,count,bs) == -1)
      return false;

   if(ArrayResize(buy,count) == -1)
      return false; 
   if(ArrayResize(sell,count) == -1)
      return false; 
   if(ArrayResize(buySell,count) == -1)
      return false; 

   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      buy[tempOffset-i] = b[i];
      sell[tempOffset-i] = s[i];
      buySell[tempOffset-i] = bs[i];
   }
   
   ArrayFree(b);
   ArrayFree(s);
   ArrayFree(bs);
   
   return true;
}

//
// Get "count" values for MaBufferId buffer into "MA[]" array starting from "start" bar  
//

bool TickChart::GetMA(int MaBufferId, double &MA[], int start, int count)
{
   double tempMA[];
   if(ArrayResize(tempMA, count) == -1)
      return false;

   if(ArrayResize(MA, count) == -1)
      return false;
   
   if(MaBufferId != VOLUMECHART_MA1 && MaBufferId != VOLUMECHART_MA2 && MaBufferId != VOLUMECHART_MA3 && MaBufferId != VOLUMECHART_MA4)
   {
      Print("Incorrect MA buffer id specified in "+__FUNCTION__);
      return false;
   }
   
   if(CopyBuffer(volumeChartHandle, MaBufferId,start,count,tempMA) == -1)
   {
      return false;
   }
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }

   ArrayFree(tempMA);      
   return true;
}

//
// Get "count" MovingAverage1 values into "MA[]" array starting from "start" bar  
//

bool TickChart::GetMA1(double &MA[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetMA instead");
   
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_MA1,start,count,tempMA) == -1)
      return false;

   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }

   ArrayFree(tempMA);      
   return true;
}

//
// Get "count" MovingAverage2 values into "MA[]" starting from "start" bar  
//

bool TickChart::GetMA2(double &MA[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetMA instead");
   
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_MA2,start,count,tempMA) == -1)
      return false;
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }
   
   ArrayFree(tempMA);   
   return true;
}

//
// Get "count" MovingAverage3 values into "MA[]" starting from "start" bar  
//

bool TickChart::GetMA3(double &MA[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetMA instead");
   
   double tempMA[];
   if(ArrayResize(tempMA,count) == -1)
      return false;

   if(ArrayResize(MA,count) == -1)
      return false;
   
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_MA3,start,count,tempMA) == -1)
      return false;
   
   for(int i=0; i<count; i++)
   {
      MA[count-1-i] = tempMA[i];
   }
   
   ArrayFree(tempMA);   
   return true;
}

//
// Get "count" Donchian channel values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool TickChart::GetDonchian(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetChannelData instead");
   return GetChannelData(HighArray,MidArray,LowArray,start,count);
}

//
// Get "count" Bollinger band values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool TickChart::GetBollingerBands(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetChannelData instead");
   return GetChannelData(HighArray,MidArray,LowArray,start,count);
}

//
// Get "count" SuperTrend values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool TickChart::GetSuperTrend(double &SuperTrendHighArray[], double &SuperTrendArray[], double &SuperTrendLowArray[], int start, int count)
{
   Print(__FUNCTION__+" is deprecated, please use GetChannel function instead");
   return GetChannelData(SuperTrendHighArray,SuperTrendArray,SuperTrendLowArray,start,count);
}

//
// Get Channel values into "HighArray[]", "MidArray[]", and "LowArray[]" arrays starting from "start" bar  
//

bool TickChart::GetChannel(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   return GetChannelData(HighArray,MidArray,LowArray,start,count);
}

//
// Private function used by GetRenkoDonchian and GetRenkoBollingerBands functions to get data
//

bool TickChart::GetChannelData(double &HighArray[], double &MidArray[], double &LowArray[], int start, int count)
{
   double tempH[], tempM[], tempL[];

   if(ArrayResize(tempH,count) == -1)
      return false;
   if(ArrayResize(tempM,count) == -1)
      return false;
   if(ArrayResize(tempL,count) == -1)
      return false;

   if(ArrayResize(HighArray,count) == -1)
      return false;
   if(ArrayResize(MidArray,count) == -1)
      return false;
   if(ArrayResize(LowArray,count) == -1)
      return false;
   
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_CHANNEL_HIGH,start,count,tempH) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_CHANNEL_MID,start,count,tempM) == -1)
      return false;
   if(CopyBuffer(volumeChartHandle,VOLUMECHART_CHANNEL_LOW,start,count,tempL) == -1)
      return false;
   
   int tempOffset = count-1;
   for(int i=0; i<count; i++)
   {
      HighArray[tempOffset-i] = tempH[i];
      MidArray[tempOffset-i] = tempM[i];
      LowArray[tempOffset-i] = tempL[i];
   }   
   
   ArrayFree(tempH);
   ArrayFree(tempM);
   ArrayFree(tempL);
   
   return true;
}

int TickChart::GetIndicatorHandle(void)
{
   int i = ChartIndicatorsTotal(0,0);
   int j=0;
   string iName;
   
   while(j < i)
   {
      iName = ChartIndicatorName(0,0,j);
      if(StringFind(iName,CUSTOM_CHART_NAME) != -1)
      {
         return ChartIndicatorGet(0,0,iName);   
      }   
      
      j++;
   }
   
   Print("Failed getting handle of "+CUSTOM_CHART_NAME);
   return INVALID_HANDLE;
}

double TickChart::GetRuntimeId()
{
   double runtimeId[1];
    
   if(CopyBuffer(volumeChartHandle, VOLUMECHART_RUNTIME_ID, 0, 1, runtimeId) == -1)
      return -1;

   return runtimeId[0];   
}