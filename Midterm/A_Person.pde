/* Behavior questions
 * what should happen if a stationary person is pushed into or out of the train?
 */

class Person {
  private PVector location, velocity, acceleration;
  private final float radius; // TODO: and personalSpaceIndex
  private Intention intention;
  private Waypoint nearestWaypoint;
  private boolean inTrain;
  // whether the Person is currently trying to enter/exit the train
  
  Person(Intention intention, boolean inTrain, ArrayList<Waypoint> waypoints) {
    this.intention = intention;
    this.inTrain = inTrain;
    
    this.radius = 5;
    this.location = spawn();
    this.velocity = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
    
    this.nearestWaypoint = this.findFirstWaypoint(waypoints);
  }
  
  /**
   * Finds a place to spawn this Person.
   */
  PVector spawn() {
    if (inTrain) {
      return train.getRandomLocation(radius);
    }
    else return platform.getRandomLocation(radius);
  }
  
  /**
   * Finds the closest waypoint to the initial location of the Person.
   * Requires that waypoints is non-empty
   */
  Waypoint findFirstWaypoint(ArrayList<Waypoint> waypoints) {
    float smallestDistance = Float.POSITIVE_INFINITY;
    Waypoint nearestWaypoint = null;
    
    for (Waypoint w : waypoints) {
      if (! (w.intention == this.intention)) {
        continue;
      }
      float distance = dist(this.location.x, this.location.y, w.location.x, w.location.y);
      if (distance < smallestDistance) {
        smallestDistance = distance;
        nearestWaypoint = w;
      }
    }
    
    return nearestWaypoint;
  }
  
  Waypoint findNextWaypoint() {
    if (nearestWaypoint.endpoint || nearestWaypoint == null || intention == Intention.STATIONARY) {
      intention = Intention.STATIONARY;
      return null;
    }
    
    ArrayList<Waypoint> waypoints = nearestWaypoint.nextOptions;
    int numWaypoints = waypoints.size();
    return waypoints.get((int)random(numWaypoints));
  }
  
  void collisionDetection(ArrayList<Person> people, Train train) {
    // reset acceleration before applying all the forces
    this.acceleration = new PVector(0, 0);
    
    for (Person p : people) {
      if (p == this) continue;
      
      if (this.location.dist(p.location) < 2.5 * radius) {
        PVector displacement = this.displacementVector(p.location);
        PVector force = displacement.setMag(-0.25/displacement.magSq());
        this.acceleration.add(force);
      }
    }
    
    PVector nearestTrainPoint = train.nearestPointOnTrain(this.location);
    if (nearestTrainPoint.mag() < 1.5 * radius) {
      PVector displacement = this.displacementVector(nearestTrainPoint);
      PVector force = displacement.setMag(-0.25/displacement.magSq());
      this.acceleration.add(force);
    }
  }
  
  void defaultVelocity() {
    if (intention == Intention.STATIONARY) {
      this.velocity = new PVector(0,0);
    }
    else {
      PVector displacement = this.displacementVector(this.nearestWaypoint.location);
      this.velocity = displacement.setMag(5);
    }
  }
  
  /**
   * Switches the intention of a person if they've been accidentally booted into
   * or out of a train
   */
  private void switchIntention(boolean actuallyInTrain) {
    if (inTrain == actuallyInTrain) return;
    
    else if (intention == Intention.STATIONARY && actuallyInTrain) {
      intention = Intention.EXITING;
      nearestWaypoint = findFirstWaypoint(waypoints);
    }
    
    else if (intention == Intention.STATIONARY && ! actuallyInTrain) {
      intention = Intention.ENTERING;
      nearestWaypoint = findFirstWaypoint(waypoints);
    }
  }
  
  PVector displacementVector(PVector that) {
    float dx = that.x - this.location.x;
    float dy = that.y - this.location.y;
    return new PVector(dx, dy);
  }
  
  void update(ArrayList<Person> people, Train train) {
    defaultVelocity();
    this.acceleration = new PVector(0,0);
    collisionDetection(people, train);
    velocity.add(acceleration);
    location.add(velocity);
    
    //boolean actuallyInTrain = train.contains(this.location);
    //switchIntention(actuallyInTrain);
  }
  
  void draw() {
    update(people, train);
    circle(location.x, location.y, radius);
    switch(this.intention) {
      case STATIONARY:
      stroke(200); break;
      case ENTERING:
      stroke(0, 255, 0); break;
      case EXITING:
      stroke(255, 0, 0); break;
      default:
      break;
    }
    // colorblind fills: entering is (0, 255, 255), exiting is (255, 206, 0)
    fill(0);
  }
}
