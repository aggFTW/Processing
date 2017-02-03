Flock democrats;
Flock republicans;

void setup() {
    size(1024, 800);
    
    // Add an initial set of boids into the system
    democrats = new Flock();
    republicans = new Flock();
    for (int i = 0; i < 150; i++) {
        democrats.addBoid(new Boid(width/2, height/2, color(0, 0, 255)));
        republicans.addBoid(new Boid(width/2, height/2, color(255, 0, 0)));
    }
}

void draw() {
    background(50);
    democrats.run(republicans);
    republicans.run(democrats);
}

// Add a new boid into the System
// void mousePressed() {
//     flock.addBoid(new Boid(mouseX,mouseY));
// }

// The Flock (a list of Boid objects)
public class Flock {
    ArrayList<Boid> boids;

    public Flock() {
        this.boids = new ArrayList<Boid>();
    }

    public void run(Flock adversaries) {
        for (Boid b : this.boids) {
            b.run(this.boids, adversaries.boids);  // Passing the entire list of boids to each boid individually
        }
    }

    public void addBoid(Boid b) {
        this.boids.add(b);
    }
}

// The Boid class
public class Boid {
    public PVector position;
    public PVector velocity;
    public PVector acceleration;
    
    private float r;
    private float maxforce;    // Maximum steering force
    private float maxspeed;    // Maximum speed

    private color c;

    public Boid(float x, float y, color c) {
        this.acceleration = new PVector(0, 0);

        // This is a new PVector method not yet implemented in JS
        // velocity = PVector.random2D();

        // Leaving the code temporarily this way so that this example runs in JS
        float angle = random(TWO_PI);
        this.velocity = new PVector(cos(angle), sin(angle));

        this.position = new PVector(x, y);
        this.r = 2.0;
        this.maxspeed = 2;
        this.maxforce = 0.03;

        this.c = c;
    }

    public void run(ArrayList<Boid> boids, ArrayList<Boid> adversaries) {
        PVector friendlyForce = this.flock(boids);
        PVector adversaryForce = this.flock(adversaries);
        this.acceleration.add(friendlyForce);
        this.acceleration.sub(adversaryForce);
        this.update();
        this.borders();
        this.render();
    }

    // We accumulate a new acceleration each time based on three rules
    private PVector flock(ArrayList<Boid> boids) {
        PVector res = new PVector(0, 0);

        PVector sep = this.separate(boids);   // Separation
        PVector ali = this.align(boids);      // Alignment
        PVector coh = this.cohesion(boids);   // Cohesion
        // Arbitrarily weight these forces
        sep.mult(1.5);
        ali.mult(1.0);
        coh.mult(1.0);

        // Add the force vectors to return
        res.add(sep);
        res.add(ali);
        res.add(coh);

        return res;
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

    // Separation
    // Method checks for nearby boids and steers away
    private PVector separate (ArrayList<Boid> boids) {
        float desiredseparation = 25.0f;
        PVector steer = new PVector(0, 0, 0);
        int count = 0;

        // For every boid in the system, check if it's too close
        for (Boid other : boids) {
            float d = PVector.dist(this.position, other.position);

            // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
            if ((d > 0) && (d < desiredseparation)) {
                // Calculate vector pointing away from neighbor
                PVector diff = PVector.sub(this.position, other.position);
                diff.normalize();
                diff.div(d);        // Weight by distance
                steer.add(diff);
                count++;            // Keep track of how many
            }
        }
        // Average -- divide by how many
        if (count > 0) {
            steer.div((float)count);
        }

        // As long as the vector is greater than 0
        if (steer.mag() > 0) {
            // First two lines of code below could be condensed with new PVector setMag() method
            // Not using this method until Processing.js catches up
            // steer.setMag(maxspeed);

            // Implement Reynolds: Steering = Desired - Velocity
            steer.normalize();
            steer.mult(this.maxspeed);
            steer.sub(this.velocity);
            steer.limit(this.maxforce);
        }

        return steer;
    }

    // Alignment
    // For every nearby boid in the system, calculate the average velocity
    private PVector align (ArrayList<Boid> boids) {
        float neighbordist = 50;
        PVector sum = new PVector(0, 0);
        int count = 0;

        for (Boid other : boids) {
            float d = PVector.dist(this.position, other.position);
            if ((d > 0) && (d < neighbordist)) {
                sum.add(other.velocity);
                count++;
            }
        }

        if (count > 0) {
            sum.div((float)count);
            // First two lines of code below could be condensed with new PVector setMag() method
            // Not using this method until Processing.js catches up
            // sum.setMag(this.maxspeed);

            // Implement Reynolds: Steering = Desired - Velocity
            sum.normalize();
            sum.mult(this.maxspeed);
            PVector steer = PVector.sub(sum, this.velocity);
            steer.limit(this.maxforce);
            return steer;
        } 
        else {
            return new PVector(0, 0);
        }
    }

    // Cohesion
    // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
    private PVector cohesion (ArrayList<Boid> boids) {
        float neighbordist = 50;
        PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
        int count = 0;
        
        for (Boid other : boids) {
            float d = PVector.dist(this.position, other.position);
            if ((d > 0) && (d < neighbordist)) {
                sum.add(other.position); // Add position
                count++;
            }
        }

        if (count > 0) {
            sum.div(count);
            return seek(sum);  // Steer towards the position
        }
        else {
            return new PVector(0, 0);
        }
    }

    // A method that calculates and applies a steering force towards a target
    // STEER = DESIRED MINUS VELOCITY
    private PVector seek(PVector target) {
        PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
        // Scale to maximum speed
        desired.normalize();
        desired.mult(this.maxspeed);

        // Above two lines of code below could be condensed with new PVector setMag() method
        // Not using this method until Processing.js catches up
        // desired.setMag(this.maxspeed);

        // Steering = Desired minus Velocity
        PVector steer = PVector.sub(desired, this.velocity);
        steer.limit(maxforce);  // Limit to maximum steering force
        return steer;
    }
}