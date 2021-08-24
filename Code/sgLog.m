classdef sgLog < handle
%zavrhnutee, nebuem implementovat cez containers.Map:
%https://www.mathworks.com/help/matlab/ref/containers.map.html
%zvazovane implemen tovat cez Cell alebo Structure Arrays
%https://www.mathworks.com/help/matlab/matlab_prog/cell-vs-struct-arrays.html

%    properties (Access = private)
    properties
        mDataArray
        mSimTime
        mColNames
    end
    methods
        function obj= sgLog(vSimTime,vColNames)
            obj.mDataArray={};
            obj.mSimTime=vSimTime;
            obj.mColNames=[{"SimCnt"}, vColNames];
        end
        function add(obj,vDataVector)
            obj.mDataArray=[obj.mDataArray; [obj.mSimTime.getActTime(), vDataVector] ];
        end
        function write(obj,fileName)
            outArray=[obj.mColNames; obj.mDataArray];
            writecell(outArray,fileName);
        end  
        function retSum=getSum(obj,vCol)
            %are theree some data rows?
            if(size(obj.mDataArray,2)>0)
                %skip the counter - use only yuser data columns
                retSum=sum([obj.mDataArray{:,vCol+1}]);
            else
                retSum=0;
            end
        end
        function plot(obj,vCol)
            bar([obj.mDataArray{:,1}],[obj.mDataArray{:,vCol+1}]);
            xlabel([obj.mColNames{1}]);
            ylabel([obj.mColNames{vCol+1}]);
        end
    end
end
