import java.util.*;
import java.util.Date.*;
import java.util.Iterator;
import java.text.*; //SimpleDateFormat
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import org.gicentre.utils.spatial.UTM;
import org.gicentre.utils.spatial.Ellipsoid;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.lang.Object;
/* package com.javainterviewpoint; import org.json.simple.JSONArray; import org.json.simple.JSONObject; import org.json.simple.parser.JSONParser; */
//import org.gicentre.geomap.GeoMap; //import org.gicentre.utils.spatial.Ellipsoid;//import org.gicentre.utils.spatial.UTM;//import org.joda.time.DateTime;//import org.joda.time.format.DateTimeFormat;//import org.joda.time.format.DateTimeFormatter;

float noiseScale0 = 0.01; // 0.02 Pretty smooth; 0.1 medium messy; 0.9 mess af // Keep a structure with noise((i++)*noiseScale,noiseScale)
// By a lot. Old values: 0.02; 0.1; 0.3. Let's try 0.01; 0.05 and 0.1
// 2021 May 12 => Ease more? Let's try 0.0090; 0.048 and 0.088
float noiseScaleE1 = 0.0090; float noiseScaleE2 = 0.0089;float noiseScaleE3 = 0.0091;float noiseScaleE4 = 0.0088;float noiseScaleE5 = 0.0092;float noiseScaleE6 = 0.0087;float noiseScaleE7 = 0.0093;float noiseScaleE8 = 0.00915;
float noiseScaleM1 = 0.048;float noiseScaleM2 = 0.049;float noiseScaleM3 = 0.047;float noiseScaleM4 = 0.050;float noiseScaleM5 = 0.046;float noiseScaleM6 = 0.051;float noiseScaleM7 = 0.045;float noiseScaleM8 = 0.0485;
float noiseScaleH1 = 0.088;float noiseScaleH2 = 0.089;float noiseScaleH3 = 0.087;float noiseScaleH4 = 0.090;float noiseScaleH5 = 0.086;float noiseScaleH6 = 0.091;float noiseScaleH7 = 0.085;float noiseScaleH8 = 0.0885;
// Values for qualitative variables -> Making it +0.03? no, let's lower them...
//float noiseScaleE4 = 0.02;float noiseScaleM4 = 0.06;float noiseScaleH4 = 0.11; float noiseScaleE5 = 0.025;float noiseScaleM5 = 0.0605;float noiseScaleH5 = 0.105;float noiseScaleE6 = 0.015;float noiseScaleM6 = 0.061;float noiseScaleH6 = 0.115;

Table table;
Table table2 = new Table();
JSONArray jsonData;
JSONArray glbl_DataComplexFinal;

UTM proj = new UTM(new Ellipsoid(Ellipsoid.WGS_84), 35, 'S');    // UTM zone centred on Mediterranean
PVector utm = null;PVector utmNext=null;PVector utmBef=null;PVector utmFar=null;PVector utmPrior=null;PVector utmVFar=null;PVector utmVPrior=null; PVector utmSmooth=null; PVector utmSmoothLoop=null;

