/**
 * Created by User on 01/07/2021.
 */
import invokeApexMethodWithCache from '@salesforce/apex/WebComponentApi.invokeApexMethodWithCache';
import invokeApexMethodWithNoCache from '@salesforce/apex/WebComponentApi.invokeApexMethodWithNoCache';

class CrabbWebComponentApi {
    /*invokeApexMethodWithNoCache( params , successCallback , failureCallback){
        invokeApexMethodWithNoCache(oarams).then((result) => successCallback);
    }*/

    invokeApexMethodWithNoCache( params , apexClass){
        return new Promise((resolve, reject) => {

            invokeApexMethodWithNoCache(params , apexClass)
            .then((result) => resolve(result))
            .catch((error) => reject(error));

        });
    }
}

export { CrabbWebComponentApi }