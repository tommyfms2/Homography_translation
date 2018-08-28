

PImage imgLenna;

int whichPointIsClicked = -1;
Point[] src_points = new Point[4];
Point[] dst_points = new Point[4];

void setup(){
  size(1000, 1000);
  
  
  dst_points[0] = new Point(  0,   0); // left up
  dst_points[1] = new Point(  0, 440); // left down
  dst_points[2] = new Point(440,   0); // right up
  dst_points[3] = new Point(440, 440); // right down
  
  
  imgLenna = loadImage("Lenna.png");
  src_points[0] = new Point(               0,               0);
  src_points[1] = new Point(               0, imgLenna.height);
  src_points[2] = new Point(  imgLenna.width,               0);
  src_points[3] = new Point(  imgLenna.width, imgLenna.height);
  
}

void draw(){
  background(240);
  
  float[] H = findHomography(dst_points, src_points);
  
  //image(imgLenna, 0, 0);
  imgLenna.loadPixels();
  loadPixels();
  for (int hi=0; hi<height; hi++){
    for (int wi=0; wi<width; wi++){
      int[] uv = warpPerspectiveXnY(H, wi, hi);
      if (uv[0] >= 0 && uv[0] < imgLenna.width && uv[1] >= 0 && uv[1] < imgLenna.height){
        pixels[wi+hi*width] = imgLenna.pixels[uv[0]+uv[1]*imgLenna.width];
      }
    }
  }
  
  updatePixels();
  imgLenna.updatePixels();
  
  for (int i=0; i<4; i++){
    ellipse( dst_points[i].x, dst_points[i].y, 10, 10 );
  }

}

void mousePressed(){
  for (int i=0; i<4; i++){
    if (dst_points[i].checkDist(mouseX, mouseY, 20)){
      whichPointIsClicked = i;
    }
  }
}
void mouseDragged(){
  if (whichPointIsClicked != -1){
    dst_points[whichPointIsClicked].x = mouseX;
    dst_points[whichPointIsClicked].y = mouseY;
  }
}
void mouseReleased(){
  whichPointIsClicked = -1;
}

int [] warpPerspectiveXnY(float [] H, int x, int y){
  float rmd = H[6]*x + H[7]*y + 1;
  int u = int((H[0]*x + H[1]*y + H[2])/rmd);
  int v = int((H[3]*x + H[4]*y + H[5])/rmd); 
  return new int[]{u, v};
}


float [] findHomography(Point[] src_points, Point[] dst_points) {
  float[] matA = {
    src_points[0].x, src_points[0].y, 1, 0, 0, 0, -src_points[0].x*dst_points[0].x, -src_points[0].y*dst_points[0].x, 
    0, 0, 0, src_points[0].x, src_points[0].y, 1, -src_points[0].x*dst_points[0].y, -src_points[0].y*dst_points[0].y, 
    src_points[1].x, src_points[1].y, 1, 0, 0, 0, -src_points[1].x*dst_points[1].x, -src_points[1].y*dst_points[1].x, 
    0, 0, 0, src_points[1].x, src_points[1].y, 1, -src_points[1].x*dst_points[1].y, -src_points[1].y*dst_points[1].y, 
    src_points[2].x, src_points[2].y, 1, 0, 0, 0, -src_points[2].x*dst_points[2].x, -src_points[2].y*dst_points[2].x, 
    0, 0, 0, src_points[2].x, src_points[2].y, 1, -src_points[2].x*dst_points[2].y, -src_points[2].y*dst_points[2].y, 
    src_points[3].x, src_points[3].y, 1, 0, 0, 0, -src_points[3].x*dst_points[3].x, -src_points[3].y*dst_points[3].x, 
    0, 0, 0, src_points[3].x, src_points[3].y, 1, -src_points[3].x*dst_points[3].y, -src_points[3].y*dst_points[3].y, 
  };

  float[] arrB = {dst_points[0].x, dst_points[0].y, dst_points[1].x, dst_points[1].y, 
                  dst_points[2].x, dst_points[2].y, dst_points[3].x, dst_points[3].y};

  float[] homoX = new float[8];
  float[] inved = getInverseN(matA, 8);

  homoX = dot8(inved, arrB);

  return homoX;
}

float [] dot8(float[] A8m8, float[] B8m1) {
  float[] ans = new float[8];

  for (int j=0; j<8; j++) {
    ans[j] = 0;
    for (int i=0; i<8; i++) {
      ans[j] += A8m8[i+j*8] * B8m1[i];
    }
  }
  return ans;
}

float [] getInverseN(float[] mat, int dim_n) {
  int fea_dim = dim_n;
  float [] inv_a = new float[fea_dim*fea_dim];
  // set inv_a as unit matrix.
  for (int i=0; i<fea_dim; i++) {
    for (int j=0; j<fea_dim; j++) {
      if (i==j) {
        inv_a[i*fea_dim+j]=1;
      } else {
        inv_a[i*fea_dim+j]=0;
      }
    }
  }

  for (int i=0; i<fea_dim; i++) {
    if (mat[i+i*fea_dim]==0) {
      for (int k=i; k<fea_dim; k++) {
        if (mat[i+k*fea_dim]!=0) {
          for (int tmpi=0; tmpi<fea_dim; tmpi++){
            float tmpnum = mat[tmpi+k*fea_dim];
            mat[tmpi+k*fea_dim] = mat[tmpi+i*fea_dim];
            mat[tmpi+i*fea_dim] = tmpnum;
            
            tmpnum = inv_a[tmpi+k*fea_dim];
            inv_a[tmpi+k*fea_dim] = inv_a[tmpi+i*fea_dim];
            inv_a[tmpi+i*fea_dim] = tmpnum;
          }
          break;
        }
      }
    }
    float buf = 1.0 / mat[i+i*fea_dim];
    for (int tmpi=0; tmpi<fea_dim; tmpi++) {
      inv_a[tmpi+i*fea_dim] = inv_a[tmpi+i*fea_dim] * buf;
      mat[tmpi+i*fea_dim] = mat[tmpi+i*fea_dim] * buf;
    }
    for (int j=0; j<fea_dim; j++) {
      if (i!=j) {
        buf = mat[i+j*fea_dim];
        for (int tmpi=0; tmpi<fea_dim; tmpi++) {
          inv_a[tmpi+j*fea_dim] = inv_a[tmpi+j*fea_dim] - inv_a[tmpi+i*fea_dim] * buf;
          mat[tmpi+j*fea_dim] = mat[tmpi+j*fea_dim] - mat[tmpi+i*fea_dim] * buf;
        }
      }
    }
  }
  return inv_a;
}