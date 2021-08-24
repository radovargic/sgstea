classdef sgProfile < handle 
    properties
        mTime
        
        mData
        mSize
        
        mStartMon
        mDurationMon
        
        mFname
    end
    methods
        %methods
        %   analyseProfile
        %   getMaxProfVal(obj)
        %   getTotalConsumption
        %   loadProfile
        %   plotProfile
        %------------------------------------------------------------
        function add(obj,vOtherObj)
            if(obj.mSize~=vOtherObj.mSize)
                error("Cannot add profiles with diferent sizes(%g!=%g",...
                    obj.mSize, vOtherObj.mSize);
            end
            obj.mData=obj.mData+vOtherObj.mData;
        end
        function analyse(obj)
            %play with histograms
            figure      
            h=histogram(obj.mData,100);
            myMax=max(obj.mData);
            myMin=min(obj.mData);
            myMea=mean(obj.mData);
            myMed=median(obj.mData);
            maxVal=max(h.Values);
            hXvals=h.BinEdges(1:end-1) + h.BinWidth/2;
            hMea=v_mean(hXvals,h.Values);
            hMed=v_median(hXvals,h.Values);            
            title(sprintf("Profile histogram (max:%.0f, min:%.0f mea:%.0f med:%.0f)", ...
                myMax, myMin, myMea,myMed))
            hold on
            myplot=plot([myMea,myMea],[0,maxVal],"LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot([myMed,myMed],[0,maxVal],"LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot([hMea,hMea],[0,maxVal],"LineWidth",2);myplot.Color(4)=0.5;
            myplot=plot([hMed,hMed],[0,maxVal],"LineWidth",2);myplot.Color(4)=0.5;
            legend("histogram", "mean","median","h.mean=mean","h.median.median");
            xlabel("kW")
        end
        %------------------------------------------------------------
        function rVal=getProfVal(obj,vIdx)
            rVal=obj.mData(vIdx);
        end
         %------------------------------------------------------------
        function rVal=get(obj)
            rVal=obj.mData();
        end
        %------------------------------------------------------------
        
        function myMax=getMaxProfVal(obj)
            myMax=max(obj.mData);
        end

        %------------------------------------------------------------
        function totalkWh=getTotalConsumption(obj)
            totalkWh=sum(obj.mData)/4;
        end
        %------------------------------------------------------------
        %function obj = sgProfilevDataFileName,vColumn,vSkipLines)
        function obj = sgProfile(varargin)
            if(nargin==4)
                obj.sgProfileFromExcel(varargin{:})
            elseif (varargin{1}=="square")
                 obj.sgProfileGenSquare(varargin{2:end})          
            else
                error("Bad INIT")
            end
        end
        function sgProfileGenSquare(obj,vMonths,vT, vTabove,vTbelow, vValAmp, vValShift)
            obj.mStartMon=1;
            obj.mDurationMon=vMonths;
            obj.mTime=sgSimTime("squareTimer", obj.mStartMon, obj.mDurationMon);
            mySteps=obj.mTime.getSimDurationInSteps();
            myTsig=[vValShift+vValAmp*[ones(1,vTabove), -ones(1,vTbelow)], zeros(1, vT-vTabove-vTbelow)];
            numSig=ceil(mySteps/vT);
            myNTSig=repmat(myTsig,1,numSig);
            obj.mSize=mySteps;
            obj.mData=myNTSig(1:mySteps);
            
        end
        
        function sgProfileFromExcel(obj,vProfileName,vDataFileName,vColumn,vSkipLines)
            %example usage
            %obj.getProfile(sprintf('../Data/%s.xls',outPrefix),4,0);
            %obj.getProfile(sprintf('../../00_Data/%s.xls',outPrefix),4,0);
            %obj.getProfile('../../00_Data/DNV-optimalizacia.xlsx',3,6);
            obj.mFname=vDataFileName;
            tabdata = readtable(obj.mFname, 'ReadVariableNames',false, 'NumHeaderLines', vSkipLines);
            obj.mData=eval(sprintf("tabdata.Var%d", vColumn));
            obj.mSize=size(obj.mData,1);
            startDate=tabdata.Var1(1);
            myStart=strsplit(startDate{1},".");
            endDate=tabdata.Var1(obj.mSize);
            myEnd=strsplit(endDate{1},".");
            startMon=str2double(myStart{2});
            endMon=str2double(myEnd{2});
            startY=str2double(myStart{3});
            endY=str2double(myEnd{3});
            durationMon=12*endY+endMon-(12*startY+startMon)+1;
            obj.mStartMon=startMon;
            obj.mDurationMon=durationMon;            
            %create simTime object anc check the duration
            obj.mTime=sgSimTime(vProfileName, obj.mStartMon, obj.mDurationMon);
            if(obj.mTime.getSimDurationInSteps() ~= obj.mSize)
                error(sprintf("Wrong profile data duration, expected=%d, available=%d",...
                    rSimTime.getSimDurationInSteps(),obj.mSize))
            else
                display(sprintf("Profile (file=%s) loaded, duration=%d",obj.mFname, obj.mSize))
            end
        end
        %------------------------------------------------------------
        function rSimTime=getProfileTime(obj)
            rSimTime=obj.mTime() 
        end
        %------------------------------------------------------------
        function rSimTime=getSimTime(obj,vTimeName)
            rSimTime=sgSimTime(vTimeName, obj.mStartMon, obj.mDurationMon);
        end
        %------------------------------------------------------------
        function plotProfile(varargin)
            obj=varargin{1};
            myLim=[1,obj.mSize];
            myComment="";
            if (nargin>=2)
                myComment=" ("+varargin{2}+")";
                if (nargin>=3)
                    myLim=varargin{3};
                end
            end
            figure
            plot(obj.mTime.getXAxis(),obj.mData)
            title("Power")
            ylabel("kW")
            xlabel("interval")           
            xlim(myLim)
            grid on
            title("Profile data"+myComment)
        end
    end
end