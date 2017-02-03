public class Boid {
    public PVector position;
    public PVector velocity;
    public PVector acceleration;
    
    public float maxforce;    // Maximum steering force
    public float maxspeed;    // Maximum speed

    private float r;
    private color c;

    private IDesireCalculator desireCalc;
    private IBorderCalculator borderCalculator;

    public Boid(
            float x,
            float y,
            color c,
            float maxspeed,
            float maxforce,
            IDesireCalculator desireCalc,
            IBorderCalculator borderCalculator) {
        this.acceleration = new PVector(0, 0);

        float angle = random(TWO_PI);
        this.velocity = new PVector(cos(angle), sin(angle));

        this.position = new PVector(x, y);
        this.r = 2.0;
        this.maxspeed = maxspeed;
        this.maxforce = maxforce;

        this.c = c;

        this.desireCalc = desireCalc;
        this.borderCalculator = borderCalculator;
    }

    public void run() {
        // Reset acceleration to 0 each cycle
        this.acceleration.mult(0);
        
        // Apply desired calc
        PVector desiredForce = this.desireCalc.calculateDesired(this);
        this.acceleration.add(desiredForce);

        this.update();
        this.borderCalculator.calculateBorders(this, this.r);
        this.render();
    }   

    // Method to update position
    private void update() {
        // Update velocity
        this.velocity.add(this.acceleration);
        // Limit speed
        this.velocity.limit(this.maxspeed);
        this.position.add(this.velocity);
    }

    private void render() {
        // Draw a triangle rotated in the direction of velocity
        float theta = this.velocity.heading2D() + radians(90);
        // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
        
        fill(this.c);
        stroke(255);
        pushMatrix();
        {
            translate(this.position.x, this.position.y);
            rotate(theta);
            beginShape(TRIANGLES);
            vertex(0, -r*2);
            vertex(-r, r*2);
            vertex(r, r*2);
            endShape();
        }
        popMatrix();
    }
}