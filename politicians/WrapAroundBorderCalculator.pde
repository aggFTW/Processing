class WrapAroundBorderCalculator implements IBorderCalculator {
    public void calculateBorders(Boid self, float r) {
        if (self.position.x < -r) self.position.x = width+r;
        if (self.position.y < -r) self.position.y = height+r;
        if (self.position.x > width+r) self.position.x = -r;
        if (self.position.y > height+r) self.position.y = -r;
    }
}