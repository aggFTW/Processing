class UsVsThemDesireCalcGoCenter extends UsVsThemDesireCalc {
    float destinationX;
    float destinationY;
    PVector destination;

    public UsVsThemDesireCalcGoCenter(Flock family, Flock adversaries, float destinationX, float destinationY) {
        super(family, adversaries);

        this.destinationX = destinationX;
        this.destinationY = destinationY;

        this.destination = new PVector(this.destinationX, this.destinationY);
    }

    public PVector calculateDesired(Boid self) {
        // Weigth avoidance wandering force vs go to point force
        float goFactor = goDestinationFactor(self);
        float packFactor = 1.0 - goFactor;

        PVector packForce = super.calculateDesired(self)
                            .mult(packFactor);
        PVector goDestinationForce = this.seek(self, this.destination)
                            .mult(goFactor);
        
        return packForce.add(goDestinationForce);
    }

    private float goDestinationFactor(Boid self) {
        float d = PVector.dist(self.position, this.destination);
        
        // TODO: maxD only works here if destination is center
        float maxD = PVector.dist(new PVector(0, 0), this.destination);

        return d/maxD;
    }
}