/* ---------------------------------------------------------------------------------------------------------------------
Name:            ChangeLogoCTRL.cls
Description:
Test class:      TestChangeLogo.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
12-Sep-2022  0.2      C.Sanna & R. Kurti              Added cebCheck Obj/FLS security and WITH SECURITY_ENFORCED (Security Review)
10-Oct-2022  0.3      C.Sanna & R.Kurti               Removed WITH SECURITY ENFORCED
----------------------------------------------------------------------------------------------------------------------*/

public with sharing class ChangeLogoCTRL {
	public Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
	public Blob newLogo 				{get; set;}
	public String filePath 				{get; set;}
	public Document currentLogo 		{get; set;}
	public String folderId 				{get; set;}
	public Boolean showCreate 			{get; set;}

	public ChangeLogoCTRL() {
		currentLogo = new Document();
		filePath = '';
		getLogo();
		showCreate = false;
		if(Utils.cebCheckObjPermission('Folder',gd).get('ACCESS')
		&& Utils.cebCheckFLSPermission('Folder','Name',gd).get('ACCESS')) {
			//List<Folder> fList = [SELECT Id FROM Folder WHERE Name = 'CRABB - Oggetti Grafici' WITH SECURITY_ENFORCED LIMIT 1];
			List<Folder> fList = [SELECT Id FROM Folder WHERE Name = 'CRABB - Oggetti Grafici' LIMIT 1];
			if (fList != null && !fList.isEmpty()) {
				folderId = fList[0].Id;
				showCreate = true;
			}
		}
	}

	public void getLogo(){
		if(Utils.cebCheckObjPermission('Document',gd).get('ACCESS')
				&& Utils.cebCheckFLSPermission('Document','Name',gd).get('ACCESS')) {
			//List<Document> docList = [SELECT Id FROM Document WHERE Name = 'CRABB - Oggetti Grafici' WITH SECURITY_ENFORCED LIMIT 1];
			List<Document> docList = [SELECT Id FROM Document WHERE Name = 'CRABB - Oggetti Grafici' LIMIT 1];
			filePath = '';
			currentLogo = null;
			if (docList != null && docList.size() > 0) {
				currentLogo = docList[0];
				filePath = '/servlet/servlet.FileDownload?file=' + docList[0].Id;
			}
		}
	}

	public PageReference updateLogo(){

		if(currentLogo != null){

			if(Utils.cebCheckObjPermission('Document', gd).get('ACCESS') && Utils.cebCheckObjPermission('Document',gd).get('UPDATE')
					&& Utils.cebCheckFLSPermission('Document', 'Body', gd).get('UPDATE')){
            	currentLogo.Body = newLogo;
            	update currentLogo;
            }

        }else{

        	if(Utils.cebCheckObjPermission('Document', gd).get('CREATE') && Utils.cebCheckObjPermission('Document',gd).get('INSERT')
					&& Utils.cebCheckFLSPermission('Document', 'Body', gd).get('UPDATE')
					&& Utils.cebCheckFLSPermission('Document', 'FolderId', gd).get('UPDATE')){
            	Document d = new Document();
            	d.Body = newLogo;
            	d.Name = 'ECLogo';
            	d.FolderId = folderId;
            	insert d;
            }
        }

		PageReference page = new PageReference('/apex/ChangeLogoPage');
		page.setRedirect(true);
		return page;
	}
}