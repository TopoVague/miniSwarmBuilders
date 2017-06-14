
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

// A fixed boundary class

class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;
  
  float x1;
  float y1;
  float cornerChamfer;
  
    //Lists of polygons that make up the boundary
  ArrayList<PolygonShape> bounds;
  
  // But we also have to make a body for box2d to know about it
  Body b;
  Body c;
  Boundary(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    b = box2d.createBody(bd);
    
    // Attached the shape to the body using a Fixture
    b.createFixture(sd,1);
    b.setUserData(this);
}

   Boundary(float x1_,float y1_,float _cornerChamfer) {
    x1 = x1_;
    y1 = y1_;
    cornerChamfer = _cornerChamfer;

    // Define the polygon

    bounds = new ArrayList<PolygonShape>();
    ///BOX BONUDARY
    // Figure out the box2d coordinates
    //float box2dW = box2d.scalarPixelsToWorld(w/2);
    //float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    //bdry.setAsBox(box2dW, box2dH);
   PolygonShape bdry1 = new PolygonShape();
   Vec2[] vertices1 = new Vec2[3];
   vertices1[0] = box2d.vectorPixelsToWorld(new Vec2(x1, y1));
   vertices1[1] = box2d.vectorPixelsToWorld(new Vec2(x1+cornerChamfer, y1));
   vertices1[2] = box2d.vectorPixelsToWorld(new Vec2(x1, y1+cornerChamfer));
   bdry1.set(vertices1, vertices1.length);    
   bounds.add(bdry1);  
   
    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(x,y));
    c = box2d.createBody(bd);
    
    // Attached the shape to the body using a Fixture
    c.createFixture(bdry1,1);
    c.setUserData(this);
    
}



  // Draw the boundary, if it were at an angle we'd have to do something fancier
  void display() {
    fill(0,255,0);
    stroke(70);
    rectMode(CENTER);
    rect(x,y,w,h);
    //rotate(PI/3.0);
    //ellipse(x+width/2,y+height/2,70,70);
    triangle(x1,y1,x1+cornerChamfer, y1,x1, y1+cornerChamfer);
  }
}
