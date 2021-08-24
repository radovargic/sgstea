classdef sgBatterySupCap < sgBattery
    methods
        function obj=sgBatterySupCap(vSimTime)
             %                          mUnitCap, mUnitPowIn, mUnitPowOut,   mUnitPrice,  mLife, mSalvagecoef, mYOpexCoef                            %                                         
             %                          kWh/item,    kW/item,     kW/item,     EUR/item,  years,         coef,       coef                  
             obj@sgBattery(vSimTime,    0.054,       118,             118,         1186,     15,          0.2,       0.05);
             %template: EATON
             %link: https://www.eaton.com/content/dam/eaton/products/electronic-components/resources/data-sheet/eaton-xlr-48-supercapacitor-module-data-sheet.pdf
             %Unit pricee is 1400 USD pre 0.054kWh: https://www.digikey.com/en/products/detail/eaton-electronics-division/XLR-48R6167-R/5956249
             %1 kWh Powerpack=7200/13.5=533.3EUR/kWh
             %1 kWh Eaton = 1400/0.054=25926 USD/kWh = 21964.5 EUR/kWh, .
             % i.e. Eaton is 41.2 TIMES more EXPEENSIVE per kWh !!!
        end
    end

end
