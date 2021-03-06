class Waypoint {
  final PVector location;
  final WaypointType type; // ex. waypoints inside the train, exits from the platform
  // we want different waypoints for people entering the train than exiting the train
  final Intention intention;
  ArrayList<Waypoint> nextOptions;

  Waypoint (PVector location, Intention intention, WaypointType type) {
    this.location = location;
    this.type = type;
    this.intention = intention;
    this.nextOptions = new ArrayList<Waypoint>();
  }

  void addNextOption(Waypoint that) {
    this.nextOptions.add(that);
  }

  void draw() {
    noStroke();
    switch(this.intention) {
    case ENTERING:
      fill(0, 255, 255, 75); 
      break;
    case EXITING:
      fill(255, 206, 0, 75); 
      break;
    default:
      throw new RuntimeException("why?");
    }
    circle(this.location.x, this.location.y, 8);
  }
}
