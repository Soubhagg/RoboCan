%% Lab 2 Robocan Assignment
close all
clc



%% Environment Creation



%% UR3




%% Custom Robot Arm

L1=Link('d',0.129, 'a', 0.002, 'alpha', -pi/2, 'offset', 0, 'qlim',[deg2rad(-170), deg2rad(170)]);
L2=Link('d',0, 'a', 0.345-0.129, 'alpha', 0, 'offset', 0, 'qlim',[deg2rad(-170), deg2rad(50)]);
L3=Link('d',0, 'a', 0.280, 'alpha',0, 'offset', 0, 'qlim',[deg2rad(-110), deg2rad(155)]);
L4=Link('d',0.152, 'a',0, 'alpha',0, 'offset', 0, 'qlim',[deg2rad(-175), deg2rad(175)]);
L5=Link('d',0, 'a', 0.260-0.152, 'alpha',0 , 'offset', 0, 'qlim',[deg2rad(-120), deg2rad(120)]);
L6=Link('d',0.075, 'a', 0, 'alpha',0, 'offset', 0, 'qlim',[deg2rad(-350), deg2rad(350)]);

Robot = SerialLink([L1,L2,L3,L4,L5,L6], 'name', 'KUKA' );

q = zeros(1,6);       
Robot.plot(q);       
Robot.teach();
      



%% Main
