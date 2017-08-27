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

Canvas orthophoto, buildings;
final LatLon[] bounds = new LatLon[] {
    new LatLon(42.5181, 1.50803),
    new LatLon(42.495, 1.55216)
};

City3D city;


HashMap<String, ColorScheme> colors = new HashMap();
int it = -1;


void setup() {

    size(1200,805,P3D);
    //pixelDensity(2); 
    
    surface = new WarpSurface(this, "surface.xml");
    orthophoto = new Canvas(this, "textures/orto_epsg3857.jpg", bounds);
    
    city = new City3D(this, width, height, "gis/buildings_EPSG4326", Projection.EPSG4326);
    city.paint(#37383a);
    
    ColorScheme ir = new ColorScheme();
    ir.addColor(0.1, #636bff);
    ir.addColor(396, #70ff67);
    ir.addColor(792, #fcf663);
    ir.addColor(1189, #e24f4f);
    colors.put("irradiation", ir);
    
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
    
    city.update(width/2, height/2, 0, 3);

}


void draw() {
    
    background(#181B1C);

    city.draw();
 
    fill(#FFFFFF);
    if(it != -1) colors.get(it).drawLegend(40,40, 200);
    //text(frameRate, 20, 20);

    surface.draw(orthophoto);

}


void mouseClicked() {
    LatLon loc = surface.unmapPoint(mouseX, mouseY);
    if(loc != null) {
        PVector pos = city.toPosition(loc.getLat(), loc.getLon());
        int i = city.select(pos);
        city.highlight(i, #FF0000);
        city.centerAt(i);
    }
}

void keyPressed() {
    switch(key) {
        case 'c':
            surface.toggleCalibration();
            break;
        case 'r':
            it = -1;
            city.paint(#37383a);
            city.update();
            break;
            
        case ' ':
            city.paint("ir_use", colors.get("irradiation"));
    }
}