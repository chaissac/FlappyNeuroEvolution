final Float GRAVITY = .8 ;

PVector[] pipes;
Bird[] birds ;
int count ;
int generation = 1 ;
int highScore = 0 ;

void setup() {
  size(800, 600); 
  pipes=new PVector[floor(width/250)];
  birds = new Bird[500] ;
  for (int i = 0; i < birds.length; i++) birds[i] = new Bird();
  initPipes();
}
void initPipes() {
  for (int i = 0; i < pipes.length; i++) pipes[i]=new PVector(width*2+i*250, random(height-150), height/4+random(height/4));
}
void draw() {
  background(0);
  strokeWeight(4);
  stroke(255);
  for (PVector pipe : pipes) {
    line(pipe.x, 0, pipe.x, pipe.y);
    line(pipe.x, pipe.y+pipe.z, pipe.x, 800);
    pipe.x-=3 ;
    if (pipe.x<20) pipe.set(pipe.x+width, random(height-height/4), height/4+random(height/4));
  }
  count =  birds.length ;
  int score = 0;
  for (Bird bird : birds) {
    if (bird.alive) {
      bird.think(pipes);
      bird.update();
      bird.show();
      score = max(score, bird.score);
      if (bird.crash(pipes)) {
        bird.alive = false ;
        count--;
      };
    } else count--;
  }
  if (score>highScore) highScore=score;
  println(generation + " / " + count + "    ( "+score+" / " +highScore+" )\n");
  if (count==0) nextGeneration();
}