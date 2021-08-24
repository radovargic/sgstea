% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for member variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
clear all;
close all;
myRoiOptimiser=sgEcnRoiOptimiser(15);
myRoiOptimiser.demo();
return;

myRoiModel=sgRoiModel(15);
myRoiModel.demo();
return


% myVectSalvage={0.2;0.9;10}
% myVectSalvage=[2:9]/10
% 
% for loop1=myVectSalvage
% end
% 
%             %obj.addAfterCapex("Battery",500,0.2,0.01);
% 
% function demo(obj)
%             obj.addBeforeMonOpex("RK+Fines",100/12);
%             %obj.addBeforeCapex("Battery",500,NaN,0.01);
%             obj.addAfterMonOpex("RK+Fines",150/12);
%             %obj.addAfterCapex("Battery",500,0.2,0.01);
%             %obj.mBeforeList.myPlot(1);
%             %obj.mAfterList.myPlot(1);
%             myROI=obj.computeRoi(1)
%             
%         end


%myProfile=sgProfile('../../00_Data/001.xls',4,0);
myProfile=sgProfile('../../00_Data/DNV-optimalizacia.xlsx',3,6);
%myProfile.analyse();
mySimTime=myProfile.getSimTime();
myConsumer=sgConsumer(mySimTime,myProfile);

myElNetwork = sgElNetwork(mySimTime,12,1200);
myElNetwork.reserveCapacity(1070);

%myBatt      = sgBatteryPowWall(mySimTime);
%myBatt.installCap(2000,0,0);
myBatt  = sgBatteryHybrid(mySimTime,0,200, 1);

myUGrid     = sgUGrid(mySimTime, myConsumer, myElNetwork, myBatt);
tic

myUGrid.doSimulation();
toc
myUGrid.plotResults([100,350],[800,1100],"DNV");

%compute RoI against reference situation
myBeforeElNetwork = sgElNetwork(obj.mSimTime,12,1200);
myBeforeElNetwork.reserveCapacity(1200);      
myUGrid.computeRoI(obj,myBeforeElNetwork);
