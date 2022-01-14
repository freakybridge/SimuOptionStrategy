% Index基类
% v1.3.0.20220113.beta
%       首次添加
classdef Index < BaseClass.Asset.Index.Index
    properties (Constant)
        product EnumType.Product = EnumType.Product.Index;
    end

    
    methods
        function obj = Index(inputArg1,inputArg2)
            %INDEX 构造此类的实例
            %   此处显示详细说明
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            outputArg = obj.Property1 + inputArg;
        end
    end
end



%                 '000001.SH', '1990/12/19'; ...
%                 '000016.SH', '2004/01/12'; ...
%                 '000188.SH', '2015/02/09'; ...
%                 '000300.SH', '2005/01/04';...
%                 '000905.SH', '2007/01/15';...
%                 '399001.SZ', '1991/04/03';...
%                 '399005.SZ', '2006/01/24';...
%                 '399006.SZ', '2010/06/01'; ...