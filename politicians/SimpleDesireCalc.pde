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
        sep.mult(1.5);
        ali.mult(1.0);
        coh.mult(1.0);

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