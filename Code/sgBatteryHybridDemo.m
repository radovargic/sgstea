%This is CAPACITY DEMO - nice images and detail how the battery SoC
%grows/sinks a how big is potential to grow/sing
function sgBatteryHybridDemo
    clear all;
    close all;
    myProfile        = getCombiDemoProfile()
    %myProfile       = getFastDemoProfile()
    myTime           = myProfile.getProfileTime()
    myFastBatCap     = 40;
    mySlowBatCap     = 200;
    myHAlg           = 1;    
    myBatt           = sgBatteryHybrid(myTime,myFastBatCap,mySlowBatCap, myHAlg);
    myPrintEpochTime = 1;
    idx=1;
    while(myTime.notFinished())
       myBatt.simStep(myProfile.getProfVal(idx));
       idx=idx+1;
       myTime.tick(myPrintEpochTime);
    end   
    %myBatt.plotAll("Overall",myTime.getLimits());
    myBatt.plotAll("Detail 1",[0 32]);
    myBatt.plotAll("Detail 2",[0 256]);
end

function rProfile=getCombiDemoProfile(obj)
    mySlowProfile   = getSlowDemoProfile();
    myFastProfile   = getFastDemoProfile();
    mySlowProfile.add(myFastProfile);
    rProfile=mySlowProfile;
    rProfile.plotProfile("Combined Profile",[0 32]);
end

function rProfile=getSlowDemoProfile()
    myMonths=1;
    myT=32; %8 hours
    myTabove=4;
    myTbelow=4;

    myValAmp=50; %100kW
    myValShift=-20;
    rProfile=sgProfile("square",myMonths,myT, myTabove, myTbelow, myValAmp,myValShift);
    %myProfile.plotProfile("Test Square Profile");
    rProfile.plotProfile("Slow Profile",[0 myT-1]);
end

function rProfile=getFastDemoProfile()
    myMonths=1;
    myT     =4; % in 15 minute steps 
    myTabove=1;
    myTbelow=1;

    myValAmp=160; %kW
    myValShift=0;
    rProfile=sgProfile("square",myMonths,myT, myTabove, myTbelow, myValAmp,myValShift);
    %myProfile.plotProfile("Test Square Profile");
    rProfile.plotProfile("Fast Profile",[0 myT-1]);
end