/**
* Object that can be picked with a position event (eg. a mouse click) in a 3D context
* @author    Marc Vilella
* @version   1.1
*/
public interface Pickable {
    
    public final int PICK_COLOR_BASE = 0xff000001;
    
    /**
    * Get the unique pick value corresponding to this object
    * @param id    the ID of the object
    * @return the pick value
    */
    public int getPicker(int id);
    
    /**
    * Draw the object in a picking context
    * @param pickCanvas    the canvas to draw the object
    */
    public void drawForPicking(PGraphics pickCanvas);
}



/**
* Geospatial object belonging to a city
* @author    Marc Vilella
* @version   1.0
*/
public static abstract class LandArea {
    
    public static float px_m;
    
    protected final int ID;
    protected final TableRow ATTRIBUTES;
    protected final PVector[] CONTOUR;
    
    public LandArea(int id, TableRow attributes, PVector[] contour) {
        ID = id;
        ATTRIBUTES = attributes;
        CONTOUR = contour;
    }
    

    /**
    * Get the centroid of the building
    * @return the centroid position of the building
    */
    public PVector getCentroid() {
        PVector centroid = new PVector();
        for(PVector vertex : CONTOUR) {
            centroid.add(vertex);
        }
        centroid.div(CONTOUR.length);
        return centroid;
    }

}



/**
* Representation of a building in a 3D city context
* @author    Marc Vilella
* @version   1.1
*/
public class Building3D extends LandArea implements Pickable {

    protected final int PICK_COLOR;
    protected PShape extrusion;
    private color fillColor;
    
    
    /**
    * Construct the building
    * @param id            ID of the building
    * @param attributes    Row with attributes of the building
    * @param contour       Vertices of the building contour
    */
    public Building3D(int id, TableRow attributes, PVector[] contour) {
        super(id, attributes, contour);
        extrude(ATTRIBUTES.getInt("elevation") * px_m, ATTRIBUTES.getInt("height") * px_m );
        PICK_COLOR = getPicker(id);
    }


    /**
    * Get the unique pick value corresponding to this object
    * @param id    the ID of the object
    * @return the pick value
    */
    public int getPicker(int id) {
        return PICK_COLOR_BASE + 2 * id;
    }
    

    /**
    * Create a 3D representation of the building
    * @param elevation    Elevation from the floor in pixels
    * @param h            Height of the building in pixel
    */
    public void extrude(float elevation, float height) {
        extrusion = createShape(GROUP);
        
        // Build sides
        for(int i = 1; i < CONTOUR.length; i++) {
            PShape side = createShape();
            side.beginShape();
            side.vertex(CONTOUR[i-1].x, CONTOUR[i-1].y, elevation);
            side.vertex(CONTOUR[i-1].x, CONTOUR[i-1].y, elevation + height);
            side.vertex(CONTOUR[i].x, CONTOUR[i].y, elevation + height);
            side.vertex(CONTOUR[i].x, CONTOUR[i].y, elevation);
            side.endShape(CLOSE);
            extrusion.addChild(side);
        }
        
        // Build closing side
        int last = CONTOUR.length-1;
        PShape side = createShape();
        side.beginShape();
        side.vertex(CONTOUR[0].x, CONTOUR[0].y, elevation);
        side.vertex(CONTOUR[0].x, CONTOUR[0].y, elevation + height);
        side.vertex(CONTOUR[last].x, CONTOUR[last].y, elevation + height);
        side.vertex(CONTOUR[last].x, CONTOUR[last].y, elevation);
        side.endShape(CLOSE);
        extrusion.addChild(side);
        
        // Build cover
        PShape cover = createShape();
        cover.beginShape();
        for(int i = 0; i <= last; i++) {
            cover.vertex(CONTOUR[i].x, CONTOUR[i].y, elevation + height);
        }
        cover.endShape(CLOSE);
        extrusion.addChild(cover);
        
        // Default paint
        setColor(#FAFAFA); 
        strokeWeight(1);
    }
    
    
    /**
    * Draw the building
    */
    public void draw() {
        shape(extrusion);
    }
    
    
    /**
    * Draw the building into a canvas
    * @param canvas    Canvas to draw the building
    */
    public void draw(PGraphics canvas) {
        canvas.shape(extrusion);
    }
    
    
    /**
    * Draw the building plan into the canvas
    * @param canvas    the canvas to draw the building
    */
    public void drawPlan(PGraphics canvas) {
      canvas.beginShape();  
      for(PVector c : CONTOUR) canvas.vertex(c.x, c.y);
      canvas.endShape(CLOSE);
    }
    
    
    /**
    * Draw the building in a canvas implementing all needed actions to be picked
    * @param pickCanvas    Canvas to draw the building to be picked
    */
    public void drawForPicking(PGraphics pickCanvas) {
        extrusion.setFill(PICK_COLOR);
        extrusion.setStroke(PICK_COLOR);
        draw(pickCanvas);
        paint();
    }
    
    
    /**
    * Set the color of the building
    * @param c    Color of the building
    */
    public void setColor(color c) {
        fillColor = c;
        paint();
    }
    
    
    /**
    * Paint the building with the default color
    */
    public void paint() {
        paint(fillColor);
    }
    
    
    /**
    * Paint the building with the a color
    * @param fillColor    Color to paint the building
    */
    public void paint(color fillColor) {
        extrusion.setFill(fillColor);
        color strokeColor = brightness(fillColor) > 125 ?
              color(red(fillColor)-5, green(fillColor)-5, blue(fillColor)-5) :
              color(red(fillColor)+10, green(fillColor)+10, blue(fillColor)+10);
        extrusion.setStroke(strokeColor);
    }
    
    
    /**
    * Set the stroke weight of the building edges
    * @param weight    Weight of the edges
    */
    public void strokeWeight(float weight) {
        if(weight == 0) extrusion.setStroke(false);
        else extrusion.setStrokeWeight(weight);
    }
    
}