/*****************************************************************************/
/* Original: The Nature of Code <http://www.shiffman.net/teaching/nature>    */
/*           Spring 2011, Box2DProcessing example                            */
/* Edited:   Spring 2016 by Nils Napp, Petra Jennings, and Kirstin Petersen  */
/* Edited:   Spring 2017 by Evangelos Pantazis  */
/*****************************************************************************/


import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

Box2DProcessing box2d;            //A reference to our box2d world

PImage bg;                        //Background image

int counter = 0;                 //counter
int robotCounter=0;
int boundaryWidth = 35;

ArrayList<Boundary> boundaries;   //List of fixed objects

//Objects in the world:

ArrayList<Robot> robots;          //List of robot ojbects used in simulation
ArrayList<Part>  parts;           //List of part objects used in simulation
ArrayList<CustomBoundary> bounds;

// list for the name / number of different parts and robots
int robotTypes; // number of different robot types
int partTypes;  // number of different part  types
int boundaryTypes;  // number of different part  types


String[] boundaryFileNames;
String[] robotFileNames;
String[] partFileNames;

int[] robotCounts;
int[] partCounts;
int[] boundaryCounts;

boolean robotsDone;
boolean partsDone;
boolean customBoundaryDone;
boolean recording = false;
//corner chamfer for boudary
float chamfer =300;

int edge_offset_part=30;           //Distance from edge for randomly placing parts and robots
int edge_offset_mover=100;         //?

//Variables for logging
PrintWriter logfile;
String logname = "logs/logfile";
boolean printHeader;

//timer
long startTime;
long lastTime;
long deltaTms=3000; // Time between logging and frame saving events

Boolean globalCollison=false;

/*****************************************************/
/* Setup world                                       */
/*****************************************************/

void readSimDef(String fname) {
  JSONObject obj;
  JSONArray  jar;
  JSONObject jprt;

  try {
    obj = loadJSONObject(fname); 

    try {
      jar= obj.getJSONArray("robots");
      robotTypes = jar.size();        
      print("Found "  + robotTypes  +" different robot types in " + fname + ":\n");
      // instantiate the part count array
      robotCounts = new int[robotTypes];
      robotFileNames = new String[robotTypes];

      // loop through different robot parts
      for (int i=0; i < jar.size (); i++) {
        jprt=jar.getJSONObject(i);
        robotFileNames[i]=jprt.getString("file");
        robotCounts[i]=jprt.getInt("count");
        print("    " + robotCounts[i] + " times " + robotFileNames[i] + "\n");
      }
    } 
    catch(RuntimeException e) {
      print("Couldn't read robot array in simulation file.\n\n");
    }

    try {
      jar= obj.getJSONArray("parts");
      partTypes = jar.size();
      print("Found "  +  partTypes  +" different part types in " + fname + ":\n");

      // instantiate the part count array 
      partCounts = new int[partTypes];
      partFileNames = new String[partTypes];

      // loop through different robot parts
      for (int i=0; i < partTypes; i++) {
        jprt=jar.getJSONObject(i);
        partFileNames[i]=jprt.getString("file");
        partCounts[i]=jprt.getInt("count");
        print("    " + partCounts[i] + " times " + partFileNames[i] + "\n");
      }
    } 
    catch(RuntimeException e) {
      print("Couldn't read part array in simulation file.\n\n");
    }
    try {
      jar= obj.getJSONArray("boundaries");
      boundaryTypes = jar.size();
      print("Found "  +  boundaryTypes  +" different boundary types in " + fname + ":\n");

      // instantiate the boundary count array 
      boundaryCounts = new int[boundaryTypes];
      boundaryFileNames = new String[boundaryTypes];

      // loop through different boundaries
      for (int i=0; i < boundaryTypes; i++) {
        jprt=jar.getJSONObject(i);
        boundaryFileNames[i]=jprt.getString("file");
        boundaryCounts[i]=jprt.getInt("count");
        print("    " + boundaryCounts[i] + " times " + boundaryFileNames[i] + "\n");
      }
    } 
    catch(RuntimeException e) {
      print("Couldn't read boundary array in simulation file.\n\n");
    }
  }  
  catch(RuntimeException e) {
    print("Could not parse " +  fname + ".\nEXCEPTION MESSAGE: " + e.getMessage() + "\n");
    print("Defaulting to preset values.\n\n");
  }
}

