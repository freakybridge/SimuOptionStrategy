% CS FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) DCE_CS < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'CS';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2014/12/09';
    end
    
    % 构造函数
    methods
        function obj = DCE_CS(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end