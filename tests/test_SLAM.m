startup_cdt

clear mexmoos;

husky_id = 4; % Modify for your Husky

% Get the channel names and sensor IDs for this Husky
config = GetHuskyConfig(husky_id);

client = ['ExampleCdtClient' num2str(int32(rand*1e7))];
mexmoos('init', 'SERVERHOST', config.host, 'MOOSNAME', client);
mexmoos('REGISTER', config.laser_channel, 0.0);
mexmoos('REGISTER', config.stereo_channel, 0.0);
mexmoos('REGISTER', config.wheel_odometry_channel, 0.0);
mexmoos('init', 'SERVERHOST', config.host, 'MOOSNAME', client, 'SERVERPORT','9000');
pause(4.0); % give mexmoos a chance to connect (important!)

% First tell it not to move at all
SendSpeedCommand(0, 0, config.control_channel)
found_target_flag = 0;
counter = 1;
state_vector = [0; 0; 0];
state_cov = ones(3,3);
accum_time = 1e5;
req_new_carrot = 1;
plan_flag = 1;
target_location = Local2Global([0;0;0],[3;0;0]);
while true
    % Fetch latest messages from mex-moos
    pause(0.25)
    mailbox = mexmoos('FETCH');
    scan = GetLaserScans(mailbox, config.laser_channel, true);
    stereo_images = GetStereoImages(mailbox, config.stereo_channel, true);
    wheel_odometry_all = GetWheelOdometry(mailbox, ...
        config.wheel_odometry_channel, ...
        false);
    wheel_odometry = ComposeWheelOdom(wheel_odometry_all);
    [ranges, angles] = DetectPoles(scan)

    wheel_odometry'
    %   SLAM
    [state_vector, state_cov] = SLAMUpdate(wheel_odometry, ...
        [ranges;angles], ...
        state_vector, state_cov);
    %     plot own position
    clf
    scatter(state_vector(1),state_vector(2),[],'g')
    hold on
    %       plot map showing detected poles in a 2d map
    
    for i = 4:2:size(state_vector)
        scatter(state_vector(i),state_vector(i+1),[],'r');
        hold on
    end
    
    axis([-1 7 -3.5 3.5])
    
    state_vector(1:3)'
end

