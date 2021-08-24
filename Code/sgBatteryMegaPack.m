classdef sgBatteryMegaPack < sgBattery
    methods
        function obj=sgBatteryMegaPack(vSimTime)
             %                          mUnitCap, mUnitPowIn, mUnitPowOut,   mUnitPrice,  mLife, mSalvagecoef, mYOpexCoef                            %                                         
             %                          kWh/item,    kW/item,     kW/item,     EUR/item,  years,         coef,       coef                  
             obj@sgBattery(vSimTime,       174.4,       43.6,        43.6,        93013,     15,          0.2,       0.05);
             %https://impulsora.com/wp-content/uploads/2020/09/Ficha-Tecnica-Mega-Pack.pdf
             %4 hour version ( 174.4kWh step up to 
             %Round-Trip System Efficiency1=90%
             %Notes: 
             % 1) Price is set to be equivalent with unit kWh price as in PowerWall
             % 2) we can have maximally 17 UNITS, i.e. 2964.8 kWh MAX TOTAL CAPACITY      
             %podla https://www.techbyte.sk/2021/07/tesla-megapack-poziar-hasici/
             %existuju systemy , kde maju 150 takychto baterii -> 450 MWh         
        end
    end

end
