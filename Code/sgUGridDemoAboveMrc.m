% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for mmber variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgUGridDemoAboveMrc
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);

    myUgridNameA      = "sgUGridDemoAboveMrc";
    mySimTimeA        = myProfile.getSimTime(myUgridNameA);
    myConsumerA       = sgConsumer(mySimTimeA,myProfile);
    myElNetworkA      = sgElNetwork(mySimTimeA,12,1100);
    myElNetworkA.reserveCapacity(1050);
    myBattA           = sgBatteryPowWall(mySimTimeA);
    myBattA.installCap(200);
    %myBattA          = sgBatteryHybrid(mySimTimeA,0,200, 1);
    myUGridA         = sgUGrid(mySimTimeA, myConsumerA, myElNetworkA, myBattA);
    myPrintEpochTime = 1;
    tic
    myUGridA.doSimulation(myPrintEpochTime);
    toc
    myUGridA.plotResults(myUgridNameA+"_ALL");
    myUGridA.zoomResults(myUgridNameA+"_ZOOM",[2420 2480],[800,1130]);
end
