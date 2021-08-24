% Project Smart grid uses lowerCamelCase notation
% sg - SmartGrid (prefix for all classes/Modules
% m  - prefix for member variables
% v  - prefix for passed   values to   functions
% r  - prefix for returned values from functions
% my - prefix for local variables
function sgSimTimeDemo
    clear all;
    close all;
    myStartMonth=1 %january
    myMonths=2
    myTime=sgSimTime("Demo",myStartMonth, myMonths);
   [rStartStep,rEndStep]=myTime.getActMonthRest();
   disp(sprintf("Act month=%g [start=%g, end=%g]",myTime.getActMon(),rStartStep,rEndStep))
   myEndStepMon0=myTime.getSimMonEnd(0)
   myEndStepMon1=myTime.getSimMonEnd(1)
    %perform all simulation steeps
    while(myTime.notFinished())
        if(myTime.ActStepIsFirstInDay())
           disp(sprintf("THIS IS THE FIRST STEP IN day %g",myTime.getActDayInMon()));
       end
       if(myTime.ActStepIsLastInDay())
           disp(sprintf("THIS IS THE LAST STEP IN day %g",myTime.getActDayInMon()));
       end
       if(myTime.ActStepIsFirstInMonth())
           disp(sprintf("MOREOVER, THIS IS THE FIRST STEP IN MONTH %g",myTime.getActMonInSim()));
           [rStartStep,rEndStep]=myTime.getActMonthRest();
           disp(sprintf("Act month=%g [start=%g, end=%g]",myTime.getActMon(),rStartStep,rEndStep))
       end
       if(myTime.ActStepIsLastInMonth())
           disp(sprintf("MOREOVER, THIS IS THE LAST STEP IN MONTH %g",myTime.getActMonInSim()));
           [rStartStep,rEndStep]=myTime.getActMonthRest();
           disp(sprintf("Act month=%g [start=%g, end=%g]",myTime.getActMon(),rStartStep,rEndStep))
       end     
       myTime.tick(1);
    end
       [rStartStep,rEndStep]=myTime.getActMonthRest();
   disp(sprintf("Act month=%g [start=%g, end=%g]",myTime.getActMon(),rStartStep,rEndStep))
   myEndStepMon0=myTime.getSimMonEnd(0)
   myEndStepMon1=myTime.getSimMonEnd(1)
end