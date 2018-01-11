package backend;

import snow.types.Types;
import snow.modules.opengl.GL;

using StringTools;

class Images implements spec.Images {

    public function new() {}

    public function load(path:String, ?options:LoadImageOptions, done:Image->Void):Void {

        var clearPixels = options == null || options.pixels == null || options.pixels == false;
        var createTexture = options == null || options.texture == null || options.texture == true;

        var snowApp = ceramic.App.app.backend.snow;

        path = ceramic.Utils.realPath(path);

        // Is image currently loading?
        if (loadingImageCallbacks.exists(path)) {
            // Yes, just bind it
            loadingImageCallbacks.get(path).push(function(image:Image) {
                done(image);
            });
            return;
        }
        else {
            // Add loading callbacks array
            loadingImageCallbacks.set(path, []);
        }

        function allDone(image:Image) {

            var callbacks = loadingImageCallbacks.get(path);
            if (callbacks != null) {
                loadingImageCallbacks.remove(path);
                done(image);
                for (callback in callbacks) {
                    callback(image);
                }
            }
            else {
                done(image);
            }
        }
        
        var list = [
            snowApp.assets.image(path)
        ];
        
        snow.api.Promise.all(list)
        .then(function(assets:Array<AssetImage>) {

            for (asset in assets) {
                var result = new ImageImpl(asset.image.width, asset.image.height);
                result.asset = asset;

                if (createTexture) {
                    result.loadTexture(clearPixels);
                }
                else if (clearPixels) {
                    result.pixels = null;
                    result.asset.image.pixels = null;
                }
                
                allDone(result);
                return;
            }

            allDone(null);

        }).error(function(error) {

            allDone(null);
        });

    } //load

    public function createImage(width:Int, height:Int):Image {

        return new ImageImpl(width, height);

    } //createImage

    public function destroyImage(image:Image):Void {

        // TODO

    } //destroyImage

    inline public function getImageWidth(image:Image):Int {

        return (image:ImageImpl).width;

    } //getImageWidth

    inline public function getImageHeight(image:Image):Int {

        return (image:ImageImpl).height;

    } //getImageHeight

    inline public function getImagePixels(image:Image):UInt8Array {

        return (image:ImageImpl).pixels;

    } //getImagePixels

    public function createRenderTarget(width:Int, height:Int):Image {

        return null; // TODO

    } //createRenderTarget

/// Internal

    var loadingImageCallbacks:Map<String,Array<Image->Void>> = new Map();

    var loadedImages:Map<String,ImageImpl> = new Map();

    var loadedImagesRetainCount:Map<String,Int> = new Map();

} //Images
