classdef sgElNetwork < handle
    
    properties (Access = private)
        mRcFixPeriods       = [1,3,12]
        mRcFixPricesPerkW  = [6.2243, 5.4124,4.6005]
        mRcFixRcFinePerkW  = 33.1939
        mRcFixMrcFinePerkW = 3*33.1939
    end
    properties
        mSimTime
        mSimFixPer
        mSimRcMonUnitPrice
        mSimMrcVal
        mSimRcLog
        mSimRcMonths
        mSimInvLog
        mSimInvRcLog
        mSimInvFineLog

        mSimRcOrigInMonths
        mSimRcOrigInSteps
        mSimRcInSteps
        mSimConsumptionSteps
        mSimConsMaxMonth
    end
    
    methods
        function rRc=getRc(obj)
            rRc=obj.mSimRcInSteps;
        end
        
        %------------------------------------------------------------
        %based on real costs during the whole simulation, estimate the
        %average costs per month
        function rCosts=avgMoncosts(obj)
            rCosts = obj.mSimInvLog.getSum(4)/obj.mSimTime.getSimDurationInMonths();
        end
        function rCosts=avgRcMoncosts(obj)
            rCosts = obj.mSimInvRcLog.getSum(4)/obj.mSimTime.getSimDurationInMonths();
        end
        function rCosts=avgFineMoncosts(obj)
            rCosts = obj.mSimInvFineLog.getSum(4)/obj.mSimTime.getSimDurationInMonths();
        end
        %------------------------------------------------------------
        function obj=sgElNetwork(vSimTime,vFixPeriod,vMrcValue)
            fixPerType=find(obj.mRcFixPeriods==vFixPeriod);
            if (isempty(fixPerType))
                error(sprintf("Not supporteed fixation period %d months",vFixPeriod))
            end
            obj.mSimTime           = vSimTime;
            obj.mSimFixPer         = vFixPeriod;
            obj.mSimRcMonUnitPrice = obj.mRcFixPricesPerkW(fixPerType);
            obj.mSimMrcVal         = vMrcValue;
            %obj.myLog=sheet(3);
            obj.mSimConsumptionSteps    = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimRcOrigInSteps       = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimRcInSteps           = zeros(1,obj.mSimTime.getSimDurationInSteps()); %this will dynamically upgrade
            obj.mSimRcOrigInMonths      = zeros(1,obj.mSimTime.getSimDurationInMonths());
            obj.mSimRcMonths            = 0;  %reserved months
            obj.mSimRcLog               = sgLog(vSimTime,{"Rc[kW]"});
            obj.mSimInvLog              = sgLog(vSimTime,{"Month","Type","RcUpg[kW]","Price[Eur]"});
            obj.mSimInvRcLog            = sgLog(vSimTime,{"Month","Type","RcUpg[kW]","Price[Eur]"});
            obj.mSimInvFineLog          = sgLog(vSimTime,{"Month","Type","RcUpg[kW]","Price[Eur]"});
            
        end
        %------------------------------------------------------------
        function obj=consume(obj,vConsumption)
            actIdx=obj.mSimTime.getActTime()+1;
            obj.mSimConsumptionSteps(actIdx)=vConsumption;
            if(vConsumption>obj.mSimRcInSteps(actIdx))
                %we exceeeded the Rk ... ... now how much?
                rcViolation=min(vConsumption,obj.mSimMrcVal)-obj.mSimRcInSteps(actIdx);
                mrcViolation=vConsumption-max(obj.mSimMrcVal,obj.mSimRcInSteps(actIdx));
                
                
                if(rcViolation>0)
                    fineRcString="+"+rcViolation+"="+vConsumption;
                    fineRc=rcViolation * obj.mRcFixRcFinePerkW;
                    obj.mSimInvLog.add({obj.mSimTime.getActMon(),"fineRc",fineRcString,fineRc});
                    obj.mSimInvFineLog.add({obj.mSimTime.getActMon(),"fineRc",fineRcString,fineRc});          
                end
                if(mrcViolation>0)
                    fineMRcString="+"+mrcViolation+"="+vConsumption;
                    fineMrc=mrcViolation * obj.mRcFixMrcFinePerkW;
                    obj.mSimInvLog.add({obj.mSimTime.getActMon(),"fineMrc",fineMRcString,fineMrc});
                    obj.mSimInvFineLog.add({obj.mSimTime.getActMon(),"fineMrc",fineMRcString,fineMrc});
                end
                [startRcstep,endRcstep] = obj.mSimTime.getActMonthRest();
                obj.mSimRcInSteps(startRcstep+1:endRcstep+1) = vConsumption;                
            end
            if(obj.mSimTime.ActStepIsLastInMonth())
                %when actual inteerval is the last in month, we need to pay ordered RC
                %issue the invoice
                actMon    = obj.mSimTime.getActMon();
                orderedRc = obj.mSimRcOrigInMonths(actMon+1);
                price     = orderedRc*obj.mSimRcMonUnitPrice;
                obj.mSimInvLog.add({actMon,"RcFee",orderedRc,price})
                obj.mSimInvRcLog.add({actMon,"RcFee",orderedRc,price})
            end
                
        end
        %------------------------------------------------------------
        function reserveCapacity(obj,vRcValue)
            obj.mSimRcLog.add({vRcValue});
            startRcIdx = 1+obj.mSimTime.getSimMonStart(obj.mSimRcMonths);
            endRcIdx    = 1+obj.mSimTime.getSimMonEnd(obj.mSimRcMonths+obj.mSimFixPer);
            obj.mSimRcOrigInSteps(startRcIdx:endRcIdx)=vRcValue;
            obj.mSimRcInSteps(startRcIdx:endRcIdx)=vRcValue;
            obj.mSimRcOrigInMonths(obj.mSimRcMonths+1:obj.mSimRcMonths+obj.mSimFixPer)=vRcValue;
            obj.mSimRcMonths=obj.mSimRcMonths+obj.mSimFixPer;
        end
        %------------------------------------------------------------
        function plotRc(obj)
            obj.mLog.plot(3);
        end
        function [rCons,rRC,rARC,rAMRC]=getDataLogs(obj)
            rCons=obj.mSimConsumptionSteps;
            rRC  = obj.mSimRcInSteps;
            rARC = obj.mSimRcInSteps;
            rAMRC= obj.mSimRcInSteps;
            rRC(rRC>obj.mSimRcOrigInSteps)=NaN;
            rARC((rARC==obj.mSimRcOrigInSteps)|(rARC>obj.mSimMrcVal))=NaN;
            rAMRC((rAMRC==obj.mSimRcOrigInSteps)|(rARC<=obj.mSimMrcVal))=NaN;
        end
        %------------------------------------------------------------
        function plotRcCons(obj)
            [myCons,myRC,myARC,myAMRC]=getDataLogs(obj);
            myplot=plot(myCons,"k","LineWidth",2);myplot.Color(4)=0.5;
            hold on
            myplot=plot(myRC,"r","LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot(myARC,"g","LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot(myAMRC,"b","LineWidth",2);myplot.Color(4)=0.5;
            legend("consumption","Rc","aboveRc","aboveMrc","Location","SouthEast")
        end
        %------------------------------------------------------------
        function rActRc = getActRc(obj)
            rActRc=obj.mSimRcInSteps(obj.mSimTime.getActTime()+1);
        end
    end
end

