//
//  CLibrary.cpp
//  HabitManager
//
//  A C++ Library of data fields and their respective mutator
//  and accessor methods.
//
//  Created by Tyler Baker on 5/27/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//

#include "CLibrary.hpp"
#include <string>
#include <stdio.h>
#include <vector>




/*data field declarations*/

int mode = 0;
int timePickerVisible = 0;
int intervalPickerVisible = 0;
int firstRun = 1;
int tabPressed = 0;
int selectedInterval = 60;
int selectedIntervalHours = 0;
int selectedIntervalMinutes = 0;
char alertOptionsMode0Text [1024] = "None";
char alertOptionsMode1Text [1024] = "Every 1 minute";




/* mutator method for timePickerVisible data field
 @param update - the new value to apply to timePickerVisible boolean.
 */
void setTimePickerVisible(int update){
    timePickerVisible = update;
}
/* accessor method for timePickerVisible data field
 @return - an int boolean of whether the daily time wheel is visible ot the user.
 */
int getTimePickerVisible(void){
    return timePickerVisible;
}

/* mutator method for intervalPickerVisble data field
 @param update - the new value to apply to intervalPickerVisible boolean.
 */
void setIntervalPickerVisible(int update){
    intervalPickerVisible = update;
}
/* accessor method for intervalPickerVisble data field
 @return - an int boolean of whether the reoccuring time wheel is visible ot the user.
 */
int getIntervalPickerVisible(void){
    return intervalPickerVisible;
}

/* mutator method for firstRun data field
 @param update - the new value to apply to toggle the firstRun of the app.
 */
void setFirstRun(int update){
    firstRun = update;
}
/* accessor method for firstRun data field
 @return - an int boolean indicator whether this is the first run of the app.
 */
int getFirstRun(void){
    return firstRun;
}

/* mutator method for mode data field
 @param update - the new value to toggle between Daily and Reoccurring mode.
 */
void setMode(int update){
    mode = update;
}
/* accessor method for mode data field
 @return - the current mode the app is in (Daily/Reoccurring).
 */
int getMode(void){
    return mode;
}

/* mutator method for selectedInterval data field
 @param update - the new value to set the time interval picked by user.
 */
void setSelectedInterval(int update){
    selectedInterval = update;
}
/* accessor method for selectedInterval data field
 @return - the total value of the selectedInterval.
 */
int getSelectedInterval(void){
    return selectedInterval;
}

/* mutator method for selectedIntervalHours data field
 @param update - the amount of hours selected by the user for the time interval.
 */
void setSelectedIntervalHours(int update){
    selectedIntervalHours = update;
}
/* accessor method for selectedIntervalHours data field
 @return - the int amount of hours for the current habit.
 */
int getSelectedIntervalHours(void){
    return selectedIntervalHours;
}

/* mutator method for selectedIntervalMinutes data field
 @param update - the amount of minutes selected by the user for the time interval.
 */
void setSelectedIntervalMinutes(int update){
    selectedIntervalMinutes = update;
}
/* accessor method for selectedIntervalMinutes data field
 @return - the int value of the amount of minutes selected by the user.
 */
int getSelectedIntervalMinutes(void){
    return selectedIntervalMinutes;
}

/* mutator method for alertOptionsMode0Text data field
 @param update - the char array of the alert message based on the user input of time/habit name.
 */
void setAlertOptionsMode0Text(char update[]){
    strcpy(alertOptionsMode0Text, update);
}
/* accessor method for alertOptionsMode0Text data field
 @return - the char array of the daily habit banner.
 */
char * getAlertOptionsMode0Text(void){
    return alertOptionsMode0Text;
}

/* mutator method for alertOptionsMode1Text data field
 @param update - the char array of the reoccuring notification name based on the user input of time.
 */
void setAlertOptionsMode1Text(char update[]){
    strcpy(alertOptionsMode1Text, update);
}
/* accessor method for alertOptionsMode1Text data field
 @return - the char array of the reoccuring banner.
 */
char * getAlertOptionsMode1Text(){
    return alertOptionsMode1Text;
}

/* mutator method for tabPressed data field
 @param update - switches between the two tabs (All Habits/Today).
 */
void setTabPressed(int update){
    tabPressed = update;
}
/* accessor method for tabPressed data field
 @return - the current tab state.
 */
int getTabPressed(void){
    return tabPressed;
}


/* convert the interval (in seconds) to readable text */
char * convertIntervalAndDisplay(int hour, int minute){
    std::string message;
    char * charConversion = NULL;
    
    
    if((hour == 0 || hour == 1) && minute != 0 && minute != 1){
        message = "Every " + std::to_string(hour) + " hour and " + std::to_string(minute) +" minutes";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }else if((hour == 0 || hour == 1) && (minute == 0 || minute == 1)){
        message = "Every " + std::to_string(hour) + " hour and " + std::to_string(minute) +" minute";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }else if(hour != 0 && hour != 1 && (minute == 0 || minute == 1)){
        message = "Every " + std::to_string(hour) + " hours and " + std::to_string(minute) +" minute";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }else{
        message = "Every " + std::to_string(hour) + " hours and " + std::to_string(minute) +" minutes";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }
    
    if(hour == 0 && minute != 0 && minute != 1){
        message = "Every " + std::to_string(minute) +" minutes";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }else if(minute == 0 && hour != 0 && hour != 1){
        message = "Every " + std::to_string(hour) + " hours";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }else if(hour == 0 && (minute == 0 || minute == 1)){
        message = "Every " + std::to_string(minute) +" minute";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }else if(minute == 0 && (hour == 0 || hour == 1)){
        message = "Every " + std::to_string(hour) + " hour";
        charConversion = new char[message.length()+1];
        strcpy(charConversion, message.c_str());
        setAlertOptionsMode1Text(charConversion);
        delete [] charConversion;
    }
    return getAlertOptionsMode1Text();
}
