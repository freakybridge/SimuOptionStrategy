% CY FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CZCE_CY < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'CY';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 5;
        date_ini char = '2017/08/18';
    end
    
    % ���캯��
    methods
        function obj = CZCE_CY(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end