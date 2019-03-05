function target_location = TargetDetector(config, stereo_images)
%
% target_location = TargetDetector(config, stereo_images)
%
% Get target location from image input.
%
% INPUTS:
%   config - Husky config.
%   stereo_images - raw image input from the cameras.
%
% OUTPUTS:
%   target_location - location of the target as a range and bearing (rad)
%   relative to the robot.


% Undistort the images.
undistorted_stereo_images = UndistortStereoImage(stereo_images, ...
                                                 config.camera_model);

% Find the target in each image.
%left_brightness = sqrt(sum(left_img, 3));
%normalised_left_img_red = rescale(left_img(:,:,1)./left_brightness, 0, 255);
baseline = undistorted_stereo_images.baseline;
focal_length = undistorted_stereo_images.left.fx;
left_coord = FindTarget(undistorted_stereo_images.left.rgb);
right_coord = FindTarget(undistorted_stereo_images.right.rgb);

% Do some geometry.
depth_estimate = focal_length * baseline / (left_coord(1) ...
                                            - right_coord(1));

range_est_left = sqrt(depth_estimate^2 + left_coord(1)^2);
range_est_right = sqrt(depth_estimate^2 + right_coord(1)^2);
range_estimate = (range_est_left + range_est_right) / 2;
                                        
angle_est_left = atan(left_coord(1)/depth_estimate);
angle_est_right = atan(right_coord(1)/depth_estimate);
angle_estimate = (angle_est_left + angle_est_right) / 2;


target_location = [range_estimate, angle_estimate];