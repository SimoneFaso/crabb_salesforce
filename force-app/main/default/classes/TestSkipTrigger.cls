/* ---------------------------------------------------------------------------------------------------------------------
Name:            TestSkipTrigger.cls
Description:     Test Class for Code Coverage of skipTrigger.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
03-Mar-2020  0.1      Alessandro Smiriglia            First Version
----------------------------------------------------------------------------------------------------------------------*/

@IsTest
public class TestSkipTrigger {
    @IsTest
    static void skipTest(){
        skipTrigger.skip('test');
    }
}