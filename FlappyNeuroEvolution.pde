final Float GRAVITY = .8 ;

PVector[] pipes;
Bird[] birds ;
int count ;
int generation = 1 ;
int highScore = 0 ;

void setup() {
  size(800, 600); 
  pipes=new PVector[floor(width/250)];
  birds = new Bird[500] ;                                              // Here you can change # of Birds for each generation
  for (int i = 0; i < birds.length; i++) birds[i] = new Bird();
  initPipes();
  textSize(18);
  textAlign(CENTER,CENTER);
}
void initPipes() {
  for (int i = 0; i < pipes.length; i++) pipes[i]=new PVector(width+i*250, random(height-150), height/4+random(height/4));
}
void draw() {
  background(0);
  strokeWeight(8);
  stroke(255);
  for (PVector pipe : pipes) {
    line(pipe.x, 0, pipe.x, pipe.y);
    line(pipe.x, pipe.y+pipe.z, pipe.x, 800);
    pipe.x-=3 ;
    if (pipe.x<20) pipe.set(pipe.x+width+random(50)-25, random(height-height/4), height/4+random(height/4));
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
      } 
    } else count--;
  }
  fill(255,255,200,100);
  stroke(255);
  rect(width-300,height/2-125,250,250);
  fill(0,255,0);
  text("Generation #"+generation+"\n***************\n"+(count>1?("Still "+count+" birds"):"The LAST Bird")+" !\n***************\nCurrent Score "+score+"\nHighScore "+highScore,width-175,height/2);
  //println(generation + " / " + count + "    ( "+score+" / " +highScore+" )\n");
  if (count==0 || (score>2*highScore && score>1000)) {
    if (score>highScore) highScore=score;
    nextGeneration();
  }
}