%% Section 1: ONLY RUN ONCE
% Initialise connection to ROS computer from MATLAB
rosinit('192.168.27.1'); % If unsure, please ask a tutor
jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');

% Run the next section after initialising connection with ROS computer
%% Goal 1: 
% Get current joint state from the real robot
jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
pause(2); % Pause to give time for a message to appear
currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position); % Note the default order of the joints is 3,2,1,4,5,6
currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];

jointStateSubscriber.LatestMessage

% Before sending commands, we create a variable with the joint names so that the joint commands are associated with a particular joint.
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};

% To send a set of joint angles to the robot, you need to create a 'client' and define a 'goal'. 
% The function rosactionclient Links to an external site. will create these variables, and allow you to use them to 
% "connect to an action server using a SimpleActionClient object and request the execution of action goals."

[client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
goal.Trajectory.JointNames = jointNames;
goal.Trajectory.Header.Seq = 1;
goal.Trajectory.Header.Stamp = rostime('Now','system');
goal.GoalTimeTolerance = rosduration(0.05);
bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.

% =========================================================================
% CHANGE THE durationSeconds TO ADJUST THE SPEED OF THE ROBOT BETWEEN GOALS
% =========================================================================
durationSeconds = 5; % This is how many seconds the movement will take

startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
startJointSend.Positions = currentJointState_123456;
startJointSend.TimeFromStart = rosduration(0);     
      
endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');

% =========================================================================
% UPDATE THE JOINT STATE GOALS (IN RADIANS)
% =========================================================================
nextJointState_123456 = [-1.5070,-0.8667,1.5357,-0.6690,2.2980,1.5708];

endJointSend.Positions = nextJointState_123456;
endJointSend.TimeFromStart = rosduration(durationSeconds);

goal.Trajectory.Points = [startJointSend; endJointSend];

% Sends the next goal to the robot, but will not move it
%% SEND COMMAND TO UR3
goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
sendGoal(client,goal);

% Sending this will make the robot move towards the goal sent to it in the
% previous section
%% Goal 2: 
% Get current joint state from the real robot
jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
pause(2); % Pause to give time for a message to appear
currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];

jointStateSubscriber.LatestMessage

% Before sending commands, we create a variable with the joint names so that the joint commands are associated with a particular joint.
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};

% To send a set of joint angles to the robot, you need to create a 'client' and define a 'goal'. 
% The function rosactionclient Links to an external site. will create these variables, and allow you to use them to 
% "connect to an action server using a SimpleActionClient object and request the execution of action goals."

[client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
goal.Trajectory.JointNames = jointNames;
goal.Trajectory.Header.Seq = 1;
goal.Trajectory.Header.Stamp = rostime('Now','system');
goal.GoalTimeTolerance = rosduration(0.05);
bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.

% =========================================================================
% CHANGE THE durationSeconds TO ADJUST THE SPEED OF THE ROBOT BETWEEN GOALS
% =========================================================================
durationSeconds = 5; % This is how many seconds the movement will take

startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
startJointSend.Positions = currentJointState_123456;
startJointSend.TimeFromStart = rosduration(0);     
      
endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');

% =========================================================================
% UPDATE THE JOINT STATE GOALS (IN RADIANS)
% =========================================================================
nextJointState_123456 = [-1.5070 -1.0778 0.8947 0.1831 2.2980 1.5708];

endJointSend.Positions = nextJointState_123456;
endJointSend.TimeFromStart = rosduration(durationSeconds);

goal.Trajectory.Points = [startJointSend; endJointSend];

% Sends the next goal to the robot, but will not move it
%% SEND COMMAND TO UR3
goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
sendGoal(client,goal);

% Sending this will make the robot move towards the goal sent to it in the
% previous section
%% Goal 3: 
% Get current joint state from the real robot
jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
pause(2); % Pause to give time for a message to appear
currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];

jointStateSubscriber.LatestMessage

% Before sending commands, we create a variable with the joint names so that the joint commands are associated with a particular joint.
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};

% To send a set of joint angles to the robot, you need to create a 'client' and define a 'goal'. 
% The function rosactionclient Links to an external site. will create these variables, and allow you to use them to 
% "connect to an action server using a SimpleActionClient object and request the execution of action goals."

