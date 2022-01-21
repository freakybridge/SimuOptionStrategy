% OI FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CZCE_OI < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'OI';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2007/06/08';
    end
    
    % ���캯��
    methods
        function obj = CZCE_OI(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end