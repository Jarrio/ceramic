package ceramic;

import ceramic.Shape;

/**
 * An extension of Shape that creates a nicely rounded rectangle
 */
class RoundedQuad extends Shape {

    /**
     * Amount of corner segments
     * One to ten is going to be the sanest quantity
     */
    public var segments:Int = 10;

    /**
     * Defines the radius of the top left
     */
    public var radiusTopLeft:Int = 0;

    /**
     * Defines the radius of the top right
     */
    public var radiusTopRight:Int = 0;

    /**
     * Defines the radius of the bottom right
     */
    public var radiusBottomRight:Int = 0;

    /**
     * Defines the radius of the bottom left
     */
    public var radiusBottomLeft:Int = 0;

    override public function new() {
        super();
        autoComputeSize = false;
    }

    override function computeContent() {

        // Define the relative coordinates for the radius
        var sine = [for (angle in 0...segments + 1) Math.sin(Math.PI / 2 * angle / segments)];
        var cosine = [for (angle in 0...segments + 1) Math.cos(Math.PI / 2 * angle / segments)];

        // TOP LEFT
        for (pointPairIndex in 0...segments) {
            points.push(radiusTopLeft * (1 - cosine[pointPairIndex]));
            points.push(radiusTopLeft * (1 - sine[pointPairIndex]));
        }

        // TOP RIGHT
        for (pointPairIndex in 0...segments) {
            points.push(width + radiusTopRight * (cosine[segments - pointPairIndex] - 1));
            points.push(radiusTopRight * (1 - sine[segments - pointPairIndex]));
        }

        // BOTTOM RIGHT
        for (pointPairIndex in 0...segments) {
            points.push(width + radiusBottomRight * (cosine[pointPairIndex] - 1));
            points.push(height + radiusBottomRight * (sine[pointPairIndex] - 1));
        }

        // BOTTOM LEFT
        for (pointPairIndex in 0...segments) {
            points.push(radiusBottomLeft * (1 - cosine[segments - pointPairIndex]));
            points.push(height + radiusBottomLeft * (sine[segments - pointPairIndex] - 1));
        }

        super.computeContent();

    }

	/**
	 * A shortcut for setting all of the corner radiuses at once
	 */
    public function radius(topLeft:Int, ?topRight:Int, ?bottomRight:Int, ?bottomLeft:Int):Void {
        if (topRight == null && bottomRight == null && bottomLeft == null) {
            topRight = topLeft;
            bottomRight = topLeft;
            bottomLeft = topLeft;
        }
        else if (bottomRight == null && bottomLeft == null) {
            bottomRight = topRight;
            bottomLeft = topLeft;
        }
        else {
            if (topRight == null) topRight = topLeft;
            if (bottomRight == null) bottomRight = topLeft;
            if (bottomLeft == null) bottomLeft = topLeft;
        }
        radiusTopLeft = topLeft;
        radiusTopRight = topRight;
        radiusBottomRight = bottomRight;
        radiusBottomLeft = bottomLeft;
    }

}
