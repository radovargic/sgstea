classdef sgEcnTcoCapexItem < sgEcnTcoItem
    properties
        mInitPrice
        mAfterEcnTimeRestPriceCoef
        mYearOpexCostCoef
    end
    
    methods
        %--------------------------------------------------------------
        function obj = sgEcnTcoCapexItem(vEcnTime, vName, vInitVal, vAfterEcnTimeRestPriceCoef,vYearOpexCostCoef)  
            obj@sgEcnTcoItem(vEcnTime, sprintf("%s, CPX[%g,%g,%g]",vName,vInitVal, vAfterEcnTimeRestPriceCoef,vYearOpexCostCoef));            
            obj.mInitPrice=vInitVal;
            obj.mAfterEcnTimeRestPriceCoef=vAfterEcnTimeRestPriceCoef;
            obj.mYearOpexCostCoef=vYearOpexCostCoef;
        end
        %--------------------------------------------------------------
        %vyzera to, zee zvyskova cena (residual value) 
        %sa tiez pocita linearne, minimalne pri autách:
        %https://www.deskera.com/blog/residual-value/%  
        %existujú aj nelineárne emetódy, tieto sú štandardné:
        %https://corporatefinanceinstitute.com/resources/knowledge/accounting/types-depreciation-methods/
        %mne sa najviac paci: %#4 Sum-of-the-Years-Digits Depreciation Method:
        %odpovedá to zrychlenemu padu  ceny na za ciatku a spomalenemu na konci, 
        %pricom presne sa da stanovit zostatková cena (salvage value, nie rest pricee) 
        %https://www.accountingtools.com/articles/what-is-salvage-value.html
        %napr. ak ma bateria po 15 rokoch zostatkovu hodnotu 20% tymto
        %modelom sa da urcit cena po kazdom roku (anie nie po kazdych
        %15 minutach), toto treba vygooglit, kto vie, ci standard je
        %presne taky ako pri investiciach (eulerovo cislo)        
        function rTco=getTco(obj, vDoPlot)
            myIntervals=obj.mEcnTime.mIntervals;
            mytimeline=[0:myIntervals];
            myCAPEX=obj.mInitPrice*ones(1,myIntervals+1);
            if(isnan(obj.mAfterEcnTimeRestPriceCoef))
                mySalvage=zeros(1,myIntervals+1);
            else
                mysum=myIntervals*(myIntervals+1)/2;
                myDiff=[myIntervals:-1:1]/mysum*obj.mInitPrice*(1-obj.mAfterEcnTimeRestPriceCoef);
                mySalvage=obj.mInitPrice-[0, cumsum(myDiff)];
            end 
            myOpex=mytimeline*(obj.mYearOpexCostCoef/obj.mEcnTime.getYearIntervals())*obj.mInitPrice;
            rTco=myCAPEX-mySalvage+myOpex;
            if(vDoPlot)
                [myTimeline myTimelineLim]=obj.mEcnTime.getTimelineInYears();
                myLine=plot(myTimeline,myCAPEX,"b","LineWidth",2);myLine.Color(4)=0.75;
                hold on
                myLine=plot(myTimeline,mySalvage,"g","LineWidth",2);myLine.Color(4)=0.75;
                myLine=plot(myTimeline,myOpex,"r","LineWidth",2);myLine.Color(4)=0.75;
                myLine=plot(myTimeline,rTco,"k","LineWidth",3);myLine.Color(4)=0.75;
                xlim(myTimelineLim)
                ylabel("Eur");
                xlabel("Time [years]")
                legend("CAPEX","SALVAGE","OPEX","TCO")
                ylabel("Eur");
                title(sprintf("TCO detail for: %s, period: %g Years",obj.mName,obj.mEcnTime.mNumYears))
                grid on
            end
        end 
    end
end

