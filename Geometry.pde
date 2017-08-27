/**
* Geometry utilities collection
* @autor Marc Vilella
* @version 0.3
*/
public static class Geometry {

    /**
    * Determine if a point belongs to a line
    * @param p    Point to check
    * @param a    Sart point of the line
    * @param b    End point of the line
    * @return true if point belongs to line, false otherwise
    */
    public static boolean inLine(PVector p, PVector a, PVector b) {
        final float EPSILON = 0.001f;
        PVector ap = PVector.sub(p, a);
        PVector ab = PVector.sub(b, a);
        return PVector.angleBetween(ap, ab) <= EPSILON && ap.mag() < ab.mag();
    }


    /**
    * Find the vector projector of a point onto a vector
    * This is, the orthogonal projection of point onto a straight line parallel to the vector
    * @param p    Point to project
    * @param a    Sart point of the line
    * @param b    End point of the line
    * @return the projection point
    */
    public static PVector vectorProjection(PVector p, PVector a, PVector b) {
        PVector ap = PVector.sub(p, a);
        PVector ab = PVector.sub(b, a).normalize();
        ab.mult( ap.dot(ab) );
        return PVector.add(a, ab);
    }
    
    
    /**
    * Find the intersection between two infinite lines, each one defined by two points
    * @param p1    Point belonging to line 1
    * @param p2    Point belonging to line 1
    * @param p3    Point belonging to line 2
    * @param p4    Point belonging to line 2
    * @return the intersection point
    */
    private static PVector linesIntersection(PVector p1, PVector p2, PVector p3, PVector p4) {
        float d = (p2.x-p1.x) * (p4.y - p3.y) - (p2.y-p1.y) * (p4.x - p3.x);
        if(d == 0) return null;
        return new PVector(p1.x+(((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d)*(p2.x-p1.x), p1.y+(((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d)*(p2.y-p1.y));
    }
    
    
    /**
    * Determine if a point is inside a polygon
    * @param p           Point to check
    * @param vertices    Vertices that define the polygon
    * @return true if the polygon contains the point, false otherwise
    */
    public static boolean polygonContains(PVector p, PVector... vertices) {
        if(vertices.length < 2) return false;
        int i, j;
        boolean result = false;
        for (i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
            if ((vertices[i].y > p.y) != (vertices[j].y > p.y) && (p.x < (vertices[j].x - vertices[i].x) * (p.y - vertices[i].y) / (vertices[j].y-vertices[i].y) + vertices[i].x)) {
                result = !result;
            }
        }
        return result;
    }
    
}