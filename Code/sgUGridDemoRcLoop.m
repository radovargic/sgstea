% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for mmber variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgUGridDemoRcLoop
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);

    myUgridNameA="sgUGridDemoRcLoop";
    mySimTimeA   = myProfile.getSimTime(myUgridNameA);
    myConsumerA  = sgConsumer(mySimTimeA,myProfile);
    myBattA      = sgBatteryPowWall(mySimTimeA);
    myBattA.installCap(200);
    %myBattA      = sgBatteryHybrid(mySimTimeA,0,200, 1);
    myUGridA     = sgUGrid(mySimTimeA, myConsumerA, 0, myBattA);
      
    myMaxRc=myProfile.getMaxProfVal()
    myMinRc=0;
    myRcStep=-10;
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
        %myUGridA.plotResults([2420 2480],[800,1130],"DNV_BATT");
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
    outFname=sprintf("../Results/%s.png",myUgridNameA)
    print(myFig,outFname,'-dpng','-r300')
    disp(sprintf("Overall uGrid situation stored as:%s", outFname))
    
