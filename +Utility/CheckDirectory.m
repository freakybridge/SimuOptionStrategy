% ���Ŀ¼
function CheckDirectory(pth)

if (exist(pth, 'dir') == 0)
    mkdir(pth);
end
end