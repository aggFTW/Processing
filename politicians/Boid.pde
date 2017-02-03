public class Boid {
    public PVector position;
    public PVector velocity;
    public PVector acceleration;
    
    public float maxforce;    // Maximum steering force
    public float maxspeed;    // Maximum speed

    private float r;
    private color c;

    private IDesireCalc desireCalc;

    public Boid(float x, float y, color c, float maxspeed, float maxforce, IDesireCalc desireCalc) {
        this.acceleration = new PVector(0, 0);

        float angle = random(TWO_PI);
        this.velocity = new PVector(cos(angle), sin(angle));

        this.position = new PVector(x, y);
        this.r = 2.0;
        this.maxspeed = maxspeed;
        this.maxforce = maxforce;

        this.c = c;

        this.desireCalc = desireCalc;
    }

    public void run() {
        // Apply desired calc
        PVector desiredForce = this.desireCalc.calculateDesired(this);
        this.acceleration.add(desiredForce);

        this.update();
        this.borders();
        this.render();
    }   

    // Method to update position
    private void update() {
        // Update velocity
        this.velocity.add(this.acceleration);
        // Limit speed
        this.velocity.limit(this.maxspeed);
        this.position.add(this.velocity);
        // Reset acceleration to 0 each cycle
        this.acceleration.mult(0);
    }

    // Wraparound
    private void bordersWrap() {
        if (this.position.x < -r) this.position.x = width+r;
        if (this.position.y < -r) this.position.y = height+r;
        if (this.position.x > width+r) this.position.x = -r;
        if (this.position.y > height+r) this.position.y = -r;
    }

    // Wraparound
    private void borders() {
        if (this.position.x < -r) this.position.x = width+r;
        if (this.position.y < -r) this.position.y = height+r;
        if (this.position.x > width+r) this.position.x = -r;
        if (this.position.y > height+r) this.position.y = -r;
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