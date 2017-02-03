class BounceBorderCalculator implements IBorderCalculator {
    public void calculateBorders(Boid self, float r) {
        if (self.position.x < -r || self.position.x > width+r)
            self.velocity.x = -self.velocity.x;
        if (self.position.y < -r || self.position.y > height+r)
            self.velocity.y = -self.velocity.y;
    }
}