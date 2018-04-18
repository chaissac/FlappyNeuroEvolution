
void nextGeneration() {
  initPipes();
  // Normalize the fitness values 0-1
  normalizeFitness();
  // Generate a new set of birds
  birds = generate();
  generation++ ;
}

Bird[] generate() {
  Bird[] newBirds = new Bird[birds.length];
  for (int i = 0; i < birds.length; i++) {
    newBirds[i] = poolSelection();
  }
  return newBirds;
}
void normalizeFitness() {
  Float sum = 0. ; 
  for (int i = 0; i < birds.length; i++) {
    birds[i].score*= birds[i].score;
    sum += birds[i].score;
  }
  // Divide by the sum
  for (int i = 0; i < birds.length; i++) {
    birds[i].fitness = birds[i].score / sum;
  }
}

Bird poolSelection() {
  int index = 0;
  Float r = random(1);
  while (r > 0) {
    r -= birds[index].fitness;
    index += 1;
  }
  index -= 1;
  return new Bird(birds[index]) ;
}