classdef sgEcnRoiModel < handle 
   
    
    properties
        mEcnTime
        mBeforeCosts
        mAfterCosts
        
    end
    
    methods
        function obj = sgEcnRoiModel(vBeforeCosts, vAfterCosts)
            obj.mBeforeCosts = vBeforeCosts;
            obj.mAfterCosts  = vAfterCosts;
            if (obj.mBeforeCosts.getYears() ~= obj.mAfterCosts.getYears())
                error("Error: Unequal Cost model durations (%g, %g)",...
                    obj.mBeforeCosts.getYears(),obj.mAfterCosts.getYears())
            end 
            obj.mEcnTime=obj.mAfterCosts.getTime();
        end
        function rRoi=computeRoi(obj,vDoPlot)
            myFoundRoi=find(obj.mBeforeCosts.getTco()>obj.mAfterCosts.getTco());
            if(size(myFoundRoi,2)==0)
                rRoi=inf;
            else
                rRoi=obj.mEcnTime.getTimeInYearsForStep(myFoundRoi(1));
            end
            if(vDoPlot)
                figure
                [myTimeline myTimelineLim]=obj.mEcnTime.getTimelineInYears();
                myLine=plot(myTimeline,obj.mBeforeCosts.getTco(),":b","LineWidth",2);myLine.Color(4)=0.5;
                hold on
                myLine=plot(myTimeline,obj.mAfterCosts.getTco,"-b","LineWidth",2);myLine.Color(4)=0.8;
                title(sprintf("RoI situation, RoI=%g years",rRoi));
                xlim(myTimelineLim)
                ylabel("Eur");
                xlabel("Time [years]")
                legend("TCO Before","TCO After")
                if(~isinf(rRoi))
                    plot(rRoi, obj.mAfterCosts.getTcoInTime(myFoundRoi(1)),"ro",'MarkerSize',12,'linewidth',2);
                    legend("TCO Before","TCO After","RoI point")
                else
                    legend("TCO Before","TCO After")
                end
                grid on
            end
        end
    end
end

