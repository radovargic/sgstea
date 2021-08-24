function sgEcnRoiModelDemo
    clear all;
    close all;
    %requested Economic simulation length
    myYears            = 15
    %monthly opex [EUR] before change
    myBeforeMonCosts   = 100/12
    %monthly opex [EUR] after change
    myAfterMonCosts    = 50/12
    %purchase price in [EUR]
    myBattPrice        = 500
    % the battery can be sold after myYears for myBattSalvageCoef*myBattPrice [EUR]
    myBattSalvageCoef  = 0.2;   
    % the battery opex is yearly myBattYearOpexCoef*myBattPrice [EUR]
    myBattYearOpexCoef = 0.01;


    myProvideDetails=1;
    myEcnTime=sgEcnTime(myYears)
    myBeforeCosts=sgEcnCosts(myEcnTime,"Before");
    myBeforeCosts.addMonOpex("RK+Fines",myBeforeMonCosts);
    myBeforeCosts.myPlot(myProvideDetails);
    myAfterCosts=sgEcnCosts(myEcnTime,"After");
    myAfterCosts.addMonOpex("RK+Fines",myAfterMonCosts);
    myAfterCosts.addCapex("Battery",myBattPrice,myBattSalvageCoef,myBattYearOpexCoef);
    myAfterCosts.myPlot(myProvideDetails);

    myRoiModel=sgEcnRoiModel(myBeforeCosts,myAfterCosts);
    myROi=myRoiModel.computeRoi(myProvideDetails)
end
