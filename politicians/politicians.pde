Flock democrats;
Flock republicans;

IDesireCalculator democratsDesiredCalculator;
IDesireCalculator republicansDesiredCalculator;

IBorderCalculator borderCalculator;

void setup() {
    size(500, 500);
    
    // Add an initial set of boids into the system
    democrats = new Flock();
    republicans = new Flock();

    // democratsDesiredCalculator = new SimpleDesireCalc(democrats);
    // republicansDesiredCalculator = new SimpleDesireCalc(republicans);

    // democratsDesiredCalculator = new UsVsThemDesireCalc(democrats, republicans);
    // republicansDesiredCalculator = new UsVsThemDesireCalc(republicans, democrats);

    float desiredX = width / 2;
    float desiredY = height / 2;
    democratsDesiredCalculator = new UsVsThemDesireCalcGoCenter(democrats, republicans, desiredX, desiredY);
    republicansDesiredCalculator = new UsVsThemDesireCalcGoCenter(republicans, democrats, desiredX, desiredY);

    borderCalculator = new BounceBorderCalculator();

    float maxspeed = 2;
    float maxforce = 0.55;

    float demX = 10;
    float demY = 10;

    float repX = width - demX;
    float repY = height - demY;

    for (int i = 0; i < 150; i++) {
        democrats.addBoid(
            new Boid(demX,
                    demY,
                    color(0, 0, 255),
                    maxspeed,
                    maxforce,
                    democratsDesiredCalculator,
                    borderCalculator));
        republicans.addBoid(
            new Boid(repX,
                    repY,
                    color(255, 0, 0),
                    maxspeed,
                    maxforce,
                    republicansDesiredCalculator,
                    borderCalculator));
    }
}

void draw() {
    background(50);

    whiteHouse();

    democrats.run();
    republicans.run();
}

void whiteHouse() {
    stroke(255);
    fill(50);
    float whiteHouseSize = 100;
    ellipse(width/2, height/2, whiteHouseSize, whiteHouseSize);
    
    fill(255);
    textAlign(CENTER, CENTER);
    text("White House", width/2, height/2);
}