%This is CAPACITY DEMO - nice images and detail how the battery SoC
%grows/sinks a how big is potential to grow/sing
clear all;
close all;
doDemo(@sgBatteryHybridDemo);
doDemo(@sgBatteryPowWallDemoCap);
doDemo(@sgBatteryPowWallDemoPow);
doDemo(@sgEcnCostsDemo);
doDemo(@sgEcnRoiModelDemo);
doDemo(@sgEcnRoiOptimiserDemo);
doDemo(@sgProfileDemo);
doDemo(@sgProfileDemoSquare);
doDemo(@sgSimTimeDemo);
doDemo(@sgUGridDemo);
doDemo(@sgUGridDemoAboveMrc);
doDemo(@sgUGridDemoParadox);
doDemo(@sgUGridDemoRcLoop);
doDemo(@sgUGridDemoRcLoopCmp);
doDemo(@sgUGridDemoRcLoopParadox);
disp("==========================================================");
disp("              ALL DEMOS SUCCESSFULLY PASSED !!!")
disp("==========================================================");
clear all;
close all;

function doDemo(vDemo)
    myInfo=functions(vDemo);
    disp("==========================================================");
    disp(sprintf("Executing demo: %s",myInfo.function));
    vDemo();
end