%toto nie je rovnaka baterka ako ostatne jednoduche, daneho typu
classdef sgBatteryHybrid < handle
    properties
        mBattFast
        mBattSlow
        mSimTime
        mAlgNum
        
        mSimBattRequested
        mSimBattResponded
        
        mBattFastCap
        mBattSlowCap
    end
    methods
        function [rPrice, rLife, rSalvageCoef, rYOpexCoef] =getPriceVector(obj)
            [myfPrice, myfLife, myfSalvageCoef, myfYOpexCoef]=getPriceVector(obj.mBattFast);
            [mysPrice, mysLife, mysSalvageCoef, mysYOpexCoef]=getPriceVector(obj.mBattSlow);
            rPrice       = myfPrice+mysPrice;
            rLife        = min([myfLife,mysLife]);
            rSalvageCoef = max([myfSalvageCoef,mysSalvageCoef]);
            rYOpexCoef   = max([myfYOpexCoef,mysYOpexCoef]);
        end
 
        function obj=sgBatteryHybrid(vSimTime,vFastCap,vSlowCap,vAlgNum)
            obj.mSimTime=vSimTime;
            obj.mBattFast=sgBatterySupCap(vSimTime);
            obj.mBattSlow=sgBatteryPowWall(vSimTime);
            obj.mBattFastCap=vFastCap;
            obj.mBattSlowCap=vSlowCap;
            obj.mAlgNum=vAlgNum;
            obj.reset();
        end
        function reset(obj)
            obj.mBattFast.installCap(obj.mBattFastCap);
            obj.mBattSlow.installCap(obj.mBattSlowCap);
            obj.mSimBattRequested         = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimBattResponded         = zeros(1,obj.mSimTime.getSimDurationInSteps());
        end
        function [rNab,rVyb]=getNabVyp(obj)
            [FNab,FVyb]=obj.mBattFast.getNabVyp();
            [SNab,SVyb]=obj.mBattSlow.getNabVyp();
            rNab=combineNan(FNab,SNab);
            rVyb=combineNan(FVyb,SVyb);
        end
        function plotNabVyb(obj,vViewName)
            myX=obj.mSimTime.getXAxis();
            myplot=plot(myX,obj.mSimBattRequested,"b","LineWidth",2);myplot.Color(4)=0.5;
            hold on
            myplot=plot(myX,obj.mSimBattResponded,"k","LineWidth",2);myplot.Color(4)=0.5;
            [myNab,myVyb]=obj.getNabVyp();
            myplot=plot(myX,myNab,"g","LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot(myX,myVyb,"m","LineWidth",2);myplot.Color(4)=0.5;
            scatter(myX,myNab,40,"o","filled",'MarkerFaceColor',[0 1 0]);
            scatter(myX,myVyb,40,"o","filled",'MarkerFaceColor',[1 0 1]);
            [myNab,myVyb]=obj.getNabVyp();
            %ylim(1.05*[-obj.mNomPowOut obj.mNomPowIn]);
            title(sprintf("%s, power flow to/from battery",vViewName));
            grid on;
            xlabel("steps");
            ylabel("[kW]");
            legend("requested","managed","charging","discharging")
        end        
        
        % ALGNUM    ChargeOrder   DischargeOrder
        % 1          F, S         F, S
        % 2          F, S         S, F
        % 3          S, F         S, F
        % 4          S, F         F, S
        function updated=simStep(obj,kW15minUpdate)
            switch(obj.mAlgNum)
                case 1
                    % ALGNUM    ChargeOrder   DischargeOrder
                    % 1          F, S         F, S
                    if(kW15minUpdate>0)
                        %we have energy, we can charge
                        %first charge the FAST BATTERY
                        updated=obj.mBattFast.simStep(kW15minUpdate);
                        chargeRest1=kW15minUpdate-updated;
                        % we cycle the charge for SLOW BATTERY with the rest
                        updated=updated+obj.mBattSlow.simStep(chargeRest1);                  
                    else
                        %we need energy
                        %First try to use maximum from FAST battery
                        updated=obj.mBattFast.simStep(kW15minUpdate);
                        dischargeRest1=kW15minUpdate-updated;
                        %we cycle the discharge for SLOW BATTERY with the rest
                        updated=updated+obj.mBattSlow.simStep(dischargeRest1);                  
                    end
                case 2
                    % ALGNUM    ChargeOrder   DischargeOrder
                    % 2          F, S         S, F
                    if(kW15minUpdate>0)
                        %we have energy, we can charge
                        %first charge the FAST BATTERY
                        updated=obj.mBattFast.simStep(kW15minUpdate);
                        chargeRest1=kW15minUpdate-updated;
                        %we cycle the charge for SLOW BATTERY with the rest
                        updated=updated+obj.mBattSlow.simStep(chargeRest1);                  
                    else
                        %we need energy
                        %First try to use maximum from SLOW BATTERY
                        updated=obj.mBattSlow.simStep(kW15minUpdate);
                        dischargeRest1=kW15minUpdate-updated;
                        %we cycle the discharge for FAST BATTERY with the rest
                        updated=updated+obj.mBattFast.simStep(dischargeRest1);                  
                    end
                case 3
                    % ALGNUM    ChargeOrder   DischargeOrder
                    % 3          S, F         S, F
                    if(kW15minUpdate>0)
                        %we have energy, we can charge
                        %first charge the SLOW BATTERY
                        updated=obj.mBattSlow.simStep(kW15minUpdate);
                        chargeRest1=kW15minUpdate-updated;
                        %we cycle the charge for FAST BATTERY with the rest
                        updated=updated+obj.mBattFast.simStep(chargeRest1);                  
                    else
                        %we need energy
                        %First try to use maximum from SLOW BATTERY
                        updated=obj.mBattSlow.simStep(kW15minUpdate);
                        dischargeRest1=kW15minUpdate-updated;
                        %we cycle the discharge for FAST BATTERY with the rest
                        updated=updated+obj.mBattFast.simStep(dischargeRest1);                  
                    end
                case 4
                    % ALGNUM    ChargeOrder   DischargeOrder
                    % 4          S, F         F, S
                    if(kW15minUpdate>0)
                        %we have energy, we can charge
                        %first charge the SLOW BATTERY
                        updated=obj.mBattSlow.simStep(kW15minUpdate);
                        chargeRest1=kW15minUpdate-updated;
                        %we cycle the charge for FAST BATTERY with the rest
                        updated=updated+obj.mBattFast.simStep(chargeRest1);                  
                    else
                        %we need energy
                        %First try to use maximum from FAST BATTERY
                        updated=obj.mBattFast.simStep(kW15minUpdate);
                        dischargeRest1=kW15minUpdate-updated;
                        %we cycle the discharge for SLOW BATTERY with the rest
                        updated=updated+obj.mBattSlow.simStep(dischargeRest1);                  
                    end
                otherwise
                    error(sprintf("Hybrid battery Algorithm Nr.%g not yet implemented",obj.mAlgNum))
            end
            myActTime=obj.mSimTime.getActTime();
            obj.mSimBattRequested(myActTime+1)=kW15minUpdate;
            obj.mSimBattResponded(myActTime+1)=updated;
        end
        function plotPowOverruns(obj)
            myplot=plot(obj.mBattFast.mSimBattLoad/obj.mBattFast.mNomCap*100,"b","LineWidth",2);myplot.Color(4)=0.75;
            hold on
            myplot=plot(obj.mBattSlow.mSimBattLoad/obj.mBattSlow.mNomCap*100,"r","LineWidth",2);myplot.Color(4)=0.75;
            
            [vSInOverRuns,vSOutOverRuns,vSMaxInOver,vSMaxOutOver]=obj.mBattSlow.getPowOverruns();
            [vFInOverRuns,vFOutOverRuns,vFMaxInOver,vFMaxOutOver]=obj.mBattFast.getPowOverruns();
            myplot=area(vSInOverRuns,"FaceColor",[0 0.5 0]); myplot.FaceAlpha=0.25;
            myplot=area(vSOutOverRuns,"FaceColor",[0.5 0.5 0]); myplot.FaceAlpha=0.25;      
            myplot=area(vFInOverRuns,"FaceColor",[0 1 0]); myplot.FaceAlpha=1;
            myplot=area(vFOutOverRuns,"FaceColor",[1 1 0]); myplot.FaceAlpha=1;      
            legend("SoCfast","SoCslow","InOverRunSlow","OutOverRunSlow","InOverRunFast","OutOverRunFast")
            xlabel("steps")
            ylabel("[%]")
            title(sprintf("HBAT - Power, NC=%g+%g, MIOS=%g[kW], MOOS=%g[kW]",...
                obj.mBattFast.mNomCap,obj.mBattSlow.mNomCap,vSMaxInOver,vSMaxOutOver))
            grid on
        end
        function plotAll(obj,vViewName,vXLim)
            %Fast is Nor Final when Discharging
            FIFD=((obj.mAlgNum==2) || (obj.mAlgNum==3));
                
            obj.mBattFast.plotAll(vViewName+", Hybrid battery, fast part",vXLim,FIFD);
            obj.mBattSlow.plotAll(vViewName+", Hybrid battery, slow part",vXLim,~FIFD);
            myFig=figure;
            obj.plotNabVyb(vViewName);
            xlim(vXLim)
            sgUtilSaveFig(myFig,"sgBatteryHybrid"+vViewName,[0,0,6,6],200)
        end
    end
end

function rData=combineNan(vData1, vData2)
    rData=zeros(1,size(vData1,1));
    myOk1=~isnan(vData1);
    myOk2=~isnan(vData2);
    myAvailBooth=myOk1 & myOk2;
    myAvailD1only=myOk1 & (~myOk2);
    myAvailD2only=myOk2 & (~myOk1);
    myAvailNoData=(~myOk1) & (~myOk2);
    rData(myAvailBooth)=vData1(myAvailBooth)+vData2(myAvailBooth);
    rData(myAvailD1only)=vData1(myAvailD1only);
    rData(myAvailD2only)=vData2(myAvailD2only);
    rData(myAvailNoData)=NaN;
end
