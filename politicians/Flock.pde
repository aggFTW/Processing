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