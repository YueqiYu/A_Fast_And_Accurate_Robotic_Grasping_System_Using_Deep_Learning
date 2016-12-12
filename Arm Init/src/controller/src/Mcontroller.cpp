#include "ros/ros.h"
#include "std_msgs/String.h"
#include "std_msgs/Float64.h"
#include <sstream>
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <dynamixel_msgs/JointState.h>
#include <iostream> 
#include <time.h>  
 
using namespace std; 
 double position3;
void Sleep(float s) 
{ 
    int sec = int(s*1000000); 
    usleep(sec); 
}



void callback(const dynamixel_msgs::JointState& str)
   {
  // ROS_INFO("I heard: [%.2f]", str.current_pos);
 //    ROS_INFO("I'm");
      position3=str.current_pos;
 }
/**
 * This tutorial demonstrates simple sending of messages over the ROS system.
 */
int main(int argc, char **argv)
{
  ros::init(argc, argv, "Mcontroller");

  int i=1;
  ros::NodeHandle n;

  ros::Publisher Motor1_pub = n.advertise<std_msgs::Float64>("/joint1_controller/command", 1000);
  ros::Publisher Motor2_pub = n.advertise<std_msgs::Float64>("/joint2_controller/command", 1000);
  ros::Publisher Motor3_pub = n.advertise<std_msgs::Float64>("/joint3_controller/command", 1000);
  ros::Publisher Motor4_pub = n.advertise<std_msgs::Float64>("/joint4_controller/command", 1000);
  ros::Publisher Motor5_pub = n.advertise<std_msgs::Float64>("/joint5_controller/command", 1000);
  ros::Publisher Motor6_pub = n.advertise<std_msgs::Float64>("/joint6_controller/command", 1000);
  ros::Publisher Motor7_pub = n.advertise<std_msgs::Float64>("/joint7_controller/command", 1000);
   ros::Subscriber sub = n.subscribe("/joint1_controller/state", 1000, callback);
  ros::Rate loop_rate(0.1);

  /**
   * A count of how many messages we have sent. This is used to create
   * a unique string for each message.
   */
  std_msgs::Float64 ss_initial_position;
   std_msgs::Float64 ss_initial_position2;
  int count = 0;
  double ss=0.5;
  double ss2;
   double ss3=1.5;
  double initials=0;
  ss_initial_position.data=initials;
  ss_initial_position2.data=initials+1.3;
   /*initialize*/
    
    
     Motor4_pub.publish(ss_initial_position);
    Motor5_pub.publish(ss_initial_position);
     //
      Sleep(3);
      Motor2_pub.publish(ss_initial_position);
    Motor3_pub.publish(ss_initial_position);
       Sleep(3);
     Motor4_pub.publish(ss_initial_position);
     Motor5_pub.publish(ss_initial_position);
    Motor6_pub.publish(ss_initial_position);
      ss_initial_position.data=initials+0.5;
    Motor7_pub.publish(ss_initial_position);
      Sleep(3);
     Motor1_pub.publish(ss_initial_position2);
       Sleep(3);
       ROS_INFO("initial  Current [%.3f]",position3);
 //  sub = n.subscribe("/Joint3_controller1/state", 1, callback);
  while (ros::ok())
  {
    /**
     * This is a message object. You stuff it with data, and then publish it.
     */
    std_msgs::Float64 ss_msg;
    std_msgs::Float64 ss2_msg;
    std_msgs::Float64 Joint1_msg;
 //   if (count%2==0)
      ss=0.5;
  //   ss=-ss;
     ss2=-0.5;
       ss3=1.5;
  //  ss << "hello world " << count;
  //  msg.data = ss.str();
    ss_msg.data=ss;
    ss2_msg.data=ss2;
    Joint1_msg.data=ss3;

    
    /**
     * The publish() function is how you send messages. The parameter
     * is the message object. The type of this object must agree with the type
     * given as a template parameter to the advertise<>() call, as was done
     * in the constructor above.
     */
      Sleep(4);
     Motor1_pub.publish(Joint1_msg);
      Sleep(3);
     ros::spinOnce();
if(position3>1.4&&position3<1.6)
{
      Motor2_pub.publish(ss_msg);
      Motor3_pub.publish(ss2_msg);
      Motor4_pub.publish(ss_msg);
      Motor5_pub.publish(ss2_msg);
       ss2=0.3;
       ss2_msg.data=ss2;
       Sleep(3);
      Motor7_pub.publish(ss2_msg);
}
ROS_INFO("first posture Current [%.3f]",position3);
      Sleep(3);
       Joint1_msg.data=-ss3;
    Motor1_pub.publish(Joint1_msg);
         Sleep(4);
      ros::spinOnce();
if(position3>-1.6&&position3<-1.4)
{
        ss=-0.8;
        ss2=0.8;
        ss_msg.data=ss;
         ss2_msg.data=ss2;
       Motor2_pub.publish(ss_msg);
      Motor3_pub.publish(ss2_msg);
        ss_msg.data=ss+0.3;
         ss2_msg.data=ss2-0.3;
      Motor4_pub.publish(ss_msg);
      Motor5_pub.publish(ss2_msg);
       ss2=1.1;
       ss2_msg.data=ss2;
      Sleep(3);
      Motor7_pub.publish(ss2_msg);
       Sleep(3);
         ss=0.3;
        ss2=-0.3;
        ss_msg.data=ss;
         ss2_msg.data=ss2;
      Motor2_pub.publish(ss_msg);
      Motor3_pub.publish(ss2_msg);
      Motor4_pub.publish(ss_msg);
      Motor5_pub.publish(ss2_msg);
}
     
   // ros::Duration(5).sleep(); // sleep for half a second
  //  Motor3_pub.publish(ss_msg);
   ROS_INFO(" second  Current [%.3f]",position3);
    ROS_INFO("J1 is :%.2f", ss);
    ROS_INFO("J2 is :%.2f", ss2);
    ros::spinOnce();

    loop_rate.sleep();
    ++count;
  }


  return 0;
}
