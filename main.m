%% FOR YOUR FINAL SUBMISSION:
%%EEE3099S FINAL RACE DEMO
%% EBRAZH001 & ENRMOH001

%% A possible workflow
% RUN main.m FILE ( along with our define_constants.m)
% You will be prompted to choose a track
% Select the track you wish to run
%Run again and choose different track

%We have a stop block in the slx file found in duty cycle toggle system.Uncomment this to see time taken per track.
%From our testing for 10am:
%Track 1=27.89 @0.2 DC which is optimised
%Track 2=25.49 @0.2 DC which is optimised 
%Track 3=46.19 @0.2 DC which is optimised

%NB: Based on the forum message:
%"Setting the maximum speed based on the estimated time of day would be a great solution"
%We have optimsed the system for between 5am and 7pm 
%This means the system can misbehave slightly. However, this is easily
%fixed by dropping the initial duty cycle to 0.16 at the cost of slowing
%down the system for all times (Default duty cycle set to 0.2) but the
%system will work perfectly for all times then.

%Threshold value= (black lower + white lower)/2 =0.24

%% define constants
% set your group number:
groupNumber = 15;

n = input('Enter a Track to follow 1-3: ');                   %prompt user to input track

switch n                                                      %switch statements to select track based on user input
    case 1
        disp('Track 1 chosen')
        line_fn = @(x) cos(x) + x.^2/10 - 1;
        line_fn_deriv = @(x) -sin(x) + 2*x/10;
    case 2
        disp('Track 2 chosen')
        line_fn = @(x) sin(x);
        line_fn_deriv = @(x) cos(x);
    case 3
        disp('Track 3 chosen')
        line_fn = @(x) sin(x.^2/2 + 1) - sin(1);
        line_fn_deriv = @(x) cos(x.^2/2 + 1) .* x;
    otherwise
        disp('Invalid')
end

define_constants;

%% simulation
% next, simulate the robot. You can do that using the command below, or by
% opening simulink, clicking on the "SIMULATION" tab and clicking "Run"
out = sim("lineFollowerModel");

%% animation
% finally, if you want to see an animation of the simulation, run the line
% below. Look at the start of the anim_lineFollower.m file to get a better
% idea of how it works. Aside from just passing it the data needed to
% animate the robot, there are some useful flags you might want to use:

% set this variable to true if you want to save the animation as a video
% titled "wheeled_robot.mp4". The animation will run a bit slower, though
write_video = false;

% only animate every nth data point (eg. every 10th one) to make this run
% faster
every_nth = 30;

anim_lineFollower(out, row1, W, xLp, yLp, Z, write_video, every_nth)

%% plot the line sensor signal
figure;
plot(linspace(0, out.tout(end), length(out.lineSig)), out.lineSig);
title("Line sensor Right signal");
xlabel("Time [s]");
ylabel("Sensor value");
grid on;
shg

figure;
plot(linspace(0, out.tout(end), length(out.lineSig1)), out.lineSig1);
title("Line sensor Left signal");
xlabel("Time [s]");
ylabel("Sensor value");
grid on;
shg

figure;
plot(linspace(0, out.tout(end), length(out.lineSig2)), out.lineSig2);
title("Line sensor Far Right signal");
xlabel("Time [s]");
ylabel("Sensor value");
grid on;
shg

figure;
plot(linspace(0, out.tout(end), length(out.lineSig3)), out.lineSig3);
title("Line sensor Far Left signal");
xlabel("Time [s]");
ylabel("Sensor value");
grid on;
shg

