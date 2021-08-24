% Compare the Hybrid battery capabilities
% Slow versus Fast - what is the potential giveen the capacity and playing
% with RC

function sgUGridDemoRcLoopCmp
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);
    
    myMaxRc=myProfile.getMaxProfVal()
    myMinRc=0;
    myRcStep=-10;
    myRcVec=myMaxRc:myRcStep:myMinRc;
    
    mySimTime    = myProfile.getSimTime("profileTime");
    myConsumer   = sgConsumer(mySimTime,myProfile);
 
    myCapVect=[200];
    %myCapVect=[100,200,500,1000,2000,5000,10000,100000,200000, 400000];
    for myCap=myCapVect
        myCap
        myUgridNameA  = "sgUGridDemoRcLoopCmp_UGA";
        myUgridNameB  = "sgUGridDemoRcLoopCmp_UGB";
        myBattA       = sgBatteryHybrid(mySimTime,myCap,  0, 1); %fast
        myBattB       = sgBatteryHybrid(mySimTime,  0,myCap, 1); %slow

        [myFinesA,myRcPricesA] = finUgCosts(myUgridNameA, mySimTime, myConsumer, myBattA, myRcVec);
        [myFinesB,myRcPricesB] = finUgCosts(myUgridNameB, mySimTime, myConsumer, myBattB, myRcVec);
        myFig=figure
        myplot=plot(myRcVec,myRcPricesA,"r","LineWidth",2);myplot.Color(4)=0.5;
        hold on
        myplot= plot(myRcVec,myFinesA,"g","LineWidth",2);myplot.Color(4)=0.5;
%        myplot=plot(myRcVec,myRcPricesB,"--","LineWidth",2);myplot.Color(4)=0.5;
        myplot=plot(myRcVec,myFinesB,"b--","LineWidth",2);myplot.Color(4)=0.5;
        xlabel("Rc [kW]");
        ylabel("[EUR]");
        grid on
        xlim([myMinRc, myMaxRc])
        legend("RcCosts","Fines FastBatt","Fines SlowBatt");
        title(sprintf("Fines/RcCosts comparison, Battery Capacity=%g [kWh]",myCap));
        myFig.PaperUnits = 'inches';
        myFig.PaperPosition = [0 0 6 3 ];
        outFname=sprintf("../Results/sgUGridDemoRkLoopCmp%g.png",myCap)
        print(myFig,outFname,'-dpng','-r300')
        disp(sprintf("Overall uGrid situation stored as:%s", outFname))
    end
end
    
    function [rFines,rRcPrices] =finUgCosts(vUgridName, vSimTime, vConsumer, vBatt, vRcVec)
        vSimTime.changeName(vUgridName);
        myUGrid     = sgUGrid(vSimTime, vConsumer, 0, vBatt);

        myLoops=size(vRcVec,2);
        myFines=zeros(1,myLoops);
        myRcPrices=zeros(1,myLoops);
        myPrintEpoch=0;
        for myIdx=1:myLoops
            disp(sprintf("Loop=%g Rc=%g",myIdx, vRcVec(myIdx)));
            myElNetworkA = sgElNetwork(vSimTime,12,1500);
            myElNetworkA.reserveCapacity(vRcVec(myIdx));
            myUGrid.ConnectElnAndReset(myElNetworkA);
            myUGrid.doSimulation(myPrintEpoch);
            %myUGridA.plotResults([2420 2480],[800,1130],"DNV_BATT");
            myRcPrices(myIdx)=myElNetworkA.avgRcMoncosts();
            myFines(myIdx)=myElNetworkA.avgFineMoncosts();
        end
        rFines=myFines;
        rRcPrices=myRcPrices;
    end
    