void setup() {

  size(1600, 1100);                            //Size of canvas
  smooth();
  box2d = new Box2DProcessing(this);          //Initialize box2d physics
  box2d.createWorld();                        //Create world
  box2d.setGravity(0, 0);                     //Neglect gravity

  // Turn on collision listening!
  box2d.listenForCollisions();
  readSimDef("SimulationSetup.json");
  //Create parts lists:
  boundaries = new ArrayList<Boundary>();
  parts = new ArrayList<Part>();
  robots = new ArrayList<Robot>();
  bounds = new ArrayList<CustomBoundary>();

  // /////////////Create BOX boundaries
  //  CustomBoundary face = new CustomBoundary(500, 300, boundaryFileNames[0]);
  //  face.display();
  //  bounds.add(face);
  //Create box boundaries
  //  boundaries.add(new Boundary(width-5, height/2, 10, height));
  //  boundaries.add(new Boundary(5, height/2, 10, height));  
  //  boundaries.add(new Boundary(width/2, 5, width-20, 10));
  //  boundaries.add(new Boundary(width/2, height-5, width-100, 10));
  //  boundaries.add(new Boundary(0,0,chamfer));


  //load an image for the background  
  bg = loadImage("background_an_crop.PNG");
  bg.resize(width, height);
 ////////////////Draw a custom boundary///////////////////////
  //println ("boundary types are: " + boundaryTypes);
  customBoundaryDone=true;
  for (int i=0; i<boundaryTypes; i++) {
    // print("boundary=" + i + "   counts=" + boundaryCounts[i] + "\n");
    
      CustomBoundary face = new CustomBoundary(300, 200, boundaryFileNames[i]);
      //println ("created one boundary from a face");
      bounds.add(face);
      customBoundaryDone=false;
      break;
    
  }

  // file name and inital logging related variables
  logfile=createWriter(logname + "_" + round(random(0, 10000)) + ".log");
  printHeader=true;

  lastTime=System.currentTimeMillis();
  startTime=lastTime;
}

/*************************************************************/
/* Interrupt: click on a robot to make it change direction   */
/*************************************************************/

void mousePressed () {
  println(mouseX,mouseY);
  for (Robot r : robots) {
    if (r.contains(mouseX, mouseY)) {
  
      float angle = r.body.getAngle()+PI/3 + random(PI*4/3);
      Vec2 newPos = new Vec2 (mouseX+10, mouseY+10);
      r.body.setTransform(newPos, angle);
      
    }
  }
}

/*************************************************************/
/* Draw, called for every time step                          */
/*************************************************************/

void showData(){
  
   //Write som info about the simulation guide:
  noStroke();
  fill(255, 255, 255, 80);
  rect(150, 60, 280, 95);  
  fill(0, 0, 0);
  textSize(15);
  text("arena dimensions :"+ width +","+height+" mm", 20, 30);
  text("Hexbugs Robots:"+robots.size(), 20, 50);
  text("Parts:"+ parts.size(), 20, 70);
  text("Simulation Time:"+ millis()/1000, 20, 90);
  
}

