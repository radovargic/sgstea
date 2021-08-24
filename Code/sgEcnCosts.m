classdef sgEcnCosts < handle 
    properties
        mEcnTime
        mName
        mList
        mTco
    end
  
    methods   
        %--------------------------------------------------------------
        function obj=sgEcnCosts(vEcnTime,vName)
            obj.mEcnTime=vEcnTime;
            obj.mName=vName;
            obj.mTco=0;
        end
        %--------------------------------------------------------------
        function rEcnTime = getTime(obj)
            rEcnTime= obj.mEcnTime;
        end
        %--------------------------------------------------------------
        function rYears = getYears(obj)
            rYears=obj.mEcnTime.getYears;
        end
        %--------------------------------------------------------------
        function addMonOpex(obj,vName, vMonOpex)
            myNewItem=sgEcnTcoOpexItem(obj.mEcnTime,vName, vMonOpex);
            obj.addItem(myNewItem);
        end
         %--------------------------------------------------------------
        function addCapex(obj,vName, vCapex, vCapexRestPriceCoef,vYearOpexCostCoef)
            myNewItem=sgEcnTcoCapexItem(obj.mEcnTime,vName, vCapex,vCapexRestPriceCoef,vYearOpexCostCoef);
            obj.addItem(myNewItem);
        end
        %--------------------------------------------------------------
        function addItem(obj,vAddItem)
            obj.mList=[obj.mList,vAddItem];
            obj.mTco=obj.mTco+vAddItem.getTco(0);
        end
        
        %--------------------------------------------------------------
        function rVal=getTco(obj)
            rVal=obj.mTco;
        end
         %--------------------------------------------------------------
        function rVal=getTcoInTime(obj,vTime)
            rVal=obj.mTco(vTime);
        end
        %--------------------------------------------------------------
        function myPlot(obj,vPlotDetails)
            figure;
            myItems=size(obj.mList,2);
            [myTimeline myTimelineLim]=obj.mEcnTime.getTimelineInYears();
            for idx=1:myItems
                subplot(myItems+1,1,idx);
                 myLine=plot(myTimeline,obj.mList(idx).getTco(0),"k","LineWidth",2);myLine.Color(4)=0.75;
                title(obj.mList(idx).mName);
                xlim(myTimelineLim)
                ylabel("Eur");
                grid on
            end
            subplot(myItems+1,1,myItems+1);
            myLine=plot(myTimeline,obj.mTco,"k","LineWidth",3);myLine.Color(4)=0.75;
            title("Summed TCO");
            xlim(myTimelineLim)
            ylabel("Eur");
            xlabel("Time [years]")
            grid on
            sgtitle(sprintf("TCO - %s",obj.mName));
            if(vPlotDetails)
                for idx=1:myItems
                    if(isequal(class(obj.mList(idx)),"sgEcnTcoCapexItem"))                      
                        figure
                        obj.mList(idx).getTco(1);
                    end
                end
            end
        end       
    end
end

