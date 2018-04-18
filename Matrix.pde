class PMatrix {

  int rows, cols;
  Double[] data;
  final String version = "1.0";

  PMatrix(int _rows, int _cols) {
    if (_rows<1 || _cols <1) {
      error("PMatrix(" + _rows+", " + _cols + ") : each dimension size should be at least 1.");
    } else {
      rows = _rows;
      cols = _cols;
      data = new Double[rows*cols];
      init(0);
    }
  }
  PMatrix(Double[] arr) {
    fromArray(arr);
  }
  PMatrix(Double[][] arr) {
    fromArray(arr);
  }
  void error(String e) {
    println(e);
    debug();
    System.exit(0);
  }
  void fromArray(Double[] arr) {
    rows = arr.length;
    cols = 1;
    data = arr.clone();
  } 
  void fromArray(Double[][] arr) {
    rows = arr.length;
    cols = arr[0].length;
    data = new Double[rows*cols];
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i*cols+j] = arr[i][j];
      }
    }
  }
  String toJson() {
    JSONObject obj = new JSONObject();
    obj.put( "class", "PMatrix" );
    obj.put( "version", version  );
    obj.put( "rows", rows    );
    obj.put( "cols", cols    );
    obj.put( "data", data    );
    return obj.toString();
  }
  Double[] toArray() {
    return data.clone();
  }
  PMatrix clone() {
    PMatrix m = new PMatrix(rows, cols);
    m.data = data.clone();
    return m;
  }

  void transpose() {
    Double[] copy = data.clone(); 

    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        data[j+i*rows] = copy[i+j*cols];
      }
    }
    rows = cols;
    cols = floor(data.length/rows);
  }

  void init(double n) {
    for (int i = 0; i<data.length; i++) {
      data[i] = n;
    }
  }

  void randomize() {
    for (int i = 0; i<data.length; i++) {
      data[i] = Math.random()*2-1;
    }
  }
  void randomize(int a, int b) {
    for (int i = 0; i<data.length; i++) {
      data[i] = (double)floor(random(a, b));
    }
  }
  void sub(Double n) {
    for (int i = 0; i<data.length; i++) {
      data[i]-=n;
    }
  }
  void sub(PMatrix m) {
    if (rows!=m.rows || cols != m.cols) {
      error("Matrix.sub : size of Matrices should match.");
    } else {
      for (int i = 0; i<data.length; i++) {
        data[i] -= m.data[i];
      }
    }
  }

  void add(Double n) {
    for (int i = 0; i<data.length; i++) {
      data[i]+=n;
    }
  }
  void add(PMatrix m) {
    if (rows!=m.rows || cols != m.cols) {
      error("Matrix.add : size of Matrix A(" + rows + "," + cols + ") should match size of Matrix B(" +m.rows + "," + m.cols + ").");
    } else {
      for (int i = 0; i<data.length; i++) {
        data[i] += m.data[i];
      }
    }
  }

  void mult(PMatrix m) {
    if (rows!=m.rows || cols != m.cols) {
      error("Matrix.mult : size of Matrix A(" + rows + "," + cols + ") should match size of Matrix B(" +m.rows + "," + m.cols + ").");
    } else {
      for (int i = 0; i<data.length; i++) {
        data[i] *= m.data[i];
      }
    }
  }
  void mult(Double n) {
    for (int i = 0; i<data.length; i++) {
      data[i]*=n;
    }
  }

  void product(PMatrix m) {
    if (cols != m.rows) {
      error("Matrix.product : cols of Matrix A(" + rows + "," + cols + ") should match rows of Matrix B(" +m.rows + "," + m.cols + ").");
    }
    Double[] copy = new Double[rows*m.cols];
    double sum ;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < m.cols; j++) {
        sum = 0; 
        for (int k = 0; k < cols; k++) {
          sum += data[i*cols+k] * m.data[k*m.cols+j];
        }
        copy[i*m.cols+j] = sum;
      }
    }
    data = copy.clone();
    cols = m.cols;
  }

  void mutate(Float rate) {
    for (int i = 0; i<data.length; i++) 
      if (random(1) < rate) data[i]+= randomGaussian() * 0.5;
  }

  void map(String func) {
    switch (func) {
    case "sigmoid" : 
      for (int i = 0; i<data.length; i++) data[i] = 1/(1+Math.exp(-data[i])) ; 
      break;
    case "dsigmoid" : 
      for (int i = 0; i<data.length; i++) data[i] = data[i]*(1.-data[i]); 
      break;
    case "tanh" : 
      for (int i = 0; i<data.length; i++) data[i] = Math.tanh(data[i]) ; 
      break;
    case "dtanh" : 
      for (int i = 0; i<data.length; i++) data[i] = 1-data[i]*data[i] ; 
      break;    
    case "step" : 
      for (int i = 0; i<data.length; i++) data[i] = (double)((data[i]>=0)?1:-1) ; 
      break;
    case "dstep" : 
      for (int i = 0; i<data.length; i++) data[i] = (double)((data[i]>=0)?1:-1) ; 
      break;    
    case "relu" : 
      for (int i = 0; i<data.length; i++) data[i] = (double)((data[i]>0)?data[i]:0) ; 
      break;
    case "drelu" : 
      for (int i = 0; i<data.length; i++) data[i] = (double)((data[i]>0)?1:0) ; 
      break;
    default:
      error("Unknown map");
    }
  }
  void debug() {
    debug("??");
  }

  void debug(String m) {
    debug(m, false);
  }
  void debug(String m, Boolean b) {
    String s = (b)?"\n":" ";
    print(String.format("%16s", "Matrix "+m)+" ( "+rows+" , "+cols+" ) = "+s+"[ ");
    for (int i = 0; i<data.length; i++) {
      if (i>0) {
        if (i%cols==0) print(" ]   "+s+"[ "); 
        else print (" ; ");
      }
      print(String.format("%06.2f", data[i]));
    }
    println(" ]");
  }
}