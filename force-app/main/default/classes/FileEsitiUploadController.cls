/* ---------------------------------------------------------------------------------------------------------------------
Name:            FileEsitiUploadController.cls
Description:
Test class:      TestFileUploadController.cls

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
             0.1                                      First Version
08-Oct-2021  0.2      Claudio Sanna                   Modified for adding check permission:
                                                      cebCheckFLSPermission (Security Review)
13-Sep-2022  0.3      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED and cebCheckObjPermission (security review)
----------------------------------------------------------------------------------------------------------------------*/
global with sharing class FileEsitiUploadController {
    public static Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    @RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue) {
        /*
        parentId: The sfdc object Id this file will be attached to
        attachmentId: The record of the current Attachment file being processed
        fileName: Name of the attachment
        contentTye: Content Type of the file being attached
        base64BlobValue: Base64 encoded string of the file piece currently processing
        */

        //If recordId is blank this is the first part of a multi piece upload

        System.Debug('Siamo DENTRO !!!');
        if (attachmentId == '' || attachmentId == null) {
            Attachment att = new Attachment(
                    ParentId = parentId,
                    Body = EncodingUtil.Base64Decode(base64BlobValue),
                    Name = fileName,
                    ContentType = contentType
            );
            /*     if (Utils.checkFLSPermission('Attachment', 'Body').get('CREATE')
                     && Utils.checkFLSPermission('Attachment', 'Name').get('CREATE')
                     && Utils.checkFLSPermission('Attachment', 'ContentType').get('CREATE')) {*/
            if (Utils.cebCheckObjPermission('Attachment', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Attachment', 'ParentId', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Attachment', 'Name', gd).get('CREATE')
                    && Utils.cebCheckFLSPermission('Attachment', 'ContentType', gd).get('CREATE')) {
                insert att;
            }

            //Return the new attachment Id
            return att.Id;

        } else {
            if (Utils.cebCheckObjPermission('Attachment', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Attachment', 'Name', gd).get('UPDATE')
                    && Utils.cebCheckFLSPermission('Attachment', 'Body', gd).get('CREATE')) {
                //for (Attachment atm : [select Id, Body from Attachment where Id = :attachmentId WITH SECURITY_ENFORCED]) {
                for (Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]) {

                    //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                    update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
                }
            }

            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }

    public FileEsitiUploadController(UploadDataTosObject controller) {
    }
}