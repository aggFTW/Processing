Flock democrats;
Flock republicans;

IDesireCalc democratsDesiredCalculator;
IDesireCalc republicansDesiredCalculator;

void setup() {
    size(1024, 800);
    
    // Add an initial set of boids into the system
    democrats = new Flock();
    republicans = new Flock();

    democratsDesiredCalculator = new SimpleDesireCalc(democrats);
    republicansDesiredCalculator = new SimpleDesireCalc(republicans);

    for (int i = 0; i < 150; i++) {
        democrats.addBoid(
            new Boid(width/2,
                    height/2,
                    color(0, 0, 255),
                    2,
                    0.03,
                    democratsDesiredCalculator));
        republicans.addBoid(
            new Boid(width/2,
                    height/2,
                    color(255, 0, 0),
                    2,
                    0.03,
                    republicansDesiredCalculator));
    }
}

void draw() {
    background(50);
    democrats.run();
    republicans.run();
}