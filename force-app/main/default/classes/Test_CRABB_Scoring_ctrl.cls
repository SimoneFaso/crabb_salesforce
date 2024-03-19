@IsTest
private class Test_CRABB_Scoring_ctrl {
    @IsTest
    static void testScoring() {
        
        //Create tests
        List<Account> accountList = new list<Account>();
        List<string> recordIdList = new list<string>();
        Account a1 = new Account();
        a1.Name = 'Test1';
        accountList.add(a1);
        Account a2 = new Account();
        a2.Name = 'Test2';
        accountList.add(a2);
        insert accountList;
        recordIdList.add(a1.Id);
        recordIdList.add(a2.Id);

        //test method elaborateScoring
        CRABB_Scoring_ctrl.elaborateScoring(recordIdList,'Account');

        //test method getAccountInfo
        CRABB_Scoring_ctrl.getAccountInfo(accountList[0].id);
    }



    @IsTest
    static void CheckCondition_lessThan(){
        boolean bool;
        string condition='<';
        date a,b; a=system.today(); b=a.adddays(1);
        datetime at,bt; at=system.now(); bt=at.adddays(1);
        Decimal ad,bd; ad=1.45; bd=1.68;
        Double adD,bdD; adD=1.45; bdD=1.68;
        Integer adI,bdI; adI=1; bdI=68;
        String sa='1',sb='2';

        test.startTest();
       /* bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(at,bt,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ad,bd,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(sa,sb,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(adD,bdD,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(adI,bdI,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
        bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
        bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
        bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(adI,bdI,condition, 'decimal');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_lessOrEqual(){
        boolean bool;
        string condition='<=';
        date a,b; a=system.today(); b=a.adddays(1);
        datetime at,bt; at=system.now(); bt=at.adddays(1);
        Decimal ad,bd; ad=1.45; bd=1.68;
        Double adD,bdD; adD=1.45; bdD=1.68;
        integer ai,bi; ai=1; bi=2;
        String sa='1',sb='2';

        test.startTest();
        /*
        bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(at,bt,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ad,bd,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(sa,sb,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(adD,bdD,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ai,bi,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
        bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
        bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
        bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(ai,bi,condition, 'decimal');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_different(){
        boolean bool;
        string condition='!=';
        date a,b; a=system.today(); b=a.adddays(1);
        datetime at,bt; at=system.now(); bt=at.adddays(1);
        Decimal ad,bd; ad=1.45; bd=ad;
        Double adD,bdD; adD=1.45; bdD=1.68;
        Integer adI,bdI; adI=1; bdI=68;
        string astr='xx',bstr='xx';
        boolean abool=true,bbool=false;
        String sa='1',sb='2';

        test.startTest();
        /*bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(at,bt,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ad,bd,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(astr,bstr,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(abool,bbool,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(sa,sb,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(adD,bdD,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(adI,bdI,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
        bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
        bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(astr,bstr,condition, 'string');
        bool= Utils.checkConditionFieldValue(abool,bbool,condition, 'boolean');
        bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
        bool= Utils.checkConditionFieldValue(adD,bdD,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(adI,bdI,condition, 'decimal');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_Equal(){
        boolean bool;
        string condition='==';
        date a,b; a=system.today(); b=a.adddays(1);
        datetime at,bt; at=system.now(); bt=at.adddays(1);
        Decimal ad,bd; ad=1.45; bd=ad;
        integer ai,bi; ai=1; bi=ai;
        string astr,bstr; astr='xx'; bstr=astr;
        boolean abool=true,bbool=false;
        String sa='1',sb='2';

        test.startTest();
        /*bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(at,bt,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ad,bd,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(astr,bstr,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(abool,bbool,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(sa,sb,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
        bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
        bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(astr,bstr,condition, 'string');
        bool= Utils.checkConditionFieldValue(abool,bbool,condition, 'boolean');
        bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_greather(){
        boolean bool;
        string condition='>';
        date a,b; a=system.today(); b=a.adddays(1);
        datetime at,bt; at=system.now(); bt=at.adddays(1);
        Decimal ad,bd; ad=1.45; bd=ad;
        integer ai,bi; ai=1; bi=ai;
        String sa='1',sb='2';

        test.startTest();
        /*
        bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(at,bt,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ad,bd,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(sa,sb,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
        bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
        bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_greatherEqual(){
        boolean bool;
        string condition='>=';
        date a,b; a=system.today(); b=a.adddays(1);
        datetime at,bt; at=system.now(); bt=at.adddays(1);
        Decimal ad,bd; ad=1.45; bd=ad;
        integer ai,bi; ai=1; bi=ai;
        String sa='1',sb='2';

        test.startTest();
        /*bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(at,bt,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(ad,bd,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(sa,sb,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'date');
        bool= Utils.checkConditionFieldValue(at,bt,condition, 'datetime');
        bool= Utils.checkConditionFieldValue(ad,bd,condition, 'decimal');
        bool= Utils.checkConditionFieldValue(sa,sb,condition, 'string');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_Includes(){
        boolean bool;
        string condition='includes';
        string a,b;
        a='a;b;c';
        b='c';

        test.startTest();
        //bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= Utils.checkConditionFieldValue(a,b,condition, 'string');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_IsIncluded(){
        boolean bool;
        string condition='IsIncluded';
        string a,b;
        a='a;b;c';
        b='c;b';

        test.startTest();
        //bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= Utils.checkConditionFieldValue(a,b,condition, 'string');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_escludes(){
        boolean bool;
        string condition='escludes';
        string a,b;
        a='a;b;c';
        b='d';
        string c,d;
        c='a;b;c';
        d='c';
        test.startTest();
        /*bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= CRABB_Scoring_ctrl.checkConditionType(c,d,condition);*/
        bool= Utils.checkConditionFieldValue(a,b,condition, 'string');
        bool= Utils.checkConditionFieldValue(c,d,condition, 'string');
        test.stopTest();
    }

    @IsTest
    static void CheckCondition_NoPresentCondition(){
        /*questo testa uno scenario in cui non gli viene fornita una condizione configurata */
        boolean bool;
        string condition='xxxxxx@@@@@';
        string a,b;
        a='a;b;c';
        b='d';
        test.startTest();
        //bool= CRABB_Scoring_ctrl.checkConditionType(a,b,condition);
        bool= Utils.checkConditionFieldValue(a,b,condition, 'string');
        test.stopTest();
    }
}