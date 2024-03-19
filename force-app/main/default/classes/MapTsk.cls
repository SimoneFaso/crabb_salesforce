public with sharing class MapTsk
{
    Public List<String> LastYear {get; set;}
    Public List<String> TipoAtt {get; set;}
    
    Public Map<String, Map<String, Integer>> mMesiAtt {get; set;}
    Private Map<Id,Task> mTsk{get; set;}
    private static Map<Integer, String> monthsMap = new Map<Integer, String>{
        1 => 'Gen',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'Mag',
        6 => 'Giu',
        7 => 'Lug',
        8 => 'Ago',
        9 => 'Set',
        10 => 'Ott',
        11 => 'Nov',
        12 => 'Dic'};
    
    public void CreateMapTsk (List<Task> tsk)
    {
        mMesiAtt = new Map<String, Map<String, Integer>>();
        LastYear = new List<String>(Last12Month());
        Map<String, Integer> mNumAtt = new Map<String, Integer>();
        TipoAtt = new List<String>{
            'Lettera di sollecito', //Sollecito
            'Phone Collection', //Phone
            'Raccomandata', //Invio A/R
            'Ordine di sospensione servizio', //Sospensione
            'Affido ADR',
            'Affido a Legale', //Affido Legale
            'Diffida',
            'Decreto',
            'Esecuzione'};
        Set<String> sTipoAtt = new Set<String>{
            'Lettera di sollecito',
            'Phone Collection',
            'Raccomandata',
            'Ordine di sospensione servizio',
            'Affido ADR',
            'Affido a Legale',
            'Diffida',
            'Decreto',
            'Esecuzione'};
        
        for(Integer x = 11; x >= 0; x--)
        {
            mNumAtt.put(LastYear[x],0);
            for(String s: TipoAtt)
            {
                mMesiAtt.put(s,mNumAtt);
            }
        }
        
        for(Task t: tsk)
        {
            String sTipo = t.ActivityExtended__r.Tipo__c;
            Datetime dCreate = t.CreatedDate;
            String sMese = monthsMap.get(dCreate.month()) + ' ' +  string.ValueOf(dCreate.year());

            if(sTipoAtt.contains(sTipo))
            {
                if(mMesiAtt.containsKey(sTipo))
                {
                    Map<String,Integer> mTemp = new map<String,Integer>(mMesiAtt.get(sTipo));
                    if(mTemp.containsKey(sMese))
                    {
                        Integer x = mTemp.get(sMese);
                        mTemp.put(sMese,x+1);
                        mMesiAtt.put(sTipo,mTemp);
                        System.debug('1: ' + sTipo + ' ' + sMese + ' ' + string.ValueOf(x));
                    }
                    else
                    {
                        mTemp.put(sMese,1);
                        mMesiAtt.put(sTipo,mTemp);
                        System.debug('2: ' + sTipo + ' ' + sMese);
                    }
                }
                else
                {
                    Map<String,Integer> mTemp = new map<String,Integer>();
                    mTemp.put(sMese,1);
                    mMesiAtt.put(sTipo,mNumAtt);
                    System.debug('3: ' + sTipo + ' ' + sMese);
                }
            }
        }      
    }
    
    Private List<String> Last12Month()
    {
        List<String> Last12MonthDesc = new List<String>();
        List<String> Last12MonthAsc = new List<String>();
        for(Integer i=11; i>=0; i--)
        {
            String sMeseAnno = '';
            Date d = System.today();
            Integer iMese = d.month();
            Integer iAnno = d.Year();
            if(iMese > i)
            {
                sMeseAnno = monthsMap.get(iMese - i) + ' ' + string.ValueOf(iAnno);
                Last12MonthDesc.add(sMeseAnno);
            }
            else
            {
                sMeseAnno = monthsMap.get(12 + (iMese - i)) + ' ' + string.ValueOf(iAnno - 1);
                Last12MonthDesc.add(sMeseAnno);
            }
        }
        
        return Last12MonthDesc;
    }

}