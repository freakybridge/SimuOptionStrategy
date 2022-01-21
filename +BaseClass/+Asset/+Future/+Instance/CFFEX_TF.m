% TF FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) CFFEX_TF < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CFFEX;
        variety char = 'TF';
        tradetimetable double = [[930, 1130]; [1300, 1515]];
        tick_size double = 0.2;
        date_ini char = '2013/09/06';
    end
    
    % 构造函数
    methods
        function obj = CFFEX_TF(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end