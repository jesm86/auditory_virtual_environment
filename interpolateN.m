function interpolatedValue = interpolateN(elevationX, azimuthY, hrtf, targetElevation, targetAzimuth)
    % Perform linear interpolation for a given point in 2D space

    % Check if the target point is within the range of the provided data
    if targetElevation < min(elevationX) || targetElevation > max(elevationX) || ...
       targetAzimuth < min(azimuthY) || targetAzimuth > max(azimuthY)
        error('Target point is outside the range of provided data.');
    end

    % Perform linear interpolation for the target point
    interpolatedValue = interp2(elevationX, azimuthY, hrtf, targetElevation, targetAzimuth, 'linear');
end