[client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
goal.Trajectory.JointNames = jointNames;
goal.Trajectory.Header.Seq = 1;
goal.Trajectory.Header.Stamp = rostime('Now','system');
goal.GoalTimeTolerance = rosduration(0.05);
bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.

% =========================================================================
% CHANGE THE durationSeconds TO ADJUST THE SPEED OF THE ROBOT BETWEEN GOALS
% =========================================================================
durationSeconds = 5; % This is how many seconds the movement will take

startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
startJointSend.Positions = currentJointState_123456;
startJointSend.TimeFromStart = rosduration(0);     
      
endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');

% =========================================================================
% UPDATE THE JOINT STATE GOALS (IN RADIANS)
% =========================================================================
nextJointState_123456 = [-2.4144 -1.0910 1.0097 0.0813 2.2980 1.5708];

endJointSend.Positions = nextJointState_123456;
endJointSend.TimeFromStart = rosduration(durationSeconds);

goal.Trajectory.Points = [startJointSend; endJointSend];

% Sends the next goal to the robot, but will not move it
%% SEND COMMAND TO UR3
goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
sendGoal(client,goal);

% Sending this will make the robot move towards the goal sent to it in the
% previous section
%% Goal 4: 
% Get current joint state from the real robot
jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
pause(2); % Pause to give time for a message to appear
currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];

jointStateSubscriber.LatestMessage

% Before sending commands, we create a variable with the joint names so that the joint commands are associated with a particular joint.
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};

% To send a set of joint angles to the robot, you need to create a 'client' and define a 'goal'. 
% The function rosactionclient Links to an external site. will create these variables, and allow you to use them to 
% "connect to an action server using a SimpleActionClient object and request the execution of action goals."

[client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
goal.Trajectory.JointNames = jointNames;
goal.Trajectory.Header.Seq = 1;
goal.Trajectory.Header.Stamp = rostime('Now','system');
goal.GoalTimeTolerance = rosduration(0.05);
bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.

% =========================================================================
% CHANGE THE durationSeconds TO ADJUST THE SPEED OF THE ROBOT BETWEEN GOALS
% =========================================================================
durationSeconds = 5; % This is how many seconds the movement will take

startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
startJointSend.Positions = currentJointState_123456;
startJointSend.TimeFromStart = rosduration(0);     
      
endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');

% =========================================================================
% UPDATE THE JOINT STATE GOALS (IN RADIANS)
% =========================================================================
nextJointState_123456 = [-2.4144 -0.6953 1.5627 -0.8674 2.2980 1.5708];

endJointSend.Positions = nextJointState_123456;
endJointSend.TimeFromStart = rosduration(durationSeconds);

goal.Trajectory.Points = [startJointSend; endJointSend];

% Sends the next goal to the robot, but will not move it
%% SEND COMMAND TO UR3
goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
sendGoal(client,goal);

% Sending this will make the robot move towards the goal sent to it in the
% previous section
%% Goal 5: 
% Get current joint state from the real robot
jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
pause(2); % Pause to give time for a message to appear
currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];

jointStateSubscriber.LatestMessage

% Before sending commands, we create a variable with the joint names so that the joint commands are associated with a particular joint.
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};

% To send a set of joint angles to the robot, you need to create a 'client' and define a 'goal'. 
% The function rosactionclient Links to an external site. will create these variables, and allow you to use them to 
% "connect to an action server using a SimpleActionClient object and request the execution of action goals."

[client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
goal.Trajectory.JointNames = jointNames;
goal.Trajectory.Header.Seq = 1;
goal.Trajectory.Header.Stamp = rostime('Now','system');
goal.GoalTimeTolerance = rosduration(0.05);
bufferSeconds = 1; % This allows for the time taken to send the message. If the network is fast, this could be reduced.

% =========================================================================
% CHANGE THE durationSeconds TO ADJUST THE SPEED OF THE ROBOT BETWEEN GOALS
% =========================================================================
durationSeconds = 5; % This is how many seconds the movement will take

startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
startJointSend.Positions = currentJointState_123456;
startJointSend.TimeFromStart = rosduration(0);     
      
endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');

% =========================================================================
% UPDATE THE JOINT STATE GOALS (IN RADIANS)
% =========================================================================
nextJointState_123456 = [-2.4144 -0.6953 1.5627 -0.8674 2.2980 1.5708];

endJointSend.Positions = nextJointState_123456;
endJointSend.TimeFromStart = rosduration(durationSeconds);

goal.Trajectory.Points = [startJointSend; endJointSend];

% Sends the next goal to the robot, but will not move it
%% SEND COMMAND TO UR3
goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
sendGoal(client,goal);

% Sending this will make the robot move towards the goal sent to it in the
% previous section