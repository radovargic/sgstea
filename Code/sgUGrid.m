classdef sgUGrid < handle 
    properties
        mSimTime
        mElNetwork
        %mGenerator
        mConsumer
        mBatt
        mCosts
        
        mResultsFig
    end
    methods
        function obj=sgUGrid(vSimTime, vConsumer, vElNetwork, vBatt)
            obj.mSimTime   = vSimTime;
            obj.mConsumer  = vConsumer;
            obj.mElNetwork = vElNetwork;
            obj.mBatt      = vBatt;
        end
        function ConnectElnAndReset(obj,vElNetwork)
            obj.mElNetwork = vElNetwork;
            obj.mSimTime.reset();
            obj.mBatt.reset();
        end
            
        function rCosts=getCosts(obj,vEcnTime)
            obj.mCosts = sgEcnCosts(vEcnTime,obj.mSimTime.mName);
            obj.mCosts.addMonOpex("EL. network",obj.mElNetwork.avgMoncosts());
            if(isobject(obj.mBatt))
                [myBattPrice, myBattLife, myBattSalvageC, myBattOpexC]=obj.mBatt.getPriceVector();
                if(myBattLife<vEcnTime.getYears())
                    error("Error: Requested Ecn model duration (%g y) incopatible with BatteryLife (%g y)",...
                             vEcnTime.getYears(),myBattLife)
                else
                    obj.mCosts.addCapex("Battery",myBattPrice,myBattSalvageC,myBattOpexC);
                end
            end
            rCosts=obj.mCosts;
        end
        
        function rResult = doSimulation(obj, vPrintEpoch)         
            while(obj.mSimTime.notFinished())
                actConsumption = obj.mConsumer.doConsumption();
                actRc          = obj.mElNetwork.getActRc();  
                if(isobject(obj.mBatt))
                    % we have battery, try to usee it
                    % and update the consumption correspondingly
                    balanceKw     = actRc-actConsumption;                    
                    % if balancekW >0 we can charge the battery
                    % if balancekW <0 we ask energy from battery
                    balanceKwNew  = obj.mBatt.simStep(balanceKw);
                    actConsumption = actConsumption+balanceKwNew;
                end
                obj.mElNetwork.consume(actConsumption);
                obj.mSimTime.tick(vPrintEpoch);
            end
            rResult=true;
        end
        function rRoI=computeRoI(obj,vRefGrid,vDisplayInfo)
            display(sprintf("*** RoI estimation uGRID %s to reference uGRID %s ***",...
                obj.mSimTime.mName, vRefGrid));
            %we do now 15 YEAR MODEL!!!
            myYears            = 15;
            myBeforeMonCosts   = vRefElNetwork.estMonCosts();
            myAfterMonCosts    = obj.mElNetwork.avgMoncosts();
            myBattPrice        = obj.mBatt.getPrice();
            myBattSalvageCoef  = 0.2;
            myBattYearOpexCoef = 0.05;
            
            myRoiModel=sgEcnRoiModel(myYears);
            myRoiModel.addBeforeMonOpex("RK",myBeforeMonCosts);
            myRoiModel.addAfterMonOpex("RK",myAfterMonCosts);
            myRoiModel.addAfterCapex("Battery",myBattPrice,myBattSalvageCoef,myBattYearOpexCoef);
            rRoI=myRoiModel.computeRoi(1);
            if(vDisplayInfo)
                myYears           
                myBeforeMonCosts   
                myAfterMonCosts 
                myInvoiceLog=obj.mElNetwork.mSimInvLog.mDataArray
                myBattPrice        
                myBattSalvageCoef  
                myBattYearOpexCoef 
                
            end
        end
        function zoomResults(obj,vTitle,vXLim,vYLim)
            myfig=figure;
            origChidren = obj.mResultsFig.Children; 
            copyobj(origChidren, myfig);
            for idx=1:size(myfig.Children,1)
                if (isa(myfig.Children(idx),'matlab.graphics.axis.Axes'))
                   myfig.Children(idx).XLim=vXLim;  
                   if(idx==size(myfig.Children,1))
                       myfig.Children(idx).YLim=vYLim;  
                   end
                end 
            end 
            obj.printImg(myfig,vTitle);
        end
        
        function plotResults(obj,vTitle)
            obj.mResultsFig=figure
            if(isobject(obj.mBatt))
                mySubRows=3;
            else
                mySubRows=1;
            end
            %-----------------------------
            sub1=subplot(mySubRows,1,1);
            [myConsumption,myRC,myARC,myAMRC]=obj.mElNetwork.getDataLogs();
            myProfile=obj.mConsumer.mProfile.get();
            
            myplot=plot(myConsumption,"b","LineWidth",1);myplot.Color(4)=1;
            hold on
            myplot=plot(myProfile,"k","LineWidth",3);myplot.Color(4)=0.25;
            myplot=plot(myRC,"c","LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot(myARC,"m","LineWidth",3);myplot.Color(4)=0.5;
            myplot=plot(myAMRC,"r","LineWidth",4);myplot.Color(4)=0.5;
            
            if(isobject(obj.mBatt))
               [myNab,myVyb]=obj.mBatt.getNabVyp();
                myplot=plot(myRC-myNab,"g","LineWidth",1);myplot.Color(4)=0.5;
                myplot=plot(myRC-myVyb,"y","LineWidth",1);myplot.Color(4)=0.5;
                legend("Grid load", "Profile load","Rc","aboveRc","aboveMrc","batt. charging","batt. discharging","Location","SouthEast")
            else
                legend("Grid load","Profile load","Rc","aboveRc","aboveMrc","Location","SouthEast")
            end
            xlim(obj.mSimTime.getLimits());
            title(sprintf("Migrogrid %s",obj.mSimTime.mName))
            grid on
            ylim([0 max(1.05*[myProfile ;transpose(myRC)])])
            %-----------------------------

            if(isobject(obj.mBatt))
                subplot(mySubRows,1,2);
                obj.mBatt.plotPowOverruns();
                xlim(obj.mSimTime.getLimits());
                            
                subplot(mySubRows,1,3);
                obj.mBatt.plotCapOverruns();
                xlim(obj.mSimTime.getLimits());            
            end
            obj.printImg(obj.mResultsFig,vTitle);
        end
        function printImg(obj,vFig,vTitle)
            vFig.PaperUnits = 'inches';
            vFig.PaperPosition = [0 0 8 12 ];
            outFname=sprintf("../Results/%s.png",vTitle)
            print(vFig,outFname,'-dpng','-r300')
            disp(sprintf("Overall uGrid situation stored as:%s", outFname))
        end

    end
end
    
   