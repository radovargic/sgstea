% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for mmber variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgUGridDemo
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);
    %myProfile=sgProfile('../Data/Nakup.xlsx',3,6);
    myPrintEpochTime=1;
    if(1)
        myUgridNameA="sgUGridDemoUgA";
        %MICROGRID A 
        mySimTimeA   = myProfile.getSimTime(myUgridNameA);
        myConsumerA  = sgConsumer(mySimTimeA,myProfile);
        myElNetworkA = sgElNetwork(mySimTimeA,12,1500);
        myElNetworkA.reserveCapacity(1018);
        myBattA      = sgBatteryPowWall(mySimTimeA);
        myBattA.installCap(200);
        %myBattA      = sgBatteryHybrid(mySimTimeA,0,200, 1);
        myUGridA     = sgUGrid(mySimTimeA, myConsumerA, myElNetworkA, myBattA);
        tic
        myUGridA.doSimulation(myPrintEpochTime);
        toc
        myUGridA.plotResults(myUgridNameA+"_ALL");
        myUGridA.zoomResults(myUgridNameA+"_ZOOM",[2420 2480],[800,1130]);
        myElNetworkA.mSimInvLog.mDataArray
    end
    %MICROGRID B
    if (1)
        myUgridNameB="sgUGridDemoUgB";
        mySimTimeB=myProfile.getSimTime(myUgridNameB);
        myConsumerB=sgConsumer(mySimTimeB,myProfile);
        myElNetworkB = sgElNetwork(mySimTimeB,12,1500);
        myElNetworkB.reserveCapacity(1300);
        myUGridB     = sgUGrid(mySimTimeB, myConsumerB, myElNetworkB, NaN);
        tic
        myUGridB.doSimulation(myPrintEpochTime);
        toc
        myUGridB.plotResults(myUgridNameB+"_ALL");
        myUGridB.zoomResults(myUgridNameB+"_ZOOM",[2420 2480],[800,1130]);
    end

    myProvideDetails = 1;
    myEcnYears       = 15
    myEcnTime        = sgEcnTime(myEcnYears );
    myUGridACosts    = myUGridA.getCosts(myEcnTime);
    myUGridBCosts    = myUGridB.getCosts(myEcnTime);

    % plot the costs
    myUGridACosts.myPlot(myProvideDetails);
    myUGridBCosts.myPlot(myProvideDetails);

    %create RoI model and compute ...
    myRoiModel       = sgEcnRoiModel(myUGridBCosts, myUGridACosts);
    myRoi=myRoiModel.computeRoi(myProvideDetails)
end 


