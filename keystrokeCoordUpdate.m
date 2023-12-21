function [source, receiver] = keystrokeCoordUpdate(source, receiver, room, event)
    switch event.Key
        case 'a'
            if (0 <= source(1) - 1)
                source(1) = source(1) - 5;
            end
        case 's'
            if (0 <= source(2) - 1)
                source(2) = source(2) - 5;
            end
        case 'd'
            if (room(1) >= source(1) + 1)
                source(1) = source(1) + 5;
            end
        case 'w'
            if (room(2) >= source(2) + 1)
                source(2) = source(2) + 5;
            end
        case 'q'
            if (0 <= source(3) - 1)
                source(3) = source(3) - 5;
            end
        case 'e'
            if (room(3) >= source(3) + 5)
                source(3) = source(3) + 5;
            end
        case 'uparrow'
            if (room(2) >= receiver(2) + 5)
                receiver(2) = receiver(2) + 5;
            end
        case 'downarrow'
            if (0 <= receiver(2) - 5)
                receiver(2) = receiver(2) - 5;
            end
        case 'leftarrow'
            if (0 <= receiver(1) - 5)
                receiver(1) = receiver(1) - 5;
            end
        case 'rightarrow'
            if (room(1) >= receiver(1) + 5)
                receiver(1) = receiver(1) + 5;
            end
        case 'o'
            if (room(3) >= receiver(3) + 5)
                receiver(3) = receiver(3) + 5;
            end
        case 'p'
            if (0 <= receiver(3) - 5)
                receiver(3) = receiver(3) - 5;
            end
    end
end