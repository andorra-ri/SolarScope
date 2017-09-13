import java.util.Set;
import java.util.LinkedHashMap;

public class Slider {

    private boolean active;
    private int iterator = 0;
    private LinkedHashMap<String, Canvas> slides = new LinkedHashMap();
  
    public Slider(PApplet parent, String directory, String[] lbls, LatLon[] bounds) {
        for(String month : lbls) {
            slides.put(month, new Canvas(parent, directory + "/" + month + "_epsg3857.jpg", bounds));
        }
    }
    
    
    public void toggle() {
        active = !active;
    }
    
    
    public boolean isActive() {
        return active;
    }
    
    
    public Canvas next() {
        iterator = (iterator + 1) % slides.size();
        return get(iterator);
    }
    
    
    public Canvas prev() {
        iterator = iterator == 0 ? slides.size()-1 : iterator-1;
        return get(iterator);
    }
    
    
    public Canvas get(int i) {
        Set months = slides.keySet();
        if(i >= 0 && i < months.size()) return slides.get(months.toArray()[i]);
        return null;
    }
    
    
    public void drawLegend() {
        pushMatrix();
        translate(2734, 750);
        rotate(-PI/140);
        hint(DISABLE_OPTIMIZED_STROKE);
        stroke(255); strokeWeight(1);
        line(0, 0, 600, 0);
        float dX = 600 / (slides.size()-1);
        int i = 0;
        for(String month : slides.keySet()) {
            fill(i == iterator ? 255 : 0);
            float x = i * dX;
            ellipse(x, 0, 10, 10);
            i++;
            fill(255); textAlign(CENTER, TOP);
            text(month, x, 5);
        }
        hint(ENABLE_OPTIMIZED_STROKE);
        popMatrix();
    }
  
}