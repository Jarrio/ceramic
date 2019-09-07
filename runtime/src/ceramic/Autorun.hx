package ceramic;

import ceramic.Shortcuts.*;

using ceramic.Extensions;

class Autorun extends Entity {

/// Current autorun

    static var prevCurrent:Array<Autorun> = [];

    public static var current:Autorun = null;

/// Events

    @event function reset();

/// Properties

    var onRun:Void->Void;

    var boundAutorunArrays:Array<Array<Autorun>> = null;

    public var invalidated(default,null):Bool = false;

/// Lifecycle

    public function new(onRun:Void->Void) {

        this.onRun = onRun;

        // Run once to create initial binding and execute callback
        run();

    } //new

    override function destroy() {

        // Ensure everything gets unbound
        emitReset();

        // Remove any callback as we won't use it anymore
        onRun = null;

        // Destroy
        super.destroy();

    } //destroy

    inline function willEmitReset():Void {

        unbindFromAllAutorunArrays();

    } //willEmitReset

    public function run():Void {

        // Nothing to do if destroyed
        if (destroyed) return;

        // We are not invalidated anymore as we are resetting state
        invalidated = false;

        // Unbind everything
        emitReset();

        // Set current autorun to self
        var _prevCurrent = current;
        current = this;
        var numPrevCurrent = prevCurrent.length;

        // Run (and bind) again
        onRun();

        // Restore previous current autorun
        while (numPrevCurrent < prevCurrent.length) prevCurrent.pop();
        current = _prevCurrent;

    } //run

    inline public function invalidate():Void {

        if (invalidated) return;
        invalidated = true;

        unbindFromAllAutorunArrays();

        app.onceImmediate(run);

    } //invalidate

/// Static helpers

    /** Ensures current `autorun` won't be affected by the code after this call.
        `reobserve()` should be called to restore previous state. */
    #if !debug inline #end public static function unobserve():Void {

        // Set current autorun to null
        prevCurrent.push(current);
        current = null;

    } //unobserve

    /** Resume observing values and resume affecting current `autorun` scope.
        This should be called after an `unobserve()` call. */
    #if !debug inline #end public static function reobserve():Void {

        Assert.assert(prevCurrent.length > 0, 'Cannot call reobserve() without calling observe() before.');

        // Restore previous current autorun
        current = prevCurrent.pop();

    } //reobserve

    /** Executes the given function synchronously and ensures the
        current `autorun` scope won't be affected */
    public static function unobserved(func:Void->Void):Void {

        unobserve();
        func();
        reobserve();

    } //unobserved

/// Autorun arrays

    public function bindToAutorunArray(autorunArray:Array<Autorun>):Void {

        // There is no reason to bind to an already invalidated autorun.
        // (this should not happen when correctly used by the way)
        if (invalidated) return;
        
        // Check if this autorun array is already bound
        var alreadyBound = false;
        if (boundAutorunArrays == null) {
            boundAutorunArrays = getArrayOfAutorunArrays();
        }
        else {
            for (i in 0...boundAutorunArrays.length) {
                if (boundAutorunArrays.unsafeGet(i) == autorunArray) {
                    alreadyBound = true;
                    break;
                }
            }
        }

        // If not, do it
        if (!alreadyBound) {
            autorunArray.push(this);
            boundAutorunArrays.push(autorunArray);
        }

    } //bindToAutorunArray

    public function unbindFromAllAutorunArrays():Void {

        if (boundAutorunArrays != null) {
            for (ii in 0...boundAutorunArrays.length) {
                var autorunArray = boundAutorunArrays.unsafeGet(ii);

                for (i in 0...autorunArray.length) {
                    var autorun = autorunArray.unsafeGet(i);
                    if (autorun == this) {
                        autorunArray.unsafeSet(i, null);
                    }
                }
            }

            recycleArrayOfAutorunArrays(boundAutorunArrays);
            boundAutorunArrays = null;
        }

    } //unbindFromAllAutorunArrays

/// Recycling autorun arrays

    static var _autorunArrays:Array<Array<Autorun>> = [];
    static var _autorunArraysLen:Int = 0;

    public static function getAutorunArray():Array<Autorun> {

        if (_autorunArraysLen > 0) {
            _autorunArraysLen--;
            var array = _autorunArrays[_autorunArraysLen];
            _autorunArrays[_autorunArraysLen] = null;
            return array;
        }
        else {
            return [];
        }

    } //getAutorunArray

    public static function recycleAutorunArray(array:Array<Autorun>):Void {

        #if cpp
        untyped array.__SetSize(0);
        #else
        array.splice(0, array.length);
        #end

        _autorunArrays[_autorunArraysLen] = array;
        _autorunArraysLen++;

    } //recycleAutorunArray

/// Recycling array of autorun arrays

    static var _arrayOfAutorunArrays:Array<Array<Array<Autorun>>> = [];
    static var _arrayOfAutorunArraysLen:Int = 0;

    inline public static function getArrayOfAutorunArrays():Array<Array<Autorun>> {

        if (_arrayOfAutorunArraysLen > 0) {
            _arrayOfAutorunArraysLen--;
            var array = _arrayOfAutorunArrays[_arrayOfAutorunArraysLen];
            _arrayOfAutorunArrays[_arrayOfAutorunArraysLen] = null;
            return array;
        }
        else {
            return [];
        }

    } //getArrayOfAutorunArrays

    inline public static function recycleArrayOfAutorunArrays(array:Array<Array<Autorun>>):Void {

        #if cpp
        untyped array.__SetSize(0);
        #else
        array.splice(0, array.length);
        #end

        _arrayOfAutorunArrays[_arrayOfAutorunArraysLen] = array;
        _arrayOfAutorunArraysLen++;

    } //recycleArrayOfAutorunArrays

} //Autorun
