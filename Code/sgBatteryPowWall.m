classdef sgBatteryPowWall < sgBattery
    methods
        function obj=sgBatteryPowWall(vSimTime)
             %                          mUnitCap, mUnitPowIn, mUnitPowOut,   mUnitPrice,  mLife, mSalvagecoef, mYOpexCoef                            %                                         
             %                          kWh/item,    kW/item,     kW/item,     EUR/item,  years,         coef,       coef                  
%             obj@sgBattery(vSimTime,    13.5,              5,           5,         7200,     15,          0.2,       0.05);
             obj@sgBattery(vSimTime,    13.5,              5,           5,         7200,     15,          0.2,       0.05);
        end
    end

end
