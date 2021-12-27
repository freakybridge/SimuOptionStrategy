% ¼ì²éÄ¿Â¼
function CheckDirectory(pth)

if (exist(pth, 'dir') == 0)
    mkdir(pth);
end
end