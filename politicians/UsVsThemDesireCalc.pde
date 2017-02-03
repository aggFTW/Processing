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