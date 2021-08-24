% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for member variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgProfileDemoSquare
    clear all;
    close all;
    myMonths=1;
    myT=32; %8 hours
    myTabove=4;
    myTbelow=8;

    myValAmp=50; %100kW
    myValShift=0;

    myProfile=sgProfile("square",myMonths,myT, myTabove, myTbelow, myValAmp,myValShift);
    myProfile.plotProfile("Test Square Profile");
    myProfile.plotProfile("Test Square Profile",[0 myT-1]);
end
