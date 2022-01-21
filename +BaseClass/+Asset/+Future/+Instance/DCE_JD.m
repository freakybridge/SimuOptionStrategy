% JD FUTURE类
% v1.3.0.20220113.beta
%       首次添加
classdef (Sealed) DCE_JD < BaseClass.Asset.Future.Future
    
    % 父类Asset属性
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'JD';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]];
        tick_size double = 1;
        date_ini char = '2013/11/08';
    end
    
    % 构造函数
    methods
        function obj = DCE_JD(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end