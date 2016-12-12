#include <iostream>
#include <boost/bind.hpp>
#include <gazebo/gazebo.hh>
#include <gazebo/physics/physics.hh>
#include <gazebo/common/common.hh>
#include <stdio.h>
#include <gazebo_plugins/gazebo_ros_utils.h>
#include <boost/thread.hpp>
#include "std_msgs/String.h"

#include <gazebo/common/Plugin.hh>
#include <ros/ros.h>
#include <std_msgs/Float64.h>

namespace gazebo
{   
  class SetJoints : public ModelPlugin
  {
        public:
		ros::NodeHandle* nh;
		ros::Subscriber sub;
		ros::Subscriber sub2;
		ros::Subscriber sub3;
		ros::Subscriber sub4;
		ros::Subscriber sub5;
		ros::Subscriber sub6;

		ros::Publisher pub;
		std::string robot_namespace_;
		float tiltAngle;
                float tiltAngle2;
		float inputAngle;
		float inputAngle2;
		float inputAngle3;
		float inputAngle4;
		float inputAngle5;
		float inputAngle6;

		
		

	public:
		GazeboRosPtr gazeboROS;
// 		Pointer to the model
	//	physics::ModelPtr model;
// 		Pointer to the update event connection
	//	event::ConnectionPtr updateConnection;
		physics::JointPtr joint;
		physics::JointPtr joint2;
		physics::JointPtr joint3;
		physics::JointPtr joint4;
		physics::JointPtr joint5;
		physics::JointPtr joint6;
	public:	
		void tiltCallback(const std_msgs::Float64::ConstPtr& msg)
		{
			ROS_INFO("I heard: [%.f]", msg->data);
			inputAngle = msg->data;
		}
		void tiltCallback2(const std_msgs::Float64::ConstPtr& msg)
		{
			ROS_INFO("I heard: [%.f]", msg->data);
			inputAngle2 = msg->data;
		}
		void tiltCallback3(const std_msgs::Float64::ConstPtr& msg)
		{
			ROS_INFO("I heard: [%.f]", msg->data);
			inputAngle3 = msg->data;
		}
		void tiltCallback4(const std_msgs::Float64::ConstPtr& msg)
		{
			ROS_INFO("I heard: [%.f]", msg->data);
			inputAngle4 = msg->data;
		}
		void tiltCallback5(const std_msgs::Float64::ConstPtr& msg)
		{
			ROS_INFO("I heard: [%.f]", msg->data);
			inputAngle5 = msg->data;
		}
		void tiltCallback6(const std_msgs::Float64::ConstPtr& msg)
		{
			ROS_INFO("I heard: [%.f]", msg->data);
			inputAngle6 = msg->data;
		}
		



        public: void Load(physics::ModelPtr _parent, sdf::ElementPtr _sdf/*_sdf*/) 
               {
			if (!ros::isInitialized())
			{
				ROS_FATAL_STREAM("A ROS node for Gazebo has not been initialized, unable to load plugin. "
				  << "Load the Gazebo system plugin 'libgazebo_ros_api_plugin.so' in the gazebo_ros package)");
				int argc = 0;
				char** argv = NULL;
				ros::init(argc,argv,"SetJoints",ros::init_options::NoSigintHandler|ros::init_options::AnonymousName);
			}
      			 // Store the pointer to the model
     			this->model = _parent;
	//		gazeboROS = GazeboRosPtr ( new GazeboRos ( _parent, _sdf, "SetJoints" ) );
			joint = this->model->GetJoint("base_hinge");
			joint2 = this->model->GetJoint("First_joint_hinge");
			joint3 = this->model->GetJoint("Second_joint_hinge");
			joint4 = this->model->GetJoint("Third_joint_hinge");
			joint5 = this->model->GetJoint("right_finger_hinge");
			joint6 = this->model->GetJoint("left_finger_hinge");
                        joint->SetMaxForce ( 0, 20 );
                        joint2->SetMaxForce ( 0, 50);
                        joint3->SetMaxForce ( 0, 20 );
                        joint4->SetMaxForce ( 0, 20 );
                        joint5->SetMaxForce ( 0, 20 );
                        joint6->SetMaxForce ( 0, 20 );
      	//		this->j2_controller = new physics::JointController(model);

      			// Listen to the update event. This event is broadcast every
      			// simulation iteration.
      			this->updateConnection = event::Events::ConnectWorldUpdateBegin(boost::bind(&SetJoints::OnUpdate, this, _1));

                        this->robot_namespace_ = "";
                        nh = new ros::NodeHandle(this->robot_namespace_);
			sub = nh->subscribe("/tilt_angle", 10, &SetJoints::tiltCallback, this);
			sub2 = nh->subscribe("/tilt_angle2", 10, &SetJoints::tiltCallback2, this);
			sub3 = nh->subscribe("/tilt_angle3", 10, &SetJoints::tiltCallback3, this);
			sub4 = nh->subscribe("/tilt_angle4", 10, &SetJoints::tiltCallback4, this);
			sub5 = nh->subscribe("/tilt_angle5", 10, &SetJoints::tiltCallback5, this);
			sub6 = nh->subscribe("/tilt_angle6", 10, &SetJoints::tiltCallback6, this);

			pub = nh->advertise<std_msgs::Float64>("/out_tilt_angle", 100);
			inputAngle = 0;
			tiltAngle = 0;
    		}

  		  // Called by the world update start event
    	public: void OnUpdate(const common::UpdateInfo & /*_info*/)
    		{
  			/*    // Apply a small linear velocity to the model.
     			 //this->model->SetLinearVel(math::Vector3(.03, 0, 0));

      			
   			//   std::string j2name("base_hinge");  
      			j2_controller->SetJointPosition(this->model->GetJoint("First_joint_hinge"), angle);
      			j2_controller->SetJointPosition(this->model->GetJoint("Second_joint_hinge"), angle2);
      			j2_controller->SetJointPosition(this->model->GetJoint("Third_joint_hinge"), angle3);*/
			double angle(45.0);
      			double angle2(-45.0);
      			double angle3(0.0);
		//	tiltAngle = 20;
                        std_msgs::Float64 curtiltMsg;
			tiltAngle = joint->GetAngle(0).Degree();
			tiltAngle2 = joint2->GetAngle(0).Degree();
			if (tiltAngle < inputAngle-0.5)
			{		
				joint->SetVelocity(0, 0.25);
			}
			else if (tiltAngle > inputAngle+0.5)
			{
				joint->SetVelocity(0, -0.25);
			}
			else
			{
				joint->SetVelocity(0, 0);
			}
                        tiltAngle2 = joint2->GetAngle(0).Degree();
			if (tiltAngle2 < inputAngle2-0.5)
			{		
				joint2->SetVelocity(0, 0.25);
			}
			else if (tiltAngle2 > inputAngle2+0.5)
			{
				joint2->SetVelocity(0, -0.25);
			}
			else
			{
				joint2->SetVelocity(0, 0);
			}
			std::cout << joint2->GetAngle(0).Degree() << std::endl;

		//	std_msgs::Float64 curtiltMsg;
// 			curtiltMsg.data = tiltAngle * 180 / PI;
			curtiltMsg.data = 20;
			pub.publish(curtiltMsg);
			ros::spinOnce();

    }

    // Pointer to the model
    private: physics::ModelPtr model;

    // Pointer to the update event connection
    private: event::ConnectionPtr updateConnection;

    private: physics::JointController * j2_controller;

  };

  // Register this plugin with the simulator
  GZ_REGISTER_MODEL_PLUGIN(SetJoints)
}
