/**
 * Created by MatteoSala on 16/07/2020.
 */

Global with sharing class CRABB_Schedule_BatchPDF implements Schedulable
{
    private Integer bSize = 30;

    global CRABB_Schedule_BatchPDF(Integer bSize)
    {
        this.bSize = bSize;
    }

    global void execute(SchedulableContext sc)
    {
        CRABB_Batch_PDF_Attachment b = new CRABB_Batch_PDF_Attachment();
        Database.executebatch(b,bSize);
    }
}