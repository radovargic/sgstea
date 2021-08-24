%This is POWER DEMO - nice images and detail how the battery in/out Power varies
% and how it encounters the limits
function sgBatteryPowWallDemoPow
    clear all;
    close all;
    myStartMonth=1; %january
    myMonths=12%wholee year
    myTime=sgSimTime("Demo",myStartMonth, myMonths)
    myBatt      = sgBatteryPowWall(myTime);
    myBatt.installCap(200);

    mySteps=myTime.getSimDurationInSteps();
    myRequest=100*cos(2*pi*4/mySteps*(0:mySteps-1));
    idx=1;
    myPrintEpochTime=1;
    while(myTime.notFinished())
       myBatt.simStep(myRequest(idx));
       idx=idx+1;
       myTime.tick(myPrintEpochTime);
    end   
    myBatt.plotAll("Overall",myTime.getLimits());
    myBatt.plotAll("Detailed",[2100 2500]);
end
