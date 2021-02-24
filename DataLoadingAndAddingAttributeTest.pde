import java.util.*;
import java.util.Date.*;
import java.text.*; //SimpleDateFormat
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import org.gicentre.utils.spatial.UTM;
import org.gicentre.utils.spatial.Ellipsoid;
//import org.gicentre.geomap.GeoMap;
//import org.gicentre.utils.spatial.Ellipsoid;
//import org.gicentre.utils.spatial.UTM;
//import org.joda.time.DateTime;
//import org.joda.time.format.DateTimeFormat;
//import org.joda.time.format.DateTimeFormatter;

float noiseScale0 = 0.01; // 0.02 Pretty smooth; 0.1 medium messy; 0.9 mess af // Keep a structure with noise((i++)*noiseScale,noiseScale)
// todo make everything easier. By a lot. Old values: 0.02; 0.1; 0.3. Let's try 0.01; 0.05 and 0.1
float noiseScaleE1 = 0.01;float noiseScaleM1 = 0.05;float noiseScaleH1 = 0.1; 
float noiseScaleE2 = 0.009;float noiseScaleM2 = 0.049;float noiseScaleH2 = 0.09; 
float noiseScaleE3 = 0.011;float noiseScaleM3 = 0.051;float noiseScaleH3 = 0.11;
// Values for qualitative variables -> Making it +0.03? no, let's lower them...
//float noiseScaleE4 = 0.02;float noiseScaleM4 = 0.06;float noiseScaleH4 = 0.11; 
//float noiseScaleE5 = 0.025;float noiseScaleM5 = 0.0605;float noiseScaleH5 = 0.105; 
//float noiseScaleE6 = 0.015;float noiseScaleM6 = 0.061;float noiseScaleH6 = 0.115;
float noiseScaleE4 = 0.0150;float noiseScaleM4 = 0.040;float noiseScaleH4 = 0.080; 
float noiseScaleE5 = 0.0155;float noiseScaleM5 = 0.045;float noiseScaleH5 = 0.085; 
float noiseScaleE6 = 0.0145;float noiseScaleM6 = 0.035;float noiseScaleH6 = 0.075;


Table table;

UTM proj = new UTM(new Ellipsoid(Ellipsoid.WGS_84),35,'S');    // UTM zone centred on Mediterranean
PVector utm = null;
PVector utmNext=null;
PVector utmBef=null;
PVector utmFar=null;
PVector utmPrior=null;
PVector utmVFar=null;
PVector utmVPrior=null;

PVector utmSmooth=null; PVector utmSmoothLoop=null;

