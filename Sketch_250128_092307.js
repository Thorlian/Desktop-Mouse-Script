var path = new Path();
path.strokeColor = 'black';
path.strokeWidth = 2;

// Initial points and handle
var startPoint = new Point(100, 200);
var endPoint = new Point(400, 200);
var handlePoint = new Point(250, 100);

// Create the path with the two end points and one handle
path.add(startPoint);
path.cubicCurveTo(handlePoint, handlePoint, endPoint);

// Create a circle to represent the handle point
var handles = [];
handles.push(new Handle(new Point(200, 100),1));


// Track whether the handle is selected for dragging
var selectedHandle = null;

// Mouse down event: check if the user clicks on the handle
function onMouseDown(event) {
  //for each in handles check if contains event.point if so dont do the other stuff
    handles.forEach(function(pElement){
        if(pElement.circle.contains(event.point))
        selectedHandle = pElement;
    });
    if(selectedHandle == null){
        var tPoint = path.lastSegment.point;
        path.add(event.point);
        if(path.length >=2){
            handles.push(new Handle(getMidpoint(tPoint,event.point),path.segments.length-1));
        }
    }
}

// Mouse drag event: move the selected handle and update the curve
function onMouseDrag(event) {
    if (selectedHandle) {
        selectedHandle.setPosition(event.point); // Move the handle
       // handlePoint = event.point; // Update the handle point
        //updatePath(); // Update the path based on the new handle position
    }
}

// Mouse up event: deselect the handle
function onMouseUp(event) {
    
    selectedHandle = null;
}


function Handle(pPosition, pIndex){
    this.position = pPosition;
    this.index = pIndex
    this.circle = new Path.Circle({
    center: pPosition,
    radius: 8,
    fillColor: 'red',
    strokeColor: 'black'
    });
    this.setPosition = function(p2Position){
        console.log(p2Position);
      this.position = p2Position;
      var tSegments = path.segments;
      console.log(this.index)
      tSegments[this.index -1].handleOut = p2Position.subtract(tSegments[this.index -1].point);
      tSegments[this.index].handleIn = p2Position.subtract(tSegments[this.index].point);
      this.circle.position = p2Position;
    };
}
function getMidpoint(point1, point2) {
    return new Point(
        (point1.x + point2.x) / 2  ,
        (point1.y + point2.y) / 2
    );
}
function getOffsetPoint(point1, point2, pOffset){
    return new Point(
        ((1-pOffset) * point1.x + pOffset * point2.x),
        ((1-pOffset) * point1.y + pOffset * point2.y)
        );
}
    
path.fullySelected = false;
