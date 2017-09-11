//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//  Created by Tyler Baker on 5/27/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//


/* Declarations of mutator and accessor methods accessible to Swift code. */



void setTimePickerVisible(int update);
int getTimePickerVisible(void);

void setIntervalPickerVisible(int update);
int getIntervalPickerVisible(void);

void setFirstRun(int update);
int getFirstRun(void);

void setMode(int update);
int getMode(void);

void setSelectedInterval(int update);
int getSelectedInterval(void);

void setSelectedIntervalHours(int update);
int getSelectedIntervalHours(void);

void setSelectedIntervalMinutes(int update);
int getSelectedIntervalMinutes(void);

void setAlertOptionsMode0Text(char update[]);
char * getAlertOptionsMode0Text(void);

void setAlertOptionsMode1Text(char update[]);
char * getAlertOptionsMode1Text(void);

void setTabPressed(int update);
int getTabPressed(void);

void setConvertedTime(void);
char * convertIntervalAndDisplay(int hour, int minute);

void setMessage(void);
