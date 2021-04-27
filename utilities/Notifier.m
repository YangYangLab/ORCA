classdef Notifier < handle
    events
        FramesIn
        Reloading
    end
    properties
        Data
    end
    methods
        function FileChanged(obj)
            notify(obj,'FramesIn')
        end
        function Reload(obj)
            notify(obj, 'Reloading')
        end
    end
end


    
       
