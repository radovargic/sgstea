classdef sgEcnTcoOpexItem < sgEcnTcoItem
    properties
        mMonOpex
    end
    
    methods
        %--------------------------------------------------------------
        function obj = sgEcnTcoOpexItem(vEcnTime, vName, vMonOpex)  
            obj@sgEcnTcoItem(vEcnTime, sprintf("%s, OPX[%g]",vName,vMonOpex));           
            obj.mMonOpex=vMonOpex;
        end
        %--------------------------------------------------------------
        function rTco=getTco(obj, vDoPlot)
            myIntervals=obj.mEcnTime.mIntervals;
            mytimeline=[0:myIntervals];
            rTco=mytimeline*obj.mMonOpex*12/obj.mEcnTime.getYearIntervals();
            if(vDoPlot)
                plot(rTco)
                title(sprintf("TCO [EUR] - Detail for: %s, period: %g Years",obj.mName,obj.mEcnTime.mNumYears))
            end
        end 
    end
end

