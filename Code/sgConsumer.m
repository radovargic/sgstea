classdef sgConsumer < handle 
    properties
        mProfile
        mSimTime
    end
    methods
        function obj=sgConsumer(vSimTime, vProfile)
            obj.mProfile=vProfile;
            obj.mSimTime=vSimTime;
        end
        function rConsumption=doConsumption(obj)
            rConsumption=obj.mProfile.getProfVal(obj.mSimTime.getActTime()+1);
        end
    end
end