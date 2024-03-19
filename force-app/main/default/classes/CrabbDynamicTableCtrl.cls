/* ---------------------------------------------------------------------------------------------------------------------
Name:            CrabbDynamicTableCtrlc.cls
Description:
Test class:

Date         Version  Author                          Summary of Changes
-----------  -------  ------------------------------  -----------------------------------------------------------------
04-Aug-2020  0.1      M.Sala                          First Version

13-Sep-2022  0.2      R.Kurti & C.Sanna               Added WITH SECURITY ENFORCED (security review)
----------------------------------------------------------------------------------------------------------------------*/

public class CrabbDynamicTableCtrl {


    @AuraEnabled(Cacheable=true)
    public static  CrabbDynamicTableWrapperOutput getTableData(String reportName){
        CrabbDynamicTableWrapperOutput out = new CrabbDynamicTableWrapperOutput();
        try {
            List <Report> reportList = [
                    SELECT Id,DeveloperName
                    FROM Report
                    where DeveloperName = :reportName
                    WITH SECURITY_ENFORCED
            ];
            if(reportList.size()==0){
                throw new CrabbDynamicTableCtrlException('No report found');
            }
            String reportId = (String)reportList.get(0).get('Id');
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            // Get the first down-grouping in the report
            Reports.Dimension dim = results.getGroupingsDown();
            if(dim.getGroupings().size()>0) {
                /*Reports.GroupingValue groupingVal = dim.getGroupings()[0];c
                System.debug('Key: ' + groupingVal.getKey());
                System.debug('Label: ' + groupingVal.getLabel());
                System.debug('Value: ' + groupingVal.getValue());

                String factMapKey = groupingVal.getKey() + '!T';

                Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap().get(factMapKey);

                Reports.SummaryValue sumVal = factDetails.getAggregates()[0];
                System.debug('Summary Value: ' + sumVal.getLabel());

                Reports.ReportDetailRow detailRow = factDetails.getRows()[0];
                System.debug(detailRow.getDataCells()[0].getLabel());*/
            }else{
                Reports.ReportMetadata rm = results.getReportMetadata();
                System.debug('reportmetadata' + JSON.serialize( rm ) );
                List<Map<String , Object>> columnData = new List<Map<String , Object>>();
                Reports.ReportExtendedMetadata rmd =   results.getReportExtendedMetadata();
                System.debug('ReportExtendedMetadata -> ' + JSON.serialize( rmd ) );
                /*for(String col :  rm.getDetailColumns()){
                    Map<String,Object> obj = new Map<String,Object>();
                    System.debug('Column -> '+col);
                    List<String> colApiNameData = col.split('[.]');

                    obj.put('fieldName',col);
                    obj.put('label',Schema.getGlobalDescribe().get(colApiNameData.get(0)).getDescribe().fields.getMap().get(colApiNameData.get(1)).getDescribe().getLabel());
                    columnData.add( obj );
                    if('Id'.equalsIgnoreCase( colApiNameData.get(1))){
                        out.tableKey = col;
                    }
                }*/
                Map<String,Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();

                for(String key : colMap.KeySet()){
                    System.debug('Key=' + Key + ' label=' + colMap.get(key).getLabel());
                    Map<String,Object> obj = new Map<String,Object>();
                    Reports.DetailColumn col = colMap.get(key);
                    List<String> colApiNameData = col.getName().split('[.]');

                    obj.put('fieldName',col.getName());
                    //obj.put('label',Schema.getGlobalDescribe().get(colApiNameData.get(0)).getDescribe().fields.getMap().get(colApiNameData.get(1)).getDescribe().getLabel());
                    obj.put('label', col.getLabel());
                    obj.put('sortable' , true);
                    columnData.add( obj );
                    /*if(colApiNameData.size()>1 && 'Id'.equalsIgnoreCase( colApiNameData.get(1))){
                        out.tableKey = col.getName();
                    }*/
                }
                out.tablekey = 'id';
                out.columns=columnData;
                Integer contRow = 0;
                List<Reports.ReportDetailRow > detailRows = ((Reports.ReportFactWithDetails)results.getFactMap().get('T!T')).getRows();
                List<Map<String , Object>> recordData = new List<Map<String , Object>>();
                for(Reports.ReportDetailRow detail : detailRows){
                    System.debug('detail '+detail.getDataCells());
                    Map<String , Object> record = new Map<String , Object>();
                    Integer contCol=0;
                    record.put( 'id' , String.valueOf( contRow ) );
                    for(Reports.ReportDataCell d : detail.getDataCells()){
                        record.put( rm.getDetailColumns().get(contCol) , d.getLabel());
                        System.debug('value : '+d.getValue());
                        System.debug('label : '+d.getLabel());
                        contCol++;
                    }
                    recordData.add(record);
                    contRow++;
                }
                out.data = recordData;
            }


        }catch(CrabbDynamicTableCtrlException ex){
            out.errors = ex.getMessage();
        }
        return out;
    }

    public class CrabbDynamicTableWrapperOutput{
        @AuraEnabled
        public List<Map<String , Object>> columns {get;set;}
        @AuraEnabled
        public List<Map<String , Object>> data {get;set;}
        @AuraEnabled
        public String tableKey {get;set;}
        @AuraEnabled
        public String errors {get;set;}
    }

    public class CrabbDynamicTableCtrlException extends Exception{}
}