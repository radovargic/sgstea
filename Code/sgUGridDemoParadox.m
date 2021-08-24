% Paradox: smaller RCcan lead to smaller fines. How?
% How is it possible?
% 1) Smaller RC can lead to faster ans smaller RC upgrade 
%    due to battery capacity overrun
%    (see ugA upgrade to 1013->1075 Kw in steps 911-918!
% 2) Bigger  RC can lead to later  but bigger  RC upgrade 
%    due to battery capacity overrun
%    (see ugB upgrade to 1047->1128 Kw in step  2446-2454!
%

function sgUGridDemo
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);
    %myProfile=sgProfile('../Data/Nakup.xlsx',3,6);
    myPrintEpochTime=1;
    %-------------------------------------------------------------
    myUgridNameA="sgUGridDemoParadoxUgA";
    %MICROGRID A 
    mySimTimeA   = myProfile.getSimTime(myUgridNameA);
    myConsumerA  = sgConsumer(mySimTimeA,myProfile);
    myElNetworkA = sgElNetwork(mySimTimeA,12,1500);
    myElNetworkA.reserveCapacity(1013);
    myBattA      = sgBatteryPowWall(mySimTimeA);
    myBattA.installCap(200);
    %myBattA      = sgBatteryHybrid(mySimTimeA,0,200, 1);
    myUGridA     = sgUGrid(mySimTimeA, myConsumerA, myElNetworkA, myBattA);
    tic
    myUGridA.doSimulation(myPrintEpochTime);
    toc
    myUGridA.plotResults(myUgridNameA+"_ALL");
    myUGridA.zoomResults(myUgridNameA+"_ZOOM1",[900,930],[800,1130]);
    myUGridA.zoomResults(myUgridNameA+"_ZOOM2",[2420,2480],[800,1130]);
    myElNetworkA.mSimInvLog.mDataArray

    %-------------------------------------------------------------
    myUgridNameB="sgUGridDemoParadoxUgB";
    mySimTimeB   = myProfile.getSimTime(myUgridNameB);
    myConsumerB  = sgConsumer(mySimTimeB,myProfile);
    myElNetworkB = sgElNetwork(mySimTimeB,12,1500);
    myElNetworkB.reserveCapacity(1018);
    myBattB      = sgBatteryPowWall(mySimTimeB);
    myBattB.installCap(200);
    myUGridB     = sgUGrid(mySimTimeB, myConsumerB, myElNetworkB, myBattB);
    tic
    myUGridB.doSimulation(myPrintEpochTime);
    toc
    myUGridB.plotResults(myUgridNameB+"_ALL");
    myUGridB.zoomResults(myUgridNameB+"_ZOOM1",[900,930],[800,1130]);
    myUGridB.zoomResults(myUgridNameB+"_ZOOM2",[2420,2480],[800,1130]);
    myElNetworkB.mSimInvLog.mDataArray
    end