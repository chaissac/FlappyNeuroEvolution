class NeuralNetwork { 
  int inputNodes, hiddenNodes, outputNodes ;
  PMatrix weightsIH, weightsHO, biasH, biasO ;
  double learningRate ;
  String activationFunction ;
  final String version = "0.4";

  NeuralNetwork(int input, int hidden, int output, String fn) {

    inputNodes = input ;
    hiddenNodes = hidden ;
    outputNodes = output ;

    weightsIH = new PMatrix(hiddenNodes, inputNodes);
    weightsHO = new PMatrix(outputNodes, hiddenNodes);
    weightsIH.randomize();
    weightsHO.randomize();

    biasH = new PMatrix(hiddenNodes, 1);
    biasO = new PMatrix(outputNodes, 1);
    biasH.randomize();
    biasO.randomize();

    setLearningRate(0.1);
    setActivationFunction(fn);
  }

  NeuralNetwork(NeuralNetwork n) {

    inputNodes = n.inputNodes ;
    hiddenNodes = n.hiddenNodes ;
    outputNodes = n.outputNodes ;

    weightsIH = n.weightsIH.clone();
    weightsHO = n.weightsHO.clone();

    biasH = n.biasH.clone();
    biasO = n.biasO.clone();

    learningRate = n.learningRate;
    setActivationFunction(n.activationFunction);
  }

  void setLearningRate(double lr) {
    learningRate = lr;
  }   
  void setLearningRate(float lr) {
    learningRate = (double)lr;
  }   
  void setLearningRate(int lr) {
    learningRate = (double)lr;
  } 
  String checkFunction(String fn) {
    fn.toLowerCase();
    switch (fn) {
    case "sigmoid":
    case "tanh":
    case "step":
    case "relu":
      return fn;
    default:
      return "sigmoid";
    }
  }

  void mutate(Float rate) {
    weightsIH.mutate(rate);
    weightsHO.mutate(rate);
  }
  void setActivationFunction(String func) {
    activationFunction = checkFunction(func);
  }  
  String toJson() {
    JSONObject json = new JSONObject();
    json.put( "class", "NeuralNetwork" );
    json.put( "version", version );
    json.put( "inputNodes", inputNodes );
    json.put( "hiddenNodes", hiddenNodes );
    json.put( "outputNodes", outputNodes );
    json.put( "learningRate", learningRate );
    json.put( "activationFunction", activationFunction );
    json.put( "weightsIH", weightsIH.toJson() );
    json.put( "weightsHO", weightsHO.toJson() );
    json.put( "biasH", biasH.toJson() );
    json.put( "biasO", biasO.toJson() );
    return json.toString();
  }  
  void save(String file) {
    String json = toJson();
    println(json);
  }
  Double[] predict(Double[] inputArray) {
    // Generating the Hidden Outputs
    PMatrix inputs = new PMatrix(inputArray);
    PMatrix hidden = weightsIH.clone();
    hidden.product(inputs);
    hidden.add(biasH);
    // activation function!
    hidden.map(activationFunction);

    // Generating the output's output!
    PMatrix output = weightsHO.clone() ;
    output.product(hidden);
    output.add(biasO);
    output.map(activationFunction);

    // Sending back to the caller!
    return output.toArray();
  }

  void train(Double[] inputArray, Double[] targetArray) {

    // Generating the Hidden Outputs
    PMatrix inputs = new PMatrix(inputArray);
    PMatrix hidden = weightsIH.clone();
    hidden.product(inputs);
    hidden.add(biasH);
    // activation function!
    hidden.map(activationFunction);

    // Generating the output's output!
    PMatrix outputs = weightsHO.clone() ;
    outputs.product(hidden);
    outputs.add(biasO);
    outputs.map(activationFunction);

    // Convert array to matrix object
    PMatrix targets = new PMatrix(targetArray);

    // Calculate the error
    // ERROR = TARGETS - OUTPUTS
    PMatrix outputErrors = targets.clone();
    outputErrors.sub(outputs);

    // let gradient = outputs * (1 - outputs);
    // Calculate gradient
    PMatrix gradient = outputs.clone();
    gradient.map("d"+activationFunction);
    gradient.mult(outputErrors);
    gradient.mult(learningRate);

    // Calculate deltas
    PMatrix hiddenT = hidden.clone();
    hiddenT.transpose();
    PMatrix weightHODeltas = gradient.clone();
    weightHODeltas.product(hiddenT);

    // Adjust the weights by deltas
    weightsHO.add(weightHODeltas);
    // Adjust the bias by its deltas (which is just the gradients)
    biasO.add(gradient);

    // Calculate the hidden layer errors
    PMatrix hiddenErrors = weightsHO.clone();
    hiddenErrors.transpose();
    hiddenErrors.product(outputErrors);

    // Calculate hidden gradient
    PMatrix hiddenGradient = hidden.clone();
    hiddenGradient.map("d"+activationFunction);
    hiddenGradient.mult(hiddenErrors);
    hiddenGradient.mult(learningRate);

    // Calculate input->hidden deltas
    PMatrix inputsT = inputs.clone();
    inputsT.transpose();
    PMatrix weightIHDeltas = hiddenGradient.clone();
    weightIHDeltas.product(inputsT);

    // Adjust the weights by deltas
    weightsIH.add(weightIHDeltas);
    // Adjust the bias by its deltas (which is just the gradients)
    biasH.add(hiddenGradient);
  }
}