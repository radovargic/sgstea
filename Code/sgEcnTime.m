classdef sgEcnTime < handle 
    
    properties
        mNumYears
        mDaysPerYear
        mIntervalsPerDay
        mIntervals       
    end
    
    methods
        function obj = sgEcnTime(vNumyears)
            obj.mNumYears=vNumyears;
            obj.mDaysPerYear=365;
            obj.mIntervalsPerDay=96;
            obj.mIntervals=obj.mNumYears*obj.mDaysPerYear*obj.mIntervalsPerDay;
        end
        function rYears=getYears(obj)
            rYears=obj.mNumYears;
        end 
        
        function rIntervals=getYearIntervals(obj)
            rIntervals=obj.mDaysPerYear*obj.mIntervalsPerDay;
        end 
        function [rTimelineYears, rTimelineYearsLim] =getTimelineInYears(obj)
            rTimelineYears=(0:obj.mIntervals)/obj.getYearIntervals();
            rTimelineYearsLim=[0, obj.mIntervals/obj.getYearIntervals()];
        end
        function rTimeY=getTimeInYearsForStep(obj,vStep)
            rTimeY=vStep/obj.getYearIntervals();
        end
    end
end

