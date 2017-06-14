/*****************************************************************************/
/* By EvangelosPantazis, Apri 2017                             */
/* Reads in part parameters from files and creates boundary based on a given gemery (i.e. mesh face                    */
/*****************************************************************************/         

// A custom boundary
class CustomBoundary {
  
  //To keep track of bodies
  Body body;

  //Lists of polygons that make the boundary
  ArrayList<PolygonShape> polygons;
  
  
  //logging variales
  String name;
  
  
  float scale;            //Option to scale the size of the object
  //parameters that get read from the file (or set to defautls if the read fails)   
  color boundaryColor;
  
  //JSON Object for parsing 
  // This could move inside the functions since it is only
  // Needed during initalizaiton
  JSONObject obj;
  //Constructor(s) 
  //Try to parse the file name
  //If it's not there use the defaul(s)
  //Constructor
  CustomBoundary(float x, float y, String partname) {
        polygons = new ArrayList<PolygonShape>();

        if(loadFile(partname)){
          parseJSON();     
        }else{
         setDefaults(); 
        }        
        makeBody(new Vec2(x, y));
        body.setUserData(this);
}

// Constructor that takes JSON object instead of string, that way the customBoundary class can
// parse the customBoundary paramteters and give the rest to the Part 
  CustomBoundary(float x, float y, JSONObject initObj) {
     polygons = new ArrayList<PolygonShape>();
     obj=initObj;
     parseJSON();
     body.setUserData(this);
  
}
  
  boolean loadFile(String fname){
  
    try{
         obj = loadJSONObject(fname);
         return true;
    }catch(RuntimeException e){
         print("Could not parse " + fname + ".\nEXCEPTION MESSAGE: " + e.getMessage() + "\n");
         print("If the filname is correct, check for matching \"{}\", \"[]\", and missing \",\" etc.\n");
         print("Defaulting to preset values.\n\n");
         return false;  
      }

  }  
  
  //This function parses the boundary curve from the JSON ojbect
  //It assums a file has been parsed or the construcor is called 
  //with the JSON Object
  void parseJSON(){
        
    JSONObject polyObj;
    JSONObject polyPt;
    JSONArray polyPtArray;
    JSONObject circObj;
 
    try{
      name = obj.getString("name");            
    } 
    catch(RuntimeException e){
      print("Engry for \"name\" missing or not parsable.\nEXCEPTION MESSAGE: " + e.getMessage() + "\n");
      name = "CustomBoundary"; 
    }  
      try{
        scale= obj.getFloat("scale");
     }  
     catch(RuntimeException e){
        print("Entry \"scale\" not found.\nEXCEPTION MESSAGE: " + e.getMessage() + "\n");
        print("Setting \"scale\" to 1\n\n");
        scale=1; 
     }
     
     try{
        JSONObject colObj= obj.getJSONObject("color");
        boundaryColor = color(colObj.getInt("r"), colObj.getInt("g"),colObj.getInt("b"));
     }  
     catch(RuntimeException e){
        print("Color missing or not parsable.\nEXCEPTION MESSAGE: " + e.getMessage() + "\n");
        boundaryColor = color(50,50,50); 
     }
     try{
          JSONArray polyArray = obj.getJSONArray("polygons");
          for(int i=0; i<polyArray.size(); i++){                                // Loop through polygons
            polyObj = polyArray.getJSONObject(i);                               //Extract polygon object
            polyPtArray = polyObj.getJSONArray("poly");
            Vec2[] vertices = new Vec2[polyPtArray.size()];                     //Set up vector for vertices of the appropriate size
            for(int p=0; p<polyPtArray.size(); p++){                            //Add vertices to the polygon        
              polyPt = polyPtArray.getJSONObject(p);
              vertices[p] = box2d.vectorPixelsToWorld(new Vec2(polyPt.getFloat("x")*scale, polyPt.getFloat("y")*scale)); 
            }      
            PolygonShape sd = new PolygonShape();
            sd.set(vertices, vertices.length);                
            polygons.add(sd);                                                    //Add shape to shape array of part class 
          }
      }catch(RuntimeException e){                                              //Polygon exception catch, set default shape
        //  print("No boundary polygons found in " + fname + ".\n\n");                
      }

  }     //End of load file

  // Function to populate defaults
 void setDefaults(){
          boundaryColor=color(0,150,150);
          PolygonShape sd = new PolygonShape();
          Vec2[] vertices = new Vec2[4];
          vertices[0] = box2d.vectorPixelsToWorld(new Vec2(-15, 25));
          vertices[1] = box2d.vectorPixelsToWorld(new Vec2(15, 0));
          vertices[2] = box2d.vectorPixelsToWorld(new Vec2(20, -15));
          vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-10, -10));
          sd.set(vertices, vertices.length);              
          polygons.add(sd);    
 }
 
/*****************************************************/
/* Drawing the boundary (in pixels)                      */
/*****************************************************/
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);                     //Get screen position of each body
    //println ("we have" + polygons.size() + "polygons");
    for (PolygonShape p: polygons) {
      rectMode(CENTER);
      pushMatrix();
      translate(pos.x, pos.y);
      fill(boundaryColor);
      stroke(boundaryColor);
      beginShape();
    
      for (int i = 0; i < p.getVertexCount(); i++) {
        Vec2 v = box2d.vectorWorldToPixels(p.getVertex(i));
        vertex(v.x, v.y);
        //println ("position is" + v);
      }
      endShape(CLOSE);
      popMatrix() ;
    }   
 }
 
 
/*****************************************************/
/* Making the body, creating the physics             */
/*****************************************************/
/*
This function assumes that some infromation has been put into the shape arrays 
and parameters such as scale, friciton, etc.
*/

void makeBody(Vec2 center) {

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    body = box2d.createBody(bd);
    //Make polygons
    for (PolygonShape p: polygons) {
      // Define a fixture
      FixtureDef fd = new FixtureDef();
      fd.shape = p;
      // Create Fixture
      body.createFixture(fd);
    }  
  }
}//CustomBoundary
