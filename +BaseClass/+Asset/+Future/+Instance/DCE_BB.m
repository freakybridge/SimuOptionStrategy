% BB FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) DCE_BB < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.DCE;
        variety char = 'BB';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]];
        tick_size double = 0.05;
        date_ini char = '2013/12/06';
    end
    
    % ���캯��
    methods
        function obj = DCE_BB(varargin)
            obj = obj@BaseClass.Asset.Future.Future(varargin{:});
        end
    end
end