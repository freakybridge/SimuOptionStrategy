% DataManager / IsInstruNeedUpdate �ж��Ƿ���Ҫ���º�Լ��
% v1.2.0.20220105.beta
%       �״�����
function ret = IsInstruNeedUpdate(~, instrus)

% ����ǰ�޺�Լ��Ϣ���������
if (isempty(instrus))
    ret = true;
    return;
end

% �����ϴθ�������7�죬�������
last_ud_dt = max(datenum(instrus.LAST_UPDATE_DATE));
if (now - last_ud_dt >= 7)
    ret = true;
else
    ret = false;
end
end