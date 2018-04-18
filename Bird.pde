class Bird {
  Float x, y, r, velocity, lift, fitness ;
  int score ;
  PVector vel;
  Boolean alive = true ;
  color c ;
  Float rate ;
  NeuralNetwork brain;

  Bird() {
    init();
    brain = new NeuralNetwork(8, 24, 2, "sigmoid");
  }
  Bird(Bird papa) {
    init();
    if (random(1)<rate) r = papa.r+randomGaussian() ;
    brain = new NeuralNetwork(papa.brain);
    brain.mutate(rate);
    c = papa.c;
  }
  void init() {
    x = 50.0;
    y = height/2.0;
    r = 8.0;
    velocity=0.;
    lift = -8.0;
    fitness = 0.;
    score = 0;
    rate = .1 ;
    c = color(random(256),random(256),random(256));
    alive = true;
  }
  void show() {
    strokeWeight(1);
    fill(c, 127);
    stroke(255);
    ellipse(x, y, r*2, r*2);
  }

  void up() {
    velocity += lift ;
  }
  void update() {
    velocity += GRAVITY ;
    velocity *= 0.9 ;
    y+=velocity;
    score++ ;
  }
  Boolean crash(PVector[] pipes) {
    if (y-r<0 || y+r>height) return true ;
    for (PVector pipe : pipes) 
      if ((y - r) < pipe.y || (y + r) > (pipe.y +pipe.z)) 
        if (abs(pipe.x-x)<r) 
          return true ;
    return false;
  }
  void think(PVector[] pipes) {
    PVector closest = pipes[0];
    float record = pipes[0].x - x;
    float diff ;
    for (int i = 1; i < pipes.length; i++) {
      diff = pipes[i].x - x;
      if (diff > 0 && diff < record) {
        record = diff;
        closest =  pipes[i];
      }
    }
    // Now create the inputs to the neural network
    Double[] inputs = new Double[8];
    // x position of closest pipe
    inputs[0] = (double)map(closest.x, x, width, -1, 1);
    // top of closest pipe opening
    inputs[1] = (double)map(closest.y, 0, height, -1, 1);
    // bottom of closest pipe opening
    inputs[2] = (double)map(closest.z, 0, height, -1, 1);
    // bird's y position
    inputs[3] = (double)map(y, 0, height, -1, 1);
    // bird's y velocity
    inputs[4] = (double)map(velocity, 0, height, -1, 1);
    // bird's size
    inputs[5] = (double)map(r, 0, 20, -1, 1);  
    // Gravity
    inputs[6] = (double)map(GRAVITY, 0, 10, -1, 1);
    // Lift
    inputs[7] = (double)map(lift, -20, 0, -1, 1);
    // Get the outputs from the network
    Double[] action = brain.predict(inputs);
    // Decide to jump or not!
    if (action[1] > action[0]) up();
  }
}