void draw() {
  //draw a solid colour as background
  background(0);
  //draw an analysis image as background
  //background (bg);
  
  
  //////Draw all the boundaries, parts, and robots:
  for (Boundary wall : boundaries) {
    wall.display();
  }

  for (CustomBoundary face : bounds) {
    face.display();
  }
   for (Robot r : robots) {
    r.display();
  }

  for (Part p : parts) {
    p.display();
  }

  ///////////////////////////////////
  
    showData();
  //Write screenshot to file, appends to old image sequences 
  //Advance time one step
  box2d.step();
 


  ///////////////////////////create the Parts / Components 
  partsDone=true;
  for (int i=0; i<partTypes; i++) {
    // print("part=" + i + "   counts=" + partCounts[i] + "\n");
    if (partsDone ==true && robotsDone==true ) {
      for (int j=0; j<partCounts[i]; j++) {
        partCounts[i]=partCounts[i]-1;
        //Part p = new Robot(edge_offset_part/2 + random(width-edge_offset_part), edge_offset_part/2 + random(height-edge_offset_part), partFileNames[i]);
        Part p = new Part(random(760,1400), random(200,908), partFileNames[i]);
        //Part p = new Part(width/2+random(-40*j,40*j), height/2+random(-40*j,40*j), partFileNames[i]);
        counter +=1;

        parts.add(p);
        partsDone=false;
        break;
      }
    }
  }
  //////////////////////////////////////////////
  
    ///////////////////////////Create and place them Robots in the arena
  robotsDone=true;
  for (int i=0; i<robotTypes; i++) {
    // print("type=" + i + "   counts=" + robotCounts[i] + "\n");
    if (partsDone==false) {
      for (int j=0; j<robotCounts[i]; j++) {
        robotCounts[i]=robotCounts[i]-1;
        //Robot r = new Robot(random(100+j*0.1,300-j*0.1), random(100-j*0.1,300), robotFileNames[i]);
           // Robot r = new Robot(random(100+j*0.1,300-j*0.1), random(100-j*0.1,300), robotFileNames[i]);
        //Robot r = new Robot(random(170,490),random(230,850), robotFileNames[i]);
        Robot r = new Robot(500+i*5,330+i*8, robotFileNames[i]);
        robots.add(r);
        robotCounter+=1;
        robotsDone=false;
        break;
      }
    }
  }


  ////Change location of the parts if collision is detected

  
  for (Part p : parts) {
    if (p.inCollision && !p.placed) {
      p.jumpRandom();
      p.inCollision=false;
      p.freeSteps=3;
    } else {
      p.inCollision=false;
      if (p.freeSteps-- < 0) {
        p.placed=true;
      }

      //print("Jump for overlap.\n");
    }
  }
//  ////Change location of the robots if collision is detected
//  for (Robot r : robots) {
//    if (r.inCollision && !r.placed) {
//      r.robotJumpRandom();
//      r.inCollision=false;
//      r.freeSteps=3;
//      //    print("Jump for overlap.\n");
//    } else {
//      // p.placed=true;
//      r.inCollision=false;
//      if (r.freeSteps-- < 0) {
//        r.placed=true;
//      }
//    }
//  }
//  //////////////Apply forces / move robots 
  for (Robot r : robots) {
    r.move();

    Vec2 pos = box2d.getBodyPixelCoord(r.body);

    if (pos.x<boundaryWidth) {
      r.applySoftBoundary(0.0, 100);
    }
    if (pos.x>(width-boundaryWidth)) {
      r.applySoftBoundary(PI/12, 100);
    }   

    if (pos.y<boundaryWidth) {
      r.applySoftBoundary(PI/12, 100);
    }
    if (pos.y>(height-boundaryWidth)) {
      r.applySoftBoundary(PI/12, 100);
    }
  }
  if ( deltaTms < (System.currentTimeMillis()-lastTime)) {
    lastTime=System.currentTimeMillis();
    // print("Logging at "+ ( System.currentTimeMillis()-startTime) + "ms\n");
    fill(0);
    //log stuff
    if (partsDone && robotsDone) {
      /////method to record a movie
      makeMovie(recording);  
      if (printHeader) {
        printHeader=false;
        logfile.print("time.ms");
      } else {
        logfile.print(( System.currentTimeMillis()-startTime));
      }
      // Display all the parts
      for (Part p : parts) {
        p.logpose(logfile);
      } 
      // Display all the parts
      for (Robot r : robots) {
        r.logpose(logfile);
        //r.jumpRandom(width, height); //<>//
      } 
      logfile.print("\n");
      logfile.flush();
    }// end log entry
  }// end log / image save timer
}///end of draw method


/////// Collision event functions!
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();

  // Get both bodies //<>//
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  if (o1.getClass() == Part.class   || (o1.getClass() == Robot.class   ) ) {
    Part p = (Part) o1;
    p.inCollision=true;
  } 
  if (o2.getClass() == Part.class   || (o2.getClass() == Robot.class   ) ) {
    Part p = (Part) o2;
    p.inCollision=true;
  }
}//////////////end of collision event

///////// Objects stop touching each other
void endContact(Contact cp) {
}/////////////////////////////


//press key to start exporting frames
 void keyPressed(){   
   if (key == 'r' || key == 'R' ){  
       if(recording == false ){
          recording = true;
          println("start recording");
          println ( "Recording value is now: " + recording + ". You are saving images in rootFolder/movie" );
       }else{
         recording = false;
         println("stop recording");
        }
     }
  } 
     
///////method to save frames 
   void makeMovie(boolean _recording) {
       boolean rec = _recording;
       if (rec == true && millis()%2 != 0){      
        saveFrame("movie/hex-"+(System.currentTimeMillis()-startTime)+".png");
       }
   }
 /////////////////////////


