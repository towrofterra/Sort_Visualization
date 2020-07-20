import java.util.Collections;
import processing.sound.*;

ArrayList<Float> items = new ArrayList();
SinOsc sound = new SinOsc(this);
int sortDex, numBubPasses, sortType, drawType;
HashMap<Integer, String> sortTypes;
HashMap<Integer, String> drawTypes;
boolean loopingSort = false;

void setup() {
  fullScreen(P2D);
  //size(800, 400, P2D);
  colorMode(HSB);
  textSize(32);
  fill(0);
  int size = 100;
  for (float i = 0; i <= 1.00001; i+= (1.0/size))
    items.add(new Float(i));

  Collections.shuffle(items);
  sortDex = 0;
  numBubPasses = 0;
  sortType = 0;
  drawType = 0;
  sortTypes = new HashMap();
  sortTypes.put(0, "Pause");
  sortTypes.put(1, "Bubble");
  sortTypes.put(2, "Selection");
  sortTypes.put(3, "Insertion");
  drawTypes = new HashMap();
  drawTypes.put(0, "Line");
  drawTypes.put(1, "Shell");
  drawTypes.put(2, "Color");
}

void draw() {
  translate(width/2.0, height/2.0);

  if (drawTypes.get(drawType).equals("Line"))
    drawLine(items);
  if (drawTypes.get(drawType).equals("Shell"))
    drawShell(items);
  if (drawTypes.get(drawType).equals("Color"))
    drawColor(items);


  if (sortTypes.get(sortType).equals("Pause")) {
    sound.stop();
  }


  if (sortTypes.get(sortType).equals("Bubble")) {
    sound.play(items.get(sortDex + (items.size() - sortDex) / 2) * 600, 1);
    // If the sort is complete, the bubblePass function will return true
    if (bubblePass(items))
      stopSort();
  }

  if (sortTypes.get(sortType).equals("Selection")) {
    // Plays the sound at a frequency based on the element halfway through the unsorted part of the list
    sound.play(items.get((sortDex + (items.size() - sortDex) / 2) - 2) * 600, 1);
    // If the sort is complete, the selectionPass function will return true
    if (selectionPass(items, sortDex++)) {
      stopSort();
    }
  }

  if (sortTypes.get(sortType).equals("Insertion")) {
    // Plays the sound at a frequency based on the element halfway through the unsorted part of the list
    sound.play(items.get((sortDex + (items.size() - sortDex) / 2) - 2) * 600, 1);
    // If the sort is complete, the selectionPass function will return true
    if (insertionPass(items, sortDex++)) {
      stopSort();
    }
  }


  text(sortTypes.get(sortType), 25 - width / 2, 50 - height / 2);
}

// EFFECT: Changes the type of sort being used with the number keys, pauses and resumes with p/o, 0 is reset
void keyPressed() {
  if (key == '0' || key == '1' || key == '2' || key == '3') {
    Collections.shuffle(items);
    sortDex = 0;
    sortType = Character.getNumericValue(key); 
    redraw();
    loop();
  } else if (key == 'p') {
    sound.stop();
    noLoop();
  } else if (key == 'o') {
    loop();
  } else if (key == 'l') {
    loopingSort = !loopingSort;
  }
}

// EFFECT: Changes the representation of the data
void mousePressed() {
  drawType = (drawType + 1) % drawTypes.size();
  redraw();
}


// EFFECT: Do a bubble sort pass on the given list
// Returns true if the sort is done
boolean bubblePass(ArrayList<Float> items) {
  // If there are no swaps, the array is sorted
  int numSwaps = 0;

  for (int i = 0; i < items.size() - 1; i++) {
    if (items.get(i) > items.get(i+1)) {
      // If they aren't in the right order, switch them
      numSwaps++;
      float temp = items.get(i);
      items.set(i, items.get(i+1));
      items.set(i+1, temp);
    }
  }

  numBubPasses++;
  return numSwaps == 0;
}

// EFFECT: Do a selection sort pass
// int start is the index of the first unsorted element
// Returns true if the sort is done
boolean selectionPass(ArrayList<Float> items, int start) {
  if (start >= items.size() - 1)
    return true;
  int minDex = start;
  // Find the index of the minimum value
  // This code assumes the list is at least of size 2
  for (int i = minDex + 1; i < items.size() - 1; i++) {
    if (items.get(i) < items.get(minDex)) {
      minDex = i;
    }
  }
  // Switch the minimum value with the first unsorted element
  float temp = items.get(minDex);
  items.set(minDex, items.get(start));
  items.set(start, temp);
  return false;
}

// EFFECT: Do a insertion sort pass
// int start is the index of the first unsorted element
// Returns true if the sort is done
boolean insertionPass(ArrayList<Float> items, int start) {
  if (start >= items.size()) // if the list is sorted, we're done
    return true;
  else if(items.get(start) <= items.get(0)){ // If the new item is the smallest we've encountered, just stick it on the front 
    items.add(0, items.remove(start));
    return false;
  }
  else if(items.get(start-1) <= items.get(start)) // If the new item is bigger than the largest sorted item, just leave it where it is and move on
    return false;
    
  else {
    for(int i=0; i<start;i++){
      if(items.get(start) >= items.get(i) && items.get(start) <= items.get(i+1)){
         items.add(i+1, items.remove(start));
      }
    }
  }
  return false;

}



// EFFECT: Draws the given list as a bar graph
void drawLine(ArrayList<Float> items) {
  float xDist = 0;
  background(128);
  for (Float i : items) {
    stroke(256 * i);
    line(xDist - width/2, height / 2, xDist - width/2, height / 2 - (height * i));
    xDist += float(width) / items.size();
  }
}

// EFFECT: Draws the given list as a pie chart (lines of different lengths radiating out from a central point
void drawShell(ArrayList<Float> items) {
  float theta, x, y;
  background(128);
  theta = 0;

  for (Float i : items) {
    stroke(i * 256);
    // Convert polar to cartesian
    theta += TWO_PI / items.size();
    x = width/2*i * cos(theta);
    y = height/2*i * sin(theta);
    line(0, 0, x, y);
  }
}


// EFFECT: Draws the given list as a color gradient
void drawColor(ArrayList<Float> items) {
  float xDist = 0;
  background(128);
  for (Float i : items) {
    stroke(i* 256, 256, 256);
    line(xDist - width/2, height / 2, xDist - width/2, -height / 2);
    xDist += float(width) / items.size();
  }
}

// EFFECT: Slices the given image up and assigns each column of pixels to a value on the list
void drawPicture(ArrayList<Float> items, PImage img) {
  //todo
}

// EFFECT: Stop all sound, stop the draw() loop and set the sort type to pause
void stopSort() {
  sound.stop();
  if (loopingSort) {
    Collections.shuffle(items);
    sortDex = 0;
    return;
  }
  noLoop();
  sound.stop();
  sortType = 0;
}
