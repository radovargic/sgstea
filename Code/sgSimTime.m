% time simulation is in 15 minute steps.
% steps are counted from 0
% so the first day has steps 0, 1, ... 95
% second ray has steps 96, 97, ...
% real days are counted 1-30,  months are counted 1-12
% simulation duration days, months are counted from 0

classdef sgSimTime < handle
  
    properties (Access = private)
        mMonDays=[31,28,31,30,31,30,31,31,30,31,30,31];
        mDAYSTEPS=96;
        mYEARMONTHS=12;
        
        mCnt
        mCntStepDayMon   %counter of steps in actual day
        mCntDayMon       %counter of days in actual month
        mCntMon
        mCumulMonSteps 
    end
    
    %public properties
    properties
        mName
    end
    
    properties
        mStartMonth
        mMonths
        mDurationInSteps
    end
    
    methods
        function rStep=getActStepInDay(obj)
            rStep=obj.mCntStepDayMon;
        end
        function rStep=getActDayInMon(obj)
            rStep=obj.mCntDayMon;
        end
        function rStep=getActMonInSim(obj)
            rStep=obj.mCntMon;
        end
        
        function obj=sgSimTime(vTimerName, vStartMonth, vMonths)
            obj.mName=vTimerName;
            obj.mStartMonth=vStartMonth;
            obj.mMonths=vMonths;
            obj.reset();
        end
        function changeName(obj,vNewName)
            obj.mName=vNewName;
        end 
        function rAxis=getXAxis(obj)
            rAxis=[0:(obj.mDurationInSteps-1)];
        end
        function rLimits=getLimits(obj)
            rLimits=[0,obj.mDurationInSteps];
        end
        function rMonths=getSimDurationInMonths(obj)
            rMonths=obj.mMonths;
        end
        % simmonths are counted from 0 !
        function rStartStep=getSimMonStart(obj,vSimMon)
           if(vSimMon==0)
               rStartStep=0;
           else
               rStartStep=obj.mCumulMonSteps(vSimMon)-1;
           end
        end
        %get last mon idem index, truncate if exceeding the array
        function rEndStep=getSimMonEnd(obj,vSimMon)
           myMon=min(vSimMon+1,length(obj.mCumulMonSteps));
           rEndStep=obj.mCumulMonSteps(myMon)-1;
        end
        function [rStartStep,rEndStep]=getActMonthRest(obj)
           if(obj.mCntMon<obj.mMonths)
               rStartStep=obj.mCnt;
               rEndStep=obj.getSimMonEnd(obj.mCntMon);
           else
               rStartStep=nan;
               rEndStep=nan;
           end
        end
        
        function tick(obj,vPrintEpoch)
            if(obj.mCntStepDayMon==0 & vPrintEpoch)
               disp(sprintf("[%s EPOCH %07d=%02d:%02d:%02d]",obj.mName, obj.mCnt, obj.mCntMon, obj.mCntDayMon,obj.mCntStepDayMon)) 
            end
            obj.mCnt=obj.mCnt+1;
            obj.mCntStepDayMon=obj.mCntStepDayMon+1;
            if(obj.mCntStepDayMon==obj.mDAYSTEPS)
                obj.mCntStepDayMon=0;
                obj.mCntDayMon=obj.mCntDayMon+1;
                actMonIdx=mod(obj.mStartMonth-1+obj.mCntMon,obj.mYEARMONTHS)+1;
                if(obj.mCntDayMon>(obj.mMonDays(actMonIdx)-1))
                    obj.mCntDayMon=0;
                    obj.mCntMon=obj.mCntMon+1;
                end
            end
%            display(sprintf("[SIM EPOCH %07d=%02d:%02d:%02d]",obj.mCnt, obj.mCntMon, obj.mCntDayMon,obj.mCntStepDayMon)) 
        end
        function rVal=ActStepIsFirstInDay(obj)
            rVal=(obj.mCntStepDayMon==0);
        end        
        function rVal=ActStepIsLastInDay(obj)
            rVal=((obj.mCntStepDayMon+1)==obj.mDAYSTEPS);
        end       
        function rVal=ActStepIsFirstInMonth(obj)
            rVal=(obj.mCntStepDayMon==0 & obj.mCntDayMon==0);
        end        
        function rVal=ActStepIsLastInMonth(obj)
            rVal=false;
            %check if last step in day
            if((obj.mCntStepDayMon+1)==obj.mDAYSTEPS)
                actMonIdx=mod(obj.mStartMonth-1+obj.mCntMon,obj.mYEARMONTHS)+1;
                if(obj.mCntDayMon+1>(obj.mMonDays(actMonIdx)-1))
                    rVal=true;
                end
            end
        end            
        
        function rVal=notFinished(obj)
            rVal = (obj.mCnt<obj.mDurationInSteps);
        end
        function steps=getSimDurationInSteps(obj)
            steps=obj.mDurationInSteps;
        end
        function rActTime=getActMon(obj)
            rActTime=obj.mCntMon;
        end
        function rActTime=getActTime(obj)
            rActTime=obj.mCnt;
        end
        function reset(obj)
            obj.mCntMon=0;
            obj.mCntDayMon=0;
            obj.mCntStepDayMon=0;
            obj.mCnt=0;
            simDurationInDays=0;
            simMonDays=zeros(1,obj.mMonths);
            for actMon=0:(obj.mMonths-1)
                actMonIdx=mod(obj.mStartMonth-1+actMon,obj.mYEARMONTHS)+1;
%                simDurationInDays=simDurationInDays+obj.monDays(actMonIdx);
                simMonDays(actMon+1)=obj.mMonDays(actMonIdx);
            end
            simDurationInDays=sum(simMonDays);
            obj.mDurationInSteps=simDurationInDays*obj.mDAYSTEPS;
            obj.mCumulMonSteps=cumsum(simMonDays)*obj.mDAYSTEPS;
        end       
    end
end

