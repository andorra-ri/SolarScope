public static class Geometry {

    public static boolean inLine(PVector p, PVector a, PVector b) {
        final float EPSILON = 0.001f;
        PVector ap = PVector.sub(p, a);
        PVector ab = PVector.sub(b, a);
        return PVector.angleBetween(ap, ab) <= EPSILON && ap.mag() < ab.mag();
    }

    public static PVector scalarProjection(PVector p, PVector a, PVector b) {
        PVector ap = PVector.sub(p, a);
        PVector ab = PVector.sub(b, a).normalize();
        ab.mult( ap.dot(ab) );
        return PVector.add(a, ab);
    }
    
    
    private static PVector linesIntersection(PVector p1, PVector p2, PVector p3, PVector p4) {
        float d = (p2.x-p1.x) * (p4.y - p3.y) - (p2.y-p1.y) * (p4.x - p3.x);
        if(d == 0) return null;
        return new PVector(p1.x+(((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d)*(p2.x-p1.x), p1.y+(((p3.x - p1.x) * (p4.y - p3.y) - (p3.y - p1.y) * (p4.x - p3.x)) / d)*(p2.y-p1.y));
    }
    
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