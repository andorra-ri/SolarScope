public enum Projection { EPSG4326, EPSG3857 };

WarpSurface surface;
/*
final LatLon[] ROI = new LatLon[] {
    new LatLon(42.505085,1.509961),
    new LatLon(42.517067,1.544024),
    new LatLon(42.508160,1.549798),
    new LatLon(42.496162,1.515728)
};
*/

final LatLon[] orthoBounds = new LatLon[] {
    new LatLon(42.5181, 1.50803),
    new LatLon(42.495, 1.55216)
};
Canvas mainCanvas, orthophoto;

City3D city;

final int MOD_POW = 250;
final float MOD_EFF = 0.8;
final String[] MONTHS = new String[] { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" };
Table solarAttributes;
Panel panel;

Slider monthRadiation;

HashMap<String, ColorScheme> colors = new HashMap();
int it = -1;

PImage logo;

void setup() {

    //size(1200,805,P3D);
    fullScreen(P3D, SPAN);
    
    logo =  loadImage("logoOBSA.png");
    
    solarAttributes = loadTable("solar.csv", "header, csv");
    panel = new Panel(500, height);
    
    surface = new WarpSurface(this, "surface_screen.xml");
    orthophoto = new Canvas(this, "textures/orto_epsg3857.jpg", orthoBounds);
    
    monthRadiation = new Slider(this, "textures/solar", MONTHS, orthoBounds);
    
    //city = new City3D(this, 1200,795, "gis/buildings", Projection.EPSG4326);
    city = new City3D(this, 1630,1080, "gis/buildings", Projection.EPSG4326);
    city.paint(#37383a);
    city.update(width/6, height/2, 200, 2);
    
    city.addObserver(panel);
    
    
    ColorScheme pot = new ColorScheme();
    pot.addColor(0.1, #fcf663);
    pot.addColor(336, #e24f4f);
    pot.addColor(672, #ff91f7);
    colors.put("power", pot);
    
    ColorScheme elec = new ColorScheme();
    elec.addColor(0.1, #fcf663);
    elec.addColor(672, #e24f4f);
    colors.put("electricity", elec);
    
    ColorScheme co2 = new ColorScheme();
    co2.addColor(0.1, #d2e68d);
    co2.addColor(2195, #297d7d);
    colors.put("co2", co2);
    
    ColorScheme returnPeriod = new ColorScheme();
    returnPeriod.addColor(0, color(#FF0000,170));
    returnPeriod.addColor(10, color(#FF0000,170));
    returnPeriod.addColor(10.1, color(#FF8800,170));
    returnPeriod.addColor(12, color(#FF8800,170));
    returnPeriod.addColor(12.1, color(#FFFF00,170));
    returnPeriod.addColor(14, color(#FFFF00,170));
    returnPeriod.addColor(12.1, color(#FFFF88,170));
    returnPeriod.addColor(16, color(#FFFF88,170));
    
    //mainCanvas = city.drawPlan(orthophoto, color(#00FF00, 170));
    mainCanvas = city.drawPlan(orthophoto, solarAttributes, "return_period", returnPeriod);
    
}


void draw() {
    
    //cursor( mouseX > width / 3 && mouseX < 2 * width / 3 ? CROSS : ARROW );
    
    background(0);
    
    if(monthRadiation.isActive()) {
        if(frameCount % 60 == 0) mainCanvas = monthRadiation.next();
        monthRadiation.drawLegend();
    }
    
    city.rotate(0.001);
    city.draw();
 
    /* 
    fill(#FFFFFF);
    if(it != -1) colors.get(it).drawLegend(40,40, 200);
    */
    
    surface.draw(mainCanvas);
    
    panel.draw();
    image(logo, width/3 - 300, 200, 130, 30);
    fill(255); textAlign(LEFT, TOP);
    text("http://www.obsa.ad/solar", width/3-300, 250);
}


void mouseClicked() {
    LatLon loc = surface.unmapPoint(mouseX, mouseY);
    if(loc != null) {
        PVector pos = city.toPosition(loc.getLat(), loc.getLon());
        int i = city.select(pos);
        city.highlight(i, #00FF00);
        city.centerAt(i);
        if(i != -1 && !monthRadiation.isActive()) mainCanvas = city.drawPlan(orthophoto, color(#FF0000, 170), i);
        else mainCanvas.paint(orthophoto);
    }
}


void keyPressed() {
    switch(key) {
        case 'c':
            surface.toggleCalibration();
            break;
            
        case ' ':
            monthRadiation.toggle();
            if(!monthRadiation.isActive()) mainCanvas = orthophoto;
            break;
        
        /*
        case 'r':
            it = -1;
            city.paint(#37383a);
            city.update();
            break;
        case ' ':
            city.paint("rad_aug", colors.get("irradiation"));
            break;
        */
    }
}