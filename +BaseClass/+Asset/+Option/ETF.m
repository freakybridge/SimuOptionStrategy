% ETF��Ȩ����
% v1.3.0.20220113.beta
%       1.�����Ա����Լ��
%       2.���Ա�ع�
% v1.2.0.20220105.beta
%       �״����
classdef ETF < BaseClass.Asset.Option.Option
    methods
        function obj = ETF(varargin)
            obj = obj@BaseClass.Asset.Option.Option(varargin{:});
        end
    end    
end