void setup() {
  // jsonData = loadJSONArray("kaLineData.210717-1930_10.json");
  jsonData = loadJSONArray("kaLineData.210725-1836_31.json");
  glbl_DataComplexFinal = loadJSONArray("glbl_DataComplexFinal.json");

  //table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/eclipse/vast2014/src/data/jwoData/gps.csv", "header");
  table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/Extracted_Modified/gps_time.csv", "header");
  //table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/Extracted_Modified/gps_10Jan2014_ID1.csv", "header");
  //table = loadTable("C:/Users/kevin/Documents/VAST challenges datasets/VASTChallenge2014/Extracted_Modified/gps_10Jan2014_IDALL.csv", "header");
  println(table.getRowCount() + " total rows in table");

  table.addColumn("numberPassengers");table.addColumn("engineTemperature");table.addColumn("fuelConsumption");table.addColumn("suspensionSpringForce");table.addColumn("wiperOn");table.addColumn("gpsOn");table.addColumn("carPhoneUsed");table.addColumn("heatingSeatsOn");table.addColumn("computerElectricityConsumption");
  table.addColumn("utmx");table.addColumn("utmy");

  // --+-- New functions

  //ArrayList<Float>testInterpolateArr1 =  interpolateArray(5, new ArrayList<Float>(Arrays.asList(10.0,20.0)));
  //ArrayList<Float>testInterpolateArr2 =  interpolateArray(5, new ArrayList<Float>(Arrays.asList(30.0,5.0,20.0)));
  //ArrayList<Float>testInterpolateArr3 =  interpolateArray(8, new ArrayList<Float>(Arrays.asList(-30.0,-5.0,20.0)));
  //  ArrayList<Float>testInterpolateArr4 =  interpolateArray(15, new ArrayList<Float>(Arrays.asList(-30.0,-5.0,20.0)));
  //println("testInterpolateArr1: "+testInterpolateArr1+", testInterpolateArr2: "+testInterpolateArr2+", testInterpolateArr3: "+testInterpolateArr3+", testInterpolateArr4: "+testInterpolateArr4);
    
    ArrayList<Integer> interpolateQlTest = interpolateArrayBinary (12, new ArrayList<Integer>(Arrays.asList(0,0,1,0,0,0,0,1)));
    println("//// interpolateQlTest: "+interpolateQlTest);

    //ArrayList<Float> test2N_a = interpolate(4.0, 9.5, 5); ArrayList<Float> test2N_b = interpolate(-12.0, 9.5, 7);
    //println("test2N_a: "+test2N_a.toString()+", test2N_b: "+test2N_b.toString());
    
  //ArrayList<Float> arrt42 =  interpolateArray(10,new ArrayList<Float>(Arrays.asList(30.0,5.0,20.0)));
  //ArrayList<Float> arrt43 =  interpolateArray(10,new ArrayList<Float>(Arrays.asList(-30.0,-5.0,20.0)));
  //ArrayList<Float> arrt43_b =  interpolateArray(10,new ArrayList<Float>(Arrays.asList(-30.0,45.0,20.0)));
  //println("arrt43_b: "+arrt43_b);
  //ArrayList<Float> arrt44 =  interpolateArray(20,new ArrayList<Float>(Arrays.asList(30.0,-1.0,-1.0,-4.0,5.0,20.0)));
  //println("arrt44: "+arrt44);
  //ArrayList<Float> arrt45 =  interpolateArray(3,new ArrayList<Float>(Arrays.asList(30.0,-1.0,-1.0,-4.0,5.0,20.0)));
  //println("arrt45: "+arrt45);  
  
  HashMap<String,String> complexitiesIdsMods = getDesiredComplexities(4);
  println("complexitiesIdsMods: "+complexitiesIdsMods);  
  ArrayList<Integer> indexesDataMatching_qn_easy = allIndexesForDifficultyQn_Ql("dZ", "easy", jsonData);ArrayList<Integer> indexesDataMatching_qn_medium = allIndexesForDifficultyQn_Ql("dZ", "medium", jsonData);ArrayList<Integer> indexesDataMatching_qn_hard = allIndexesForDifficultyQn_Ql("dZ", "hard", jsonData);
  ArrayList<Integer> indexesDataMatching_ql_easy = allIndexesForDifficultyQn_Ql("dQ", "easy", jsonData);ArrayList<Integer> indexesDataMatching_ql_medium = allIndexesForDifficultyQn_Ql("dQ", "medium", jsonData);ArrayList<Integer> indexesDataMatching_ql_hard = allIndexesForDifficultyQn_Ql("dQ", "hard", jsonData);
  
  //ArrayList<ArrayList<Integer>> test1 = AllTimeInAnIDC(table, glbl_DataComplexFinal);
  //println("test1: "+test1);
  //println("test1.get(0).get(0): "+test1.get(0).get(0));
  //println("info test1.get(0).get(0): "+ glbl_DataComplexFinal.get(test1.get(0).get(0)));
  //println("test1.get(0).size(): "+test1.get(0).size());
  WriteFile(table, table2, jsonData, glbl_DataComplexFinal);
  
  // --+--

  // Normal engine temperature is around 60-65 degrees celsius. Long drive can reach around 80-85 degrees.
  table.addColumn("speed"); table.addColumn("speedSmooth"); table.addColumn("angle");table.addColumn("angleBasedOnDistance"); table.addColumn("direction"); table.addColumn("directionBasedOnDistance");table.addColumn("straightness");
  table.addColumn("lat"); table.addColumn("lon");table.addColumn("xSmooth");table.addColumn("ySmooth");table.addColumn("utmxSmooth");table.addColumn("utmySmooth");
  float diffAngleTotal = 0; float diffAngleTotalFar = 0; String oldDir="";  String oldDirFar=""; float averageDist=0.0;  float sumDist =0.0; float maxDist=0.0; averageDist = 1945.8987;float averageDistFar=0.0; float sumDistFar =0.0; float maxDistFar=0.0;averageDistFar = 1945.8987; int amountOverAvg = 0;float averageDiffToAvg=0.0; float sumDiffToAvg=0.0;float averageClean = 141.0506;
  int numSmallDist=0; float disregardedSum=0.0;float newAverage; float sumStraightness=0; float sumStraightnessClose=0; float sumStraightnessFar=0;int countInfinite=0; float avgStrRecord = 0.0016489563; float avgStrRecordClose = 0.0016241027; float avgStrRecordFar = 3.5712388E-4;int countOvAvgStr = 0; int countOvAvgStrFar = 0; int countOvAvgStrClose = 0;int sumTimeBadlyOrdered = 0;


  int countRow = 0;
  int totalRowCount=0; 
  int maxRowsCount = table.getRowCount();
  int prevID = 0;
  float prevX = -Float.MAX_VALUE; 
  float prevY = -Float.MAX_VALUE;
  long prevMilli = -Long.MAX_VALUE;

  TableRow rowZero = table.getRow(totalRowCount); 
  TableRow rowFive; 
  if ( totalRowCount+5 <= maxRowsCount) { 
    rowFive = table.getRow(totalRowCount+5);
  } else { 
    rowFive = table.getRow(maxRowsCount);
  }
  float xPosBeg = rowZero.getFloat("x"); float yPosBeg = rowZero.getFloat("y");float xPosEnd = rowFive.getFloat("x"); float yPosEnd = rowFive.getFloat("y");
  String dBeg = rowZero.getString("t");
  OffsetDateTime odtBeg = OffsetDateTime.parse(dBeg);
  long millisBeg = odtBeg.toInstant().toEpochMilli();
  String dEnd = rowFive.getString("t"); 
  OffsetDateTime odtEnd = OffsetDateTime.parse(dEnd);
  long millisEnd = odtEnd.toInstant().toEpochMilli();    
  int idBeg = rowZero.getInt("id"); 
  int idEnd = rowFive.getInt("id");

  float timeDiffZero = millisEnd-millisBeg; 
  float timeDiffHZero = 0;
  timeDiffZero /= 1000; // changed to seconds here
  if (timeDiffZero !=0) { 
    timeDiffHZero = timeDiffZero/360;
  }
  println("timeDiffHZero: "+timeDiffHZero);
  println("xPosBeg: "+xPosBeg + ", xPosEnd: "+xPosEnd); 
  println("yPosBeg: "+yPosBeg + ", yPosEnd: "+yPosEnd); 
  println("idBeg: "+idBeg+", idEnd: "+idEnd);
  int countForEnd = 5;
  int countForEnd_E = 15; 
  int countForEnd_M = 10; 
  int countForEnd_H = 5;
  int countBinDurGPS=0; 
  int countBinDurPhone=0; 
  int countBinDurWiper=0; 
  int countBinDurHeatingSeatsOn =0; 
  int prevGPS=0; 
  int prevPhone=0; 
  int prevWiper = 0;

  float minValEngineTemperature = Float.MAX_VALUE; float maxValEngineTemperature = Float.MIN_VALUE; float minValFuelConsumption = Float.MAX_VALUE; float maxValFuelConsumption = Float.MIN_VALUE; float minValComputerElectricityConsumption = Float.MAX_VALUE; float maxValComputerElectricityConsumption = Float.MIN_VALUE;

  
  float valVarEg = 0, valVarFc = 0; 
  int countVariation = 0; 
  float prevEg = 0, prevFc = 0;

  int monthLoop = 0; 
  OffsetDateTime odtLoop = OffsetDateTime.now(); 
  int idLoop=0; 
  int countSkips = 0; 
  int countSameIdWrongTime=0; 
  int countOrderOk = 0; 
  OffsetDateTime odtMax = OffsetDateTime.parse("2000-01-01T00:00:00Z", DateTimeFormatter.ISO_OFFSET_DATE_TIME);
  ArrayList<Integer> listIdentifiersDone = new ArrayList<Integer>(); 
  ArrayList<OffsetDateTime> listDates = new ArrayList<OffsetDateTime>();
  HashMap<Integer, OffsetDateTime> hMap = new HashMap<Integer, OffsetDateTime>();
  HashMap<Integer, Integer> countMonth = new HashMap<Integer, Integer>();
  HashMap<Integer, Integer> countIdCases = new HashMap<Integer, Integer>();
  HashMap<Integer, HashMap <OffsetDateTime, Integer>> countDatesOccurencesId = new  HashMap<Integer, HashMap <OffsetDateTime, Integer>>();
  HashMap<Integer, Integer> numPositiveQualId = new HashMap<Integer, Integer>();
  HashMap<Integer, Integer> numVariationsId = new HashMap<Integer, Integer>(); 
  int prevValWiper=0;
  int numRows = table.getRowCount();
  println("numRows: "+numRows);

  ArrayList<ArrayList<Integer>> allIndexes =  AllTimeInAnIDC(table, glbl_DataComplexFinal);
  for(int i=0; i<allIndexes.size();i++){
    //println("i: "+i+", allIndexes.get(i).size(): "+allIndexes.get(i).size() +", allIndexes: "+allIndexes.get(i));
    int idToGetDataFor = allIndexes.get(i).get(0);
    JSONObject curComplexities = glbl_DataComplexFinal.getJSONObject(i);
    println("curComplexities: "+curComplexities);
  }

  // --------- start of the big loop for calculations for each row
  for (TableRow row : table.rows()) {
    
    
    // Looping over all the trajectories now... we have an index, and for each it defines the type of trajectory we want. MAYBE MAKES MORE SENSE TO DO IN THE JAVASCRIPT
    
    int id = row.getInt("id");
    if ( hMap.get(id) == null ) { listIdentifiersDone.add(id); 
      listDates.add(OffsetDateTime.parse("2000-01-01T00:00:00Z", DateTimeFormatter.ISO_OFFSET_DATE_TIME));
      hMap.put(id, OffsetDateTime.parse("2000-01-01T00:00:00Z", DateTimeFormatter.ISO_OFFSET_DATE_TIME)); //println("test hMap right get:  "+hMap.get(id)); println("test hMap wrong get:  "+hMap.get(42));
    }
    if (prevID != id) { countRow = 0; prevID = id; }

    rowZero = table.getRow(totalRowCount);
    if ( totalRowCount+countForEnd < maxRowsCount) { rowFive = table.getRow(totalRowCount+countForEnd); } else { rowFive = table.getRow(maxRowsCount-1); }
    idBeg = rowZero.getInt("id");  idEnd = rowFive.getInt("id");
    while ( idEnd != idBeg ) {
      countForEnd--;
      if ( totalRowCount+countForEnd < maxRowsCount) { rowFive = table.getRow(totalRowCount+countForEnd); } else { rowFive = table.getRow(maxRowsCount-1); }
      idBeg = rowZero.getInt("id"); idEnd = rowFive.getInt("id");
    }
    countForEnd=5; xPosBeg = rowZero.getFloat("x"); yPosBeg = rowZero.getFloat("y"); xPosEnd = rowFive.getFloat("x"); yPosEnd = rowFive.getFloat("y");



    dBeg = rowZero.getString("t"); 
    odtBeg = OffsetDateTime.parse(dBeg); 
    // println("dBeg: "+dBeg.toString()+", odtBeg: "+odtBeg.toString());
    millisBeg = odtBeg.toInstant().toEpochMilli(); 
    dEnd = rowFive.getString("t"); 
    odtEnd = OffsetDateTime.parse(dEnd); 


    // println("time difference between dBeg: "+dBeg+", and dEnd: "+dEnd+" = "+(dBeg.compareTo(dEnd)));
    // OffsetDateTime testDate = OffsetDateTime.parse("Fri Aug 01 2014 09:02:01 GMT+0100");
    // ArrayList<Integer> indexesTimes =  IsTimeInAnIDC(odtBeg,id,glbl_DataComplexFinal);
    // println("indexesTimes: "+indexesTimes.toString());
    // if (indexesTimes.size()>0){ println("glbl_DataComplexFinal.get(indexesTimes.get(0)) : "+glbl_DataComplexFinal.get(indexesTimes.get(0)).toString());}

    millisEnd = odtEnd.toInstant().toEpochMilli();    
    float smoothDistMeter = distFrom(xPosBeg, yPosBeg, xPosEnd, yPosEnd); float smoothDistKmPoints = smoothDistMeter/100; float speedSmooth=smoothDistKmPoints/timeDiffZero; float speedSmoothKmH = smoothDistKmPoints/timeDiffHZero;

    // Should we consider variations on noise generations?!
    float noiseVal = noise((countRow)*noiseScaleE1, noiseScaleE1);
    float noiseValE1 = noise ( countRow*noiseScaleE1, noiseScaleE1, noiseScaleE1 );float noiseValE2 = noise ( noiseScaleE2, countRow*noiseScaleE2, noiseScaleE2 );float noiseValE3 = noise ( noiseScaleE3, noiseScaleE3, countRow*noiseScaleE3 );float noiseValE4 = noise ( countRow*noiseScaleE4 , countRow*noiseScaleE4, noiseScaleE4 );float noiseValE5 = noise ( countRow*noiseScaleE5, noiseScaleE5, countRow*noiseScaleE5 );float noiseValE6 = noise ( noiseScaleE6, countRow*noiseScaleE6, countRow*noiseScaleE6 );float noiseValE7 = noise ( countRow*noiseScaleE7, countRow*noiseScaleE7, countRow*noiseScaleE7 );float noiseValE8 = noise ( 2*countRow*noiseScaleE8 , noiseScaleE8, noiseScaleE8 ); float noiseValM1 = noise ( countRow*noiseScaleM1, noiseScaleM1, noiseScaleM1 );float noiseValM2 = noise ( noiseScaleM2, countRow*noiseScaleM2, noiseScaleM2 );float noiseValM3 = noise ( noiseScaleM3, noiseScaleM3, countRow*noiseScaleM3 );float noiseValM4 = noise ( countRow*noiseScaleM4, countRow*noiseScaleM4, noiseScaleM4 );float noiseValM5 = noise ( countRow*noiseScaleM5, noiseScaleM5, countRow*noiseScaleM5 );float noiseValM6 = noise ( noiseScaleM6, countRow*noiseScaleM6, countRow*noiseScaleM6 );float noiseValM7 = noise ( countRow*noiseScaleM7, countRow*noiseScaleM7, countRow*noiseScaleM7 );float noiseValM8 = noise ( 2*countRow*noiseScaleM8, noiseScaleM8, noiseScaleM8 ); float noiseValH1 = noise ( countRow*noiseScaleH1, noiseScaleH1, noiseScaleH1 );float noiseValH2 = noise ( noiseScaleH2, countRow*noiseScaleH2, noiseScaleH2 );float noiseValH3 = noise ( noiseScaleH3, noiseScaleH3, countRow*noiseScaleH3 );float noiseValH4 = noise ( countRow*noiseScaleH4, countRow*noiseScaleH4, noiseScaleH4 );float noiseValH5 = noise ( countRow*noiseScaleH5, noiseScaleH5, countRow*noiseScaleH5 );float noiseValH6 = noise ( noiseScaleH6, countRow*noiseScaleH6, countRow*noiseScaleH6 );float noiseValH7 = noise ( countRow*noiseScaleH7, countRow*noiseScaleH7, countRow*noiseScaleH7 );float noiseValH8 = noise ( 2*countRow*noiseScaleH8, noiseScaleH8, noiseScaleH8 ); 
    float valVariationsShared = 45;float noiseTemperature_E = 60 + noiseValE1*valVariationsShared; float noiseTemperature_M = 60 + noiseValM1*valVariationsShared;  float noiseTemperature_H = 60 + noiseValH1*valVariationsShared;float noiseSuspensionSpringForce_E = 77.2 + noiseValE2*valVariationsShared; float noiseSuspensionSpringForce_M = 77.2 + noiseValM2*valVariationsShared; float noiseSuspensionSpringForce_H = 77.2 + noiseValH2*valVariationsShared;float noiseFuelConsumption_E = 75 + noiseValE3*valVariationsShared;float noiseFuelConsumption_M = 75 + noiseValM3*valVariationsShared; float noiseFuelConsumption_H = 75 + noiseValH3*valVariationsShared; float noiseComputerElectricityConsumption_E = 55 + noiseValE7*valVariationsShared; float noiseComputerElectricityConsumption_M = 55 + noiseValM7*valVariationsShared; float noiseComputerElectricityConsumption_H = 55 + noiseValH7*valVariationsShared; 
    float quantHeatingSeatsOn_E=noiseValE8*10; float quantHeatingSeatsOn_M=noiseValM8*10; float quantHeatingSeatsOn_H=noiseValH8*10; float quantWiper_E=noiseValE4*10; float quantWiper_M=noiseValM4*10; float quantWiper_H=noiseValH4*10; float quantGPS_E=noiseValE5*10; float quantGPS_M=noiseValM5*10; float quantGPS_H=noiseValH5*10; float quantPhone_E=noiseValE6*10; float quantPhone_M=noiseValM6*10; float quantPhone_H=noiseValH6*10;
    // Noise 
    float noiseValPassengers = noise(countRow*noiseScaleE1, noiseScaleE1); float noiseValGPS = noise(countRow*noiseScaleE1, noiseScaleE1, noiseScaleE1);  float noiseValWiperOn = noise(noiseScaleE2, countRow*noiseScaleE2, noiseScaleE2 );  float noiseValPhone = noise(noiseScaleE3, noiseScaleE3, 2*countRow*noiseScaleE3); float noiseValHeatingSeatsOn = noise(2*countRow*noiseScaleE4, noiseScaleE4, countRow*noiseScaleE4); int noisePassengers = (int) (noiseValPassengers*4); int noiseGPSon= (int) (noiseValGPS*2);  int noisePhone= (int) (noiseValPhone*2);  int noiseWiperOn = (int) (noiseValWiperOn*2);  int noiseHeatingSeatsOn = (int) (noiseValHeatingSeatsOn*2);



    float x = row.getFloat("x"); float y = row.getFloat("y"); String d = row.getString("t"); OffsetDateTime odt = OffsetDateTime.parse(d); 
    long millis = odt.toInstant().toEpochMilli();
    float speed = 0; float timeDiffH = 0; float speedKmH = 0;

    OffsetDateTime oldMaxT = hMap.get(id); 
    if ( oldMaxT.compareTo(odt) <0 ) { hMap.replace(id, odt); }

    int curMonth = odt.getMonth().getValue(); 
    if (countMonth.get(curMonth) == null) { countMonth.put(curMonth, 0); }
    int sumMonth = countMonth.get(curMonth); 
    sumMonth++; 
    countMonth.replace(curMonth, sumMonth);

    if (countRow == 0) { prevX = row.getFloat("x"); prevY = row.getFloat("y");prevMilli = millis;prevID = id;odtLoop = odt;idLoop=id;monthLoop = curMonth; }

    if ( oldMaxT != null && oldMaxT.compareTo(odt)>=0 ) {
      if ( idLoop ==id ) { countSkips++; }
      countSameIdWrongTime++;
    } else {
      countOrderOk++;
      if (countIdCases.get(id) == null) { countIdCases.put(id, 0); }; 
      int countId = countIdCases.get(id) +1 ; 
      countIdCases.replace(id, countId);
      // Calculate speed
      float timeDiff = millis-prevMilli; 
      timeDiff /= 1000;  
      if (timeDiff !=0) { timeDiffH = timeDiff/360; }
      float distMetersPoints = distFrom(x, y, prevX, prevY); 
      float distKmPoints = distMetersPoints/100; 
      speed = distMetersPoints/timeDiff;
      if (countRow!=0 && timeDiff!=0) { speedKmH = distKmPoints/ timeDiffH; } 
      if (countRow == 0) { speed=0; } // Happens often, but not sure why?

      // data verification
      if (countDatesOccurencesId.get(id) == null) { 
        HashMap<OffsetDateTime, Integer> countHM = new HashMap<OffsetDateTime, Integer> (); 
        countHM.put(odt, 0); 
        countDatesOccurencesId.put(id, countHM);
      }

      if (countDatesOccurencesId.get(id) != null ) {
        HashMap<OffsetDateTime, Integer> timeSelec = countDatesOccurencesId.get(id);
        if (timeSelec.get(odt) == null) { timeSelec.put(odt, 0); }
        int valCptTime = timeSelec.get(odt); 
        valCptTime++; 
        timeSelec.replace(odt, valCptTime);
        if (valCptTime>1) { println("big probleme here, id: "+id+", valCptTime: "+valCptTime+", odt: "+odt.toString()); }
        countDatesOccurencesId.replace(id, timeSelec);
      }

      // Cases selection (Easy_Easy_Medium, etc.) and adaptation of the values based on that.
      int modId = id%8; 
      float noiseFuelConsumption = noiseFuelConsumption_E;float noiseTemperature = noiseTemperature_M;float noiseSuspensionSpringForce = noiseSuspensionSpringForce_H;  // case 0
      float noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_E;
      int actualCountForEnd_GPS = countForEnd, actualCountForEnd_Phone = countForEnd, actualCountForEnd_Wiper = countForEnd, actualCountForEnd_HeatingSeatsOn = countForEnd;
      int countEnd_E = 40; int countEnd_M = 36; int countEnd_H = 32;
      int qualGPS=0; int qualPhone=0; int qualWiper=0; int qualHeatingSeatsOn=0;
      
      // Changes for the possibility to vary with repetition of difficulties in mods. 
      // We order the attributes in three groups [gpsOn,EngineTemperature|carPhoneUsed,fuelConsumption|wiperOn,suspensionSpringForce] 
      if (modId == 0) { 
        actualCountForEnd_GPS = countEnd_E; noiseTemperature = noiseTemperature_E;        
        actualCountForEnd_Phone = countEnd_M; noiseFuelConsumption = noiseFuelConsumption_M; 
        actualCountForEnd_Wiper = countEnd_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H;
         
        if (quantGPS_E>5) { qualGPS=1; };
        if (quantPhone_M>5) { qualPhone=1; };
        if (quantWiper_H>5) { qualWiper=1;  };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_E;
        actualCountForEnd_HeatingSeatsOn = countEnd_E;
        if (quantHeatingSeatsOn_E>5){ qualHeatingSeatsOn=1;}
      } //EE // ee,mm,hh
      else if (modId == 1) { 
        actualCountForEnd_GPS = countEnd_M; noiseTemperature = noiseTemperature_M;
        actualCountForEnd_Phone = countEnd_E; noiseFuelConsumption = noiseFuelConsumption_E; 
        actualCountForEnd_Wiper = countEnd_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H;
        
        if (quantGPS_M>5) { qualGPS=1; };
        if (quantPhone_E>5) { qualPhone=1; };
        if (quantWiper_H>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_M;
        actualCountForEnd_HeatingSeatsOn = countEnd_M;
        if (quantHeatingSeatsOn_M>5){ qualHeatingSeatsOn=1;}
      } // EM // mm,ee,hh
      else if (modId == 2) { 
        actualCountForEnd_GPS = countEnd_E; noiseTemperature = noiseTemperature_E;        
        actualCountForEnd_Phone = countEnd_H; noiseFuelConsumption = noiseFuelConsumption_H;
        actualCountForEnd_Wiper = countEnd_M; noiseSuspensionSpringForce = noiseSuspensionSpringForce_M;
        
        if (quantGPS_E>5) { qualGPS=1; };
        if (quantPhone_H>5) { qualPhone=1; };
        if (quantWiper_M>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_E;
        actualCountForEnd_HeatingSeatsOn = countEnd_E;
        if (quantHeatingSeatsOn_E>5){ qualHeatingSeatsOn=1;}
      } // ME // ee,hh,mm
      else if (modId == 3) { 
        actualCountForEnd_GPS = countEnd_H; noiseTemperature = noiseTemperature_H;
        actualCountForEnd_Phone = countEnd_M; noiseFuelConsumption = noiseFuelConsumption_M;
        actualCountForEnd_Wiper = countEnd_E; noiseSuspensionSpringForce = noiseSuspensionSpringForce_E;
        
        if (quantGPS_H>5) { qualGPS=1; };
        if (quantPhone_M>5) { qualPhone=1; };
        if (quantWiper_E>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_M;
        actualCountForEnd_HeatingSeatsOn = countEnd_M;
        if (quantHeatingSeatsOn_M>5){ qualHeatingSeatsOn=1;}
      } // MM // hh,mm,ee
      else if (modId == 4) { 
        actualCountForEnd_GPS = countEnd_H; noiseTemperature = noiseTemperature_H;
        actualCountForEnd_Phone = countEnd_E; noiseFuelConsumption = noiseFuelConsumption_E; 
        actualCountForEnd_Wiper = countEnd_M; noiseSuspensionSpringForce = noiseSuspensionSpringForce_M;
        
        if (quantGPS_H>5) { qualGPS=1; };
        if (quantPhone_E>5) { qualPhone=1; };
        if (quantWiper_M>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_H;
        actualCountForEnd_HeatingSeatsOn = countEnd_H;
        if (quantHeatingSeatsOn_H>5){ qualHeatingSeatsOn=1;}
      } // EH // hh,ee,mm
      else if (modId == 5) { 
        actualCountForEnd_GPS = countEnd_M; noiseTemperature = noiseTemperature_M;
        actualCountForEnd_Phone = countEnd_H; noiseFuelConsumption = noiseFuelConsumption_H; 
        actualCountForEnd_Wiper = countEnd_E; noiseSuspensionSpringForce = noiseSuspensionSpringForce_E;
        
        if (quantGPS_M>5) { qualGPS=1; };
        if (quantPhone_H>5) { qualPhone=1; };
        if (quantWiper_E>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_E;
        actualCountForEnd_HeatingSeatsOn = countEnd_E;
        if (quantHeatingSeatsOn_E>5){ qualHeatingSeatsOn=1;}
      } // HE // mm,hh,ee
      else if (modId == 6) { 
        actualCountForEnd_GPS = countEnd_E; noiseTemperature = noiseTemperature_E;
        actualCountForEnd_Phone = countEnd_M; noiseFuelConsumption = noiseFuelConsumption_M;
        actualCountForEnd_Wiper = countEnd_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H;
        
        if (quantGPS_E>5) { qualGPS=1; };
        if (quantPhone_M>5) { qualPhone=1; };
        if (quantWiper_H>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_H;
        actualCountForEnd_HeatingSeatsOn = countEnd_H;
        if (quantHeatingSeatsOn_H>5){ qualHeatingSeatsOn=1;}
      } // MH // ee, mm, hh
      else if (modId == 7) { 
        actualCountForEnd_GPS = countEnd_M; noiseTemperature = noiseTemperature_M;        
        actualCountForEnd_Phone = countEnd_E; noiseFuelConsumption = noiseFuelConsumption_E; 
        actualCountForEnd_Wiper = countEnd_H; noiseSuspensionSpringForce = noiseSuspensionSpringForce_H;
        
        if (quantGPS_M>5) { qualGPS=1; };
        if (quantPhone_E>5) { qualPhone=1; };
        if (quantWiper_H>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_M;
        actualCountForEnd_HeatingSeatsOn = countEnd_M; 
        if (quantHeatingSeatsOn_M>5){ qualHeatingSeatsOn=1;}
      } // HM // mm,ee,hh
      else if (id == 17 || id == 23) {
        actualCountForEnd_GPS = countEnd_M; noiseTemperature = noiseTemperature_M;
        actualCountForEnd_Phone = countEnd_H; noiseFuelConsumption = noiseFuelConsumption_H; 
        actualCountForEnd_Wiper = countEnd_E; noiseSuspensionSpringForce = noiseSuspensionSpringForce_E;
        
        if (quantGPS_M>5) { qualGPS=1; };
        if (quantPhone_H>5) { qualPhone=1; };
        if (quantWiper_E>5) { qualWiper=1; };
        
        noiseComputerElectricityConsumption = noiseComputerElectricityConsumption_H;
        actualCountForEnd_HeatingSeatsOn = countEnd_H; 
        if (quantHeatingSeatsOn_H>5){ qualHeatingSeatsOn=1;}
      } // HH // mm,hh,ee

      // reading this again, I wonder why we do it this way.
      if (countRow==0) {
        prevGPS=noiseGPSon; 
        prevPhone=noisePhone;
      }
      if (countBinDurGPS<actualCountForEnd_GPS) { 
        noiseGPSon=prevGPS; 
        countBinDurGPS++;
      } else { 
        prevGPS=noiseGPSon; 
        countBinDurGPS=0;
      }
      if (countBinDurPhone<actualCountForEnd_Phone) { 
        noisePhone=prevPhone; 
        countBinDurPhone++;
      } else { 
        prevPhone=noisePhone; 
        countBinDurPhone=0;
      }
      if (countBinDurWiper<actualCountForEnd_Wiper) { 
        noiseWiperOn=prevWiper; 
        countBinDurWiper++;
      } else { 
        prevWiper=noiseWiperOn; 
        countBinDurWiper=0;
      }

      // converting latlon to utm
      utm = proj.invTransformCoords( new PVector(y, x) );
      
      // This part might not be necessary
      if (minValEngineTemperature > noiseTemperature) { minValEngineTemperature = noiseTemperature; } 
      if (minValFuelConsumption > noiseFuelConsumption) { minValFuelConsumption = noiseFuelConsumption; } 
      if (maxValEngineTemperature < noiseTemperature) { maxValEngineTemperature = noiseTemperature; } 
      if (maxValFuelConsumption < noiseFuelConsumption) { maxValFuelConsumption = noiseFuelConsumption; }
      
      if (minValComputerElectricityConsumption > noiseComputerElectricityConsumption) { minValComputerElectricityConsumption = noiseComputerElectricityConsumption; } 
      if (maxValComputerElectricityConsumption < noiseComputerElectricityConsumption) { maxValComputerElectricityConsumption = noiseComputerElectricityConsumption; }
      
      if (countVariation == 0) { 
        prevFc = noiseFuelConsumption; 
        prevEg = noiseTemperature; 
        countVariation++;
      } else { 
        valVarEg +=  (float) Math.sqrt( Math.pow( (double)(noiseTemperature-prevEg), 2) ); 
        valVarFc += (float) Math.sqrt( Math.pow( (double)(noiseFuelConsumption-prevFc), 2) );  
        prevEg = noiseTemperature; 
        prevFc = noiseFuelConsumption; 
        countVariation++;
      }

      if (numPositiveQualId.get(id) == null) { numPositiveQualId.put(id, 0); } 
      if (  noiseWiperOn == 1 ) { 
        int curValPositiveQual = numPositiveQualId.get(id); 
        curValPositiveQual++; 
        numPositiveQualId.put(id, curValPositiveQual);
      }
      if (countVariation ==0) { prevValWiper = noiseWiperOn; } 
      if ( numVariationsId.get(id) == null ) { numVariationsId.put(id, 0); } 
      if (prevValWiper!=noiseWiperOn) { 
        int curVarWiper = numVariationsId.get(id); 
        curVarWiper++; 
        numVariationsId.put(id, curVarWiper);
      }
      prevValWiper = noiseWiperOn;


      // ---- Latest addition 2021-08-05, we override previous methods in order to work with the data generated in another program for different and more diverse values

      // ----

      // qualGPS,qualPhone,qualWiper
      row.setFloat("fuelConsumption", noiseFuelConsumption); 
      row.setFloat("engineTemperature", noiseTemperature); 
      row.setFloat("suspensionSpringForce", noiseSuspensionSpringForce);
      row.setFloat("speed", speedKmH); 
      row.setFloat("speedSmooth", speedSmoothKmH);
      row.setFloat("utmx", utm.x); 
      row.setFloat("utmy", utm.y); 
      row.setFloat("lat", x); 
      row.setFloat("lon", y);
      row.setInt("numberPassengers", noisePassengers); 
      row.setInt("gpsOn", qualGPS); 
      row.setInt("carPhoneUsed", qualPhone); 
      row.setInt("wiperOn", qualWiper);
      
      row.setFloat("computerElectricityConsumption", noiseComputerElectricityConsumption);
      row.setInt("heatingSeatsOn",qualHeatingSeatsOn);

      // Get the next x and y and get the angle // Wrong somehow... Might need to take the utm values?
      if (totalRowCount<numRows+1) {
        TableRow nextRow = table.getRow(totalRowCount+1); 
        float nextX = nextRow.getFloat("x"); 
        float nextY = nextRow.getFloat("y"); 
        utmNext = proj.invTransformCoords( new PVector(nextY, nextX) );
        TableRow befRow; 
        if ( totalRowCount>0 ) { befRow = table.getRow(totalRowCount-1);} else { befRow= row;} 
        float befX = befRow.getFloat("x"); 
        float befY = befRow.getFloat("y"); 
        utmBef = proj.invTransformCoords( new PVector(befY, befX) );

        // What about selection of the far angle?... 5,3, something else?
        TableRow farRow; 
        if (numRows>totalRowCount+4) { farRow = table.getRow(totalRowCount+5); } else { farRow = row; }
        float farX = farRow.getFloat("x"); 
        float farY = farRow.getFloat("y"); 
        utmFar = proj.invTransformCoords( new PVector(farX, farY) );
        TableRow priorRow; 
        if (totalRowCount>4) {priorRow = table.getRow(totalRowCount-5); } else { priorRow = table.getRow(0); }
        float priorX = priorRow.getFloat("x"); 
        float priorY = priorRow.getFloat("y"); 
        utmPrior = proj.invTransformCoords( new PVector(priorX, priorY) );
        TableRow farVRow; 
        if (numRows>totalRowCount+9) { farVRow = table.getRow(totalRowCount+10); } else {  farVRow = row; }
        float farVX = farVRow.getFloat("x"); 
        float farVY = farVRow.getFloat("y"); 
        utmVFar = proj.invTransformCoords( new PVector(farVX, farVY) );
        TableRow priorVRow; 
        if (totalRowCount>9) { priorVRow = table.getRow(totalRowCount-10); } else {  priorVRow = table.getRow(0); }
        float priorVX = priorVRow.getFloat("x"); 
        float priorVY = priorVRow.getFloat("y"); 
        utmVPrior = proj.invTransformCoords( new PVector(priorVX, priorVY) );

        float angle = GetAngleOfLineBetweenTwoPoints(utm.x, utm.y, utmNext.x, utmNext.y); 
        float angleFar = GetAngleOfLineBetweenTwoPoints(utm.x, utm.y, utmFar.x, utmFar.y);
        float dist = cartesianDist(utm.x, utm.y, utmNext.x, utmNext.y); 
        float distFar = cartesianDist(utm.x, utm.y, utmFar.x, utmFar.y); 
        sumDist+=dist;
        if ( dist>maxDist ) {maxDist=dist;} 
        if (dist> averageDist ) {amountOverAvg++;} 
        sumDiffToAvg+= Math.abs(dist-averageDist);

        // Verify if part of north, south, east or west.
        String dir = ""; 
        if (angle >=45 && angle <135) { dir="North"; } else if (angle >=135 && angle<225 ) { dir="West"; } else if (angle >=225 && angle <315) { dir="South"; } else { dir="East"; }
        float diffAngleLocal = 0; 
        float valAngleBase;
        if (dir=="North") {  valAngleBase=90;} else if (dir=="South") { valAngleBase=270;} else if (dir=="West") { valAngleBase=180;} else { valAngleBase=0;} // Might to be more clever here...
        if (totalRowCount==0) {oldDir=dir;}if (dir != "East") {diffAngleLocal = angle - valAngleBase;} else { if (angle<=360 && angle>= 315) { diffAngleLocal= angle-360;} else { diffAngleLocal=angle;}}          
        diffAngleTotal+=diffAngleLocal;

        String dirFar = ""; 
        if (angleFar >=45 && angleFar <135) { dirFar="North"; } else if (angleFar >=135 && angleFar<225 ) { dirFar="West"; } else if (angleFar >=225 && angleFar <315) { dirFar="South"; } else { dirFar="East"; }
        float diffAngleFar = 0; 
        float valAngleFar;
        if (dirFar=="North") { valAngleFar=90; } else if (dirFar=="South") { valAngleFar=270;} else if (dirFar=="West") {valAngleFar=180; } else { valAngleFar=0; }         
        if (totalRowCount==0) { oldDirFar=dirFar; } 
        if (dirFar != "East") { diffAngleLocal = angleFar - valAngleFar; } else { if (angleFar<=360 && angleFar>= 315) { diffAngleFar= angleFar-360; } else {  diffAngleFar=angleFar;} }          
        diffAngleTotalFar+=diffAngleFar;
        if (dist < averageClean) { dirFar=dir;} 

        float dist_i_to_imn = cartesianDist(priorX, priorY, x, y); 
        float dist_i_to_ipn = cartesianDist(x, y, farX, farY); 
        float dist_imn_to_ipn = cartesianDist(priorX, priorY, farX, farY);

        // Issue, trajectory sometimes goes back to previous positions, messing up even more the straightness calculation
        // In order of distance~index, it goes bef/next -> prior/far -> priorV/farV
        float straightness = (cartesianDist(priorX, priorY, x, y) + cartesianDist(x, y, farX, farY)) / cartesianDist(priorX, priorY, farX, farY);
        float closeStraigthness = ( cartesianDist(befX, befY, x, y) + cartesianDist(x, y, nextX, nextY) ) / (  cartesianDist(befX, befY, nextX, nextY) );
        float farStraightness = ( cartesianDist(priorVX, priorVY, x, y) + cartesianDist(x, y, farVX, farVY) ) / (  cartesianDist(priorVX, priorVY, farVX, farVY) );
        // if ((priorX == farX && priorY == farY) || (priorVX == farVX && priorY == farY) ) { println("repetition of a point"); }

        if ( Double.isInfinite(straightness) || Double.isInfinite(farStraightness) || Double.isInfinite(sumStraightnessClose) ) {
          if ( totalRowCount>0 && (priorX == farX && priorY == farY)  ) {
            TableRow altPriorRow = table.getRow(totalRowCount-4); 
            TableRow altFarRow = table.getRow(totalRowCount+4); 
            float farAltX = altFarRow.getFloat("x"); 
            float farAltY = altFarRow.getFloat("y"); 
            float priorAltX = altPriorRow.getFloat("x"); 
            float priorAltY = altPriorRow.getFloat("y");
            PVector utmAltFar = proj.invTransformCoords( new PVector(farAltX, farAltY) );
            PVector utmAltPrior =  proj.invTransformCoords( new PVector(priorAltX, priorAltY) );
            float altStraightness = (  cartesianDist(priorAltX, priorAltY, x, y) + cartesianDist(x, y, farAltX, farAltY) ) / (  cartesianDist(priorAltX, priorAltY, farAltX, farAltY) );
            straightness=altStraightness;
          }

          if (totalRowCount>0 && (priorVX == farVX && priorVY == farVY)  ) { TableRow altVPriorRow = table.getRow(totalRowCount-9); TableRow altVFarRow = table.getRow(totalRowCount+9); float farVAltX = altVFarRow.getFloat("x");float farVAltY = altVFarRow.getFloat("y");float priorVAltX = altVPriorRow.getFloat("x");float priorVAltY = altVPriorRow.getFloat("y");PVector utmAltVFar = proj.invTransformCoords( new PVector(farVAltX, farVAltY) );PVector utmAltVPrior =  proj.invTransformCoords( new PVector(priorVAltX, priorVAltY) );float altVStraightness = (  cartesianDist(priorVAltX, priorVAltY, x, y) + cartesianDist(x, y, farVAltX, farVAltY) ) / (  cartesianDist(priorVAltX, priorVAltY, farVAltX, farVAltY) );farStraightness = altVStraightness;} 
          //if ( countInfinite==0 && (Double.isInfinite(sumStraightness) || Double.isInfinite(sumStraightnessFar) || Double.isInfinite(sumStraightnessClose)) ) {countInfinite++;}
          sumStraightness+=straightness; sumStraightnessFar+=farStraightness; sumStraightnessClose+=closeStraigthness;
          countInfinite++;
          if (straightness>avgStrRecord ) { countOvAvgStr++; } 
          if (farStraightness>avgStrRecordFar ) { countOvAvgStrFar++; } 
          if (closeStraigthness>avgStrRecordClose ) { countOvAvgStrClose++; }
        }

        // ---------------------------- Looping to fill the xSmooth and utmxSmooth
        ArrayList<TableRow> arTableRow = new ArrayList<TableRow>();
        ArrayList<Float> pointsForSmooth = new ArrayList<Float>(); 
        ArrayList<Float> utmPointsForSmooth = new ArrayList<Float>();
        for (int k=0; k < 3; k++) {
          TableRow curRow; 
          if (numRows>totalRowCount+k) { 
            curRow = table.getRow(totalRowCount+k);
          } else { 
            curRow = row;
          }
          arTableRow.add(curRow); 
          float curX = curRow.getFloat("x"); 
          float curY = curRow.getFloat("y");
          utmSmoothLoop = proj.invTransformCoords( new PVector(curY, curX) );
          pointsForSmooth.add(curX); 
          pointsForSmooth.add(curY); 
          utmPointsForSmooth.add(utmSmoothLoop.x); 
          utmPointsForSmooth.add(utmSmoothLoop.y);
        }
        // Get new points
        ArrayList<Float> pointSmoothed =  smoothPoint(pointsForSmooth); 
        ArrayList<Float> utmPointSmoothed =  smoothPoint(utmPointsForSmooth); 
        row.setFloat("xSmooth", pointSmoothed.get(0)); 
        row.setFloat("ySmooth", pointSmoothed.get(1));
        row.setFloat("utmxSmooth", utmPointSmoothed.get(0)); 
        row.setFloat("utmySmooth", utmPointSmoothed.get(1));

        // Verify if time is always going in the right direction.
        String nextD = nextRow.getString("t");
        OffsetDateTime odtNext = OffsetDateTime.parse(nextD); 
        long millisNext = odtNext.toInstant().toEpochMilli();          
        int nextId = nextRow.getInt("id");
        //if ( nextId == id && odtNext.compareTo(odt)<0 ){ println("odtNext is earlier than odt... id: "+id+", nextId: "+nextId+", odt: "+odt.toString() + " odtNext: "+odtNext.toString()); sumTimeBadlyOrdered++; }

        row.setFloat("angle", angle);
        row.setFloat("angleBasedOnDistance", angleFar);
        row.setString("direction", dir);
        row.setString("directionBasedOnDistance", dirFar);
        row.setFloat("straightness", straightness);
      }

      // Preparation for the next loop
      countRow++;
      totalRowCount++;
      prevX = x; 
      prevY = y; 
      prevMilli = millis;
    }
  }

  println("countSkips: "+countSkips+", countSameIdWrongTime: "+countSameIdWrongTime+", countOrderOk: "+countOrderOk); 
  println("listIdentifiersDone: "+listIdentifiersDone.toString()); 
  println("valVarFc: "+valVarFc/(table.getRowCount())+", valVarEg: "+valVarEg/(table.getRowCount()));
  println("hMap: "+hMap.toString()); 
  println("numPositiveQualId: "+numPositiveQualId.toString());

  for (Map.Entry<Integer, Integer> entry : numPositiveQualId.entrySet()) {
    Integer key = entry.getKey(); 
    Integer value = entry.getValue();
    print("ratio positive: "+key+": "+( ((float) value )/ ((float) countIdCases.get(key)) ) +" ");
  }
  for (Map.Entry<Integer, Integer> entry : numVariationsId.entrySet()) { 
    Integer key = entry.getKey(); 
    Integer value = entry.getValue();
  }

  println("modulo plan, 0%8: EE, 1%8: EM, 2:8: ME, 3%8: MM, 4%8: EH, 5%8: HE, 6%8: MH, 7%8: HM");
  averageDist = sumDist/totalRowCount;
  averageDiffToAvg = sumDiffToAvg/totalRowCount;
  float numToDrop = (totalRowCount-numSmallDist);
  println("countInfinite: "+countInfinite);
  // println("averageDist: "+averageDist+", sumDist: "+sumDist+", totalRowCount: "+totalRowCount+", maxDist: "+maxDist+", amountOverAvg: "+amountOverAvg+", averageDiffToAvg: "+averageDiffToAvg);
  // println("sumStraightness: "+sumStraightness+ ", sumStraightnessFar: "+sumStraightnessFar+", sumStraightnessClose: "+sumStraightnessClose);
  // println("mean straight: "+( sumStraightness/totalRowCount )+ ", far str: "+ (sumStraightnessFar/totalRowCount) + ", close str: "+( sumStraightnessClose/totalRowCount ) );
  // println("countOvAvgStr: "+countOvAvgStr+", countOvAvgStrFar: "+countOvAvgStrFar+", countOvAvgStrClose: "+countOvAvgStrClose);
  // println("sumTimeBadlyOrdered: "+sumTimeBadlyOrdered);

  //saveTable(table, "data/fairlyOK_IDALL_10Jan2014.csv"); //saveTable(table, "data/utm_IDALL_100114_speedSmooth.csv"); //saveTable(table, "data/utm_IDALL_100114_moreAttributesTest.csv");
  saveTable(table, "data/utm_IDALL_moreDates.csv");
}

// 0.0010867288

float xoff = 0.0;
float noiseScaleTest = 0.09; // 0.02 Pretty smooth; 0.1 medium messy; 0.9 mess af
Random rnd = new Random();
int cptDraw=0;

void draw() {
  if (cptDraw==0) {
    //background(204); //xoff = xoff + .01; //float n = noise(xoff) * width; //line(n, 0, n, height);
    background(0);
    for (int x=0; x < width; x++) {
      float noiseVal = noise((x)*noiseScaleTest, 2*noiseScaleTest,(x)*noiseScaleTest);
      //float noiseVal = noise(rnd.nextInt() * noiseScaleTest, noiseScaleTest);
      stroke(noiseVal*255);
      float randomVal = noiseVal*height;
      //if (x%30==0) println("randomVal: "+ randomVal);
      line(x, 0, x, randomVal);
      cptDraw++;
    }
  }
}

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

float cartesianDist(float x1, float y1, float x2, float y2) 
{
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

/**
 * Find the new point for a smoothed line segment 
 * @param points The list of floats x, then y needed. It was 5 elements in the online example
 * @return The new point for the smoothed line segment
 */
public static ArrayList<Float> smoothPoint(ArrayList<Float> points) {
  float avgX = 0;
  float avgY = 0;
  int cptLoop=0;
  for (Float pointXoY : points) {
    if (cptLoop%2==0) {
      avgX += pointXoY;
    } else {
      avgY += pointXoY;
    }
    cptLoop++;
  }
  avgX = avgX/(points.size()/2); 
  avgY = avgY/ (points.size()/2);
  List<Float> newPoint = new ArrayList<Float>(); 
  newPoint.add(avgX); 
  newPoint.add(avgY);
  List<Float> oldPoint = new ArrayList<Float>(); 
  oldPoint.add(points.get(0)); 
  oldPoint.add(points.get(1));

  //println("newPoint: "+newPoint.toString()+", oldPoint: "+ oldPoint.toString() + ", cptLoop: "+cptLoop);
  float newX = (newPoint.get(0) + oldPoint.get(0))/2;
  float newY = (newPoint.get(1) + oldPoint.get(1))/2;
  ArrayList<Float> resPoint = new ArrayList<Float>(); 
  resPoint.add(newX); 
  resPoint.add(newY);
  return resPoint;
}


// Returns an empty ArrayList when not finding a match
public ArrayList<Integer> IsTimeInAnIDC(OffsetDateTime time, int id, JSONArray glbl_DataComplexFinal){
  // println("IsTimeInAnIDC");
  ArrayList<Integer> indexMatchingTimes = new ArrayList<Integer>();
  // println("glbl_DataComplexFinal.size(): "+glbl_DataComplexFinal.size());
  for (int i = 0; i < glbl_DataComplexFinal.size(); i++) {  
      JSONObject explrObject = glbl_DataComplexFinal.getJSONObject(i);
      Integer identifierMover = (Integer) explrObject.get("identifierMover");
    if (id== identifierMover)
    {
      String strBeg = (String) explrObject.get("tBeg");
      OffsetDateTime tBeg = OffsetDateTime.parse(strBeg);
      OffsetDateTime tEnd =OffsetDateTime.parse((String) explrObject.get("tEnd"));

      if (tBeg.compareTo(time)<0 && tEnd.compareTo(time)>0){
        indexMatchingTimes.add(i);
      }
    }
  }
  return indexMatchingTimes;
}


// Returns an empty ArrayList when not finding a match
public ArrayList<ArrayList<Integer>> AllTimeInAnIDC(Table table, JSONArray glbl_DataComplexFinal){
  ArrayList<ArrayList<Integer>> allIndexMatchingTimes = new ArrayList<ArrayList<Integer>>();
  // ArrayList<ArrayList<String>> pointsIdsMatching = new ArrayList<ArrayList<String>>();
  // ArrayList<HashMap<Integer,ArrayList<String>>> indxtoPointsIds = new ArrayList<HashMap<Integer,ArrayList<String>>>();
  
  // HashMap<String,Integer> idcForPointMatching = new HashMap<String,Integer>();
  // println("idcForPointMatching get test: "+idcForPointMatching.get("test")+", is null: "+ (idcForPointMatching.get("test")==null));
  
  Boolean firstBlockMet=false; Boolean lastBlockMet=false;

  for (TableRow row : table.rows()) {
    
    // Looping over all the trajectories now... we have an index, and for each it defines the type of trajectory we want.
    int id = row.getInt("id");
    String _id = row.getString("_id");
    String tStr = row.getString("t"); 
    OffsetDateTime time = OffsetDateTime.parse(tStr);

    // println("glbl_DataComplexFinal.size(): "+glbl_DataComplexFinal.size());
    for (int i = 0; i < glbl_DataComplexFinal.size(); i++) {  
      JSONObject explrObject = glbl_DataComplexFinal.getJSONObject(i);
      Integer identifierMover = (Integer) explrObject.get("identifierMover");
      Integer idc = (Integer) explrObject.get("idc");
      // println("identifierMover: "+identifierMover+", idc: "+idc);
      if (id== identifierMover)
      {
        OffsetDateTime tBeg = OffsetDateTime.parse((String) explrObject.get("tBeg"));
        OffsetDateTime tEnd =OffsetDateTime.parse((String) explrObject.get("tEnd"));

        if (tBeg.equals(time) && !firstBlockMet){
            firstBlockMet=true;
            allIndexMatchingTimes.add(new ArrayList<Integer>());
            allIndexMatchingTimes.get(allIndexMatchingTimes.size()-1).add(i); 

            // pointsIdsMatching.add(new ArrayList<String>());
            // indxtoPointsIds.add(new HashMap<Integer,ArrayList<String>>());
            
            // indxtoPointsIds.get(indxtoPointsIds.size()-1).put(idc,new ArrayList<String>());
            // println("allIndexMatchingTimes.size(): "+allIndexMatchingTimes.size()+", time: "+time+", tBeg: "+tBeg+", tEnd: "+tEnd+", firstBlockMet: "+firstBlockMet+", tBeg.compareTo(time)<0"+(tBeg.compareTo(time)<0)+", tEnd.compareTo(time)>0: "+(tEnd.compareTo(time)>0));
        }
        if (tEnd.equals(time)){
          allIndexMatchingTimes.get(allIndexMatchingTimes.size()-1).add(i); 
          firstBlockMet=false;
          // There's more to do. We have an index for the glbl_DataComplexFinal for which each element should use an element from Jason data... But maybe we want to do that outside of the loop... outisde of this function?          
        }
        if (firstBlockMet){}
        
        if ( firstBlockMet && tBeg.compareTo(time)<0 && tEnd.compareTo(time)>0){ 
          allIndexMatchingTimes.get(allIndexMatchingTimes.size()-1).add(i); 
          // pointsIdsMatching.get(pointsIdsMatching.size()-1).add(_id);
          // //indxtoPointsIds.set(pointsIdsMatching.size()-1).add(_id);
          // indxtoPointsIds.get(indxtoPointsIds.size()-1).get(idc).add(_id);
          
          // idcForPointMatching.put(_id,idc);
        }

      }
    }
  }
  //println("pointsIdsMatching: "+pointsIdsMatching);
  // println("indxtoPointsIds: "+indxtoPointsIds);
  return allIndexMatchingTimes;
}

public HashMap<String,Integer> GetHashMapPointIdToIdc(Table table, JSONArray glbl_DataComplexFinal){
  HashMap<String,Integer> idcForPointMatching = new HashMap<String,Integer>();
  // println("idcForPointMatching get test: "+idcForPointMatching.get("test")+", is null: "+ (idcForPointMatching.get("test")==null));
  
  Boolean firstBlockMet=false; Boolean lastBlockMet=false;

  for (TableRow row : table.rows()) {
    // Looping over all the trajectories now... we have an index, and for each it defines the type of trajectory we want.
    int id = row.getInt("id");
    String _id = row.getString("_id");
    String tStr = row.getString("t"); 
    OffsetDateTime time = OffsetDateTime.parse(tStr);

    for (int i = 0; i < glbl_DataComplexFinal.size(); i++) {  
      JSONObject explrObject = glbl_DataComplexFinal.getJSONObject(i);
      Integer identifierMover = (Integer) explrObject.get("identifierMover");
      Integer idc = (Integer) explrObject.get("idc");
      // println("identifierMover: "+identifierMover+", idc: "+idc);
      if (id== identifierMover)
      {
        OffsetDateTime tBeg = OffsetDateTime.parse((String) explrObject.get("tBeg"));
        OffsetDateTime tEnd =OffsetDateTime.parse((String) explrObject.get("tEnd"));

        if (tBeg.equals(time) && !firstBlockMet){
            firstBlockMet=true;
            idcForPointMatching.put(_id,idc);            
        }
        if (tEnd.equals(time)){
          idcForPointMatching.put(_id,idc);          
          firstBlockMet=false;
        }
        if (firstBlockMet){}
        
        if ( firstBlockMet && tBeg.compareTo(time)<0 && tEnd.compareTo(time)>0){           
          idcForPointMatching.put(_id,idc);
        }

      }
    }
  }
  return idcForPointMatching;
}


public ArrayList<Float> interpolateArray(int fitCount, ArrayList<Float> data) {
  ArrayList<Float> newData = new ArrayList<Float>();
  float springFactor = ((float) data.size() - 1) / ((float) fitCount - 1);
  newData.add(data.get(0)); // for new allocation
  for ( int i = 1; i < fitCount - 1; i++) {
    float tmp = i * springFactor;
    float before = (float) Math.floor(tmp);
    float after = (float) Math.ceil(tmp);
    float atPoint = (float) tmp - before;
    // newData.add ( this.linearInterpolate(data.get(before), data.get(after) , atPoint) );
    // float[] interp = interpolate(data.get(before), data.get(after) , atPoint) ;
    newData.add(lerp(data.get((int)before),data.get((int)after),atPoint));
    }
  newData.add(data.get(data.size()- 1)); // for new allocation
  return newData;
};

/***
 * Interpolating method
 * @param start start of the interval
 * @param end end of the interval
 * @param count count of output interpolated numbers
 * @return array of interpolated number with specified count
 */
public static ArrayList<Float> interpolate(Float start, Float end, int count) {
    if (count < 2) {
        throw new IllegalArgumentException("interpolate: illegal count!");
    }
    Float[] array = new Float[count + 1];
    for (int i = 0; i <= count; ++ i) {
        Float calc = start + i * (end - start) / count;
        array[i] = calc;
    }
    ArrayList<Float> res = new ArrayList<Float>(Arrays.asList(array));
    return res;
}



public ArrayList<Integer> interpolateArrayBinary (int fitCount, ArrayList<Integer> data) {
  println("data: "+data);
  ArrayList<Integer> newData = new ArrayList<Integer>();
  float springFactor = ((float) data.size() - 1) / ((float) fitCount - 1);
  newData.add(data.get(0)); // for new allocation
  for ( int i = 1; i < fitCount - 1; i++) {
    float tmp = i * springFactor;
    float before = (float) Math.floor(tmp);
    float after = (float) Math.ceil(tmp);
    float atPoint = (float) tmp - before;
    println("tmp: "+tmp+", before: "+before+", after: "+after+", atPoint: "+atPoint);
    // newData.add ( this.linearInterpolate(data.get(before), data.get(after) , atPoint) );
    // float[] interp = interpolate(data.get(before), data.get(after) , atPoint) ;
    newData.add( Math.round( lerp(data.get((int)before),data.get((int)after),atPoint)) );
    }
  newData.add(data.get(data.size()- 1)); // for new allocation
  return newData;

};

public ArrayList<Float> changeJSONarrayToArrayListFloat(JSONArray jsonArray){
  ArrayList<Float> list = new ArrayList<Float>();     
  if (jsonArray != null) { 
     int len = jsonArray.size();
     for (int i=0;i<len;i++){ 
      // list.add((float) jsonArray.get(i));
      list.add(Float.valueOf(String.valueOf(jsonArray.get(i))));
     }
  } 
  return list;
}

public ArrayList<Integer> changeJSONarrayToArrayListInteger(JSONArray jsonArray){
  ArrayList<Integer> list = new ArrayList<Integer>();     
  if (jsonArray != null) { 
     int len = jsonArray.size();
     for (int i=0;i<len;i++){ 
      // list.add((float) jsonArray.get(i));
      list.add(Integer.valueOf(String.valueOf(jsonArray.get(i))));
     }
  } 
  return list;
}



public HashMap<String,String> getDesiredComplexities(int modId){
  HashMap<String,String>  res = new HashMap<String,String>();

  // Changes for the possibility to vary with repetition of difficulties in mods. 
  // We order the attributes in three groups [gpsOn,EngineTemperature|carPhoneUsed,fuelConsumption|wiperOn,suspensionSpringForce] 
  if (modId == 0) {         
    res.put("heatingSeatsOn","easy");res.put("computerElectricityConsumption","easy");
    res.put("gpsOn","easy");res.put("engineTemperature","easy");
    res.put("carPhoneUsed","medium");res.put("fuelConsumption","medium");
    res.put("wiperOn","hard");res.put("suspensionSpringForce","hard");
  } //EE // ee,mm,hh
  else if (modId == 1) { 
    res.put("heatingSeatsOn","easy");res.put("computerElectricityConsumption","medium");
    res.put("gpsOn","medium");res.put("engineTemperature","medium");
    res.put("carPhoneUsed","easy");res.put("fuelConsumption","easy");
    res.put("wiperOn","hard");res.put("suspensionSpringForce","hard");
  } // EM // mm,ee,hh
  else if (modId == 2) { 
    res.put("heatingSeatsOn","medium");res.put("computerElectricityConsumption","easy");
    res.put("gpsOn","easy");res.put("engineTemperature","easy");
    res.put("carPhoneUsed","hard");res.put("fuelConsumption","hard");
    res.put("wiperOn","medium");res.put("suspensionSpringForce","medium");
  } // ME // ee,hh,mm
  else if (modId == 3) { 
    res.put("heatingSeatsOn","medium");res.put("computerElectricityConsumption","medium");
    res.put("gpsOn","hard");res.put("engineTemperature","hard");
    res.put("carPhoneUsed","medium");res.put("fuelConsumption","medium");
    res.put("wiperOn","easy");res.put("suspensionSpringForce","easy");
  } // MM // hh,mm,ee
  else if (modId == 4) { 
    res.put("heatingSeatsOn","easy");res.put("computerElectricityConsumption","hard");
    res.put("gpsOn","hard");res.put("engineTemperature","hard");
    res.put("carPhoneUsed","easy");res.put("fuelConsumption","easy");
    res.put("wiperOn","medium");res.put("suspensionSpringForce","medium");
  } // EH // hh,ee,mm
  else if (modId == 5) { 
    res.put("heatingSeatsOn","hard");res.put("computerElectricityConsumption","easy");
    res.put("gpsOn","medium");res.put("engineTemperature","medium");
    res.put("carPhoneUsed","hard");res.put("fuelConsumption","hard");
    res.put("wiperOn","easy");res.put("suspensionSpringForce","easy");
  } // HE // mm,hh,ee
  else if (modId == 6) { 
    res.put("heatingSeatsOn","easy");res.put("computerElectricityConsumption","easy");
    res.put("gpsOn","easy");res.put("engineTemperature","easy");
    res.put("carPhoneUsed","medium");res.put("fuelConsumption","medium");
    res.put("wiperOn","hard");res.put("suspensionSpringForce","hard");
  } // MH // ee, mm, hh
  else if (modId == 7) { 
    res.put("heatingSeatsOn","hard");res.put("computerElectricityConsumption","medium");
    res.put("gpsOn","medium");res.put("engineTemperature","medium");
    res.put("carPhoneUsed","easy");res.put("fuelConsumption","easy");
    res.put("wiperOn","hard");res.put("suspensionSpringForce","hard");
  } // HM // mm,ee,hh
  else if (modId == 17 || modId == 23) {
    res.put("heatingSeatsOn","hard");res.put("computerElectricityConsumption","hard");
    res.put("gpsOn","medium");res.put("engineTemperature","medium");
    res.put("carPhoneUsed","hard");res.put("fuelConsumption","hard");
    res.put("wiperOn","easy");res.put("suspensionSpringForce","easy");
  } // HH // mm,hh,ee  

  return res;
}

public ArrayList<Integer> allIndexesForDifficultyQn_Ql(String typeData, String attributeDifficulty, JSONArray jsonData){
  ArrayList<Integer> res = new ArrayList<Integer>();
  int numDesiredDiff;
  if (attributeDifficulty=="easy"){numDesiredDiff=0;} else if (attributeDifficulty=="medium"){numDesiredDiff=1;}else{numDesiredDiff=2;}
  for (int i = 0; i < jsonData.size(); i++) {  
    JSONObject dGenerated = jsonData.getJSONObject(i);
    // println("dGenerated: "+dGenerated);
    int diffNumber;
    if (typeData=="dZ"){
      diffNumber = (Integer) dGenerated.get("dZ");
    } else {
      diffNumber = (Integer) dGenerated.get("dQ");
    }

    // If it matches, let's push it
    if (diffNumber==numDesiredDiff){
      res.add(i);
    }
  }
  return res;
}


public JSONObject getInfoForIdc(Integer idc, JSONArray glbl_DataComplexFinal){
  int indexObj=-1;
  for(int i=0;i<glbl_DataComplexFinal.size();i++){
    JSONObject explrObject = glbl_DataComplexFinal.getJSONObject(i);
    if (idc == explrObject.getInt("idc")){
      indexObj=i;
    }
  }
  if(indexObj!= -1){
    return glbl_DataComplexFinal.getJSONObject(indexObj);
  } else {
    return new JSONObject();
  }
}

public HashMap<Integer,Integer> idcToNumToInterpolateTo (Table table, JSONArray glbl_DataComplexFinal){
  ArrayList<ArrayList<Integer>> allIndexesMatchingTime = AllTimeInAnIDC(table, glbl_DataComplexFinal);
  HashMap<Integer,Integer> res = new HashMap<Integer,Integer>();
  for (int i=0; i < allIndexesMatchingTime.size(); i++){
    JSONObject infoObj = (JSONObject) glbl_DataComplexFinal.get(allIndexesMatchingTime.get(i).get(0));
    int numToInterpolateTo = allIndexesMatchingTime.get(i).size();
    res.put(infoObj.getInt("idc"),numToInterpolateTo);
  }
  return res;
}



public void WriteFile(Table table, Table table2, JSONArray jsonData, JSONArray glbl_DataComplexFinal ){
  println("**** WriteFile");
  
  table2.addColumn("_id");table2.addColumn("identifier");table2.addColumn("x");table2.addColumn("y");
  table2.addColumn("numberPassengers");table2.addColumn("engineTemperature");table2.addColumn("fuelConsumption");table2.addColumn("suspensionSpringForce");table2.addColumn("wiperOn");table2.addColumn("gpsOn");table2.addColumn("carPhoneUsed");table2.addColumn("heatingSeatsOn");table2.addColumn("computerElectricityConsumption");
  table2.addColumn("utmx");table2.addColumn("utmy");


  ArrayList<Integer> indexesDataMatching_qn_easy = allIndexesForDifficultyQn_Ql("dZ", "easy", jsonData);ArrayList<Integer> indexesDataMatching_qn_medium = allIndexesForDifficultyQn_Ql("dZ", "medium", jsonData);ArrayList<Integer> indexesDataMatching_qn_hard = allIndexesForDifficultyQn_Ql("dZ", "hard", jsonData);
  ArrayList<Integer> indexesDataMatching_ql_easy = allIndexesForDifficultyQn_Ql("dQ", "easy", jsonData);ArrayList<Integer> indexesDataMatching_ql_medium = allIndexesForDifficultyQn_Ql("dQ", "medium", jsonData);ArrayList<Integer> indexesDataMatching_ql_hard = allIndexesForDifficultyQn_Ql("dQ", "hard", jsonData);

  ArrayList<ArrayList<Integer>> indexesDataMatching_qn = new ArrayList<ArrayList<Integer>>();indexesDataMatching_qn.add(indexesDataMatching_qn_easy);indexesDataMatching_qn.add(indexesDataMatching_qn_medium);indexesDataMatching_qn.add(indexesDataMatching_qn_hard);
  ArrayList<ArrayList<Integer>> indexesDataMatching_ql = new ArrayList<ArrayList<Integer>>();indexesDataMatching_ql.add(indexesDataMatching_ql_easy);indexesDataMatching_ql.add(indexesDataMatching_ql_medium);indexesDataMatching_ql.add(indexesDataMatching_ql_hard);
  ArrayList<ArrayList<Integer>> allIndexesMatchingTime = AllTimeInAnIDC(table, glbl_DataComplexFinal);  
  
  HashMap<Integer,Integer> idcToNumToInterpolateTo = idcToNumToInterpolateTo (table, glbl_DataComplexFinal);
  
  HashMap<String,Integer> idxForPoint = GetHashMapPointIdToIdc(table, glbl_DataComplexFinal);

  // The code to put te utmX and utmY columns:       
  UTM proj = new UTM(new Ellipsoid(Ellipsoid.WGS_84), 35, 'S'); // UTM zone centred on Mediterranean
  PVector utm;  // converting latlon to utm


  Random random = new Random();   
  HashMap <Integer,Boolean> idcMet = new HashMap <Integer,Boolean>();
  // We write 4 attributes for Qn and 4 for Ql
  ArrayList<ArrayList<Float>> qnInterpolated = new ArrayList<ArrayList<Float>>();
  ArrayList<ArrayList<Integer>> qlInterpolated = new ArrayList<ArrayList<Integer>>();
  int indexQnInterpolated=0; int indexQlInterpolated=0;

  int indexForFilling;

  // Work in progress... loop first to fill the positions?
  // loop to put the ...
  for (TableRow row : table.rows()) {
    int id = row.getInt("id");
    String  _id = row.getString("_id");
    int modId = id%8;
    HashMap<String,String> complexitiesIdsMods = getDesiredComplexities(modId);

    // Only fill if the row is part of the elements we want
    if (idxForPoint.containsKey(_id)) {
      int idc = idxForPoint.get(_id);
      // If that element wasn't loaded yet, do it now
      if (!idcMet.containsKey(idc)){
        idcMet.put(idc,true);
        JSONObject infoIdc = getInfoForIdc(idc,glbl_DataComplexFinal);
        
        qnInterpolated = new ArrayList<ArrayList<Float>>();
        qlInterpolated = new ArrayList<ArrayList<Integer>>();
        indexQnInterpolated=0; indexQlInterpolated=0;
        indexForFilling=0;
        
        HashMap<String,String> desiredComplex = getDesiredComplexities(modId);
        println("desiredComplex: "+desiredComplex);
        HashMap<String,Integer> indForEachAttribute= new HashMap<String,Integer>();
        Iterator keySetIterator = desiredComplex.keySet().iterator();
        while (keySetIterator.hasNext()){
          String key = (String) keySetIterator.next();          
          if(desiredComplex.get(key)=="easy"){indForEachAttribute.put(key,0);} else if(desiredComplex.get(key)=="medium"){indForEachAttribute.put(key,1);} else {indForEachAttribute.put(key,2);} ;

          if(key=="engineTemperature" || key=="fuelConsumption"||key=="suspensionSpringForce"||key=="computerElectricityConsumption"){
            println("key: "+key);
            ArrayList<Integer> thisDataMatching_qn = indexesDataMatching_qn.get(indForEachAttribute.get(key));
            Integer randSelecQnIndx = random.nextInt(thisDataMatching_qn.size());
            JSONObject objMatchQn = jsonData.getJSONObject(randSelecQnIndx);
            JSONArray qnDataJSON = objMatchQn.getJSONArray("zData");
            ArrayList<Float> qnData = changeJSONarrayToArrayListFloat(qnDataJSON);
            println("qnData.size(): "+qnData.size());
            int numToInterpolateTo = idcToNumToInterpolateTo.get(idc);
          
            qnInterpolated.add(interpolateArray(numToInterpolateTo,qnData));
            println("numToInterpolateTo: "+numToInterpolateTo+", qnInterpolated.get(0).size(): "+qnInterpolated.get(0).size()); 
            indexQnInterpolated=0;

          } else {
            println("key: "+key);
            ArrayList<Integer> thisDataMatching_ql = indexesDataMatching_ql.get(indForEachAttribute.get(key));
            Integer randSelecQlIndx = random.nextInt(thisDataMatching_ql.size());
            JSONObject objMatchQl = jsonData.getJSONObject(randSelecQlIndx);
            JSONArray qlDataJSON = objMatchQl.getJSONArray("qData");
            ArrayList<Integer> qlData = changeJSONarrayToArrayListInteger(qlDataJSON);
            println("qlData.size(): "+qlData.size());
            int numToInterpolateTo = idcToNumToInterpolateTo.get(idc);
          
            qlInterpolated.add(interpolateArrayBinary(numToInterpolateTo,qlData));
            println("numToInterpolateTo: "+numToInterpolateTo+", qlInterpolated.get(0).size(): "+qlInterpolated.get(0).size()); 
            indexQlInterpolated=0;            

          }
          // ArrayList<Float> qnToInterpolate = jsonData.get(randSelecQnIndx).get("zData");
          // ArrayList<Integer> qlToInterpolate = thisDataMatching_ql.get(randSelecQnIndx).getJsonArray("qData");        
        }
        //String diffQn = infoIdc.getString("Complexity_WHAT_Qn"); String diffQl = infoIdc.getString("Complexity_WHAT_Ql"); int indexOfIndexesMatchingQn; int indexOfIndexesMatchingQl;
        //if (diffQn=="E"){indexOfIndexesMatchingQn=0;}else if(diffQn=="M"){indexOfIndexesMatchingQn=1;} else{indexOfIndexesMatchingQn=2;} //if (diffQl=="E"){indexOfIndexesMatchingQl=0;}else if(diffQl=="M"){indexOfIndexesMatchingQl=1;} else{indexOfIndexesMatchingQl=2;}

        if (qnInterpolated.size()>0){
          println("qnInterpolated.size() :"+qnInterpolated.size()+", qnInterpolated.get(0).size(): "+qnInterpolated.get(0).size());
        }
        if (qlInterpolated.size()>0){
          println("qlInterpolated.size() :"+qlInterpolated.size()+", qlInterpolated.get(0).size(): "+qlInterpolated.get(0).size());
        }

      }
      
      // todo: fill - the key exists already... what do we want to do now?
      // {heatingSeatsOn=hard, suspensionSpringForce=easy, wiperOn=easy, computerElectricityConsumption=easy, engineTemperature=medium, gpsOn=medium, carPhoneUsed=hard, fuelConsumption=hard}
      ArrayList<Integer> v_heatingSeatsOn = qlInterpolated.get(0), v_wiperOn = qlInterpolated.get(1),v_gpsOn = qlInterpolated.get(2), v_carPhoneUsed = qlInterpolated.get(3);
      ArrayList<Float> v_suspensionSpringForce = qnInterpolated.get(0), v_computerElectricityConsumption = qnInterpolated.get(1), v_engineTemperature = qnInterpolated.get(2), v_fuelConsumption = qnInterpolated.get(3) ;

      row.setInt("heatingSeatsOn",v_heatingSeatsOn.get(indexQlInterpolated));row.setInt("wiperOn",v_wiperOn.get(indexQlInterpolated));row.setInt("gpsOn",v_gpsOn.get(indexQlInterpolated));row.setInt("carPhoneUsed",v_carPhoneUsed.get(indexQlInterpolated));
      row.setFloat("suspensionSpringForce",v_suspensionSpringForce.get(indexQnInterpolated));row.setFloat("computerElectricityConsumption",v_computerElectricityConsumption.get(indexQnInterpolated));row.setFloat("engineTemperature",v_engineTemperature.get(indexQnInterpolated));row.setFloat("fuelConsumption",v_fuelConsumption.get(indexQnInterpolated));
      
      indexQnInterpolated++;indexQlInterpolated++;
      
      float x = row.getFloat("x"); float y = row.getFloat("y"); String d = row.getString("t"); OffsetDateTime odt = OffsetDateTime.parse(d); 
      utm = proj.invTransformCoords( new PVector(y, x) );
      row.setFloat("utmx", utm.x); 
      row.setFloat("utmy", utm.y);   
    }
  }

  saveTable(table, "data/data_v3.csv");
  println("****");
}
