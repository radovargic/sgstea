% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for member variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgProfileDemo
    clear all;
    close all;
    myProfile=sgProfile("DNV",'../Data/DNV-optimalizacia.xlsx',3,6);
    myProfile.plotProfile();
    myProfile.analyse();
end