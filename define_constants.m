%% code to set up constants for the Simulink model
% you shouldn't modify anything in this script, with the exception of
% the plotting code at the end, which you can comment out if you wish.

%% check that the model has been set up

if groupNumber == -1
    error("Please set your group number in main.m. It shouldn't be equal to -1")
end

% the robot should start on the line. Would be quite a difficult project if
% it didn't!
if line_fn(0) ~= 0
    error("something is wrong with the line function. Should have line_fn(0) == 0")
end

% you don't really need to understand the code below

%% create look up table for sunlight pattern

% midnight to 6am - no light
night = zeros(7, 1);

% 7am to 11am (which we take as first peak) - first peak as sunlight comes
% directly through the east window, shining bightly onto the floor
morning = [0.1; 0.3; 0.5; 0.8; 0.9];

% 12pm to 3pm - sun is directly above, so slightly less light, but still
% bright
midday = [0.8; 0.7; 0.7; 0.7];

% 4pm until 6pm - sun shines through the west window
afternoon = [0.9; 0.8; 0.7];

% 7pm until midnight - the mountain gets in the way, and then it's night
evening = [0.4; 0.2; 0; 0; 0];

% combine everything...
sunlightPattern = [night; morning; midday; afternoon; evening];

% plot(sunlightPattern)
% ylabel('amount of light on floor [scaled 0-1]')
% xlabel('hour of the day')

%% calculations based on group number
% Each group will get slightly different robot parameters
hash = (groupNumber + 10)^2. * 123.456 / 789.123;

% scale mass for each student by up to 20%
lowerbound = 0.80;
upperbound = 1.20;
mass_scale = (mod(hash, upperbound - lowerbound) + lowerbound);

% adjust ratio of wheels
lowerbound = 1;
upperbound = 4;
idx = floor(mod(hash, upperbound + 1 - lowerbound) + lowerbound);
options = [0.90; 0.95; 1.05; 1.10];
wheel_ratio_scale = options(idx);

%% constants
% total mass
m_T = 1 * mass_scale;

% total inertia
I_T = 0.1;

% wheel diameters
row1 = 0.1;
row2 = row1*wheel_ratio_scale;

% inertia about y-axis
I_yy = 5.0000e-05;

% wheel base
W = 0.35;

% rolling resistance
cRoll =  0.1;

% wheel friction
b = -0.05;

% gravity
g = 9.81;

% motor parameters
K = 0.0089;
R = 2.2;
L = 2.3E-2;
Vmax = 12;

% gear ratio
N = 50;

% Line sensor position (offset from center)
sX_R = 0.05;              % inner right sensor
sY_R = -0.03;

sX_FR = 0.05;             %far right sensor
sY_FR = -0.060;

sX_L = 0.05;              %inner left sensor
sY_L = 0.03;

sX_FL = 0.05;              %far left sensor
sY_FL = 0.060;

%% the line to be followed
gridsize = 0.005;
xL = 0:gridsize:5;
yL = -2.5:gridsize:2.5;
[X, Y] = meshgrid(xL, yL);

Z = 0.5 .* sign(Y - line_fn(X) + 0.02) - 0.5 .* sign(Y - line_fn(X) - 0.02);

% right now the line goes from the left edge to the right edge. Pad the
% matrix so that we can fit the bar in:
padamount = 50;  % must be a multiple of 2
Z = pad(Z, padamount);

% add bars at the end
xend = xL(end);
yend = line_fn(xend);
bar_slope_end = -1/line_fn_deriv(xend);

Z = Z + add_bar_at(xend, line_fn(xend), xL, yL, bar_slope_end, 0.3, gridsize, padamount, size(Z));

n = round((length(xL) - (0.01 + abs(bar_slope_end)/100)/gridsize));
Z = Z + add_bar_at(xL(n), line_fn(xL(n)), xL, yL, -1/line_fn_deriv(xend), 0.3, gridsize, padamount, size(Z));

% account for padded Z, by padding xL and yL
xLp = [(xL(1) - padamount*gridsize):gridsize:xL(1)-gridsize, xL, xL(end)+gridsize:gridsize:xL(end)+padamount*gridsize];
yLp = [(yL(1) - padamount*gridsize):gridsize:yL(1)-gridsize, yL, yL(end)+gridsize:gridsize:yL(end)+padamount*gridsize];

%% if you want to plot it in 2D
% it's worth zooming in to make sure the dot density etc is good
% you can comment out these three lines, if you want
close all;
% spy(Z);
% grid on;
imshow(Z);

%% now plot in 3D
% you can uncomment the lines below if you want to see the line plotting in
% 3D

% figure;
% idxs = find(Z);
% [Xp, Yp] = meshgrid(xLp, yLp);
% Z2 = Z;  % copy Z
% Z2(idxs) = 0.0001;
% scatter3(Xp(idxs), Yp(idxs), Z2(idxs), 3);

%%
function Z = add_bar_at(xpt, ypt, xL, yL, slope, line_width, gridsize, padamount, dims)
    W = line_width/2;
    xbar = xpt + (-W:0.001:W);
    ybar = ypt + (xbar - xbar(floor(length(xbar)/2))) .* slope;
    xidxs = round((xbar - xL(1))/gridsize);
    yidxs = round((ybar - yL(1))/gridsize);
    
    Z = zeros(dims);
    for i = 1:length(xidxs)
        x = xidxs(i); y = yidxs(i);
        Z(y+padamount, x+padamount) = 1;
    end    
end

function out = pad(arr, n)
    [ncols, nrows] = size(arr);
    out = zeros(ncols + 2*n, nrows + 2*n);
    out(n+1:end-n, n+1:end-n) = arr;
end