void setup() {
  //table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/eclipse/vast2014/src/data/jwoData/gps.csv", "header");
  table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/Extracted_Modified/gps_time.csv", "header");
  //table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/Extracted_Modified/gps_10Jan2014_ID1.csv", "header");
  //table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/Extracted_Modified/gps_10Jan2014_IDALL.csv", "header");
  println(table.getRowCount() + " total rows in table");
  table.addColumn("engineTemperature"); // Normal engine temperature is around 60-65 degrees celsius. Long drive can reach around 80-85 degrees.
  table.addColumn("speed"); 
  table.addColumn("speedSmooth"); 
  table.addColumn("angle");
  table.addColumn("angleBasedOnDistance");
  table.addColumn("direction"); // North,South,East,West
  table.addColumn("directionBasedOnDistance");
  table.addColumn("straightness");
  float diffAngleTotal = 0;
  float diffAngleTotalFar = 0;
  String oldDir=""; 
  String oldDirFar="";
  float averageDist=0.0; float sumDist =0.0; float maxDist=0.0;
  averageDist = 1945.8987;
  float averageDistFar=0.0; float sumDistFar =0.0; float maxDistFar=0.0;
  averageDistFar = 1945.8987;// might be wrong
  int amountOverAvg = 0;
  float averageDiffToAvg=0.0; float sumDiffToAvg=0.0;
  float averageClean = 141.0506;
  
  int numSmallDist=0; float disregardedSum=0.0;
  float newAverage; 
  
  float sumStraightness=0; float sumStraightnessClose=0; float sumStraightnessFar=0;
  int countInfinite=0; 
  float avgStrRecord = 0.0016489563; float avgStrRecordClose = 0.0016241027; float avgStrRecordFar = 3.5712388E-4;
  int countOvAvgStr = 0; int countOvAvgStrFar = 0; int countOvAvgStrClose = 0;
  
  int sumTimeBadlyOrdered = 0;
  
  table.addColumn("numberPassengers");
  table.addColumn("fuelConsumption");
  table.addColumn("suspensionSpringForce"); // suspension spring force?, in between 77.2 MPa and 79.3 MPa
  table.addColumn("wiperOn");
  table.addColumn("gpsOn");
  table.addColumn("carPhoneUsed");
  
  // We need to consider the addition of two more attributes. One WHAT_Qn and one WHAT_Ql
  // heatingSeatsOn
  // computerElectricityConsumption
  
  table.addColumn("utmx"); table.addColumn("utmy");
  table.addColumn("lat"); table.addColumn("lon");  
  table.addColumn("xSmooth"); table.addColumn("ySmooth");
  table.addColumn("utmxSmooth"); table.addColumn("utmySmooth");
  
  int countRow = 0;
  int totalRowCount=0; int maxRowsCount = table.getRowCount();
  int prevID = 0;
  float prevX = -Float.MAX_VALUE; 
  float prevY = -Float.MAX_VALUE;
  long prevMilli = -Long.MAX_VALUE;

  TableRow rowZero = table.getRow(totalRowCount); TableRow rowFive; 
  if ( totalRowCount+5 <= maxRowsCount){ rowFive = table.getRow(totalRowCount+5);} else { rowFive = table.getRow(maxRowsCount); }
  float xPosBeg = rowZero.getFloat("x"); float yPosBeg = rowZero.getFloat("y");
  float xPosEnd = rowFive.getFloat("x"); float yPosEnd = rowFive.getFloat("y");
  String dBeg = rowZero.getString("t");
  OffsetDateTime odtBeg = OffsetDateTime.parse(dBeg);
  long millisBeg = odtBeg.toInstant().toEpochMilli();
  String dEnd = rowFive.getString("t"); OffsetDateTime odtEnd = OffsetDateTime.parse(dEnd);
  long millisEnd = odtEnd.toInstant().toEpochMilli();    
  int idBeg = rowZero.getInt("id"); int idEnd = rowFive.getInt("id");
  
  float timeDiffZero = millisEnd-millisBeg; float timeDiffHZero = 0;
  timeDiffZero /= 1000; // changed to seconds here
  if (timeDiffZero !=0){ timeDiffHZero = timeDiffZero/360; }
  println("timeDiffHZero: "+timeDiffHZero);
  println("xPosBeg: "+xPosBeg + ", xPosEnd: "+xPosEnd); println("yPosBeg: "+yPosBeg + ", yPosEnd: "+yPosEnd); println("idBeg: "+idBeg+", idEnd: "+idEnd);
  int countForEnd = 5;
  int countForEnd_E = 15; int countForEnd_M = 10; int countForEnd_H = 5;
  int countBinDurGPS=0; int countBinDurPhone=0; int countBinDurWiper=0; int prevGPS=0; int prevPhone=0; int prevWiper = 0;

  float minValEngineTemperature = Float.MAX_VALUE; float maxValEngineTemperature = Float.MIN_VALUE; float minValFuelConsumption = Float.MAX_VALUE; float maxValFuelConsumption = Float.MIN_VALUE; float valVarEg = 0, valVarFc = 0; int countVariation = 0; float prevEg = 0, prevFc = 0;
 
  int monthLoop = 0; OffsetDateTime odtLoop = OffsetDateTime.now(); int idLoop=0; int countSkips = 0; int countSameIdWrongTime=0; int countOrderOk = 0; OffsetDateTime odtMax = OffsetDateTime.parse("2000-01-01T00:00:00Z", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
  ArrayList<Integer> listIdentifiersDone = new ArrayList<Integer>(); ArrayList<OffsetDateTime> listDates = new ArrayList<OffsetDateTime>();
  HashMap<Integer, OffsetDateTime> hMap = new HashMap<Integer, OffsetDateTime>();
  HashMap<Integer, Integer> countMonth = new HashMap<Integer, Integer>();
  HashMap<Integer, Integer> countIdCases = new HashMap<Integer, Integer>();
  HashMap<Integer,HashMap <OffsetDateTime,Integer>> countDatesOccurencesId = new  HashMap<Integer,HashMap <OffsetDateTime,Integer>>();
  HashMap<Integer,Integer> numPositiveQualId = new HashMap<Integer,Integer>();
  HashMap<Integer,Integer> numVariationsId = new HashMap<Integer,Integer>(); int prevValWiper=0;
  int numRows = table.getRowCount();


  // --------- start of the big loop for calculations for each row
  for (TableRow row : table.rows()) {
      int id = row.getInt("id");
      if ( hMap.get(id) == null ){
        listIdentifiersDone.add(id); listDates.add(OffsetDateTime.parse("2000-01-01T00:00:00Z", DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        hMap.put(id, OffsetDateTime.parse("2000-01-01T00:00:00Z", DateTimeFormatter.ISO_OFFSET_DATE_TIME)); //println("test hMap right get:  "+hMap.get(id)); println("test hMap wrong get:  "+hMap.get(42));
      }
      if (prevID != id){ countRow = 0; prevID = id; }

      rowZero = table.getRow(totalRowCount);
      if ( totalRowCount+countForEnd < maxRowsCount){ rowFive = table.getRow(totalRowCount+countForEnd);} else { rowFive = table.getRow(maxRowsCount-1); }
      idBeg = rowZero.getInt("id"); idEnd = rowFive.getInt("id");
      while( idEnd != idBeg ) {
        countForEnd--;
        if ( totalRowCount+countForEnd < maxRowsCount){ rowFive = table.getRow(totalRowCount+countForEnd);} else { rowFive = table.getRow(maxRowsCount-1); }
        idBeg = rowZero.getInt("id"); idEnd = rowFive.getInt("id");
      }
      countForEnd=5;
      xPosBeg = rowZero.getFloat("x"); yPosBeg = rowZero.getFloat("y"); xPosEnd = rowFive.getFloat("x"); yPosEnd = rowFive.getFloat("y");
      dBeg = rowZero.getString("t"); odtBeg = OffsetDateTime.parse(dBeg); millisBeg = odtBeg.toInstant().toEpochMilli(); dEnd = rowFive.getString("t"); odtEnd = OffsetDateTime.parse(dEnd); millisEnd = odtEnd.toInstant().toEpochMilli();    
      float smoothDistMeter = distFrom(xPosBeg,yPosBeg,xPosEnd,yPosEnd); float smoothDistKmPoints = smoothDistMeter/100; float speedSmooth=smoothDistKmPoints/timeDiffZero; float speedSmoothKmH = smoothDistKmPoints/timeDiffHZero;
            
      float noiseVal = noise((countRow)*noiseScaleE1, noiseScaleE1);
      float noiseValE1 = noise ( countRow*noiseScaleE1,noiseScaleE1 ); float noiseValM1 = noise ( countRow*noiseScaleM1,noiseScaleM1 ); float noiseValH1 = noise ( countRow*noiseScaleH1,noiseScaleH1 );
      float noiseValE2 = noise ( countRow*noiseScaleE2,noiseScaleE2 ); float noiseValM2 = noise ( countRow*noiseScaleM2,noiseScaleM2 ); float noiseValH2 = noise ( countRow*noiseScaleH2,noiseScaleH2 );
      float noiseValE3 = noise ( countRow*noiseScaleE3,noiseScaleE3 ); float noiseValM3 = noise ( countRow*noiseScaleM3,noiseScaleM3 ); float noiseValH3 = noise ( countRow*noiseScaleH3,noiseScaleH3 );
      float noiseValE4 = noise ( countRow*noiseScaleE4,noiseScaleE4 ); float noiseValM4 = noise ( countRow*noiseScaleM4,noiseScaleM4 ); float noiseValH4 = noise ( countRow*noiseScaleH4,noiseScaleH4 );
      float noiseValE5 = noise ( countRow*noiseScaleE5,noiseScaleE5 ); float noiseValM5 = noise ( countRow*noiseScaleM5,noiseScaleM5 ); float noiseValH5 = noise ( countRow*noiseScaleH5,noiseScaleH5 );
      float noiseValE6 = noise ( countRow*noiseScaleE6,noiseScaleE6 ); float noiseValM6 = noise ( countRow*noiseScaleM6,noiseScaleM6 ); float noiseValH6 = noise ( countRow*noiseScaleH6,noiseScaleH6 );
      
      // Previous values of ranges to multiply to random values: noiseTemperature_E 30, noiseSuspensionSpringForce_E 2.1, noiseFuelConsumption_E 75 // IMPORTANT This is where we can think about values for the queries for the masks.
      float valVariationsShared = 45;
      float noiseTemperature_E = 60 + noiseValE1*valVariationsShared; float noiseTemperature_M = 60 + noiseValM1*valVariationsShared; float noiseTemperature_H = 60 + noiseValH1*valVariationsShared;
      float noiseSuspensionSpringForce_E = 77.2 + noiseValE2*valVariationsShared; float noiseSuspensionSpringForce_M = 77.2 + noiseValM2*valVariationsShared; float noiseSuspensionSpringForce_H = 77.2 + noiseValH2*valVariationsShared;
      float noiseFuelConsumption_E = 75 + noiseValE3*valVariationsShared;float noiseFuelConsumption_M = 75 + noiseValM3*valVariationsShared; float noiseFuelConsumption_H = 75 + noiseValH3*valVariationsShared; // What unit are we expecting here? // miles per gallon // https://www.kbb.com/what-is/mpg/

      // We'll generate values in between 0 and 10, and depending if over 5 we'll make it 
      float quantWiper_E=noiseValE4*10;float quantWiper_M=noiseValM4*10;float quantWiper_H=noiseValH4*10; float quantGPS_E=noiseValE5*10;float quantGPS_M=noiseValM5*10;float quantGPS_H=noiseValH5*10; float quantPhone_E=noiseValE6*10;float quantPhone_M=noiseValM6*10;float quantPhone_H=noiseValH6*10;
      // Noise quant
      float noiseValPassengers = noise(countRow*noiseScaleE1, noiseScaleE1); float noiseValGPS = noise(countRow*noiseScaleE1, noiseScaleE1); float noiseValWiperOn = noise(countRow*noiseScaleE1,noiseScaleE1); float noiseValPhone = noise(2*countRow*noiseScaleE1, noiseScaleE1);
      // Noise qual
      int noisePassengers = (int) (noiseValPassengers*4); int noiseGPSon= (int) (noiseValGPS*2); int noisePhone= (int) (noiseValPhone*2); int noiseWiperOn = (int) (noiseValWiperOn*2);
             
      float x = row.getFloat("x");  float y = row.getFloat("y"); String d = row.getString("t");
      OffsetDateTime odt = OffsetDateTime.parse(d); long millis = odt.toInstant().toEpochMilli();
      float speed = 0; float timeDiffH = 0; float speedKmH = 0;
      
      OffsetDateTime oldMaxT = hMap.get(id); if ( oldMaxT.compareTo(odt) <0 ) { hMap.replace(id,odt); }
      
      int curMonth = odt.getMonth().getValue(); if (countMonth.get(curMonth) == null){ countMonth.put(curMonth,0); }
      int sumMonth = countMonth.get(curMonth); sumMonth++; countMonth.replace(curMonth,sumMonth);
      
      if (countRow == 0) { prevX = row.getFloat("x"); prevY = row.getFloat("y"); prevMilli = millis; prevID = id; odtLoop = odt; idLoop=id; monthLoop = curMonth; }
      
      if ( oldMaxT != null && oldMaxT.compareTo(odt)>=0 ) {
        if ( idLoop ==id ) { countSkips++; }
        countSameIdWrongTime++;
      } else {
        countOrderOk++;
        if (countIdCases.get(id) == null){ countIdCases.put(id,0); }; int countId = countIdCases.get(id) +1 ; countIdCases.replace(id, countId);
        // Calculate speed
        float timeDiff = millis-prevMilli; timeDiff /= 1000;  if (timeDiff !=0){ timeDiffH = timeDiff/360; }
        float distMetersPoints = distFrom(x,y,prevX,prevY); float distKmPoints = distMetersPoints/100; speed = distMetersPoints/timeDiff;
        if (countRow!=0 && timeDiff!=0){ speedKmH = distKmPoints/ timeDiffH; } if (countRow == 0){ speed=0; } // Happens often, but not sure why?
        
        // data verification
        if (countDatesOccurencesId.get(id) == null){ HashMap<OffsetDateTime, Integer> countHM = new HashMap<OffsetDateTime, Integer> (); countHM.put(odt,0); countDatesOccurencesId.put(id, countHM); }
        
        if (countDatesOccurencesId.get(id) != null ) {
          HashMap<OffsetDateTime,Integer> timeSelec = countDatesOccurencesId.get(id);
          if (timeSelec.get(odt) == null) { timeSelec.put(odt,0); }
          int valCptTime = timeSelec.get(odt); valCptTime++; timeSelec.replace(odt, valCptTime);
          if (valCptTime>1){ println("big probleme here, id: "+id+", valCptTime: "+valCptTime+", odt: "+odt.toString()); }
          countDatesOccurencesId.replace(id, timeSelec);
        }
        
        // Cases selection (Easy_Easy_Medium, etc.) and adaptation of the values based on that.
        int modId = id%8; float noiseFuelConsumption = noiseFuelConsumption_E; float noiseTemperature = noiseTemperature_M; float noiseSuspensionSpringForce = noiseSuspensionSpringForce_H;  // case 0
        int actualCountForEnd_GPS = countForEnd, actualCountForEnd_Phone = countForEnd, actualCountForEnd_Wiper = countForEnd; int countEnd_E = 40; int countEnd_M = 36; int countEnd_H = 32; // change the values here...? // Do these make any real change?!
        // Put higher value to limit variations. Old values were E = 12, M = 8, H = 4 !! 20, 16,12 miiiight be better? PROBABLY ZERO CHANGE
        int qualGPS=0; int qualPhone=0; int qualWiper=0;
        // Too many combinations. Let's reduce to Qn and Ql with the same difficulty but with different noise previously established (consider change...)
        // EE;EM;ME;MM;EH;HE;MH;HM;
        if (modId == 0){ noiseFuelConsumption = noiseFuelConsumption_E; noiseTemperature = noiseTemperature_E; noiseSuspensionSpringForce = noiseSuspensionSpringForce_E; 
          actualCountForEnd_GPS = countEnd_E; actualCountForEnd_Wiper = countEnd_E; actualCountForEnd_Phone = countEnd_E; 
          if (quantGPS_E>5){qualGPS=1;};if (quantWiper_E>5){qualWiper=1;};if (quantPhone_E>5){qualPhone=1;};
        } //EE
        else if (modId == 1){ noiseFuelConsumption = noiseFuelConsumption_E; noiseTemperature = noiseTemperature_E; noiseSuspensionSpringForce = noiseSuspensionSpringForce_E; 
          actualCountForEnd_GPS = countEnd_M; actualCountForEnd_Wiper = countEnd_M; actualCountForEnd_Phone = countEnd_M; 
          if (quantGPS_M>5){qualGPS=1;};if (quantWiper_M>5){qualWiper=1;};if (quantPhone_M>5){qualPhone=1;};
        } // EM
        else if (modId == 2){ noiseFuelConsumption = noiseFuelConsumption_M; noiseTemperature = noiseTemperature_M; noiseSuspensionSpringForce = noiseSuspensionSpringForce_M; 
          actualCountForEnd_GPS = countEnd_E; actualCountForEnd_Wiper = countEnd_E; actualCountForEnd_Phone = countEnd_E; 
          if (quantGPS_E>5){qualGPS=1;};if (quantWiper_E>5){qualWiper=1;};if (quantPhone_E>5){qualPhone=1;};
        } // ME
        else if (modId == 3){ noiseFuelConsumption = noiseFuelConsumption_M; noiseTemperature = noiseTemperature_M; noiseSuspensionSpringForce = noiseSuspensionSpringForce_M; 
          actualCountForEnd_GPS = countEnd_M; actualCountForEnd_Wiper = countEnd_M; actualCountForEnd_Phone = countEnd_M; 
          if (quantGPS_M>5){qualGPS=1;};if (quantWiper_M>5){qualWiper=1;};if (quantPhone_M>5){qualPhone=1;};
      } // MM
        else if (modId == 4){ noiseFuelConsumption = noiseFuelConsumption_E; noiseTemperature = noiseTemperature_E; noiseSuspensionSpringForce = noiseSuspensionSpringForce_E; 
          actualCountForEnd_GPS = countEnd_H; actualCountForEnd_Wiper = countEnd_H; actualCountForEnd_Phone = countEnd_H; 
          if (quantGPS_H>5){qualGPS=1;};if (quantWiper_H>5){qualWiper=1;};if (quantPhone_H>5){qualPhone=1;};  
      } // EH
        else if (modId == 5){ noiseFuelConsumption = noiseFuelConsumption_H; noiseTemperature = noiseTemperature_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H; 
          actualCountForEnd_GPS = countEnd_E; actualCountForEnd_Wiper = countEnd_E; actualCountForEnd_Phone = countEnd_E; 
          if (quantGPS_E>5){qualGPS=1;};if (quantWiper_E>5){qualWiper=1;};if (quantPhone_E>5){qualPhone=1;};
        } // HE
        else if (modId == 6){ noiseFuelConsumption = noiseFuelConsumption_M; noiseTemperature = noiseTemperature_M; noiseSuspensionSpringForce = noiseSuspensionSpringForce_M; 
          actualCountForEnd_GPS = countEnd_H; actualCountForEnd_Wiper = countEnd_H; actualCountForEnd_Phone = countEnd_H; 
          if (quantGPS_H>5){qualGPS=1;};if (quantWiper_H>5){qualWiper=1;};if (quantPhone_H>5){qualPhone=1;};  
        } // MH
        else if (modId == 7){ noiseFuelConsumption = noiseFuelConsumption_H; noiseTemperature = noiseTemperature_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H; 
          actualCountForEnd_GPS = countEnd_M; actualCountForEnd_Wiper = countEnd_M; actualCountForEnd_Phone = countEnd_M; 
           if (quantGPS_M>5){qualGPS=1;};if (quantWiper_M>5){qualWiper=1;};if (quantPhone_M>5){qualPhone=1;};
       } // HM
      else if (id == 17 || id == 23){
        noiseFuelConsumption = noiseFuelConsumption_H; noiseTemperature = noiseTemperature_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H; 
        actualCountForEnd_GPS = countEnd_H; actualCountForEnd_Wiper = countEnd_H; actualCountForEnd_Phone = countEnd_H; 
         if (quantGPS_H>5){qualGPS=1;};if (quantWiper_H>5){qualWiper=1;};if (quantPhone_H>5){qualPhone=1;};        
      } // HH
        
        
        if (countRow==0){prevGPS=noiseGPSon; prevPhone=noisePhone;}
        if (countBinDurGPS<actualCountForEnd_GPS){ noiseGPSon=prevGPS; countBinDurGPS++; } else { prevGPS=noiseGPSon; countBinDurGPS=0; }
        if (countBinDurPhone<actualCountForEnd_Phone){ noisePhone=prevPhone; countBinDurPhone++; } else { prevPhone=noisePhone; countBinDurPhone=0; }
        if (countBinDurWiper<actualCountForEnd_Wiper){ noiseWiperOn=prevWiper; countBinDurWiper++; } else { prevWiper=noiseWiperOn; countBinDurWiper=0; }

        // trying to convert latlon to utm
        utm = proj.invTransformCoords( new PVector(y,x) );
        if (minValEngineTemperature > noiseTemperature) { minValEngineTemperature = noiseTemperature; } if (minValFuelConsumption > noiseFuelConsumption) { minValFuelConsumption = noiseFuelConsumption; } if (maxValEngineTemperature < noiseTemperature) { maxValEngineTemperature = noiseTemperature; } if (maxValFuelConsumption < noiseFuelConsumption) { maxValFuelConsumption = noiseFuelConsumption; }
        if (countVariation == 0) { prevFc = noiseFuelConsumption; prevEg = noiseTemperature; countVariation++;} else 
          { valVarEg +=  (float) Math.sqrt( Math.pow( (double)(noiseTemperature-prevEg), 2) ); valVarFc += (float) Math.sqrt( Math.pow( (double)(noiseFuelConsumption-prevFc), 2) );  prevEg = noiseTemperature; prevFc = noiseFuelConsumption; countVariation++; }
        
        if (numPositiveQualId.get(id) == null){ numPositiveQualId.put(id,0); } if(  noiseWiperOn == 1 ) { int curValPositiveQual = numPositiveQualId.get(id); curValPositiveQual++; numPositiveQualId.put(id,curValPositiveQual); }
        if (countVariation ==0){ prevValWiper = noiseWiperOn;} if ( numVariationsId.get(id) == null ) { numVariationsId.put(id,0); } 
        if (prevValWiper!=noiseWiperOn){ int curVarWiper = numVariationsId.get(id); curVarWiper++; numVariationsId.put(id,curVarWiper); }
        prevValWiper = noiseWiperOn;

        // qualGPS,qualPhone,qualWiper
        row.setFloat("fuelConsumption", noiseFuelConsumption); row.setFloat("engineTemperature", noiseTemperature); row.setFloat("suspensionSpringForce",noiseSuspensionSpringForce);
        row.setFloat("speed", speedKmH); row.setFloat("speedSmooth",speedSmoothKmH);
        row.setFloat("utmx", utm.x); row.setFloat("utmy", utm.y); row.setFloat("lat", x); row.setFloat("lon", y);
        row.setInt("numberPassengers", noisePassengers); row.setInt("gpsOn", qualGPS); row.setInt("carPhoneUsed", qualPhone); row.setInt("wiperOn", qualWiper);
        
        // Get the next x and y and get the angle // Wrong somehow... Might need to take the utm values?
        if (totalRowCount<numRows+1){
          TableRow nextRow = table.getRow(totalRowCount+1); float nextX = nextRow.getFloat("x"); float nextY = nextRow.getFloat("y"); utmNext = proj.invTransformCoords( new PVector(nextY,nextX) );
          TableRow befRow; if ( totalRowCount>0 ){befRow = table.getRow(totalRowCount-1);} else { befRow= row;} float befX = befRow.getFloat("x"); float befY = befRow.getFloat("y"); utmBef = proj.invTransformCoords( new PVector(befY,befX) );

          // What about selection of the far angle?... 5,3, something else?
          TableRow farRow; if (numRows>totalRowCount+4){ farRow = table.getRow(totalRowCount+5); } else { farRow = row;}
          float farX = farRow.getFloat("x"); float farY = farRow.getFloat("y"); utmFar = proj.invTransformCoords( new PVector(farX,farY) );
          TableRow priorRow; if (totalRowCount>4){ priorRow = table.getRow(totalRowCount-5); } else { priorRow = table.getRow(0);}
          float priorX = priorRow.getFloat("x"); float priorY = priorRow.getFloat("y"); utmPrior = proj.invTransformCoords( new PVector(priorX,priorY) );
          TableRow farVRow; if (numRows>totalRowCount+9){ farVRow = table.getRow(totalRowCount+10); } else { farVRow = row;}
          float farVX = farVRow.getFloat("x"); float farVY = farVRow.getFloat("y"); utmVFar = proj.invTransformCoords( new PVector(farVX,farVY) );
          TableRow priorVRow; if (totalRowCount>9){ priorVRow = table.getRow(totalRowCount-10); } else { priorVRow = table.getRow(0);}
          float priorVX = priorVRow.getFloat("x"); float priorVY = priorVRow.getFloat("y"); utmVPrior = proj.invTransformCoords( new PVector(priorVX,priorVY) );

          float angle = GetAngleOfLineBetweenTwoPoints(utm.x, utm.y, utmNext.x, utmNext.y); float angleFar = GetAngleOfLineBetweenTwoPoints(utm.x, utm.y, utmFar.x, utmFar.y);
          float dist = cartesianDist(utm.x,utm.y,utmNext.x,utmNext.y); float distFar = cartesianDist(utm.x,utm.y,utmFar.x,utmFar.y); sumDist+=dist;
          if ( dist>maxDist ){maxDist=dist;} if (dist> averageDist ){amountOverAvg++;} sumDiffToAvg+= Math.abs(dist-averageDist);
          
          // Verify if part of north, south, east or west.
          String dir = ""; 
          if (angle >=45 && angle <135){dir="North";} else if (angle >=135 && angle<225 ){dir="West";} else if (angle >=225 && angle <315){dir="South";} else {dir="East";}
          float diffAngleLocal = 0; float valAngleBase;
          if (dir=="North") { valAngleBase=90; } else if (dir=="South") { valAngleBase=270; } else if (dir=="West") { valAngleBase=180; } else { valAngleBase=0;} // Might to be more clever here...
          if (totalRowCount==0){oldDir=dir;} 
          if (dir != "East") {diffAngleLocal = angle - valAngleBase;} else { if (angle<=360 && angle>= 315){ diffAngleLocal= angle-360; } else { diffAngleLocal=angle; } }          
          diffAngleTotal+=diffAngleLocal;

          String dirFar = ""; if (angleFar >=45 && angleFar <135){dirFar="North";} else if (angleFar >=135 && angleFar<225 ){dirFar="West";} else if (angleFar >=225 && angleFar <315){dirFar="South";} else {dirFar="East";}
          float diffAngleFar = 0; float valAngleFar;
          if (dirFar=="North") { valAngleFar=90; } else if (dirFar=="South") { valAngleFar=270; } else if (dirFar=="West") { valAngleFar=180; } else { valAngleFar=0;} // Might to be more clever here...
          if (totalRowCount==0){oldDirFar=dirFar;} 
          if (dirFar != "East") {diffAngleLocal = angleFar - valAngleFar;} else { if (angleFar<=360 && angleFar>= 315){ diffAngleFar= angleFar-360; } else { diffAngleFar=angleFar; } }          
          diffAngleTotalFar+=diffAngleFar;
          if (dist < averageClean){ dirFar=dir; } 

          float dist_i_to_imn = cartesianDist(priorX,priorY,x,y); float dist_i_to_ipn = cartesianDist(x,y,farX,farY); float dist_imn_to_ipn = cartesianDist(priorX,priorY,farX,farY);
          
          // Issue, trajectory sometimes goes back to previous positions, messing up even more the straightness calculation
          // In order of distance~index, it goes bef/next -> prior/far -> priorV/farV
          float straightness = (cartesianDist(priorX,priorY,x,y) + cartesianDist(x,y,farX,farY)) / cartesianDist(priorX,priorY,farX,farY);
          float closeStraigthness = ( cartesianDist(befX,befY,x,y) + cartesianDist(x,y,nextX,nextY) ) / (  cartesianDist(befX,befY,nextX,nextY) );
          float farStraightness = ( cartesianDist(priorVX,priorVY,x,y) + cartesianDist(x,y,farVX,farVY) ) / (  cartesianDist(priorVX,priorVY,farVX,farVY) );
          
          if ((priorX == farX && priorY == farY) || (priorVX == farVX && priorY == farY) ){ println("repetition of a point"); }
          
          if ( Double.isInfinite(straightness) || Double.isInfinite(farStraightness) || Double.isInfinite(sumStraightnessClose) ){
            
            if ( totalRowCount>0 && (priorX == farX && priorY == farY)  ){
              TableRow altPriorRow = table.getRow(totalRowCount-4); TableRow altFarRow = table.getRow(totalRowCount+4); 
              float farAltX = altFarRow.getFloat("x"); float farAltY = altFarRow.getFloat("y"); float priorAltX = altPriorRow.getFloat("x"); float priorAltY = altPriorRow.getFloat("y");
              PVector utmAltFar = proj.invTransformCoords( new PVector(farAltX,farAltY) );
              PVector utmAltPrior =  proj.invTransformCoords( new PVector(priorAltX,priorAltY) );
              float altStraightness = (  cartesianDist(priorAltX,priorAltY,x,y) + cartesianDist(x,y,farAltX,farAltY) ) / (  cartesianDist(priorAltX,priorAltY,farAltX,farAltY) );
              straightness=altStraightness;
            }

            if (totalRowCount>0 && (priorVX == farVX && priorVY == farVY)  ){
              TableRow altVPriorRow = table.getRow(totalRowCount-9); TableRow altVFarRow = table.getRow(totalRowCount+9); 
              float farVAltX = altVFarRow.getFloat("x"); float farVAltY = altVFarRow.getFloat("y"); float priorVAltX = altVPriorRow.getFloat("x"); float priorVAltY = altVPriorRow.getFloat("y");
              PVector utmAltVFar = proj.invTransformCoords( new PVector(farVAltX,farVAltY) );
              PVector utmAltVPrior =  proj.invTransformCoords( new PVector(priorVAltX,priorVAltY) );
              float altVStraightness = (  cartesianDist(priorVAltX,priorVAltY,x,y) + cartesianDist(x,y,farVAltX,farVAltY) ) / (  cartesianDist(priorVAltX,priorVAltY,farVAltX,farVAltY) );
              farStraightness = altVStraightness;
            } 
            //if ( countInfinite==0 && (Double.isInfinite(sumStraightness) || Double.isInfinite(sumStraightnessFar) || Double.isInfinite(sumStraightnessClose)) ) {countInfinite++;}
            sumStraightness+=straightness; sumStraightnessFar+=farStraightness; sumStraightnessClose+=closeStraigthness;
            countInfinite++;
            if (straightness>avgStrRecord ) { countOvAvgStr++;} if (farStraightness>avgStrRecordFar ) { countOvAvgStrFar++;} if (closeStraigthness>avgStrRecordClose ) { countOvAvgStrClose++;}            
          }
          
          
          // ---------------------------- Looping to fill the xSmooth and utmxSmooth
          ArrayList<TableRow> arTableRow = new ArrayList<TableRow>();
          ArrayList<Float> pointsForSmooth = new ArrayList<Float>(); ArrayList<Float> utmPointsForSmooth = new ArrayList<Float>();
          for (int k=0; k < 3; k++){
            TableRow curRow; if (numRows>totalRowCount+k){ curRow = table.getRow(totalRowCount+k); } else { curRow = row;}
            arTableRow.add(curRow); float curX = curRow.getFloat("x"); float curY = curRow.getFloat("y");
            utmSmoothLoop = proj.invTransformCoords( new PVector(curY,curX) );
            pointsForSmooth.add(curX); pointsForSmooth.add(curY); utmPointsForSmooth.add(utmSmoothLoop.x); utmPointsForSmooth.add(utmSmoothLoop.y);
          }
          // Get new points
          ArrayList<Float> pointSmoothed =  smoothPoint(pointsForSmooth); ArrayList<Float> utmPointSmoothed =  smoothPoint(utmPointsForSmooth); 
          row.setFloat("xSmooth", pointSmoothed.get(0)); row.setFloat("ySmooth", pointSmoothed.get(1));
          row.setFloat("utmxSmooth", utmPointSmoothed.get(0)); row.setFloat("utmySmooth", utmPointSmoothed.get(1));

          // Verify if time is always going in the right direction.
          String nextD = nextRow.getString("t");
          OffsetDateTime odtNext = OffsetDateTime.parse(nextD); long millisNext = odtNext.toInstant().toEpochMilli();          
          int nextId = nextRow.getInt("id");
          //if ( nextId == id && odtNext.compareTo(odt)<0 ){ println("odtNext is earlier than odt... id: "+id+", nextId: "+nextId+", odt: "+odt.toString() + " odtNext: "+odtNext.toString()); sumTimeBadlyOrdered++; }
          
          row.setFloat("angle", angle);
          row.setFloat("angleBasedOnDistance",angleFar);
          row.setString("direction",dir);
          row.setString("directionBasedOnDistance",dirFar);
          row.setFloat("straightness",straightness);
        }
    
        // Preparation for the next loop
        countRow++;
        totalRowCount++;
        prevX = x; prevY = y; prevMilli = millis;
      }
    }
  
  println("countSkips: "+countSkips+", countSameIdWrongTime: "+countSameIdWrongTime+", countOrderOk: "+countOrderOk); println("listIdentifiersDone: "+listIdentifiersDone.toString()); println("valVarFc: "+valVarFc/(table.getRowCount())+", valVarEg: "+valVarEg/(table.getRowCount()));
  println("hMap: "+hMap.toString()); println("numPositiveQualId: "+numPositiveQualId.toString());

  for(Map.Entry<Integer, Integer> entry : numPositiveQualId.entrySet()){
    Integer key = entry.getKey(); Integer value = entry.getValue();
    print("ratio positive: "+key+": "+( ((float) value )/ ((float) countIdCases.get(key)) ) +" ");
  }
  for(Map.Entry<Integer, Integer> entry : numVariationsId.entrySet()){ Integer key = entry.getKey(); Integer value = entry.getValue(); }
  
  println("modulo plan, 0%8: EE, 1%8: EM, 2:8: ME, 3%8: MM, 4%8: EH, 5%8: HE, 6%8: MH, 7%8: HM");
  averageDist = sumDist/totalRowCount;
  averageDiffToAvg = sumDiffToAvg/totalRowCount;
  float numToDrop = (totalRowCount-numSmallDist);
  println("countInfinite: "+countInfinite);
  println("averageDist: "+averageDist+", sumDist: "+sumDist+", totalRowCount: "+totalRowCount+", maxDist: "+maxDist+", amountOverAvg: "+amountOverAvg+", averageDiffToAvg: "+averageDiffToAvg);
  println("sumStraightness: "+sumStraightness+ ", sumStraightnessFar: "+sumStraightnessFar+", sumStraightnessClose: "+sumStraightnessClose);
  println("mean straight: "+( sumStraightness/totalRowCount )+ ", far str: "+ (sumStraightnessFar/totalRowCount) + ", close str: "+( sumStraightnessClose/totalRowCount ) );
  println("countOvAvgStr: "+countOvAvgStr+", countOvAvgStrFar: "+countOvAvgStrFar+", countOvAvgStrClose: "+countOvAvgStrClose);
  println("sumTimeBadlyOrdered: "+sumTimeBadlyOrdered);
  
  //saveTable(table, "data/fairlyOK_IDALL_10Jan2014.csv"); //saveTable(table, "data/utm_IDALL_100114_speedSmooth.csv"); //saveTable(table, "data/utm_IDALL_100114_moreAttributesTest.csv");
  saveTable(table, "data/utm_IDALL_moreDates.csv");
}

// 0.0010867288

float xoff = 0.0;
float noiseScaleTest = 0.01; // 0.02 Pretty smooth; 0.1 medium messy; 0.9 mess af
Random rnd = new Random();
int cptDraw=0;

void draw() {
  if (cptDraw==0){
    //background(204); //xoff = xoff + .01; //float n = noise(xoff) * width; //line(n, 0, n, height);
    background(0);
    for (int x=0; x < width; x++) {
      float noiseVal = noise((x)*noiseScaleTest, noiseScaleTest);
      //float noiseVal = noise(rnd.nextInt() * noiseScaleTest, noiseScaleTest);
      stroke(noiseVal*255);
      float randomVal = noiseVal*height;
      //if (x%30==0) println("randomVal: "+ randomVal);
      line(x, 0, x, randomVal);
      cptDraw++;
    }
  }
}


//void draw() {
//  background(250,0,0);
//  //int s = second(); int m = minute(); int h = hour(); line(s, 0, s, 33); line(m, 33, m, 66); line(h, 66, h, 100);
//  //for (int x=0; x < width; x++) {    
//    //float noiseVal = noise((mouseX+x)*noiseScale, mouseY*noiseScale);
//  int x=0;
//  for (TableRow row : table.rows()) {
//    float noiseVal = row.getFloat("engineTemperature");
//    int noisePassengers = row.getInt("numberPassengers");
//    //float noiseVal = noise((mouseX+x)*noiseScale, mouseY*noiseScale);
//    //float noiseVal = noise((x)*noiseScale, x*noiseScale, x*noiseScale);
//    stroke(noiseVal*255);
//    //println("(noiseVal): "+(noiseVal)+", mouseY: "+mouseY);
//    //line(x, mouseY+noiseVal*60, x, height);
//    //line(x, 60+noiseVal*30, x, height);
//    //println("(noisePassengers): "+(noisePassengers)+", mouseY: "+mouseY);
//    //line(x, noiseVal, x, height);
//    line(x, (height/4)*noisePassengers , x, height);
//    x++;
//  }
//}

// Takes latitude/longitude and returns meters
public static float distFrom(float lat1, float lng1, float lat2, float lng2) {
  double earthRadius = 6371000; //meters
  double dLat = Math.toRadians(lat2-lat1);
  double dLng = Math.toRadians(lng2-lng1);
  double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
             Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
             Math.sin(dLng/2) * Math.sin(dLng/2);
  double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  float dist = (float) (earthRadius * c);

  return dist;
}

float cartesianDist(float x1, float y1, float x2, float y2){
  return (float) Math.sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)  );  
}

public static float GetAngleOfLineBetweenTwoPoints(float p1X, float p1Y, float p2X, float p2Y)
{
    float xDiff = p2X - p1X;
    float yDiff = p2Y - p1Y;
    float rez = (float) Math.toDegrees(Math.atan2(yDiff, xDiff));
    if (rez<0) rez+=360;
    return rez;
}
  //// Works fine
  //println("test angle, between 10,10 and 15,15: "+ (GetAngleOfLineBetweenTwoPoints(10,10,15,15)));
  //println("test angle, between 10,10 and 10,15: "+ (GetAngleOfLineBetweenTwoPoints(10,10,10,15)));
  //println("test angle, between 10,10 and 15,10: "+ (GetAngleOfLineBetweenTwoPoints(10,10,15,10)));



/**
 * Find the new point for a smoothed line segment 
 * @param points The list of floats x, then y needed. It was 5 elements in the online example
 * @return The new point for the smoothed line segment
 */
public static ArrayList<Float> smoothPoint(ArrayList<Float> points) {
    float avgX = 0;
    float avgY = 0;
    int cptLoop=0;
    for(Float pointXoY : points) {
      if (cptLoop%2==0){
        avgX += pointXoY;
      } else {
        avgY += pointXoY;
      }
      cptLoop++;
    }
    avgX = avgX/(points.size()/2); avgY = avgY/ (points.size()/2);
    List<Float> newPoint = new ArrayList<Float>(); newPoint.add(avgX); newPoint.add(avgY);
    List<Float> oldPoint = new ArrayList<Float>(); oldPoint.add(points.get(0)); oldPoint.add(points.get(1));
    
    //println("newPoint: "+newPoint.toString()+", oldPoint: "+ oldPoint.toString() + ", cptLoop: "+cptLoop);
    float newX = (newPoint.get(0) + oldPoint.get(0))/2;
    float newY = (newPoint.get(1) + oldPoint.get(1))/2;
    ArrayList<Float> resPoint = new ArrayList<Float>(); resPoint.add(newX); resPoint.add(newY);
    return resPoint;
}
