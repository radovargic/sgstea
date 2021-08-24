% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for member variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgEcnRoiOptimiserDemo
    clear all;
    close all;
    myRoiOptimiser=sgEcnRoiOptimiser(15);

    myRoiOptimiser.set2D("salvageCoef",[0:9]/10,"opexCoef",[0:10]/100);
    myRoiOptimiser.setInitStat(@demoInitStatRoiModel);
    myRoiOptimiser.setInitDyn(@demoInitDynRoiModel);
    myRoiOptimiser.run2D("DEMO: Smartgrid RoI battery opex/salvage analysis");

    function demoInitStatRoiModel(vBefore,vAfter)
        vBefore.addMonOpex("RK+Fines",100/12);        
        vAfter.addMonOpex("RK+Fines",50/12);
    end
    function demoInitDynRoiModel(vBefore,vAfter,a,b)    
        vAfter.addCapex("Battery",500,a,b);
    end
end