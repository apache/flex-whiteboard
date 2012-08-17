/**
 *  CFPE
 */
package flex.classloader
{
import flash.events.Event;

/**
 * Class Loader Events
 */
public class ClassLoaderEvent extends Event
{
    public static var CLASS_CONTAINER_LOADED:String = "loaded";
    public static var CLASS_CONTAINER_ERROR:String = "error";
    public static var CLASS_CONTAINER_UNLOADED:String = "unloaded";


    public var msg:String;

    /**
     * Constructor
     */
    public function ClassLoaderEvent(type:String, msg:String = "")
    {
        super(type);

        this.msg = msg;
    }


    /**
     * Clone for re-dispatch
     */
    override public function clone():Event
    {
        return new ClassLoaderEvent(this.type, this.msg);
    }
}
}
