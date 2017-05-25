//
//  AddHabitCore.cpp
//  HabitManager
//
//  Created by Tyler Baker on 23/05/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//



#include "AddHabit.h"

using namespace std;


class AddHabit
{
private:
    bool timePickerVisible;
    bool intervalPickerVisible;
    bool firstRun;
    int mode;
    int selectedInterval;
    int selectedIntervalHours;
    int selectedIntervalMinutes;
    char alertOptionsMode0Text[20];
    char alertOptionsMode1Text[20];
    static int daysSelected [7];
    char uuid[10];
    
public:
    AddHabit();
    int checkTest();
};

