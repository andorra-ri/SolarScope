import java.util.Observable;
import java.util.Observer;


public class Panel implements Observer {

    private final int WIDTH, HEIGHT;
    private PGraphics canvas;
    private boolean visible = false;
    
    private final PShape car;
    private final int CAR_EMISSIONS = 2;
    
    public Panel(int width, int height) {
        WIDTH = width;
        HEIGHT = height;
        canvas = createGraphics(WIDTH, HEIGHT);
        car = loadShape("car.svg");
        car.disableStyle();
    }
    
    
    public void update(Observable obj, Object param) {
        
        if(param == null) visible = false;
        else if(param instanceof Building3D) {
            
            Building3D building = (Building3D)param;
            TableRow row = solarAttributes.getRow(building.ID);
           
            String name = building.ATTRIBUTES.getString("name");
            String use = building.ATTRIBUTES.getString("use");
            
            float radiation = 0;
            int modules = row.getInt("num_modules");
            float power = row.getFloat("installable_power");
            float electricity = 0;
            float investment = row.getFloat("investment");
            float maintenance = row.getFloat("maintenance_cost") * 20;
            float revenue = row.getFloat("revenue") * 20;
            float retPeriod = row.getFloat("return_period");
            float co2Savings = row.getFloat("co2_savings");
            FloatDict monthlyElectricity = new FloatDict();
            
            float f = (1 / (row.getFloat("useful_surface") * 1000)) *  row.getInt("num_modules") * MOD_POW * MOD_EFF;
            for(String month : MONTHS) {
                monthlyElectricity.add(month, row.getFloat("radiation_" + month) * f / 1000000);
                electricity += monthlyElectricity.get(month);
                radiation += row.getFloat("radiation_" + month);
            }
            radiation /= 1000000; // MWh/year
            color panelColor = #3399FF;
            
            canvas.beginDraw();
            canvas.clear();
            canvas.background(0, 170);
            
            canvas.pushMatrix();
            
            canvas.fill(0, 170);
            canvas.rect(0, 0, WIDTH, HEIGHT);
          
            // BUILDING
            canvas.translate(0, 130);
            canvas.fill(#FFFFFF); canvas.textSize(23); canvas.textAlign(LEFT, CENTER);
            canvas.text(name, 20, 0);
            canvas.fill(panelColor); canvas.noStroke();
            canvas.ellipse(30, 30, 10, 10);
            canvas.fill(#888888); canvas.textSize(11);
            canvas.text(use.toUpperCase(), 45, 28);
            
            // SOLAR RESOURCE
            canvas.translate(0, 90);
            canvas.fill(#FFFFFF); canvas.textSize(15);
            canvas.text("SOLAR RESOURCE", 20, 0);
            canvas.fill(#888888); canvas.textSize(12);
            canvas.text("RADIATION", 20, 15);
            canvas.fill(#FFFFFF); canvas.textSize(30);
            canvas.text(String.format("%.1f",radiation), 170, 3);
            float offset_ir = canvas.textWidth(String.format("%.1f",radiation));
            canvas.textSize(20);
            canvas.text("MWh/year", 175+offset_ir, 9);
            
          
            // INSTALLATION
            canvas.translate(0, 80);
            canvas.fill(#FFFFFF); canvas.textSize(15);
            canvas.text("INSTALLATION", 20, 0);
            canvas.fill(#888888); canvas.textSize(12);
            canvas.text("MODULES", 20, 15);
            canvas.text("MAX POWER", 120, 15);
            canvas.text("ELECTRICITY GENERATION", 280, 15);
            canvas.text("MONTHLY GENERATION", 20, 90);
            canvas.fill(#FFFFFF); canvas.textSize(30);
            canvas.text(str(modules), 20, 40);
            canvas.text(String.format("%.1f",power), 120, 40);
            canvas.text(String.format("%.1f",electricity), 280, 40);
            float offset_pow = canvas.textWidth(String.format("%.1f",power));
            float offset_elec = canvas.textWidth(String.format("%.1f",electricity));
            canvas.textSize(18);
            canvas.text("kW", 120+offset_pow, 46);
            canvas.text("MWh/year", 280+offset_elec, 46);
          
            // Chart
            PVector chartSize = new PVector(WIDTH - 60, 125);
            PVector chartInit = new PVector((WIDTH - chartSize.x)/2, 110);
            float dX = chartSize.x / 11;
            
            canvas.fill(panelColor); canvas.textSize(15); canvas.textAlign(RIGHT, BOTTOM);
            canvas.text("MWh/month", chartInit.x + chartSize.x, chartInit.y);
            float maxElectricity = monthlyElectricity.maxValue();
            PVector prevPos = null;
            for(String month : monthlyElectricity.keyArray()) {
                PVector pos = new PVector(chartInit.x, map(monthlyElectricity.get(month), 0, maxElectricity, chartInit.y + chartSize.y, chartInit.y));
                chartInit.x += dX;
                // Axis
                canvas.fill(#FFFFFF, 100); canvas.stroke(#FFFFFF, 40); canvas.strokeWeight(1);
                canvas.line(pos.x, chartInit.y, pos.x, chartInit.y + chartSize.y);
                canvas.textAlign(CENTER, TOP); canvas.textSize(11);
                canvas.text(month, pos.x, chartInit.y + chartSize.y + 5);
                // Line
                if(prevPos != null) {
                    canvas.stroke(panelColor); canvas.strokeWeight(2);
                    canvas.line(prevPos.x, prevPos.y, pos.x, pos.y);
                }
                // Ellipse
                canvas.fill(panelColor); canvas.noStroke();
                canvas.ellipse(pos.x, pos.y, 10, 10);
                // Text
                canvas.textSize(11); canvas.textAlign(CENTER, BOTTOM);
                canvas.text(String.format("%.2f",monthlyElectricity.get(month)), pos.x, pos.y - 10);
                
                prevPos = pos;
            }
          
            // FINANCE
            canvas.translate(0, 310); 
            canvas.fill(#FFFFFF); canvas.textSize(15); canvas.textAlign(LEFT, CENTER);
            canvas.text("FINANCE", 20, 0);
            
            canvas.fill(#888888); canvas.textSize(12);
            canvas.text("COSTS", 20, 15);
            canvas.text("REVENUE", 200, 15);
            canvas.text("RETURN", 370, 15);
            canvas.fill(#FFFFFF); canvas.textSize(30);
            canvas.text(str(round(investment+maintenance)), 20, 40);
            canvas.text(str(round(revenue)), 200, 40);
            canvas.text(String.format("%.1f",retPeriod), 370, 40);
            float offset_inv = canvas.textWidth(str(round(investment+maintenance)));
            float offset_rev = canvas.textWidth(str(round(revenue)));
            float offset_ret = canvas.textWidth(String.format("%.1f",retPeriod));
            canvas.textSize(18);
            canvas.text("€", 20+offset_inv, 46);
            canvas.text("€", 200+offset_rev, 46);
            canvas.text("years", 370+offset_ret, 46);
            
            float maxBalance = max(investment + maintenance, revenue);
            float investmentWidth = map(investment, 0, maxBalance, 0, WIDTH-40);
            float maintenanceWidth = map(maintenance, 0, maxBalance, 0, WIDTH-40);
            float revenueWidth = map(revenue, 0, maxBalance, 0, WIDTH-40);
            canvas.fill(#FF0000); canvas.noStroke(); canvas.textSize(15);
            canvas.rect(20, 70, investmentWidth, 12);
            canvas.rect(investmentWidth + 21, 70, maintenanceWidth, 12);
            canvas.fill(#008800);
            canvas.rect(20, 85, revenueWidth, 12);
            canvas.fill(#FFFFFF); canvas.textSize(9);
            canvas.text("INVESTMENT", 23, 74);
            canvas.text("MAINTENANCE", 24 + investmentWidth, 74);
            canvas.text("REVENUE", 23, 89);
            
            // ECOLOGY
            canvas.translate(0, 150); 
            canvas.fill(#FFFFFF); canvas.textSize(15); canvas.textAlign(LEFT, CENTER);
            canvas.text("ENVIRONMENT", 20, 0);
            canvas.fill(#888888); canvas.textSize(12);
            canvas.text("CO2 SAVINGS", 20, 15);
            canvas.fill(#FFFFFF); canvas.textSize(30);
            canvas.text(String.format("%.1f",co2Savings), 20, 40);
            float offset_co2 = canvas.textWidth(String.format("%.1f",co2Savings));
            canvas.textSize(18);
            canvas.text("t CO2", 20+offset_co2, 46);
            
            int numCars = round((co2Savings / 20) / CAR_EMISSIONS);
            canvas.fill(panelColor);
            for(int i = 0; i < numCars; i++) {
              canvas.shape(car, 20 + i % 10 * 46, 65 + i / 10 * 25, 35, 15);
            }
            
            canvas.popMatrix();
            canvas.endDraw();
            
            visible = true;
        }
        
    }
    
    
    public void draw() {
        if(visible) image(canvas, 0, 0);
    }
    
}