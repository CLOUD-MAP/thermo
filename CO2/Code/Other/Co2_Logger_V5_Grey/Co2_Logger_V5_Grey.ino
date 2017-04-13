
//OU Co2 Logger V5 Grey Sensor

#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <RTClib.h>
#define K_30_Serial Serial1
#define OFFSET 0

// Co2*************************************************************************************************************
byte readCO2[] = {0xFE, 0X44, 0X00, 0X08, 0X02, 0X9F, 0X25}; //Command packet to read Co2 (see app note)
byte response[7] ;//= {0, 0, 0, 0, 0, 0, 0}; //create an array to store the response
int valMultiplier = 1; //multiplier for value. default is 1. set to 3 for K-30 3% and 10 for K-33 ICB
int timeout = 0 ;
unsigned long valCO2 ;
// ****************************************************************************************************************

//RTC**************************************************************************************************************
RTC_DS3231 rtc;
String Year, Month, Day, Hour, Minute, FILENAMESTRING;
const String EndHeading       = ".txt" ;
int Day_int =0 ;
char filename[9] ;
//*****************************************************************************************************************

//SD***************************************************************************************************************
File Co2File ;
unsigned long previous_time = 0, current_time = 0;
//*****************************************************************************************************************

void setup() { //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // put your setup code here, to run once:
  Serial.begin(115200) ; // Open the Serial communications to the Computer at 115200 baud
  K_30_Serial.begin(9600) ; //Opens the K_30 serial port to the CO2 at 9600 baud
  Wire.begin() ;
  //RTC**********************************************************************************************************
  rtc.begin();
  if (rtc.lostPower()) {
    Serial.println("RTC lost power, lets set the time!");// following line sets the RTC to the date & time this sketch was compiled
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }
  DateTime now            = rtc.now();
  switch (now.month()) {
    case 1:
    Day_int = 0;
    break ;
    case 2:
     Day_int = 31;
    break ;
    case 3:
     Day_int = 59;
    break ;
    case 4:
     Day_int = 90;
    break ;
    case 5:
     Day_int = 120;
    break ;
    case 6:
     Day_int = 151;
    break ;
    case 7:
     Day_int = 181;
    break ;
    case 8:
     Day_int = 212;
    break ;
    case 9:
     Day_int = 243;
    break ;
    case 10:
     Day_int = 273;
    break ;
    case 11:
     Day_int = 304;
    break ;
    case 12:
     Day_int = 334;
    break ;
  }

  Day_int += now.day() ;
  Day = String(Day_int) ; 
  FILENAMESTRING   =  Day + "1" +EndHeading ;
  //filename[FILENAMESTRING.length()+1] ;
  FILENAMESTRING.toCharArray(filename, sizeof(filename));

  //*************************************************************************************************************


  //SD***********************************************************************************************************
  Co2File = SD.open(filename, FILE_WRITE);
  pinMode(10, OUTPUT);
  if (!SD.begin(10)) {
    return;
  }
  delay(10000) ;

  Create_File_Header();
  //*************************************************************************************************************
} //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void loop() {
  // put your main code here, to run repeatedly:
  current_time = millis() ;
  if (current_time - previous_time >= 500)
  {
    Co2File = SD.open(filename, FILE_WRITE);
    DateTime Time = rtc.now();
    // K_30_Serial.listen();
    sendRequest(readCO2);
    unsigned long valCO2 = getValue(response);
    if (valCO2 > 6000) {
      sendRequest(readCO2);
      unsigned long valCO2 = getValue(response);
    }
    Co2File.print(Time.unixtime());
    Co2File.print("\t");
    Co2File.println(valCO2 + OFFSET);
    Serial.print(Time.unixtime());
    Serial.print("\t");
    Serial.println(valCO2);
    Co2File.close();
    previous_time = millis() ;
  }
}

void Create_File_Header() { // This function writes the file header for the Co2 values
  Co2File = SD.open(filename, FILE_WRITE);
  Co2File.print("Co2 Data from ");
  DateTime now  = rtc.now();
  Co2File.print(now.year(), DEC);
  Co2File.print('/');
  Co2File.print(now.month(), DEC);
  Co2File.print('/');
  Co2File.print(now.day(), DEC);
  Co2File.print(' ');
  Co2File.print(now.hour(), DEC);
  Co2File.print(':');
  Co2File.print(now.minute(), DEC);
  Co2File.print(':');
  Co2File.println(now.second(), DEC);
  Co2File.println("Sensor is K30 FR from Co2meter.com, In Grey Box");
  Co2File.println("");
  Co2File.println("Time(Unix)\tCo2(ppm)");
  Co2File.close();
}

void sendRequest(byte packet[])
{
  while (!K_30_Serial.available()) //keep sending request until we start to get a response
  {
    K_30_Serial.write(readCO2, 7);
    delay(50);
  }

  timeout = 0; //set a timeoute counter
  while (K_30_Serial.available() < 7 ) //Wait to get a 7 byte response
  {
    timeout++;
    if (timeout > 50) //if it takes to long there was probably an error
    {
      while (K_30_Serial.available()) //flush whatever we have
        K_30_Serial.read();

      break; //exit and try again
    }
    delay(10);
  }

  for (int i = 0; i < 7; i++)
  {
    response[i] = K_30_Serial.read();
  }
}

unsigned long getValue(byte packet[])
{
  int high = packet[3]; //high byte for value is 4th byte in packet in the packet
  int low = packet[4]; //low byte for value is 5th byte in the packet


  unsigned long val = high * 256 + low; //Combine high byte and low byte with this formula to get value
  return val * valMultiplier;
}


