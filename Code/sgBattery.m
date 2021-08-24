classdef (Abstract) sgBattery < handle  &  matlab.mixin.Heterogeneous
 
    properties
        mSimTime
        %technicke vlastnosti baterky
        mUnitCap 
        mUnitPowIn 
        mUnitPowOut 
        
        %ekonomicke vlastnosti bateerky
        mUnitPrice
        mBattPrice
        mLife
        mSalvageCoef
        mYOpexCoef   
    end
    properties
        mReqCap
        mReqPowIn
        mReqPowOut
        
        mNomUnits
        mNomCap     %nominálna Kapacita (maximum)
        mNomPowIn   %nominálny príkon/nabíjanie (maximum)
        mNomPowOut  %nominálny vykon /vybíjanie (maximum)
        mNomCapPerc
        mNomPowInPerc
        mNomPowOutPerc
       
        mSimBattLoad
        mSimInitBattLoad
        mSimBattPowInOverRun
        mSimBattPowOutOverRun
        mSimBattCapInOverRun
        mSimBattCapOutOverRun
        
        mSimBattRequested
        mSimBattResponded
    end
    
    methods
        function [rPrice, rLife, rSalvageCoef, rYOpexCoef] =getPriceVector(obj)
            rPrice=obj.mBattPrice;
            rLife=obj.mLife;
            rSalvageCoef=obj.mSalvageCoef;
            rYOpexCoef=obj.mYOpexCoef;
        end
        function plotSoC(obj)
            plot(obj.mSimBattLoad/obj.mNomCap*100);    
            grid on
        end
        function [rInOverRun,rOutOverRun,rMaxInOver,rMaxOutOver]=getPowOverruns(obj)
            rInOverRun  = obj.mSimBattPowInOverRun;
            rOutOverRun = obj.mSimBattPowOutOverRun;
            rMaxInOver  = max(rInOverRun);
            rMaxOutOver = max(rOutOverRun);
            rInOverRun  = rInOverRun  / rMaxInOver*100;
            rOutOverRun = rOutOverRun / rMaxOutOver*100;
            rInOverRun(rInOverRun==0)=NaN;
            rOutOverRun(rOutOverRun==0)=NaN;
        end
        function [rInOverRun,rOutOverRun,rMaxInOver,rMaxOutOver]=getCapOverruns(obj)
            rInOverRun  = obj.mSimBattCapInOverRun;
            rOutOverRun = obj.mSimBattCapOutOverRun;
            rMaxInOver  = max(rInOverRun);
            rMaxOutOver = max(rOutOverRun);
            rInOverRun  = rInOverRun  / rMaxInOver*100;
            rOutOverRun = rOutOverRun / rMaxOutOver*100;
            rInOverRun(rInOverRun==0)=NaN;
            rOutOverRun(rOutOverRun==0)=NaN;
        end

        function plotPowOverruns(varargin)
            obj=varargin{1};
            myOverOutColors=[1 0 0];
            if (nargin>=2)
                if(~varargin{2})
                    myOverOutColors=[0.5 0.5 0];
                end
            end
            myX=obj.mSimTime.getXAxis();
            myplot=plot(myX,obj.mSimBattLoad/obj.mNomCap*100,"b:","LineWidth",2);myplot.Color(4)=0.75;
            hold on
            [vInOverRuns,vOutOverRuns,vMaxInOver,vMaxOutOver]=obj.getPowOverruns();
            myplot=area(myX,vInOverRuns,"FaceColor",[0 0.5 0]); myplot.FaceAlpha=0.25;
            myplot=area(myX,vOutOverRuns,"FaceColor",myOverOutColors); myplot.FaceAlpha=0.25;   
            scatter(myX,vInOverRuns,40,"o","filled",'MarkerFaceColor',[0 0.5 0]);
            scatter(myX,vOutOverRuns,40,"o","filled",'MarkerFaceColor',myOverOutColors);
            legend("SoC","PowInUnused","PowOutFailed")
            xlabel("steps")
            ylabel("[%]")
            %MIPO=MaxInPowerOver( over the battery limits)
            title(sprintf("Battery - Power; In(Lim=%g, MO=%g), Out(Lim=%g, MO=%g) [kW]",...
                obj.mNomPowIn, vMaxInOver,obj.mNomPowOut, vMaxOutOver));
            grid on
        end
        function plotCapOverruns(varargin)
            obj=varargin{1};
            myOverOutColors=[1 0 0];
            if (nargin>=2)
                if(~varargin{2})
                    myOverOutColors=[0.5 0.5 0];
                end
            end
            myX=obj.mSimTime.getXAxis();
            myplot=plot(myX,obj.mSimBattLoad/obj.mNomCap*100,"b:","LineWidth",2);myplot.Color(4)=0.75;
            hold on
            [vInOverRuns,vOutOverRuns,vMaxInOver,vMaxOutOver]=obj.getCapOverruns();
            myplot=area(myX,vInOverRuns,"FaceColor",[0 0.5 0]); myplot.FaceAlpha=0.25;
            myplot=area(myX,vOutOverRuns,"FaceColor",myOverOutColors); myplot.FaceAlpha=0.25;      
            scatter(myX,vInOverRuns,40,"o","filled",'MarkerFaceColor',[0 0.5 0]);
            scatter(myX,vOutOverRuns,40,"o","filled",'MarkerFaceColor',myOverOutColors);
            legend("SoC","CapInOverrun","CapOutOverrun")
            xlabel("steps")
            ylabel("[%]")
            %MIPO=MaxInPowerOver( over the battery limits)            
            title(sprintf("Battery - Energy; NC=%g, MIEO=%4g, MOEO=%4g [kWh]",obj.mNomCap,vMaxInOver,vMaxOutOver))
            grid on
        end
        function plotNabVybPerc(obj)
            [myNab,myVyb]=obj.getNabVyp();
            plot(obj.mSimTime.getXAxis(),myNab/obj.mNomPowIn*100);
            hold on;
            plot(obj.mSimTime.getXAxis(),myVyb/obj.mNomPowOut*100);
            %ylim(1.05*[-obj.mNomPowOut obj.mNomPowIn]);
            grid on;
            title(sprintf("Battery In/Out Power percentage, 100%% MaxPowIn/Out=%g/%g kW",...
                obj.mNomPowIn,obj.mNomPowOut)) 
            ylabel("[%] of Max")
            legend("Charge(In)","Discharge(Out)")
        end
        
        function plotNabVyb(obj)
            myX=obj.mSimTime.getXAxis();
            myplot=plot(myX,obj.mSimBattRequested,"b","LineWidth",2);myplot.Color(4)=0.5;
            hold on
            myplot=plot(myX,obj.mSimBattResponded,"k","LineWidth",2);myplot.Color(4)=0.5;
            [myNab,myVyb]=obj.getNabVyp();
            myplot=plot(myX,myNab,"g","LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot(myX,myVyb,"m","LineWidth",2);myplot.Color(4)=0.5;
            scatter(myX,myNab,40,"o","filled",'MarkerFaceColor',[0 1 0]);
            scatter(myX,myVyb,40,"o","filled",'MarkerFaceColor',[1 0 1]);
            %ylim(1.05*[-obj.mNomPowOut obj.mNomPowIn]);
            title("Power flow to/from battery")
            grid on;
            xlabel("steps");
            ylabel("[kW]");
            legend("requested","managed","charging","discharging")
        end        
        
        function [rNab,rVyb]=getNabVyp(obj)
            myNabVyb=diff([obj.mSimInitBattLoad obj.mSimBattLoad]);
            rNab  = myNabVyb*4;
            rVyb  = myNabVyb*4;
            rNab(rNab<=0)=NaN;
            rVyb(rVyb>=0)=NaN;
        end
        function obj=sgBattery(vSimTime, vUnitCap, vUnitPowIn, vUnitPowOut, vUnitPrice, vLife, vSalvageCoef, vYOpexCoef)
            obj.mSimTime     = vSimTime;
            obj.mUnitCap     = vUnitCap;
            obj.mUnitPowIn   = vUnitPowIn;
            obj.mUnitPowOut  = vUnitPowOut;
            obj.mUnitPrice   = vUnitPrice;
            obj.mLife        = vLife;
            obj.mSalvageCoef = vSalvageCoef;
            obj.mYOpexCoef   = vYOpexCoef;
        end
        
        %do uvahy zober len kapacitu, neoptimalizuj
        function installCap(obj,vReqCap)
            obj.mNomUnits=ceil(vReqCap/obj.mUnitCap); %do uvahy zober len kapacitu, neoptimalizuj
            initRest(obj,vReqCap,0,0); % rrequest zero vReqPowOut,vReqPowIn);
            obj.reset();
        end
        %Ber všetko do úvahy, cena ale bude väčšia
        function installOpt(obj,vReqCap,vReqPowOut,vReqPowIn)
            obj.mNomUnits=max(ceil([vReqCap/obj.mUnitCap, vReqPowIn/obj.mUnitPowIn, vReqPowOut/obj.mUnitPowOut]));
            initRest(this,vReqCap,vReqPowOut,vReqPowIn);
            obj.reset();
        end
        function initRest(obj,vReqCap,vReqPowOut,vReqPowIn)
            obj.mReqCap=vReqCap;
            obj.mReqPowOut=vReqPowOut;
            obj.mReqPowIn=vReqPowIn;
            obj.mNomCap=obj.mNomUnits*obj.mUnitCap;
            obj.mNomPowIn=obj.mNomUnits*obj.mUnitPowIn;
            obj.mNomPowOut=obj.mNomUnits*obj.mUnitPowOut;
            obj.mBattPrice = obj.mNomUnits* obj.mUnitPrice;
            obj.mNomCapPerc   =100*obj.mNomCap   /obj.mReqCap;
            obj.mNomPowInPerc =100*obj.mNomPowIn /obj.mReqPowIn;
            obj.mNomPowOutPerc=100*obj.mNomPowOut/obj.mReqPowOut;
        end

        function reset(obj)
            obj.mSimBattLoad              = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimInitBattLoad          = obj.mNomCap;  
            obj.mSimBattPowInOverRun      = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimBattPowOutOverRun     = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimBattCapInOverRun      = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimBattCapOutOverRun     = zeros(1,obj.mSimTime.getSimDurationInSteps());
            
            obj.mSimBattRequested         = zeros(1,obj.mSimTime.getSimDurationInSteps());
            obj.mSimBattResponded         = zeros(1,obj.mSimTime.getSimDurationInSteps());
            
        end
        %ak mame ist do plusu tak nabijame, ak mame ist do minusu tak vybijame
        %   retVal  je to, ako to bateria vyuzila. 
        %a) pri nabijani - vyuzila vsetko poskytovane... spotreebovala menej
        %b) pri vybijani   poskytla vsetko potreebne ... poskytla menej
        
        function rkW15minUpdate=simStep(obj,vReqkW15minUpdate)
            myActTime=obj.mSimTime.getActTime();
            if(myActTime==0)
                actBattLoad=obj.mSimInitBattLoad;
            else
                actBattLoad=obj.mSimBattLoad(obj.mSimTime.getActTime());
            end
            %1) check for in/out power OVERRUNS
            mykW15min=vReqkW15minUpdate;
            %check for power out  overrun
            if (mykW15min>obj.mNomPowIn)
                obj.mSimBattPowInOverRun(myActTime+1)=mykW15min-obj.mNomPowIn;
                mykW15min=obj.mNomPowIn;
            %check for power out  overrun
            elseif (mykW15min<-obj.mNomPowOut)
                obj.mSimBattPowOutOverRun(myActTime+1)=-mykW15min-obj.mNomPowOut;
                mykW15min=-obj.mNomPowOut;
            end
            %2) check for capacity OVERRUNS
            %check for capacity overrun
            if(obj.mNomCap<(actBattLoad+mykW15min/4))
                obj.mSimBattCapInOverRun(myActTime+1)=(actBattLoad+mykW15min/4)-obj.mNomCap;
                mykW15min=(obj.mNomCap-actBattLoad)*4;
            %check for capacity underrun
            elseif ((actBattLoad+mykW15min/4)<0)
                obj.mSimBattCapOutOverRun(myActTime+1)=-(actBattLoad+mykW15min/4);
                mykW15min=-actBattLoad*4;
            end
            obj.mSimBattLoad(myActTime+1)=actBattLoad+mykW15min/4;
            rkW15minUpdate=mykW15min;
            obj.mSimBattRequested(myActTime+1)=vReqkW15minUpdate;
            obj.mSimBattResponded(myActTime+1)=rkW15minUpdate;
        end
        function plotAll(varargin)
            obj=varargin{1};
            myLim=obj.mSimTime.getLimits();
            myComment="";
            ISFD=0;
            if (nargin>=2)
                myComment=" ("+varargin{2}+")";
                if (nargin>=3)
                    myLim=varargin{3};
                end
                if (nargin>=4)
                    ISFD=varargin{4};
                end
            end
            
            figure
            subplot(3,1,1)
            obj.plotNabVyb()
            xlim(myLim)
            subplot(3,1,2)
            obj.plotPowOverruns(ISFD)
            xlim(myLim)
            subplot(3,1,3)
            obj.plotCapOverruns(ISFD)
            xlim(myLim)
            sgtitle(sprintf("%s view of PowerWall battery simulation",myComment))
        end
    end
end
