/**
 * Created by gmame on 21/04/2021.
 * Used for Mapping Tests and to be Deleted. Please, do not deploy
 */

global class AccountBatchTestToDelete implements Database.Batchable<SObject> {
    Integer scopeSize = 50;

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id FROM Account WHERE Name = \'Standard User Account 2\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        if (scope.size() > 0) {
            update scope;
        }

    }

    global void finish(Database.BatchableContext bc) {
    }
}