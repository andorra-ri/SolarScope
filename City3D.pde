import java.util.TreeMap;
import org.gicentre.geomap.*;

/**
* Representation of a city in 3D. Acts as a facade for the Buildings that belong to city
* @author    Marc Vilella
* @version   1.1
*/
public class City3D {
    
    private final PApplet PARENT;
    private final int WIDTH, HEIGHT;
    private LatLon[] bounds;
    
    private ArrayList<Building3D> buildings;
    
    private boolean interactive = true;
    private PVector screenPos;
    private PVector centerTarget;
    private PVector centerPoint;
    private float rotationTarget = 0;
    private float rotation = 0;
    private float scaleTarget = 1;
    private float scale = 1;
    
    private PGraphics canvas;
    
    
    /**
    * Construct an empty city in 3D
    * @param parent    the sketch PApplet
    * @param width     Width of the city in pixels
    * @param height    Height of the city in pixels
    */
    public City3D(PApplet parent, int width, int height) {
        PARENT = parent;
        WIDTH = width;
        HEIGHT = height;
        
        screenPos = new PVector(parent.width/2, parent.height/2);
        centerPoint = new PVector(WIDTH/2, HEIGHT/2);
        centerTarget = new PVector(WIDTH/2, HEIGHT/2);
        canvas = createGraphics(WIDTH, HEIGHT, P3D);
        
        parent.registerMethod("mouseEvent", this);
        parent.registerMethod("keyEvent", this);
    }
    
    
    /**
    * Construct a city loading it from a GIS file
    * @param parent     the sketch PApplet
    * @param width      Width of the city in pixels
    * @param height     Height of the city in pixels
    * @param pathGIS    Path to the GIS file
    * @param proj       Projection used in GIS file
    */
    public City3D(PApplet parent, int width, int height, String pathGIS, Projection proj) {
        this(parent, width, height);
        load(pathGIS, proj);
    }
    
    
    /**
    * Load city from a GIS file
    * @param pathGIS    Path to the GIS file
    * @param proj       Projection used in GIS file
    * @return
    */
    public void load(String pathGIS, Projection proj) {
        
        GeoMap geoMap = new GeoMap(0, 0, WIDTH, HEIGHT, PARENT);
        geoMap.readFile(pathGIS);
        Table attributes = geoMap.getAttributeTable();
        
        bounds = new LatLon[] {
            new LatLon(geoMap.getMaxGeoY(), geoMap.getMinGeoX()),
            new LatLon(geoMap.getMinGeoY(), geoMap.getMaxGeoX())
        };
        
        float dY = geoMap.getMaxGeoY() - geoMap.getMinGeoY();
        if(proj == Projection.EPSG4326) dY *= 111320;
        LandArea.px_m = HEIGHT / dY;
        
        buildings = new ArrayList();
        for(int i = 0; i < geoMap.getNumPolys(); i++) {
            
            Polygon poly = (Polygon)geoMap.getFeatures().get(i+1);    // GeoMap starts indexing at 1
            PVector[] contour = new PVector[poly.getNumVertices()-1];
            float[] x = poly.getXCoords();
            float[] y = poly.getYCoords();
            for(int v = 0; v < poly.getNumVertices()-1; v++) {
                contour[v] = geoMap.geoToScreen(x[v], y[v]);  
            }
            Building3D building = new Building3D(buildings.size(), attributes.getRow(i), contour);

            buildings.add(building);
        }
        
        update();
    }
    
    
    /**
    * Draw city's buffer 
    */
    public void draw() {
       
        boolean update = false;
        if(centerPoint.dist(centerTarget) > 1) {
            centerPoint.lerp(centerTarget, 0.5);
            update = true;
        }
        if(abs(rotationTarget - rotation) > 0.00873) {
            rotation = lerp(rotation, rotationTarget, 0.5);
            update = true;
        }
        if(abs(scaleTarget - scale) > 0.1) {
            scale = lerp(scale, scaleTarget, 0.5);
            update = true;
        }
        if(update) update();
        
        image(canvas, 0, 0);    
    }
    
    
    public Canvas drawPlan() {
        Canvas c = new Canvas(PARENT, WIDTH, HEIGHT, bounds);
        c.beginDraw();
        c.background(0);
        c.fill(#FFFFFF); c.stroke(#A0A0A0);
        for(Building3D b : buildings) b.drawPlan(c);
        c.endDraw();
        return c;
    }
    
    
    /**
    * Update city drawing parameters
    * @param centerX    x position of the city's drawing center
    * @param centerY    y position of the city's drawing center
    * @param rot        Rotation of the city's drawing
    * @param sc         Scale of the city's drawing
    */
    public void update(int centerX, int centerY, float rotation, float scale) {
        screenPos = new PVector(centerX, centerY);
        rotationTarget = radians(rotation);
        scaleTarget = scale;
    }
    
    
    /**
    * Redraw city's buffer
    */
    public void update() {
        canvas.beginDraw();
        canvas.clear();
        canvas.lights();
        canvas.pushMatrix();
        canvas.translate(screenPos.x, screenPos.y,0);
        canvas.rotateX(QUARTER_PI);
        canvas.rotateZ(rotation);
        canvas.scale(scale);
        canvas.translate(-centerPoint.x, -centerPoint.y, 0);
        for(Building3D building : buildings) {
            building.draw(canvas);
        }
        canvas.popMatrix();
        canvas.endDraw();
    }
    
    
    /**
    * Activate or deactivate interactivity with city
    * @param i    To true if interactivity enabled, false otherwise
    */
    public void setInteractivity(boolean i) {
        interactive = i;
    }

    
    /**
    * Rotate the city
    * @param dR    Rotation increment angle in degrees
    */
    public void rotate(float dR) {
        rotationTarget += dR;
    }
    
    
    /**
    * Move the city. The movement will translate also the rotation center
    * @param dX    x increment in pixels
    * @param dY    y increment in pixels
    */
    public void move(float dX, float dY) {
        PVector mov = new PVector(dX, dY).rotate(-rotation);
        centerTarget.add(mov);
    }
    
    
    /**
    * Change zoom of the city
    * @param dScale    Zoom increment
    */
    public void zoom(float dZ) {
        if(scaleTarget + dZ > 0) scaleTarget += dZ;
        else scaleTarget = 1;
    }
    
    
    /**
    * Paint buildings with a color
    * @param fillColor    Color to paint buildings
    */
    public void paint(color fillColor) {
        for(Building3D building : buildings) {
            building.setColor(fillColor);
        }
        update();
    }
    
    
    /**
    * Paint buildings with a color depending on a specific attribute
    * @param attribute    Building's attribute that will determine painting color
    * @param scheme       Scheme with possible [range of] colors
    */
    public void paint(String attribute, ColorScheme scheme) {
        for(Building3D building : buildings) {
            float value = building.ATTRIBUTES.getFloat(attribute);
            building.setColor( scheme.getColor(value) );
        }
        update();
    }
    
    
    /**
    * Temporally paint a building with a color 
    * @param id           ID of the building to paint
    * @param fillColor    Color to fill the selected building
    */
    public void highlight(int id, color fillColor) {
        for(Building3D building : buildings) {
            if(building.ID == id) building.paint(fillColor);
            else building.paint();      
        }
        update();
    }
    
    
    /**
    * Center city (and rotation center) to a building. If building invalid, center to city's center
    * @param id    ID of the building to center
    */
    public void centerAt(int id) {
        if(id == -1) centerTarget = new PVector(WIDTH/2, HEIGHT/2);
        else centerTarget = buildings.get(id).getCentroid();
    }
    
    
    /**
    * Translate a Lat, Lon location to a position in the city
    * @param lat    Latitude of location
    * @param lon    Longitude of location
    * @return translated position in pixels
    */
    public PVector toPosition(float lat, float lon) {
        return new PVector(
            map(lon, bounds[0].getLon(), bounds[1].getLon(), 0, WIDTH),
            map(lat, bounds[0].getLat(), bounds[1].getLat(), 0, HEIGHT)
        );
    }
    
    
    /**
    * Select a building that contains a point
    * @param p    Point to select the building
    */
    public int select(PVector p) {
        for(Building3D b : buildings) {
            if(Geometry.polygonContains(p, b.CONTOUR)) return b.ID;
        }
        return -1;
    }
    
    
    /**
    * Pick a building in a 3D scenario
    * @param x    x component of the picking position
    * @param y    y component of the picking position
    */
    public int pick(int x, int y) {
        PGraphics pickMap = createGraphics(width, height, P3D);
        pickMap.beginDraw();
        pickMap.background(0);
        pickMap.pushMatrix();
        pickMap.translate(screenPos.x, screenPos.y,0);
        pickMap.rotateX(QUARTER_PI);
        pickMap.rotateZ(rotation);
        pickMap.scale(scale);
        pickMap.translate(-centerPoint.x, -centerPoint.y, 0);
        for(Building3D building : buildings) {
            if(building instanceof Pickable) building.drawForPicking(pickMap);
        }
        pickMap.popMatrix();
        pickMap.endDraw();
        int c = pickMap.get(x, y);
        for(Building3D building : buildings) {
            if(building instanceof Pickable && c  == building.PICK_COLOR) return building.ID;
        }
        return -1;
    }
    
    
    /**
    * Mouse event handler
    * @param e    the mouse event
    */
    public void mouseEvent(MouseEvent e) {
        if(!interactive) return;
        switch(e.getAction()) {
            case MouseEvent.DRAG:
                float dX = pmouseX - mouseX;
                city.rotate(map(dX, 0, width, 0, TWO_PI));
                break;
        }
    }
    
    
    /**
    * Key event handler
    * @param e    the key event
    */
    public void keyEvent(KeyEvent e) {
        if(!interactive) return;
        if(e.getAction() == KeyEvent.PRESS) {
            switch(e.getKey()) {
                case '+':
                    city.zoom(1);
                    break;
                case '-':
                    city.zoom(-1);
                    break;
                case CODED:
                    switch(keyCode) {
                        case LEFT:
                            city.move(-10, 0);
                            break;
                        case RIGHT:
                            city.move(10, 0);
                            break;
                        case UP:
                            city.move(0, -10);
                            break;
                        case DOWN:
                            city.move(0, 10);
                            break;
                    }
                    break;                
            }
        }
    }
    
}