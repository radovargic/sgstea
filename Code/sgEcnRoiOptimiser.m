classdef sgEcnRoiOptimiser < handle 
    properties
        mNumyears
        m2DparA
        m2DparAName        
        m2DparB
        m2DparBName
        mInitStatFun
        mInitDynFun
        
        mOutArray
    end
    methods
        function obj=sgEcnRoiOptimiser(vNumyears)
            obj.mNumyears=vNumyears;
        end
        function set2D(obj,v2DparAName, v2DparA, v2DparBName,v2DparB)
            obj.m2DparA=v2DparA;
            obj.m2DparAName=v2DparAName;
            obj.m2DparB=v2DparB;
            obj.m2DparBName=v2DparBName;
        end
        function setInitStat(obj, vHandle)
            obj.mInitStatFun=vHandle;
        end
        function setInitDyn(obj, vHandle)
            obj.mInitDynFun=vHandle;
        end
        function run2D(obj,vTitle)
            dimR=size(obj.m2DparA,2);
            dimC=size(obj.m2DparB,2);
            obj.mOutArray=zeros(dimR,dimC);
            interation=0;
            for row=1:dimR
                for col=1:dimC
                    myEcnTime=sgEcnTime(obj.mNumyears);
                    myBeforeCosts=sgEcnCosts(myEcnTime,"Before");                    
                    myAfterCosts=sgEcnCosts(myEcnTime,"After");
                    obj.mInitStatFun(myBeforeCosts,myAfterCosts);
                    obj.mInitDynFun(myBeforeCosts,myAfterCosts,obj.m2DparA(row),obj.m2DparB(col));
                    myRoiModel=sgEcnRoiModel(myBeforeCosts, myAfterCosts);
                    obj.mOutArray(row,col)=myRoiModel.computeRoi(0);
                    interation=interation+1;
                    display(sprintf("Computing ... %g%%",interation/(dimR*dimC)*100));
                end
            end
            figure
            surf(obj.m2DparB,obj.m2DparA,obj.mOutArray);
            xlabel(obj.m2DparBName);
            ylabel(obj.m2DparAName);
            zlabel("RoI [years]");
            view(-100,37);
            title(vTitle)
        end
    end
end
    
