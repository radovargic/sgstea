classdef sgEcnTcoItem < handle & matlab.mixin.Heterogeneous
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mEcnTime
        mName
    end
    
    methods(Abstract)
        rTco=getTco(obj, vDoPlot)
    end
    methods
        %--------------------------------------------------------------
        function obj = sgEcnTcoItem(vEcnTime, vName)
            obj.mEcnTime=vEcnTime;
            obj.mName=vName;            
        end
        %--------------------------------------------------------------
    end
end

