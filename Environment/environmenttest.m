%% Environment Test

        % GripperBase0;LeftHand;RightHand;robot;robot2;                      % Tag Name for 2 Robot Arms and Gripper
        % Can;Can_vert;Can_transf;Cap;Cap_vert;Cap_transf;                   % Tag Name for Can And Cap
        % qDest = [];                                                        % Joints Stage at destination
        % qMatrix = [];matrix_signal;                                        % Matrix of Joints Stages - matrix_signal: 0 (Cant Found) - 1 (Found)
        % collision_signal;                                                  % Signal for collision detection: 0 (Not Collided) - 1 (Collided)
        % gripper_signal;                                                    % Signal for gripper stage: 0 (Close) - 1 (Open)
        % object_pos;object_index;                                           % Position of each objects and current object index
        % target_pos;destination_pos;target_ori                              % Position and Orientation of the current target
        % can_attached;                                                      % Indicate the status of the current object which is grab by the Gripper or not (True - False)
        % stop_signal = false;                                               % E-Stop Signal: true(Stop)-false(Run)
        % handles;                                                           % Information Storage for the GUI
        % cur_state;cur_step;                                                % Indicate the current stage and step
        % smart_feature;    
        % Barrier;Barrier_vert;Barrier_transf

close all

%% Walls %%

surf([-6,-6;6,6],[-4,4;-4,4],[0,0;0,0],'CData',imread('Floor.jpg'),'FaceColor','texturemap','FaceLighting','none');
hold on
surf([6,6;6,6],[-4,4;-4,4],[0,0;3,3],'CData',imread('Wall.jpg'),'FaceColor','texturemap');
hold on
surf([-6,6;-6,6],[4,4;4,4],[0,0;3,3],'CData',imread('Wall.jpg'),'FaceColor','texturemap');
hold on


Table = PlaceObject('counter.ply');
Table_vertices = get(Table,'Vertices');
transformedVerticesT = [Table_vertices,ones(size(Table_vertices,1),1)]*troty(-pi/2)'*transl(0,0,0)';
set(Table,'Vertices',transformedVerticesT(:,1:3));
axis equal
hold on
axis equal

BarrierLocations = [
    0,-0.5,1.5935
    0,-0.249625,1.5935
    0,0.00075,1.5935
    0,0.251125,1.5935
    -2.003,-0.5,1.5935
    -2.003,-0.249625,1.5935
    -2.003,0.00075,1.5935
    -2.003,0.251125,1.5935
];

BarrierLocations2 = [
    0,-0.5,1.5935
    0,-0.249625,1.5935
    0,0.00075,1.5935
    0,0.251125,1.5935
    0,0.5015,1.5935
    0,0.751875,1.5935
    0,1.00225,1.5935
    0,1.252625,1.5935
    -2.003,-0.5,1.5935
    -2.003,-0.249625,1.5935
    -2.003,0.00075,1.5935
    -2.003,0.251125,1.5935
    -2.003,0.5015,1.5935
    -2.003,0.751875,1.5935
    -2.003,1.00225,1.5935
    -2.003,1.252625,1.5935
];

BarrierPlacement = PlaceObject('Barrier.ply',[BarrierLocations; BarrierLocations2]);

% Define the rotation angle in radians (90 degrees)
angle = -pi/2;

% Use troty to rotate only BarrierLocations2
BarrierPlacementIndices = size(BarrierLocations, 1) + 1:size(BarrierLocations, 1) + size(BarrierLocations2, 1);
for i = BarrierPlacementIndices
    BarrierVertices = get(BarrierPlacement(i), 'Vertices');
    rotatedVertices = (transl(-1.428,-0.542114,0)*trotz(angle) * [BarrierVertices, ones(size(BarrierVertices, 1), 1)]').';
    set(BarrierPlacement(i), 'Vertices', rotatedVertices(:, 1:3));
end

Estop = PlaceObject('emergencyStopButton.ply');
Estop_vertices = get(Estop,'Vertices');
transformedVerticesE = [Estop_vertices,ones(size(Estop_vertices,1),1)]*transl(1.5,-0.4,1.5)';
set(Estop,'Vertices',transformedVerticesE(:,1:3));

% barrier_pos1 = [
% 0,-0.5,1.5935
% 0,-0.249625,1.5935
% 0,0.00075,1.5935
% 0,0.251125,1.5935
% -1.0015,-0.5,1.5935
% -1.0015,-0.249625,1.5935
% -1.0015,0.00075,1.5935
% -1.0015,0.251125,1.5935
% ];
% 
% barrier_pos2 = [
    % 0,-0.5,1.5935
    % 0,-0.249625,1.5935
    % 0,0.00075,1.5935
    % 0,0.251125,1.5935
    % ];
% 
% for i = 1: size(barrier_pos1)
%     self.Barrier{i} = PlaceObject('Barrier.ply');
%     self.Barrier_vert{i} = get(self.Barrier{i},'Vertices');
%     self.Barrier_trans{i} = [self.Barrier_vert{i},ones(size(self.Barrier_vert{i},1),1)]*transl(self.object_pos{index})';
%     set(self.Barrier{i},'Vertices',self.Barrier_transf{index}(:,1:6));
% 
% end
% 
% for i = 1: size(barrier_pos2)
%     self.Barrier{i} = PlaceObject('Barrier.ply');
%     self.Barrier_vert{i} = get(self.Barrier{i},'Vertices');
%     self.Barrier_trans{i} = [self.Barrier_vert{i},ones(size(self.Barrier_vert{i},1),1)]*trotx(pi/2)*transl(self.object_pos{index})';
%     set(self.Barrier{i},'Vertices',self.Barrier_transf{index}(:,1:6));
% end
