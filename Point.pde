

class Point{
  int x;
  int y;
  Point(int _x, int _y){
    x = _x;
    y = _y;
  }
  
  boolean checkDist(int mx, int my, int dist){
    if ( ((mx-this.x)*(mx-this.x)+(my-this.y)*(my-this.y))<(dist*dist) ){
      return true;
    }
    return false;
  }
}