//
//  CLibrary.hpp
//  HabitManager
//
//  Created by Tyler Baker on 5/27/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//



/* declares the following methods to be compiled in C. This is to bridge
 the C++ library to Swift, using the built in Bridging-Header support*/

extern "C" {
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
    char * getAlertOptionsMode1Text();
    
    void setTabPressed(int update);
    int getTabPressed(void);
    
    void setMessage(void);
}
