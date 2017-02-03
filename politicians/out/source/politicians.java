import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class politicians extends PApplet {

Flock democrats;
Flock republicans;

IDesireCalculator democratsDesiredCalculator;
IDesireCalculator republicansDesiredCalculator;

IBorderCalculator borderCalculator;

public void setup() {
    
    
    // Add an initial set of boids into the system
    democrats = new Flock();
    republicans = new Flock();

    // democratsDesiredCalculator = new SimpleDesireCalc(democrats);
    // republicansDesiredCalculator = new SimpleDesireCalc(republicans);
    democratsDesiredCalculator = new UsVsThemDesireCalc(democrats, republicans);
    republicansDesiredCalculator = new UsVsThemDesireCalc(republicans, democrats);

    borderCalculator = new BounceBorderCalculator();

    for (int i = 0; i < 150; i++) {
        democrats.addBoid(
            new Boid(width/2,
                    height/2,
                    color(0, 0, 255),
                    2,
                    0.03f,
                    democratsDesiredCalculator,
                    borderCalculator));
        republicans.addBoid(
            new Boid(width/2,
                    height/2,
                    color(255, 0, 0),
                    2,
                    0.03f,
                    republicansDesiredCalculator,
                    borderCalculator));
    }
}

public void draw() {
    background(50);
    democrats.run();
    republicans.run();
}
public class Boid {
    public PVector position;
    public PVector velocity;
    public PVector acceleration;
    
    public float maxforce;    // Maximum steering force
    public float maxspeed;    // Maximum speed

    private float r;
    private int c;

    private IDesireCalculator desireCalc;
    private IBorderCalculator borderCalculator;

    public Boid(
            float x,
            float y,
            int c,
            float maxspeed,
            float maxforce,
            IDesireCalculator desireCalc,
            IBorderCalculator borderCalculator) {
        this.acceleration = new PVector(0, 0);

        float angle = random(TWO_PI);
        this.velocity = new PVector(cos(angle), sin(angle));

        this.position = new PVector(x, y);
        this.r = 2.0f;
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
class BounceBorderCalculator implements IBorderCalculator {
    public void calculateBorders(Boid self, float r) {
        if (self.position.x < -r || self.position.x > width+r)
            self.velocity.x = -self.velocity.x;
        if (self.position.y < -r || self.position.y > height+r)
            self.velocity.y = -self.velocity.y;
    }
}
public class Flock {
    ArrayList<Boid> boids;

    public Flock() {
        this.boids = new ArrayList<Boid>();
    }

    public void run() {
        for (Boid b : this.boids) {
            b.run();  // Passing the entire list of boids to each boid individually
        }
    }

    public void addBoid(Boid b) {
        this.boids.add(b);
    }
}
interface IBorderCalculator {
    public void calculateBorders(Boid self, float r);
}
interface IDesireCalculator {
    public PVector calculateDesired(Boid self);
}
class SimpleDesireCalc implements IDesireCalculator {
    private ArrayList<Boid> boids;

    public SimpleDesireCalc(Flock family) {
        this.boids = family.boids;
    }

    public PVector calculateDesired(Boid self) {
        return calculateDesiredWithBoids(self, this.boids);
    }

    protected PVector calculateDesiredWithBoids(Boid self, ArrayList<Boid> boids) {
        PVector desiredForce = new PVector(0, 0);

        PVector sep = this.separate(self, boids);   // Separation
        PVector ali = this.align(self, boids);      // Alignment
        PVector coh = this.cohesion(self, boids);   // Cohesion

        // Arbitrarily weight these forces
        sep.mult(1.5f);
        ali.mult(1.0f);
        coh.mult(1.0f);

        // Add the force vectors to return
        desiredForce.add(sep);
        desiredForce.add(ali);
        desiredForce.add(coh);

        return desiredForce;
    }

    // Separation
    // Method checks for nearby boids and steers away
    private PVector separate (Boid self, ArrayList<Boid> boids) {
        float desiredseparation = 15.0f;
        PVector steer = new PVector(0, 0, 0);
        int count = 0;

        // For every boid in the system, check if it's too close
        for (Boid other : boids) {
            float d = PVector.dist(self.position, other.position);

            // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
            if ((d > 0) && (d < desiredseparation)) {
                // Calculate vector pointing away from neighbor
                PVector diff = PVector.sub(self.position, other.position);
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
            steer.mult(self.maxspeed);
            steer.sub(self.velocity);
            steer.limit(self.maxforce);
        }

        return steer;
    }

    // Alignment
    // For every nearby boid in the system, calculate the average velocity
    private PVector align (Boid self, ArrayList<Boid> boids) {
        float neighbordist = 50;
        PVector sum = new PVector(0, 0);
        int count = 0;

        for (Boid other : boids) {
            float d = PVector.dist(self.position, other.position);
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
            sum.mult(self.maxspeed);
            PVector steer = PVector.sub(sum, self.velocity);
            steer.limit(self.maxforce);
            return steer;
        } 
        else {
            return new PVector(0, 0);
        }
    }

    // Cohesion
    // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
    private PVector cohesion (Boid self, ArrayList<Boid> boids) {
        float neighbordist = 50;
        PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
        int count = 0;
        
        for (Boid other : boids) {
            float d = PVector.dist(self.position, other.position);
            if ((d > 0) && (d < neighbordist)) {
                sum.add(other.position); // Add position
                count++;
            }
        }

        if (count > 0) {
            sum.div(count);
            return seek(self, sum);  // Steer towards the position
        }
        else {
            return new PVector(0, 0);
        }
    }

    // A method that calculates and applies a steering force towards a target
    // STEER = DESIRED MINUS VELOCITY
    private PVector seek(Boid self, PVector target) {
        PVector desired = PVector.sub(target, self.position);  // A vector pointing from the position to the target
        // Scale to maximum speed
        desired.normalize();
        desired.mult(self.maxspeed);

        // Steering = Desired minus Velocity
        PVector steer = PVector.sub(desired, self.velocity);
        steer.limit(self.maxforce);  // Limit to maximum steering force
        return steer;
    }
}
class UsVsThemDesireCalc extends SimpleDesireCalc {
    private ArrayList<Boid> relatives;
    private ArrayList<Boid> adversaries;

    public UsVsThemDesireCalc(Flock family, Flock adversaries) {
        super(family);
        
        this.relatives = family.boids;
        this.adversaries = adversaries.boids;
    }

    public PVector calculateDesired(Boid self) {
        PVector desiredForce = new PVector(0, 0);
        PVector familyForce = calculateDesiredWithBoids(self, relatives);
        PVector adversaryForce = calculateDesiredWithBoids(self, adversaries);

        return desiredForce.add(familyForce).sub(adversaryForce);
    }
}
class WrapAroundBorderCalculator implements IBorderCalculator {
    public void calculateBorders(Boid self, float r) {
        if (self.position.x < -r) self.position.x = width+r;
        if (self.position.y < -r) self.position.y = height+r;
        if (self.position.x > width+r) self.position.x = -r;
        if (self.position.y > height+r) self.position.y = -r;
    }
}
  public void settings() {  size(600, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "politicians" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
