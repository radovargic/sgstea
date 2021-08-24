% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for mmber variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgUGridDemoRcLoopParadox
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);

    myUgridNameA="sgUGridDemoRcLoopParadox";
    mySimTimeA   = myProfile.getSimTime(myUgridNameA);
    myConsumerA  = sgConsumer(mySimTimeA,myProfile);
    myBattA      = sgBatteryPowWall(mySimTimeA);
    myBattA.installCap(200);
    %myBattA      = sgBatteryHybrid(mySimTimeA,0,200, 1);
    myUGridA     = sgUGrid(mySimTimeA, myConsumerA, 0, myBattA);
      
    myMaxRc=myProfile.getMaxProfVal()
    myMinRc=0;
    myRcStep=-5;
    myRcVec=myMaxRc:myRcStep:myMinRc;
    myLoops=size(myRcVec,2);
    myFines=zeros(1,myLoops);
    myRcPrices=zeros(1,myLoops);
    myPrintEpoch=0;
    for myIdx=1:myLoops
        disp(sprintf("Loop=%g Rc=%g",myIdx, myRcVec(myIdx)));
        myElNetworkA = sgElNetwork(mySimTimeA,12,1500);
        myElNetworkA.reserveCapacity(myRcVec(myIdx));
        myUGridA.ConnectElnAndReset(myElNetworkA);
        myUGridA.doSimulation(myPrintEpoch);
        myRcPrices(myIdx)=myElNetworkA.avgRcMoncosts();
        myFines(myIdx)=myElNetworkA.avgFineMoncosts();
    end
    myFig=figure
    plot(myRcVec,myRcPrices)
    hold on
    plot(myRcVec,myFines)
    legend("RcPrice","Fines");
    myFig.PaperUnits = 'inches';
    myFig.PaperPosition = [0 0 12 6 ];
    outFname=sprintf("../Results/sgUGridDemoRkLoopParadox.png")
    print(myFig,outFname,'-dpng','-r300')
    disp(sprintf("Overall uGrid situation stored as:%s", outFname))

    
