Flock democrats;
Flock republicans;

IDesireCalculator democratsDesiredCalculator;
IDesireCalculator republicansDesiredCalculator;

IBorderCalculator borderCalculator;

void setup() {
    size(200, 200);
    
    // Add an initial set of boids into the system
    democrats = new Flock();
    republicans = new Flock();

    // democratsDesiredCalculator = new SimpleDesireCalc(democrats);
    // republicansDesiredCalculator = new SimpleDesireCalc(republicans);
    democratsDesiredCalculator = new UsVsThemDesireCalc(democrats, republicans);
    republicansDesiredCalculator = new UsVsThemDesireCalc(republicans, democrats);

    borderCalculator = new BounceBorderCalculator();

    float maxspeed = 2;
    float maxforce = 0.05;

    for (int i = 0; i < 150; i++) {
        democrats.addBoid(
            new Boid(width/2,
                    height/2,
                    color(0, 0, 255),
                    maxspeed,
                    maxforce,
                    democratsDesiredCalculator,
                    borderCalculator));
        republicans.addBoid(
            new Boid(width/2,
                    height/2,
                    color(255, 0, 0),
                    maxspeed,
                    maxforce,
                    republicansDesiredCalculator,
                    borderCalculator));
    }
}

void draw() {
    background(50);
    democrats.run();
    republicans.run();
}