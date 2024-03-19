/* ---------------------------------------------------------------------------------------------------------------------
Name:            CRABB_ListOfFieldsCS.cls
Description:
Test class:      TestCRABB_ListOfFieldsCS.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
16-Sep-2022  0.2      R. Kurti & C. Sanna             Replaced CheckObjPermissions with cebCheckObjPermissions and added WITH SECURITY ENFORCED (Security Review)
----------------------------------------------------------------------------------------------------------------------*/
public with sharing class CRABB_ListOfFieldsCS
{
	public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

	public class PageData
	{
		@AuraEnabled
		public List<ListOfFields__c> listLOF { get; set; }
		@AuraEnabled
		public String obj { get; set; }
		@AuraEnabled
		public String title { get; set; }
		@AuraEnabled
		public String subTitle { get; set; }
		@AuraEnabled
		public Boolean show { get; set; }
		@AuraEnabled
		public List<options> listObject { get; set; }
		@AuraEnabled
		public List<String> listStrObject { get; set; }
		@AuraEnabled
		public String selectedObj { get; set; }
		@AuraEnabled
		public List<options> listFields { get; set; }
		@AuraEnabled
		public Map<String, String> listStrFields { get; set; }

		@AuraEnabled
		public Map<String, Integer> mapIdrecordOrder { get; set; }
		@AuraEnabled
		public String filePath { get; set; }

		@AuraEnabled
		public Map<String, List<ListOfFields__c>> mapTabFields { get; set; }

		@AuraEnabled
		public List<options> listTabObjOptions { get; set; }
		@AuraEnabled
		public List<options> listObjFieldOptions { get; set; }

		@AuraEnabled
		public Map<String, Boolean> mapShowTF;

		@AuraEnabled
		public Map<String, List<String>> mapObjTitleSub = new Map<String, List<String>>
		{
				'TAB' => new List<String> { system.label.Cruscotto_Pratica_Title, system.label.Cruscotto_Pratica_Description},
				'PDF' => new List<String> {label.Estratto_Conto_Title, label.Estratto_Conto_Description},
				'CSVNEW' => new List<String> {'Flussi Collector', 'Configurazione CSV'}
		};

		@AuraEnabled
		public Map<String, List<String>> mapObjAvailable = new Map<String, List<String>>
		{
				'PDF' => new List<String> {Utils.NAMESPACE + 'Pratica__c', Utils.NAMESPACE + 'Movimento__c'},
				'CSVNEW' => new List<String> {'Account', Utils.NAMESPACE + 'Pratica__c', Utils.NAMESPACE + 'Movimento__c'}
		};

		@AuraEnabled
		public Map<String, String> mapObjLabel = new Map<String, String>
		{
				Utils.NAMESPACE + 'Pratica__c' => system.label.Pratica,
				Utils.NAMESPACE + 'Movimento__c' => system.label.Transaction
		};

              
		@AuraEnabled
		public Map<String, String> mapTabRecName = new Map<String, String>
		{
				'Expired Amounts Ageing' => '',
				'Statement of Account' => 'FMov',
				'Activities' => 'FTsk',
				'Repayment Plans' => 'FPdR',
				'Service Requests' => 'FSR0',
				'Service/Product Detail' => 'FSer',
				'Assignments' => 'Whatever',
				'Voices' => '',
				'Documentation' => 'FAtt',
				'Strategy' => '',
				'Chatter' => '',
				'Funded Statement of Account' => ''
		};

		@AuraEnabled
		public Map<String, String> mapTabObj = new Map<String, String>
		{
				'Statement of Account' => Utils.NAMESPACE + 'Movimento__c',
				'Activities' => 'Task',
				'Repayment Plans' => Utils.NAMESPACE + 'Piano_di_Rientro__c',
				'Service/Product Detail' => Utils.NAMESPACE + 'Servizio__c',
				'Assignments' => Utils.NAMESPACE + 'Affidamento__c',
				'Documentation' => 'Attachment',
				'Service Requests' => Utils.NAMESPACE + 'SR__c'
		};
            
	}

	@AuraEnabled
	public static Response onComponentLoad(String obj)
	{
		try
		{

			PageData pageData = new PageData();
			pageData.obj = obj;
			pageData.show = true;
			pageData.listFields = new List<options>();
			//pageData.listFields.add(new options('','--- None ---'));
			if(obj == null || String.isBlank(obj))
			{
				pageData.show = false;
				//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No type selected (CSVNEW, TAB, PDF).'));
				return new Response(false, null, 'No type selected (CSVNEW, TAB, PDF).');

			}

			if(pageData.mapObjTitleSub.containsKey(obj))
			{
				pageData.title = (pageData.mapObjTitleSub.get(obj))[0];
				pageData.subTitle = (pageData.mapObjTitleSub.get(obj))[1];
			}
			else
			{
				//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid type. Available CSVNEW, TAB, PDF'));
				pageData.show = false;
				return new Response(false, null, 'Invalid type. Available CSVNEW, TAB, PDF');
			}
          
			String fieldString = String.escapeSingleQuotes(Utils.getSOBJECTFieldsForQuery('ListOfFields__c'));
			String nameLike = obj + '%';
			String queryString = 'SELECT ' + fieldString + ' FROM ListOfFields__c WHERE Name Like :nameLike ORDER BY Name ASC';
			pageData.listLOF = Database.query(queryString);
			pageData.listLOF.sort();
            if(pageData.listLOF != null && !pageData.listLOF.isEmpty())
			{
				for(ListOfFields__c lof : pageData.listLOF)
                {
                    if ((Schema.getGlobalDescribe().containsKey(Utils.NAMESPACE+lof.CRABB_DEV__Object__c)) && 
                       (Schema.getGlobalDescribe().get(Utils.NAMESPACE+lof.CRABB_DEV__Object__c).getDescribe().fields.getmap().containsKey(Utils.NAMESPACE+lof.CRABB_DEV__Field_Label__c))){
                           lof.CRABB_DEV__Field_Label__c = Schema.getGlobalDescribe().get(Utils.NAMESPACE+lof.CRABB_DEV__Object__c).getDescribe().fields.getmap().get(Utils.NAMESPACE+lof.CRABB_DEV__Field_Label__c).getDescribe().getLabel();
                    }

                }
            }
			pageData.mapIdrecordOrder = new Map<String, Integer>();

			if(pageData.listLOF != null && !pageData.listLOF.isEmpty())
			{
				for(ListOfFields__c lof : pageData.listLOF)
				{
					if(obj != null && obj.equalsIgnoreCase('PDF'))
					{
						pageData.mapIdrecordOrder.put(lof.Id, Integer.valueOf(lof.Name.substring(lof.Name.lastIndexOf('_') + 1)));
					}
					else if(obj != null && obj.equalsIgnoreCase('CSVNEW'))
					{
						pageData.mapIdrecordOrder.put(lof.Id, Integer.valueOf(lof.Name.substring(lof.Name.length() - 6)));
					}
				}
			}

			if(String.isNotBlank(obj) && !obj.equalsIgnoreCase('TAB'))
			{
				pageData = retrieveListObject(obj, pageData);
			}

			if(String.isNotBlank(obj) && obj.equalsIgnoreCase('TAB'))
			{
				pageData = retrieveTabFields(pageData);
				pageData = createTabObj(pageData);
			}

			String count1 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FMov%\'';
			String count2 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FTsk%\'';
			String count3 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FPdr%\'';
			String count4 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FSR0%\'';
			String count5 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FSer%\'';
			String count6 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'Whatever%\'';
			String count7 = 'SELECT COUNT() FROM ListOfFields__c WHERE Name Like \'FAtt%\'';

			Integer int1 = Database.countQuery(count1);
			Integer int2 = Database.countQuery(count2);
			Integer int3 = Database.countQuery(count3);
			Integer int4 = Database.countQuery(count4);
			Integer int5 = Database.countQuery(count5);
			Integer int6 = Database.countQuery(count6);
			Integer int7 = Database.countQuery(count7);

			pageData.mapShowTF = new Map<String, Boolean>();
			pageData.mapShowTF.put('Expired Amounts Ageing', false);
			if(int1 > 0) pageData.mapShowTF.put('Statement of Account', true);
			else pageData.mapShowTF.put('Statement of Account', false);
			if(int2 > 0) pageData.mapShowTF.put('Activities', true);
			else pageData.mapShowTF.put('Activities', false);
			if(int3 > 0) pageData.mapShowTF.put('Repayment Plans', true);
			else pageData.mapShowTF.put('Repayment Plans', false);
			if(int4 > 0) pageData.mapShowTF.put('Service Requests', true);
			else pageData.mapShowTF.put('Service Requests', false);
			if(int5 > 0) pageData.mapShowTF.put('Service/Product Detail', true);
			else pageData.mapShowTF.put('Service/Product Detail', false);
			if(int6 > 0) pageData.mapShowTF.put('Assignments', true);
			else pageData.mapShowTF.put('Assignments', false);
			pageData.mapShowTF.put('Voices', false);
			if(int7 > 0) pageData.mapShowTF.put('Documentation', true);
			else pageData.mapShowTF.put('Documentation', false);
			pageData.mapShowTF.put('Strategy', false);
			pageData.mapShowTF.put('Chatter', false);
			pageData.mapShowTF.put('Funded Statement of Account', false);

			System.debug(' pageData.mapIdrecordOrder' + JSON.serializePretty(pageData));
			return new Response(true, pageData, null);
		}
		catch(Exception e)
		{
			System.debug(' Exception' + e.getMessage() + '::' + e.getLineNumber());
			return new Response(false, null, e.getMessage());
		}
	}

	private static PageData createTabObj(PageData pageData)
	{
		pageData.listTabObjOptions = new List<options>();
		pageData.listTabObjOptions.add(new options('', '-- None --'));
		for(String str : pageData.mapTabObj.keySet())
		{
			pageData.listTabObjOptions.add(new options(str, str));
		}
		//pageData.listTabObjOptions.sort();

		pageData.listObjFieldOptions = new List<options>();
		//pageData.listObjFieldOptions.add(new options('','-- None --'));

		return pageData;
	}

	private static PageData retrieveListObject(String what, PageData pageData)
	{

		pageData.listObject = new List<options>();
		pageData.listStrObject = new List<String>();
		//pageData.listObject.add(new options('','--- None ---'));
		if(what != null && String.isNotBlank(what))
		{

			if(pageData.mapObjAvailable.containsKey(what))
			{
				for(String str : pageData.mapObjAvailable.get(what))
				{
					if(pageData.mapObjLabel.containsKey(str))
					{
						pageData.listObject.add(new options(str, pageData.mapObjLabel.get(str)));
					}
					else
					{
						pageData.listObject.add(new options(str, str));
					}
					pageData.listStrObject.add(str);
				}
				//pageData.listObject.sort();
			}
		}
		return pageData;
	}

	@AuraEnabled
	public static Response retrieveListFields(String selectedObj)
	{

		PageData pageData = new PageData();
		pageData.listFields = new List<options>();
		pageData.listStrFields = new Map<String, String>();
		Map<String, Schema.SObjectField> temp =
				Schema.getGlobalDescribe().get(selectedObj).getDescribe().fields.getMap();
		for(String ss : temp.keySet())
		{
			Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
			if(dfr.isAccessible())
			{
				pageData.listStrFields.put(dfr.getName(), dfr.getLabel());
				pageData.listFields.add(new options(dfr.getName(), dfr.getLabel()));
			}
		}

		return new Response(true, pageData, null);

	}

	@AuraEnabled
	public static Response retrieveTabObj(String selectedTO)
	{

		PageData pageData = new PageData();
		if(selectedTO != null && String.isNotBlank(selectedTO))
		{
			String objSel = pageData.mapTabObj.get(selectedTO);
			pageData.listObjFieldOptions = new List<options>();

			Map<String, Schema.SObjectField> temp = Schema.getGlobalDescribe().get(objSel).getDescribe().fields.getMap();
			for(String ss : temp.keySet())
			{
				Schema.DescribeFieldResult dfr = temp.get(ss).getDescribe();
				if(dfr.isAccessible())
				{
					pageData.listObjFieldOptions.add(new options(dfr.getName(), dfr.getLabel()));
				}
			}

			if(selectedTO.equalsIgnoreCase('Activities'))
			{
				Map<String, Schema.SObjectField> tempAct = Schema.getGlobalDescribe().get(Utils.NAMESPACE + 'ActivityExtended__c').getDescribe().fields.getMap();
				for(String ss : tempAct.keySet())
				{
					Schema.DescribeFieldResult dfr = tempAct.get(ss).getDescribe();
					if(dfr.isAccessible())
					{
						String tempOName = (dfr.getName().startsWith(Utils.NAMESPACE)) ? dfr.getName().split(Utils.NAMESPACE.right(7))[1] : dfr.getName();
						pageData.listObjFieldOptions.add(new options('ActivityExtended__r.' + tempOName, 'ActivityExtended__r.' + dfr.getLabel()));
					}
				}
			}
		}

		return new Response(true, pageData, null);
	}

	@AuraEnabled
	public static Response addTabField(String selectedOF, String selectedTO, Boolean selectedTOFvisible,
			String obj,String selectedOFLabel )
	{
		System.debug('@@@ ' + selectedOF + ' - ' + selectedTO);
		try
		{
			if(selectedOF != null && String.isNotBlank(selectedOF) && selectedTO != null && String.isNotBlank(selectedTO))
			{

				PageData pageData = new PageData();
				if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('CREATE')
						&& Utils.cebCheckObjPermission('ListOfFields__c',gd).get('INSERT'))
				{
					ListOfFields__c newTabField = new ListOfFields__c();
					newTabField.Field__c = (selectedOF.startsWith(Utils.NAMESPACE)) ? selectedOF.replace(Utils.NAMESPACE, '') : selectedOF;
					newTabField.Object__c = (pageData.mapTabObj.get(selectedTO).startsWith(Utils.NAMESPACE)) ?
							pageData.mapTabObj.get(selectedTO).replace(Utils.NAMESPACE, '') :
							pageData.mapTabObj.get(selectedTO);
					newTabField.Show__c = selectedTOFvisible;
					newTabField.Field_Label__c = selectedOFLabel;
					String likeName = pageData.mapTabRecName.get(selectedTO) + '%';
					String splitName = pageData.mapTabRecName.get(selectedTO).substring(1);
					List<ListOfFields__c> existingLof =
					[
							SELECT Id, Name
							FROM
									ListOfFields__c
							WHERE Name LIKE :likeName
							WITH SECURITY_ENFORCED
							ORDER BY Name DESC
							LIMIT 1
					];

					String newName = '';
					if(existingLof != null && !existingLof.isEmpty())
					{
						List<String> tempSplitName = existingLof[0].Name.split(splitName);
						Integer tempInt = Integer.valueOf(tempSplitName[1]) + 1;
						newName = String.valueOf(tempInt);
						/*while(newName.length()<7){
							newName = '0'+newName;
						}*/
					}
					else
					{
						newName = '1';
					}

					if(pageData.mapTabRecName.get(selectedTO).equalsIgnoreCase('FSR0'))
					{
						while(newName.length() < 6)
						{
							newName = '0' + newName;
						}
					}
					else if(!pageData.mapTabRecName.get(selectedTO).equalsIgnoreCase('Whatever'))
					{
						while(newName.length() < 7)
						{
							newName = '0' + newName;
						}
					}

					newTabField.Name = pageData.mapTabRecName.get(selectedTO) + newName;
					insert newTabField;
				}
			}

			return CRABB_ListOfFieldsCS.onComponentLoad(obj);
		}
		catch(Exception e)
		{
			System.debug(' Exception' + e.getMessage() + '::' + e.getLineNumber());
			return new Response(false, null, e.getMessage());
		}

	}

	@AuraEnabled
	public static Response addRecord(String selectedObj, String selectedField, Boolean selectedVisible,
			String obj, String selectedFieldLabel)
	{
		System.debug('@@@ ' + selectedObj + ' - ' + selectedField);
		try
		{
			ListOfFields__c newLof = new ListOfFields__c();
			newLof.Show__c = selectedVisible;
			newLof.Field__c = selectedField.replaceFirst(Utils.NAMESPACE, '');

			Map<String, ListOfFields__c> mapLofs = ListOfFields__c.getAll();
			List<String> lofsName = new List<String>();

			if(obj.equalsIgnoreCase('CSVNEW'))
			{
				newLof.Object__c = 'CSV||' + selectedObj.replaceFirst(Utils.NAMESPACE, '');

				for(String str : mapLofs.keySet())
				{
					if(mapLofs.get(str).Name.startsWith('CSVNEW'))
					{
						lofsName.add(mapLofs.get(str).Name);
					}
				}

			}
			else if(obj.equalsIgnoreCase('PDF'))
			{

				newLof.Object__c = selectedObj.replaceFirst(Utils.NAMESPACE, '');

				for(String str : mapLofs.keySet())
				{
					if(mapLofs.get(str).Name.startsWith('Pdf'))
					{
						lofsName.add(mapLofs.get(str).Name);
					}
				}
				system.debug('PDF ->' +lofsName.size() );
				newLof.Field_Label__c = selectedFieldLabel;
			}

			lofsName.sort();
			List<String> tempSplit = new List<String>();
			String newName = '';

			if(obj.equalsIgnoreCase('CSVNEW'))
			{
				if(lofsName != null && !lofsName.isEmpty() && lofsName.size() > 0)
				{
					tempSplit = lofsName[lofsName.size() - 1].split('NEW');
					Integer newIntName = Integer.valueOf(tempSplit[1]) + 1;
					String tempOrder = String.valueOf(newIntName);
					while(tempOrder.length() < 7)
					{
						tempOrder += '0';
					}
					tempOrder = tempOrder.reverse();
					newName = 'CSVNEW' + tempOrder;
				}
				else
				{
					newName = 'CSVNEW0000000';
				}
			}
			else if(obj.equalsIgnoreCase('PDF'))
			{
				if(lofsName != null && !lofsName.isEmpty() && lofsName.size() > 0)
				{
                    tempSplit = lofsName[lofsName.size()-1].split('_');
                    Integer newIntName = Integer.valueOf(tempSplit[1])+1;
                    String tempOrder = String.valueOf(newIntName);
					while(tempOrder.length() < 2)
					{
						tempOrder = '0' + tempOrder;
					}
					newName = 'Pdf_' + tempOrder;
				}
				else
				{
					newName = 'Pdf_01';
				}
			}

			newLof.Name = newName;

			if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('CREATE')
					&& Utils.cebCheckObjPermission('ListOfFields__c',gd).get('INSERT')) {
				insert newLof;
			}

			return CRABB_ListOfFieldsCS.onComponentLoad(obj);
		}
		catch(Exception e)
		{
			System.debug(' Exception' + e.getMessage() + '::' + e.getLineNumber());
			return new Response(false, null, e.getMessage());
		}
	}

	public static PageData retrieveTabFields(PageData pageData)
	{
		Map<String, String> mapTabObjLabel = new Map<String, String>
		{
				'Movimento__c' => 'Statement of Account',
				'Task' => 'Activities',
				'Piano_di_Rientro__c' => 'Repayment Plans' ,
				'Servizio__c'=>'Service/Product Detail' ,
				'Affidamento__c' =>'Assignments' ,
				'Attachment' => 'Documentation',
				 'SR__c' => 'Service Requests'
		};
        pageData.mapTabFields = new Map<String, List<ListOfFields__c>>();
		List<ListOfFields__c> tempFieldsList = new List<ListOfFields__c>();
		Map<String, ListOfFields__c> mapCS = ListOfFields__c.getAll();
		Map<String, List<ListOfFields__c>> tempMap = new Map<String, List<ListOfFields__c>>();

		for(String ss : pageData.mapTabRecName.keySet())
		{
			if(pageData.mapTabRecName.get(ss) != null && String.isNotBlank(pageData.mapTabRecName.get(ss)))
			{
				tempMap.put(pageData.mapTabRecName.get(ss), new List<ListOfFields__c>());
			}
		}

		for(String str : mapCS.keySet())
		{
			ListOfFields__c t = mapCS.get(str);
           // t.CRABB_DEV__Field_Label__c = Schema.getGlobalDescribe().get(Utils.NAMESPACE+t.CRABB_DEV__Object__c).getDescribe().fields.getmap().get(Utils.NAMESPACE+t.CRABB_DEV__Field__c).getDescribe().getLabel();
			system.debug(' object   ' + t.CRABB_DEV__Object__c + '  list '  + t.CRABB_DEV__Field__c );
            if (Schema.getGlobalDescribe().containskey(Utils.NAMESPACE+t.CRABB_DEV__Object__c)){
            	system.debug(' object   ' + t.CRABB_DEV__Object__c + '  list '  + t.CRABB_DEV__Field__c );
                if (Schema.getGlobalDescribe().get(Utils.NAMESPACE+t.CRABB_DEV__Object__c).getDescribe().fields.getmap().containskey(Utils.NAMESPACE+t.CRABB_DEV__Field__c)){
					t.CRABB_DEV__Field_Label__c = Schema.getGlobalDescribe().get(Utils.NAMESPACE+t.CRABB_DEV__Object__c).getDescribe().fields.getmap().get(Utils.NAMESPACE+t.CRABB_DEV__Field__c).getDescribe().getLabel();
                    
                }
            }
            if (Schema.getGlobalDescribe().containskey(t.CRABB_DEV__Object__c)){
            	system.debug(' object   ' + t.CRABB_DEV__Object__c + '  list '  + t.CRABB_DEV__Field__c );
                if (Schema.getGlobalDescribe().get(t.CRABB_DEV__Object__c).getDescribe().fields.getmap().containskey(t.CRABB_DEV__Field__c)){
					t.CRABB_DEV__Field_Label__c = Schema.getGlobalDescribe().get(t.CRABB_DEV__Object__c).getDescribe().fields.getmap().get(t.CRABB_DEV__Field__c).getDescribe().getLabel();
                    
                }
            }    
            if (mapTabObjLabel.containskey(t.CRABB_DEV__Object__c))
            	t.CRABB_DEV__Object__c = mapTabObjLabel.get(t.CRABB_DEV__Object__c);
            if(tempMap.containsKey(t.Name.substring(0, 4)))
			{
				List<ListOfFields__c> tList = tempMap.get(t.Name.substring(0, 4));
				tList.add(t);
				tempMap.remove(t.Name.substring(0, 4));
				tempMap.put(t.Name.substring(0, 4), tList);
			}
			else if(t.Name.startsWith('Whatever') && tempMap.containsKey('Whatever'))
			{
				List<ListOfFields__c> tList = tempMap.get('Whatever');
				tList.add(t);
				tempMap.remove('Whatever');
				tempMap.put('Whatever', tList);
			}
		}

		for(String str : pageData.mapTabRecName.keySet())
		{
			if(pageData.mapTabRecName.get(str) != null && String.isNotBlank(pageData.mapTabRecName.get(str)))
			{
				pageData.mapTabFields.put(str, tempMap.get(pageData.mapTabRecName.get(str)));
			}
		}

		return pageData;
	}

	@AuraEnabled
	public static Response removeRecord(String id, String obj)
	{

		try
		{
			if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('DELETE')) {
				ListOfFields__c toRemove = new ListOfFields__c(Id = id);
				delete toRemove;
			}

			return CRABB_ListOfFieldsCS.onComponentLoad(obj);
		}
		catch(Exception e)
		{
			System.debug(' Exception' + e.getMessage() + '::' + e.getLineNumber());
			return new Response(false, null, e.getMessage());
		}
	}

	@AuraEnabled
	public static Response updateRecords(String pageDataStr)
	{

		try
		{
			PageData pageData = (PageData) JSON.deserialize(pageDataStr, PageData.class);
			System.debug(JSON.serializePretty(pageData));
			if(pageData.obj != null && String.isNotBlank(pageData.obj) && pageData.obj.equalsIgnoreCase('TAB'))
			{

				if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('UPDATE'))
				{

					update pageData.listLOF;
					List<ListOfFields__c> allList = new List<ListOfFields__c>();
					for(String str : pageData.mapTabFields.keySet())
					{
						allList.addAll(pageData.mapTabFields.get(str));
					}
					update allList;
				}

			}
			else
			{

				Set<Integer> tempSet = new Set<Integer>();
				Set<String> existingName = new Set<String>();
				Map<String, String> mapIdName = new Map<String, String>();

				if(pageData.listLOF != null && !pageData.listLOF.isEmpty())
				{
					for(ListOfFields__c l : pageData.listLOF)
					{
                        system.debug('l id-->' + l.id);
                        system.debug('l name-->' + l.name);
						mapIdName.put(l.Id, l.Name);
						if(!tempSet.contains(pageData.mapIdrecordOrder.get(l.Id)))
						{
                            system.debug('map ID recordorder-->' + pageData.mapIdrecordOrder.get(l.Id));
							tempSet.add(pageData.mapIdrecordOrder.get(l.Id));
						}
						else
						{
							return new Response(false,null,'Duplicated Order : ' + pageData.mapIdrecordOrder.get(l.Id) + ' . Please review and correct.');
						}
					}
				}

				for(String str : pageData.mapIdrecordOrder.keySet())
				{
					String tempName = '';
					if(pageData.obj != null && pageData.obj.equalsIgnoreCase('PDF'))
					{
                        system.debug('pageData.mapIdrecordOrder.get(str)-->' + pageData.mapIdrecordOrder.get(str));
						String tempOrder = String.valueOf(pageData.mapIdrecordOrder.get(str));
						while(tempOrder.length() < 2)
						{
							tempOrder = '0' + tempOrder;
                            system.debug('temporder-->' + temporder);
						}
						tempName = 'Pdf_' + tempOrder;
                        system.debug('tempName-->' + tempName);
					}
					else if(pageData.obj != null && pageData.obj.equalsIgnoreCase('CSVNEW'))
					{
						//tempName = 'CSVNEW00000'+mapIdrecordOrder.get(str);
						String tempOrder = String.valueOf(pageData.mapIdrecordOrder.get(str));
						while(tempOrder.length() < 7)
						{
							tempOrder += '0';
						}
						tempOrder = tempOrder.reverse();
						tempName = 'CSVNEW' + tempOrder;
					}

					for(String st : mapIdName.keySet())
					{
                        system.debug('mapIdname st--> ' + st );
						if(mapIdName.get(st).equalsIgnoreCase(tempName))
						{
							existingName.add(st);
                            system.debug('added to existing name' );
						}
					}
				}

				for(ListOfFields__c l : pageData.listLOF)
				{

					if(existingName != null && !existingName.isEmpty() && existingName.contains(l.Id))
					{
						system.debug('if LOF exists in existin namme' );
						if(pageData.obj != null && pageData.obj.equalsIgnoreCase('PDF'))
						{

							l.Name = 'Pdf_' + System.now() + pageData.mapIdrecordOrder.get(l.Id);
                            system.debug('inside existing l.name->' + l.name );

						}
						else if(pageData.obj != null && pageData.obj.equalsIgnoreCase('CSVNEW'))
						{

							l.Name = 'CSV' + System.now() + pageData.mapIdrecordOrder.get(l.Id);

						}

					}
					else
					{

						if(pageData.obj != null && pageData.obj.equalsIgnoreCase('PDF'))
						{
                            system.debug('inside not existing l.name->' + l.name );

							if(Integer.valueOf(l.Name.substring(l.Name.lastIndexOf('_') + 1)) != pageData.mapIdrecordOrder.get(l.Id))
							{
								l.Name = l.Name.substring(0, l.Name.lastIndexOf('_') + 1) + pageData.mapIdrecordOrder.get(l.Id);
                                system.debug('inside not existing l.name->' + l.name );

							}
						}
						else if(pageData.obj != null && pageData.obj.equalsIgnoreCase('CSVNEW'))
						{
							if(Integer.valueOf(l.Name.substring(l.Name.length() - 6)) != pageData.mapIdrecordOrder.get(l.Id))
							{
								l.Name = l.Name.substring(0, l.Name.length() - 2) + pageData.mapIdrecordOrder.get(l.Id);
							}
						}
					}
				}

				if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('UPDATE'))
				{
					update pageData.listLOF;
				}

				if(existingName != null && !existingName.isEmpty())
				{

					List<ListOfFields__c> tempLOF = new List<ListOfFields__c>();
				
					for(ListOfFields__c ll : pageData.listLOF)
					{
                        system.debug('for each updated LOF');
						if(existingName.contains(ll.Id))
						{
                            system.debug('for each updated LOF exist in existing name');
							if(pageData.obj != null && pageData.obj.equalsIgnoreCase('PDF'))
							
                            {
								String tempOrder = String.valueOf(pageData.mapIdrecordOrder.get(ll.Id));
                                while(tempOrder.length() < 2)
                                {
                                    tempOrder = '0' + tempOrder;
                                    system.debug('temporder-->' + temporder);
                                }
                                                        
                                system.debug('for each updated LOF exist in existing name llname--' + ll.name);
								ll.Name = 'Pdf_' + tempOrder;

							}
							else if(pageData.obj != null && pageData.obj.equalsIgnoreCase('CSVNEW'))
							{

								String tempOrder = String.valueOf(pageData.mapIdrecordOrder.get(ll.Id));

								while(tempOrder.length() < 7)
								{
									tempOrder += '0';
								}

								tempOrder = tempOrder.reverse();

								ll.Name = 'CSVNEW' + tempOrder;

							}
							tempLOF.add(ll);
                            system.debug('added to temp lof');
						}
					}

					if(Utils.cebCheckObjPermission('ListOfFields__c',gd).get('CREATE')) {
						update tempLOF;
                        system.debug('updated temp lof');
					}

				}

			}

			return CRABB_ListOfFieldsCS.onComponentLoad(pageData.obj);
		}
		catch(Exception e)
		{
			System.debug(' Exception' + e.getMessage() + '::' + e.getLineNumber());
			return new Response(false, null, e.getMessage());
		}

	}

	public class options
	{
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;

		public options(String value, String label)
		{
			this.value = value;
			this.label = label;
		}

	}
}